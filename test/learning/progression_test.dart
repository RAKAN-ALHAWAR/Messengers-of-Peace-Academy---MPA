import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'empty_home_test.dart' show functionOf, fixtureResponse, userFixture;

Map<String, Object> activityFixture(String module, {bool completed = false}) =>
    {
      NameX.topicId: 1,
      NameX.activityName: module,
      NameX.completionPercent: completed ? 100 : 0,
      NameX.isOpen: true,
      NameX.isCompleted: completed,
      NameX.videoUrl: 'https://synthetic.invalid/video',
      NameX.cmId: module,
    };
Map<String, Object> courseFixture(String id, {bool completed = false}) => {
  NameX.courseId: id,
  NameX.courseName: id,
  NameX.levelId: 'level-1',
  NameX.levelName: 'Level',
  NameX.completionPercent: completed ? 50 : 0,
  NameX.completedTopicsTotal: completed ? 1 : 0,
  NameX.activities: [
    activityFixture('module-A', completed: completed),
    activityFixture('module-B'),
  ],
};
Future<CourseDetailsController> mountCourse(WidgetTester tester) async {
  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: '/entry',
      getPages: [
        GetPage(name: '/entry', page: () => const Scaffold(body: SizedBox())),
        GetPage(
          name: '/course-test',
          page: () => const Scaffold(body: SizedBox()),
        ),
        GetPage(
          name: RouteNameX.videoPlayer,
          page: () => const Scaffold(body: Text('Synthetic player')),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
  Get.toNamed('/course-test', arguments: 'synthetic-course');
  await tester.pumpAndSettle();
  final controller = Get.put<CourseDetailsController>(CourseDetailsController());
  expect(controller.isClosed, isFalse, reason: 'Synthetic controller is alive');
  expect(Get.isRegistered<CourseDetailsController>(), isTrue);
  expect(identical(Get.find<CourseDetailsController>(), controller), isTrue);
  expect(identical(Get.find<AppControllerX>(), controller.app), isTrue);
  return controller;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-progression-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    Get.testMode = true;
    Get.locale = const Locale('en');
    await HiveX.removeAll();
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    Get.put(
      AppControllerX()..user = UserX.fromJson(userFixture('synthetic-A')).obs,
      permanent: true,
    );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    ToastX.dismiss();
    Get.delete<CourseDetailsController>(force: true);
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  for (final failure in ['completion', 'refresh']) {
    testWidgets(
      'explicit $failure failure retains incomplete state and allows another visit',
      (tester) async {
        var completions = 0;
        var loads = 0;
        await http.runWithClient(
          () async {
            final controller = await mountCourse(tester);
            await controller.getData();
            final pending = controller.onTapLessonVideo(0);
            await tester.pumpAndSettle();
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 5100)),
            );
            Get.back();
            await tester.pumpAndSettle();
            await pending;
            await tester.pump();
            expect(completions, 1);
            expect(loads, failure == 'refresh' ? 2 : 1);
            expect(
              controller.course.value!.activities.first.isCompleted,
              isFalse,
            );
            expect(find.byIcon(Icons.info_outline), findsOneWidget);
            expect(
              tester.takeException(),
              isNotNull,
              reason: 'Failure reaches the sanitized diagnostic boundary',
            );
            final retry = controller.onTapLessonVideo(0);
            await tester.pumpAndSettle();
            expect(Get.currentRoute, RouteNameX.videoPlayer);
            Get.back();
            await tester.pumpAndSettle();
            await retry;
            await tester.pump(const Duration(seconds: 5));
            // A short return still refetches (the page always shows the
            // server state), so the failing refresh reports again.
            if (failure == 'refresh') {
              expect(tester.takeException(), isNotNull);
            }
          },
          () => MockClient((request) async {
            if (request.url.queryParameters['wsfunction'] ==
                functionOf(DBEndPointX.postCompleteVideoOfCourse)) {
              completions++;
              return fixtureResponse({
                'status': failure == 'completion' ? 'error' : 'success',
                'message': 'Synthetic completion response',
              });
            }
            loads++;
            if (failure == 'refresh' && loads > 1) {
              return fixtureResponse({
                'status': 'error',
                'message': 'Synthetic refresh rejected',
              });
            }
            return fixtureResponse(courseFixture('synthetic-course'));
          }),
        );
      },
    );
  }

  testWidgets(
    'completion uses the activity opened before a list reorder and reloads server checkmarks',
    (tester) async {
      final completedModules = <String>[];
      var loads = 0;
      await http.runWithClient(
        () async {
          final controller = await mountCourse(tester);
          await controller.getData();
          final pending = controller.onTapLessonVideo(0);
          await tester.pumpAndSettle();
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 5100)),
          );
          final activities = controller.course.value!.activities;
          final first = activities.removeAt(0);
          activities.add(first);
          Get.back();
          await tester.pumpAndSettle();
          await pending;
          expect(completedModules, ['module-A']);
          expect(loads, 2);
          expect(controller.course.value!.activities.first.isCompleted, isTrue);
          expect(controller.course.value!.activities[1].isCompleted, isFalse);
          expect(controller.course.value!.completionPercent, 50);
        },
        () => MockClient((request) async {
          if (request.url.queryParameters['wsfunction'] ==
              functionOf(DBEndPointX.postCompleteVideoOfCourse)) {
            completedModules.add(request.bodyFields[NameX.cmId]!);
            return fixtureResponse({'status': 'success'});
          }
          loads++;
          return fixtureResponse(
            courseFixture('synthetic-course', completed: loads > 1),
          );
        }),
      );
    },
  );
}
