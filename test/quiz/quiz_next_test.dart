import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestResults/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestResults/view/view.dart';
import '../learning/lesson_counts_test.dart' show activityJson;
import 'quiz_flow_test.dart' show QuizHarness;

/// Course: topic 1 = video then quiz, topic 2 = video that opens once the quiz
/// is passed. The server answers from the harness state (finalize called).
Map<String, Object?> course(
  QuizHarness h, {
  bool lastIsQuiz = true,
  bool nextOpensAfterPass = true,
}) {
  final passed = h.finalizeCalls > 0;
  return {
    'courseid': 'synthetic-course',
    'coursename': 'Course',
    'levelid': 1,
    'levelname': 'Level',
    'completion_percent': passed ? 50 : 0,
    'completed_topics_total': passed ? 1 : 0,
    'activities': [
      activityJson(
        topicId: 1,
        cmId: 'V1',
        video: 'https://x.invalid/1',
        completed: true,
        percent: 100,
      ),
      activityJson(
        topicId: 1,
        cmId: 'Q',
        quizId: 'synthetic-quiz',
        completed: passed,
        percent: passed ? 100 : 0,
      ),
      if (lastIsQuiz)
        activityJson(
          topicId: 2,
          cmId: 'V2',
          video: 'https://x.invalid/2',
          open: passed && nextOpensAfterPass,
        ),
    ],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late QuizHarness h;
  var courseLoads = 0;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-quiz-next-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await HiveX.box.clear();
    await HiveX.box.put('userid', 'synthetic-user');
    await HiveX.box.put('token', 'synthetic-token');
    Get.put(
      AppControllerX()
        ..user = UserX(
          id: 'synthetic-user',
          username: 'synthetic',
          firstname: 'Test',
          lastname: 'User',
          email: 'test@example.invalid',
          lang: 'en',
          customfields: [],
          city: '',
          image: '',
          points: 0,
        ).obs,
    );
    h = QuizHarness();
    courseLoads = 0;
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  /// Quiz endpoints come from the harness, the course from [course]
  http.Client Function() client({bool nextOpens = true}) {
    final quiz = h.client();
    final mock = MockClient((request) async {
      if (request.url.queryParameters['wsfunction'] ==
          Uri.parse(DBEndPointX.postGetCourse).queryParameters['wsfunction']) {
        courseLoads++;
        return http.Response.bytes(
          utf8.encode(jsonEncode(course(h, nextOpensAfterPass: nextOpens))),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      final copy = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = request.bodyBytes;
      return http.Response.fromStream(await quiz.send(copy));
    });
    return () => mock;
  }

  /// Course details is below the results; the next stops are stubs
  Future<void> mountResults(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        initialRoute: RouteNameX.root,
        getPages: [
          GetPage(
            name: RouteNameX.root,
            page: () => const Scaffold(body: Text('Synthetic root')),
          ),
          GetPage(
            name: RouteNameX.testResults,
            page: () => const TestResultsView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => TestResultsController());
            }),
          ),
          GetPage(
            name: RouteNameX.courseDetails,
            page: () => const CourseDetailsView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => CourseDetailsController());
            }),
          ),
          GetPage(
            name: RouteNameX.videoPlayer,
            page: () => const Scaffold(body: Text('Synthetic player')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed(
      RouteNameX.testResults,
      arguments: [
        h.quiz,
        'synthetic-quiz',
        h.attempt,
        <int?>[null, 1],
        10,
        'synthetic-course',
      ],
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> afterTap(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'passing a quiz lands on a freshly fetched course with the checkmark',
    (tester) async {
      await http.runWithClient(() async {
        await mountResults(tester);
        await afterTap(tester);
        final results = Get.find<TestResultsController>();
        expect(results.isSuccess, isTrue);
        results.onTapButton();
        await afterTap(tester);
        // The old course page is gone, the next lesson (a video) opened.
        expect(courseLoads, greaterThanOrEqualTo(1));
        expect(Get.currentRoute, startsWith(RouteNameX.videoPlayer));
        expect(Get.arguments, 'https://x.invalid/2');
        Get.back();
        await afterTap(tester);
        expect(Get.currentRoute, startsWith(RouteNameX.courseDetails));
        final details = Get.find<CourseDetailsController>();
        expect(details.course.value!.activities[1].isCompleted, isTrue);
        expect(details.lessonsDone, 1);
        expect(find.text('1/2'), findsOneWidget);
      }, client());
    },
  );

  testWidgets('a locked next lesson leaves the user on the course page', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await mountResults(tester);
      await afterTap(tester);
      Get.find<TestResultsController>().onTapButton();
      await afterTap(tester);
      expect(Get.currentRoute, startsWith(RouteNameX.courseDetails));
      expect(find.text('1/2'), findsOneWidget);
    }, client(nextOpens: false));
  });
}
