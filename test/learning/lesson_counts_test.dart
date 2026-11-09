import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Service/course_progress.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/course/course.dart';
import 'package:messengersofpeace/Data/Model/course/mini_course.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/view/view.dart';
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

  testWidgets('catalog and details keep 11 lessons as progress advances', (
    tester,
  ) async {
    Get.put(AllCoursesController());
    var done = 2;
    var detailsRequests = 0;
    Map<String, Object?> details() => {
      'courseid': 130,
      'coursename': 'Course 130',
      'levelid': 1,
      'levelname': 'Level',
      'completion_percent': 21,
      'completed_topics_total': done,
      'activities': [
        for (var topic = 1; topic <= 11; topic++) ...[
          activityJson(
            topicId: topic,
            cmId: 'v$topic',
            video: topic <= 3 ? 'https://x.invalid/lesson' : '',
            completed: topic <= done || topic == 3,
            open: topic <= 3,
          ),
          activityJson(
            topicId: topic,
            cmId: 'q$topic',
            quizId: topic,
            completed: topic <= done,
            open: topic <= 3,
          ),
        ],
        activityJson(topicId: 12, cmId: 'final', quizId: 99),
        activityJson(topicId: 13, cmId: 'file', file: 'https://x.invalid/f'),
      ],
    };

    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          GetMaterialApp(
            locale: const Locale('ar'),
            translations: TranslationX(),
            initialRoute: '/entry',
            getPages: [
              GetPage(
                name: '/entry',
                page: () => const Scaffold(body: AllCoursesView()),
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
        expect(find.text('2/11'), findsOneWidget);
        expect(find.text('18%'), findsOneWidget);
        expect(find.text('11 درس'), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('2/11')).textDirection,
          TextDirection.ltr,
        );
        expect(detailsRequests, 1);

        await tester.tap(find.text('Course 130'));
        await tester.pumpAndSettle();
        expect(find.text('2/11'), findsOneWidget);
        expect(find.text('18%'), findsOneWidget);
        expect(find.text('(11 درس)'), findsOneWidget);
        expect(find.text('activity final'), findsOneWidget);
        expect(find.text('activity file'), findsOneWidget);

        done = 3;
        await Get.find<CourseDetailsController>().getData();
        await tester.pumpAndSettle();
        expect(find.text('3/11'), findsOneWidget);
        expect(find.text('27%'), findsOneWidget);
        Get.back();
        await tester.pumpAndSettle();
        expect(find.text('3/11'), findsOneWidget);
        expect(find.text('27%'), findsOneWidget);
        expect(find.text('11 درس'), findsOneWidget);
        expect(detailsRequests, 3);
      },
      () => MockClient((request) async {
        final function = request.url.queryParameters['wsfunction'];
        if (function!.endsWith('get_course_details')) {
          detailsRequests++;
          return utf8Response(details());
        }
        return utf8Response([
          {
            'levelid': 1,
            'levelname': 'Level',
            'totalcourses': 1,
            'completedcourses': 0,
            'completion_percent': 0,
            'is_open': true,
            'is_completed': false,
            'courses': [
              {
                ...cardCourse(
                  numSections: done + 1,
                  completed: done,
                  percent: 66,
                ).toJson(),
                'courseid': 130,
                'coursename': 'Course 130',
              },
            ],
          },
        ]);
      }),
    );
  });

  test(
    'cards share the fetch and an older reply cannot undo detail progress',
    () async {
      final response = Completer<http.Response>();
      var requests = 0;
      await http.runWithClient(
        () async {
          final firstCard = CourseProgressStoreX.load('19');
          final secondCard = CourseProgressStoreX.load('19');
          await Future<void>.delayed(Duration.zero);
          expect(requests, 1);
          CourseProgressStoreX.record(
            courseOf([
              activityJson(
                topicId: 1,
                cmId: 'v',
                video: 'video',
                completed: true,
              ),
            ]),
          );
          response.complete(
            utf8Response(
              courseOf([
                activityJson(topicId: 1, cmId: 'v', video: 'video'),
              ]).toJson(),
            ),
          );
          expect((await firstCard)?.done, 1);
          expect((await secondCard)?.done, 1);
          expect((await CourseProgressStoreX.load('19'))?.done, 1);
          expect(requests, 1);
        },
        () => MockClient((_) {
          requests++;
          return response.future;
        }),
      );
    },
  );

  test('a late response cannot enter a newer account cache', () async {
    final response = Completer<http.Response>();
    final unfinished = courseOf([
      activityJson(topicId: 1, cmId: 'v', video: 'video'),
    ]);
    await http.runWithClient(
      () async {
        final oldAccount = CourseProgressStoreX.load('19');
        await Future<void>.delayed(Duration.zero);
        await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
        await LocalDataX.put(LocalKeyX.token, 'token-B');
        expect((await CourseProgressStoreX.load('19'))?.done, 0);
        response.complete(
          utf8Response(
            courseOf([
              activityJson(
                topicId: 1,
                cmId: 'v',
                video: 'video',
                completed: true,
              ),
            ]).toJson(),
          ),
        );
        expect(await oldAccount, isNull);
        expect((await CourseProgressStoreX.load('19'))?.done, 0);
      },
      () => MockClient((request) async {
        if (request.url.queryParameters['wstoken'] == 'token-B') {
          return utf8Response(unfinished.toJson());
        }
        return response.future;
      }),
    );
  });

  group('lesson topics and assessment-only courses', () {
    testWidgets('quiz-only entry exam shows test progress and has no lessons', (
      tester,
    ) async {
      final controller = await mountCourse(tester);
      controller.course.value = courseOf([
        activityJson(topicId: 89, cmId: '99', quizId: 2),
      ]);
      expect(controller.lessonsTotal, 0);
      expect(controller.lessonsDone, 0);
      expect(controller.progress.isAssessment, isTrue);
      expect(controller.progress.total, 1);
      expect(controller.progress.done, 0);
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
      expect(controller.lessonsDone, 0);
      expect(controller.lessonsTotal, 0);
      expect(controller.progress.done, 1);
      expect(controller.progress.total, 1);
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
        activityJson(topicId: 4, cmId: ''),
      ]);
      expect(
        controller.lessonsTotal,
        2,
        reason: 'only the two lesson topics count',
      );
      expect(controller.getActivityCountName, 'Two Lessons');
    });

    testWidgets(
      'course 130 shape: 11 video+quiz topics and standalone resources',
      (tester) async {
        final controller = await mountCourse(tester);
        controller.course.value = courseOf([
          for (var t = 1; t <= 11; t++) ...[
            activityJson(
              topicId: t,
              cmId: 'v$t',
              video: 'https://x.invalid/$t',
            ),
            activityJson(topicId: t, cmId: 'q$t', quizId: t),
          ],
          activityJson(topicId: 12, cmId: 'f', file: 'https://x.invalid/f'),
          activityJson(topicId: 13, cmId: 'final', quizId: 99, completed: true),
        ]);
        expect(controller.lessonsTotal, 11);
        expect(controller.lessonsDone, 0);
      },
    );

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
          expect(find.text('Test progress'), findsOneWidget);
          expect(find.text('(One Lesson)'), findsNothing);
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

  testWidgets('unavailable details do not show the misleading summary', (
    tester,
  ) async {
    final course = cardCourse(numSections: 3, completed: 2, percent: 66);
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
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
        await tester.pumpAndSettle();
        expect(find.text(course.name), findsOneWidget);
        expect(find.text('2/3'), findsNothing);
        expect(find.text('66%'), findsNothing);
      },
      () => MockClient((_) async => utf8Response({'errorcode': 'unavailable'})),
    );
  });
}
