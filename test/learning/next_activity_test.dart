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
import 'package:messengersofpeace/Data/Model/course/activity.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart' show ToastX;
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/controller/controller.dart';
import 'empty_home_test.dart' show functionOf, userFixture;
import 'lesson_counts_test.dart' show activityJson, utf8Response;

const videoA = 'https://x.invalid/A';
const videoB = 'https://x.invalid/B';

ActivityX activity(
  String cmId, {
  int topicId = 1,
  String video = '',
  String file = '',
  Object? quizId,
  bool open = true,
}) => ActivityX.fromJson(
  activityJson(
    topicId: topicId,
    cmId: cmId,
    video: video,
    file: file,
    quizId: quizId,
    open: open,
  ),
);

/// Course payload: A (video) then B (video), B unlocks once A is completed
Map<String, Object?> courseJson({
  required bool aDone,
  List<Map<String, Object?>>? tail,
}) => {
  'courseid': 19,
  'coursename': 'Course',
  'levelid': 1,
  'levelname': 'Level',
  'completion_percent': aDone ? 50 : 0,
  'completed_topics_total': aDone ? 1 : 0,
  'activities': [
    activityJson(topicId: 1, cmId: 'A', video: videoA, completed: aDone),
    ...(tail ??
        [activityJson(topicId: 1, cmId: 'B', video: videoB, open: aDone)]),
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-next-');
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
    Get.delete<CourseDetailsController>(force: true);
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  /// The selection rule, as a plain function
  group('nextActivityAfter', () {
    String? next(List<ActivityX> list, String cmId) =>
        CourseDetailsController.nextActivityAfter(list, cmId)?.cmId;

    test('next video', () {
      final list = [activity('a', video: videoA), activity('b', video: videoB)];
      expect(next(list, 'a'), 'b');
    });

    test('next quiz', () {
      final list = [activity('a', video: videoA), activity('q', quizId: 4)];
      expect(next(list, 'a'), 'q');
    });

    test('next file', () {
      final list = [
        activity('q', quizId: 4),
        activity('f', file: 'https://x.invalid/f'),
      ];
      expect(next(list, 'q'), 'f');
    });

    test('locked next gives null', () {
      final list = [
        activity('a', video: videoA),
        activity('b', video: videoB, open: false),
      ];
      expect(next(list, 'a'), isNull);
    });

    test('last activity gives null', () {
      final list = [activity('a', video: videoA), activity('b', video: videoB)];
      expect(next(list, 'b'), isNull);
    });

    test('unknown activity gives null', () {
      expect(next([activity('a', video: videoA)], 'zzz'), isNull);
    });

    test('mixed order across topics follows the course order', () {
      final list = [
        activity('v1', topicId: 1, video: videoA),
        activity('q1', topicId: 1, quizId: 1),
        activity('v2', topicId: 2, video: videoB),
        activity('q2', topicId: 2, quizId: 2),
        activity('f3', topicId: 3, file: 'https://x.invalid/f'),
      ];
      expect(next(list, 'v1'), 'q1');
      expect(next(list, 'q1'), 'v2');
      expect(next(list, 'v2'), 'q2');
      expect(next(list, 'q2'), 'f3');
      expect(next(list, 'f3'), isNull);
    });

    test('an activity without content is skipped', () {
      final list = [
        activity('a', video: videoA),
        activity('empty', topicId: 2),
        activity('b', topicId: 2, video: videoB),
      ];
      expect(next(list, 'a'), 'b');
    });
  });

  /// Pages used by the flow tests; the player and the quiz info are stubs
  Future<CourseDetailsController> mount(
    WidgetTester tester, {
    Map<String, String>? parameters,
  }) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/entry',
        getPages: [
          GetPage(
            name: '/entry',
            page: () => const Scaffold(body: SizedBox()),
          ),
          GetPage(
            name: '/course-test',
            page: () => const Scaffold(body: SizedBox()),
          ),
          GetPage(
            name: RouteNameX.videoPlayer,
            page: () => const Scaffold(body: Text('Synthetic player')),
          ),
          GetPage(
            name: RouteNameX.testInfo,
            page: () => const Scaffold(body: Text('Synthetic quiz info')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed('/course-test', arguments: '19', parameters: parameters);
    await tester.pumpAndSettle();
    final controller = Get.put<CourseDetailsController>(
      CourseDetailsController(),
    );
    // A Hive disk write never finishes under the fake test clock
    controller.addLearnedSeconds = (_) async {};
    return controller;
  }

  /// Watch the first video for longer than the five second rule
  Future<void> dwell(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5100)),
    );
  }

  /// Let the mocked requests answer, then settle navigation and rebuilds
  Future<void> answered(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
  }

  /// Serves the course (first load before, later loads after the completion)
  http.Client Function() server({
    required Map<String, Object?> Function(bool done) course,
    List<String>? completed,
    void Function()? onLoad,
    bool failReload = false,
  }) {
    var loads = 0;
    final client = MockClient((request) async {
      if (request.url.queryParameters['wsfunction'] ==
          functionOf(DBEndPointX.postCompleteVideoOfCourse)) {
        completed?.add(request.bodyFields[NameX.cmId]!);
        return utf8Response({'status': 'success'});
      }
      loads++;
      onLoad?.call();
      if (failReload && loads > 1) return http.Response('boom', 500);
      return utf8Response(course(loads > 1 && (completed?.isNotEmpty ?? true)));
    });
    return () => client;
  }

  group('video: checkmark and Next', () {
    testWidgets('Next after a completed video opens the unlocked next video', (
      tester,
    ) async {
      final completed = <String>[];
      var loads = 0;
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          await controller.getData();
          expect(controller.course.value!.activities[1].isOpen, isFalse);
          final pending = controller.onTapLessonVideo(0);
          await dwell(tester);
          Get.back(result: 'next');
          await answered(tester);
          expect(completed, ['A']);
          expect(loads, 2, reason: 'refetched before opening the next lesson');
          expect(controller.course.value!.activities[0].isCompleted, isTrue);
          expect(Get.currentRoute, RouteNameX.videoPlayer);
          expect(Get.arguments, videoB);
          Get.back();
          await answered(tester);
          await pending;
        },
        server(
          course: (done) => courseJson(aDone: done),
          completed: completed,
          onLoad: () => loads++,
        ),
      );
    });

    testWidgets('Next on a locked next lesson stays on the course page', (
      tester,
    ) async {
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          await controller.getData();
          final pending = controller.onTapLessonVideo(0);
          await dwell(tester);
          Get.back(result: 'next');
          await answered(tester);
          await pending;
          expect(Get.currentRoute, '/course-test');
        },
        server(
          course: (done) => courseJson(
            aDone: done,
            tail: [
              activityJson(topicId: 1, cmId: 'B', video: videoB, open: false),
            ],
          ),
        ),
      );
    });

    testWidgets('Next on the last activity stays on the course page', (
      tester,
    ) async {
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          await controller.getData();
          final pending = controller.onTapLessonVideo(0);
          await dwell(tester);
          Get.back(result: 'next');
          await answered(tester);
          await pending;
          expect(Get.currentRoute, '/course-test');
          expect(controller.course.value!.activities.first.isCompleted, isTrue);
        },
        server(
          course: (done) => courseJson(aDone: done, tail: []),
        ),
      );
    });

    testWidgets('Next opens a quiz as its test info', (tester) async {
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          await controller.getData();
          final pending = controller.onTapLessonVideo(0);
          await dwell(tester);
          Get.back(result: 'next');
          await answered(tester);
          expect(Get.currentRoute, RouteNameX.testInfo);
          expect(Get.arguments, ['7', '19']);
          Get.back();
          await answered(tester);
          await pending;
        },
        server(
          course: (done) => courseJson(
            aDone: done,
            tail: [activityJson(topicId: 1, cmId: 'Q', quizId: 7)],
          ),
        ),
      );
    });

    testWidgets('a failed refetch does not open anything', (tester) async {
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        final pending = controller.onTapLessonVideo(0);
        await dwell(tester);
        Get.back(result: 'next');
        await answered(tester);
        await pending;
        expect(Get.currentRoute, '/course-test');
        expect(controller.course.value!.activities.first.isCompleted, isFalse);
      }, server(course: (done) => courseJson(aDone: done), failReload: true));
      expect(tester.takeException(), isNotNull, reason: 'reported, not thrown');
      ToastX.dismiss();
    });

    testWidgets('a short visit still refetches but records nothing', (
      tester,
    ) async {
      final completed = <String>[];
      var loads = 0;
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          await controller.getData();
          final pending = controller.onTapLessonVideo(0);
          await tester.pumpAndSettle();
          Get.back();
          await answered(tester);
          await pending;
          expect(completed, isEmpty);
          expect(loads, 2);
          expect(Get.currentRoute, '/course-test');
        },
        server(
          course: (done) => courseJson(aDone: done),
          completed: completed,
          onLoad: () => loads++,
        ),
      );
    });
  });

  group('quiz: return and results', () {
    testWidgets('coming back from the quiz info refetches the course', (
      tester,
    ) async {
      var loads = 0;
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          await controller.getData();
          final quiz = controller.course.value!.activities[1];
          final pending = controller.onTapLessonQuiz(quiz);
          await tester.pumpAndSettle();
          expect(Get.currentRoute, RouteNameX.testInfo);
          Get.back();
          await answered(tester);
          await pending;
          expect(loads, 2);
        },
        server(
          course: (done) => courseJson(
            aDone: false,
            tail: [activityJson(topicId: 1, cmId: 'Q', quizId: 7)],
          ),
          onLoad: () => loads++,
        ),
      );
    });

    testWidgets(
      'arriving from a passed quiz opens the next activity after it, once',
      (tester) async {
        await http.runWithClient(
          () async {
            final controller = await mount(
              tester,
              parameters: {CourseDetailsController.nextAfterQuizParam: '7'},
            );
            await controller.getData();
            await tester.pumpAndSettle();
            expect(Get.currentRoute, RouteNameX.videoPlayer);
            expect(Get.arguments, videoB);
            Get.back();
            await tester.pumpAndSettle();
            await controller.getData();
            await tester.pumpAndSettle();
            expect(Get.currentRoute, isNot(RouteNameX.videoPlayer));
          },
          server(
            course: (done) => courseJson(
              aDone: false,
              tail: [
                activityJson(topicId: 1, cmId: 'Q', quizId: 7, completed: true),
                activityJson(topicId: 2, cmId: 'B', video: videoB),
              ],
            ),
          ),
        );
      },
    );
  });
}
