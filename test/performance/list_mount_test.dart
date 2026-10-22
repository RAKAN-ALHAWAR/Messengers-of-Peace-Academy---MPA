import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/blog.dart';
import 'package:messengersofpeace/Data/Model/leaderboard.dart';
import 'package:messengersofpeace/Ui/Screen/Blog/Blog/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Blog/Blog/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Leaderboard/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Leaderboard/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

class _Blogs extends BlogController {
  _Blogs(this.count);
  final int count;
  @override
  Future<List<BlogX>> getData() async {
    blogs.assignAll(
      List.generate(
        count,
        (i) => BlogX(
          id: '$i',
          subject: 'Article $i',
          summary: '',
          imageUrl: '',
          lang: 'en',
        ),
      ),
    );
    return List.of(blogs);
  }
}

class _Ranks extends LeaderboardController {
  _Ranks(this.count);
  final int count;
  @override
  Future<List<LeaderboardX>> getData() async => List.generate(
    count,
    (i) => LeaderboardX(
      id: '$i',
      userImage: '',
      username: 'Learner $i',
      points: 0,
      rank: i + 1,
    ),
  );
}

void main() {
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-list-mount');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  for (final count in [0, 1, 20, 100, 1000]) {
    for (final blog in [true, false]) {
      testWidgets(
        '${blog ? 'Blog' : 'Leaderboard'} $count rows mount only viewport images',
        (tester) async {
          Get.testMode = true;
          tester.view.physicalSize = const Size(400, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          if (blog) {
            Get.put<BlogController>(_Blogs(count));
          } else {
            Get.put<LeaderboardController>(_Ranks(count));
          }
          await tester.pumpWidget(
            GetMaterialApp(
              locale: const Locale('en'),
              home: blog ? const BlogView() : const LeaderboardView(),
            ),
          );
          await tester.pumpAndSettle();
          final mounted = find.byType(ImageNetworkX).evaluate().length;
          expect(mounted, lessThanOrEqualTo(25));
          expect(mounted, count == 0 ? 0 : greaterThan(0));
          if (count >= 100) {
            expect(
              find.text('${blog ? 'Article' : 'Learner'} ${count - 1}'),
              findsNothing,
            );
            final scrollable = tester.state<ScrollableState>(
              find.byType(Scrollable).first,
            );
            scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
            await tester.pumpAndSettle();
            expect(
              find.text('${blog ? 'Article' : 'Learner'} ${count - 1}'),
              findsOneWidget,
            );
            expect(
              find.byType(ImageNetworkX).evaluate().length,
              lessThanOrEqualTo(25),
            );
          }
          await tester.pumpWidget(const SizedBox());
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'blog footer reacts to loading and error without replacing rows',
    (tester) async {
      Get.testMode = true;
      final controller = Get.put<BlogController>(_Blogs(1));
      await tester.pumpWidget(
        GetMaterialApp(locale: const Locale('en'), home: const BlogView()),
      );
      await tester.pumpAndSettle();
      controller.hasMore.value = true;
      await tester.pumpAndSettle();
      expect(find.text('Load more'), findsOneWidget);
      controller.isLoadingMore.value = true;
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      controller.isLoadingMore.value = false;
      controller.hasMore.value = false;
      await tester.pumpAndSettle();
      expect(find.text('Load more'), findsNothing);
      expect(find.text('Article 0'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
