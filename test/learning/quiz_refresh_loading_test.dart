// The course page shows its loading sign while a refetch after a lesson, a
// video or a passed quiz is pending, so stale progress never looks final.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Core/Error/error.dart' show ErrorX;
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/view/sections/loading.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart' show ToastX;
import 'atoms_s2_test.dart' show mount, named, quizTail;
import 'empty_home_test.dart' show userFixture;
import 'lesson_counts_test.dart' show utf8Response;

/// Serves the course: the first load at once, later loads as [held] says
class _Server {
  int loads = 0;
  final Map<int, Completer<http.Response>> held = {};

  /// Holds load number [load] until the returned completer is completed
  Completer<http.Response> hold(int load) =>
      held[load] = Completer<http.Response>();

  http.Client client() => MockClient((request) async {
    final load = ++loads;
    if (held.containsKey(load)) return held[load]!.future;
    return utf8Response(named('Course $load', tail: quizTail));
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-quiz-refresh-');
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

  group('after a passed quiz', () {
    testWidgets('the loading sign is on until the new course is shown', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        expect(controller.isRefreshing.value, isFalse);
        final slow = server.hold(2);
        final pending = controller.continueAfterPassedQuiz('7');
        await tester.pump();
        expect(server.loads, 2);
        expect(controller.isRefreshing.value, isTrue);
        expect(controller.course.value!.name, 'Course 1');
        slow.complete(utf8Response(named('Course 2', tail: quizTail)));
        await pending;
        expect(controller.isRefreshing.value, isFalse);
        expect(controller.course.value!.name, 'Course 2');
      }, server.client);
    });

    testWidgets('a failed refetch turns the sign off and keeps the course', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        final slow = server.hold(2);
        final pending = controller.continueAfterPassedQuiz('7');
        await tester.pump();
        expect(controller.isRefreshing.value, isTrue);
        slow.complete(http.Response('boom', 500));
        await pending;
        // The failure is reported once, then the old course stays
        expect(tester.takeException(), isA<ErrorX>());
        // The failure toast closes on its own timer
        await tester.pump(const Duration(seconds: 10));
        expect(controller.isRefreshing.value, isFalse);
        expect(controller.course.value!.name, 'Course 1');
      }, server.client);
    });

    testWidgets('a newer load retires the sign of the older refetch', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        final old = server.hold(2);
        final pending = controller.continueAfterPassedQuiz('7');
        await tester.pump();
        expect(controller.isRefreshing.value, isTrue);
        await controller.getData();
        expect(controller.isRefreshing.value, isFalse);
        old.complete(utf8Response(named('Old', tail: quizTail)));
        await pending;
        expect(controller.isRefreshing.value, isFalse);
        expect(controller.course.value!.name, 'Course 3');
      }, server.client);
    });

    testWidgets('only the newest of two refetches turns the sign off', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        final first = server.hold(2);
        final second = server.hold(3);
        final one = controller.continueAfterPassedQuiz('7');
        await tester.pump();
        final two = controller.continueAfterPassedQuiz('7');
        await tester.pump();
        expect(server.loads, 3);
        first.complete(utf8Response(named('Course 2', tail: quizTail)));
        await one;
        expect(controller.isRefreshing.value, isTrue);
        second.complete(utf8Response(named('Course 3', tail: quizTail)));
        await two;
        expect(controller.isRefreshing.value, isFalse);
      }, server.client);
    });
  });

  group('other callers of the refetch', () {
    testWidgets('back from the quiz page the sign is on while it loads', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        final pending = controller.onTapLessonQuiz(
          controller.course.value!.activities[1],
        );
        await tester.pumpAndSettle();
        expect(controller.isRefreshing.value, isFalse);
        final slow = server.hold(2);
        Get.back();
        await tester.pump();
        await tester.pump();
        expect(server.loads, 2);
        expect(controller.isRefreshing.value, isTrue);
        slow.complete(utf8Response(named('Course 2', tail: quizTail)));
        await pending;
        expect(controller.isRefreshing.value, isFalse);
        expect(controller.course.value!.name, 'Course 2');
      }, server.client);
    });

    testWidgets('back from a lesson video the sign is on while it loads', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        final pending = controller.onTapLessonVideo(0);
        await tester.pumpAndSettle();
        expect(controller.isRefreshing.value, isFalse);
        final slow = server.hold(2);
        Get.back();
        await tester.pump();
        await tester.pump();
        expect(server.loads, 2);
        expect(controller.isRefreshing.value, isTrue);
        slow.complete(utf8Response(named('Course 2', tail: quizTail)));
        await pending;
        expect(controller.isRefreshing.value, isFalse);
      }, server.client);
    });
  });

  group('the page', () {
    testWidgets(
      'shows the first-load skeleton over the course while it loads',
      (tester) async {
        final server = _Server();
        await http.runWithClient(() async {
          await tester.pumpWidget(
            GetMaterialApp(
              initialRoute: '/entry',
              getPages: [
                GetPage(
                  name: '/entry',
                  page: () => const Scaffold(body: SizedBox()),
                ),
                GetPage(
                  name: '/details',
                  page: () {
                    Get.put(
                      CourseDetailsController()
                        ..addLearnedSeconds = (_) async {},
                    );
                    return const CourseDetailsView();
                  },
                ),
              ],
            ),
          );
          await tester.pump();
          Get.toNamed('/details', arguments: '19');
          await tester.pump();
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)),
          );
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));
          final controller = Get.find<CourseDetailsController>();
          expect(controller.course.value!.name, 'Course 1');
          expect(find.byType(CourseDetailsLoading), findsNothing);
          expect(find.text('Course 1'), findsOneWidget);

          final slow = server.hold(2);
          final pending = controller.continueAfterPassedQuiz('7');
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(CourseDetailsLoading), findsOneWidget);

          slow.complete(utf8Response(named('Course 2', tail: quizTail)));
          await tester.runAsync(() => pending);
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));
          expect(find.byType(CourseDetailsLoading), findsNothing);
          expect(find.text('Course 2'), findsOneWidget);
        }, server.client);
      },
    );
  });
}
