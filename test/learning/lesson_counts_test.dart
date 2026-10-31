import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/course/course.dart';
import 'package:messengersofpeace/Data/Model/course/mini_course.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/course_card.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/view/view.dart';
import 'empty_home_test.dart' show userFixture;
import 'progression_test.dart' show mountCourse;

/// Real activity shape of get_course_details (captured from the live server).
Map<String, Object?> activityJson({
  required int topicId,
  required String cmId,
  String video = '',
  String file = '',
  Object? quizId,
  bool completed = false,
  num percent = 0,
  bool open = true,
}) => {
  'Topic name': '',
  'topicid': topicId,
  'Activity number': 1,
  'Activity name': 'activity $cmId',
  'cmid': cmId,
  'completion_percent': percent,
  'is_open': open,
  'is_completed': completed,
  'video_url': video,
  'video_duration': video.isEmpty ? '0:00' : '3:00',
  'download_url': file,
  'quizid': quizId,
};

CourseX courseOf(List<Map<String, Object?>> activities) => CourseX.fromJson({
  'courseid': 19,
  'coursename': 'اختبار القبول',
  'levelid': 1,
  'levelname': 'Level',
  'completion_percent': 0,
  'completed_topics_total': 0,
  'activities': activities,
});

/// The live payload holds Arabic names, so the body must be sent as UTF-8
http.Response utf8Response(Object value) => http.Response.bytes(
  utf8.encode(jsonEncode(value)),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

MiniCourseX cardCourse({
  required int numSections,
  required int completed,
  bool isCompleted = false,
  num percent = 0,
}) => MiniCourseX.fromJson({
  'courseid': 19,
  'coursename': 'اختبار القبول',
  'numsections': numSections,
  'completion_percent': percent,
  'is_open': true,
  'is_completed': isCompleted,
  'completed_topics_total': completed,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-counts-');
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

  /// Course details: a lesson is every activity that has content
  group('course details counts every activity with content', () {
    testWidgets('quiz-only entry exam counts as 1 lesson, 0 done', (
      tester,
    ) async {
      final controller = await mountCourse(tester);
      controller.course.value = courseOf([
        activityJson(topicId: 89, cmId: '99', quizId: 2),
      ]);
      expect(controller.lessonsTotal, 1);
      expect(controller.lessonsDone, 0);
      expect(controller.getActivityCountName, 'One Lesson');
    });

    testWidgets('a passed quiz makes it 1/1', (tester) async {
      final controller = await mountCourse(tester);
      controller.course.value = courseOf([
        activityJson(
          topicId: 89,
          cmId: '99',
          quizId: 2,
          completed: true,
          percent: 100,
        ),
      ]);
      expect(controller.lessonsDone, 1);
      expect(controller.lessonsTotal, 1);
    });

    testWidgets('a lesson is a topic: video + quiz in one topic is 1 lesson', (
      tester,
    ) async {
      final controller = await mountCourse(tester);
      controller.course.value = courseOf([
        activityJson(topicId: 1, cmId: 'v1', video: 'https://x.invalid/1'),
        activityJson(topicId: 1, cmId: 'q1', quizId: 1),
        activityJson(topicId: 2, cmId: 'v2', video: 'https://x.invalid/2'),
        activityJson(topicId: 2, cmId: 'q2', quizId: 5),
        activityJson(topicId: 3, cmId: 'f3', file: 'https://x.invalid/f'),
        activityJson(topicId: 4, cmId: 'empty'),
      ]);
      expect(
        controller.lessonsTotal,
        3,
        reason: 'two topics plus a file topic',
      );
      expect(controller.getActivityCountName, '3 Lessons');
    });

    testWidgets('course 130 shape: 11 video+quiz topics and a summary file', (
      tester,
    ) async {
      final controller = await mountCourse(tester);
      controller.course.value = courseOf([
        for (var t = 1; t <= 11; t++) ...[
          activityJson(topicId: t, cmId: 'v$t', video: 'https://x.invalid/$t'),
          activityJson(topicId: t, cmId: 'q$t', quizId: t),
        ],
        activityJson(topicId: 12, cmId: 'f', file: 'https://x.invalid/f'),
      ]);
      expect(controller.lessonsTotal, 12);
      expect(controller.lessonsDone, 0);
    });

    testWidgets('a topic is done only when all its content is done', (
      tester,
    ) async {
      final controller = await mountCourse(tester);
      controller.course.value = courseOf([
        // topic 1: video done and quiz at 100 percent, so the lesson is done
        activityJson(
          topicId: 1,
          cmId: 'a',
          video: 'https://x.invalid/1',
          completed: true,
        ),
        activityJson(topicId: 1, cmId: 'b', quizId: 1, percent: 100),
        // topic 2: video done but quiz at 50 percent, so not done
        activityJson(
          topicId: 2,
          cmId: 'c',
          video: 'https://x.invalid/2',
          completed: true,
        ),
        activityJson(topicId: 2, cmId: 'd', quizId: 2, percent: 50),
        // topic 3: nothing done
        activityJson(topicId: 3, cmId: 'e', video: 'https://x.invalid/3'),
      ]);
      expect(controller.lessonsDone, 1);
      expect(controller.lessonsTotal, 3);
    });

    testWidgets('no course loaded gives 0 and 0', (tester) async {
      final controller = await mountCourse(tester);
      expect(controller.lessonsTotal, 0);
      expect(controller.lessonsDone, 0);
    });

    testWidgets('page shows 0/1 for the entry exam, not 0/0', (tester) async {
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            GetMaterialApp(
              locale: const Locale('en'),
              initialRoute: '/entry',
              getPages: [
                GetPage(
                  name: '/entry',
                  page: () => const Scaffold(body: SizedBox()),
                ),
                GetPage(
                  name: RouteNameX.courseDetails,
                  page: () => const CourseDetailsView(),
                  binding: BindingsBuilder(() {
                    Get.lazyPut(() => CourseDetailsController());
                  }),
                ),
              ],
            ),
          );
          await tester.pumpAndSettle();
          Get.toNamed(RouteNameX.courseDetails, arguments: '19');
          await tester.pumpAndSettle();
          expect(find.text('0/1'), findsOneWidget);
          expect(find.text('(One Lesson)'), findsOneWidget);
          expect(find.text('(No Lesson)'), findsNothing);
        },
        () => MockClient(
          (request) async => utf8Response({
            'courseid': 19,
            'coursename': 'اختبار القبول',
            'levelid': 1,
            'levelname': 'Level',
            'completion_percent': 0,
            'completed_topics_total': 0,
            'activities': [activityJson(topicId: 89, cmId: '99', quizId: 2)],
          }),
        ),
      );
    });
  });

  /// Course card: completed first, then total, digits in an LTR isolate
  group('course card shows completed/total', () {
    Future<void> pumpCard(WidgetTester tester, MiniCourseX course) =>
        tester.pumpWidget(
          GetMaterialApp(
            locale: const Locale('ar'),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: CourseCard(course: course, onTap: (_) {}),
              ),
            ),
          ),
        );

    testWidgets('normal course: 3 done of 12', (tester) async {
      await pumpCard(tester, cardCourse(numSections: 12, completed: 3));
      expect(find.text('3/12'), findsOneWidget);
    });

    testWidgets('quiz-only course (numsections 0) shows 0/1', (tester) async {
      await pumpCard(tester, cardCourse(numSections: 0, completed: 0));
      expect(find.text('0/1'), findsOneWidget);
    });

    testWidgets('completed quiz-only course shows 1/1', (tester) async {
      await pumpCard(
        tester,
        cardCourse(numSections: 0, completed: 0, isCompleted: true),
      );
      expect(find.text('1/1'), findsOneWidget);
    });

    testWidgets('completed with percent 0 shows 100 percent and N/N', (
      tester,
    ) async {
      await pumpCard(
        tester,
        cardCourse(numSections: 5, completed: 0, isCompleted: true),
      );
      expect(find.text('5/5'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('0%'), findsNothing);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 1.0);
    });

    testWidgets('not completed keeps the server percent and counter', (
      tester,
    ) async {
      await pumpCard(
        tester,
        cardCourse(numSections: 5, completed: 2, percent: 40),
      );
      expect(find.text('2/5'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.4);
    });

    testWidgets('the counter is laid out left to right', (tester) async {
      await pumpCard(tester, cardCourse(numSections: 12, completed: 3));
      final text = tester.widget<Text>(find.text('3/12'));
      expect(text.textDirection, TextDirection.ltr);
    });
  });
}
