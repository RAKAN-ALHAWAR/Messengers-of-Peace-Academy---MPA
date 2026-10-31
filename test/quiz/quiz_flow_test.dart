import 'dart:async';
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
import 'package:messengersofpeace/Data/Model/quiz/question.dart';
import 'package:messengersofpeace/Data/Model/quiz/quiz.dart';
import 'package:messengersofpeace/Data/Model/quiz/quiz_start_attempt.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestInfo/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestInfo/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestQuestions/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestQuestions/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestResults/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestResults/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'result_integrity_test.dart'
    show resultJson, answerJson, capturedFailedResult;

class QuizHarness {
  final quiz = QuizX(
    name: 'Synthetic quiz',
    description: 'Synthetic description',
    timelimit: 3600,
    attemptsAllowed: 2,
    lastAttemptStatus: QuizAttemptStatusX.notAttempted,
    canStart: true,
    totalQuestions: 2,
    gradeTotal: 2,
    gradeToPass: 1,
  );
  late QuizStartAttemptX attempt;
  int startCalls = 0,
      answerCalls = 0,
      finalizeCalls = 0,
      resultCalls = 0,
      infoCalls = 0,
      startTimeCalls = 0;
  Map<String, String>? answerBody;
  Future<http.Response> Function()? onStart,
      onAnswer,
      onFinalize,
      onResult,
      onInfo;
  Map<String, dynamic> results = resultJson(
    answers: [answerJson(7, selected: 1, right: true), answerJson(2)],
  );
  QuizHarness() {
    attempt = QuizStartAttemptX(
      attemptId: 'synthetic-attempt',
      state: 'inprogress',
      status: 'success',
      totalQuestions: 2,
      questions: [
        QuestionX(
          slot: 2,
          id: 12,
          number: 1,
          text: 'Synthetic first question',
          answers: ['Same label', 'Same label'],
        ),
        QuestionX(
          slot: 7,
          id: 17,
          number: 2,
          text: 'Synthetic second question',
          answers: ['First', 'Second'],
        ),
      ],
      correctAnswers: 0,
      wrongAnswers: 0,
    );
  }
  String? function(String endpoint) =>
      Uri.parse(endpoint).queryParameters['wsfunction'];
  http.Response jsonResponse(Object? value) =>
      http.Response(jsonEncode(value), 200);
  MockClient client() => MockClient((request) async {
    // All requests are intercepted. Never print Request, URL, or credentials.
    final stage = request.url.queryParameters['wsfunction'];
    if (stage == function(DBEndPointX.postGetQuizStartAttempt)) {
      startCalls++;
      return onStart?.call() ?? jsonResponse(attempt.toJson());
    }
    if (stage == function(DBEndPointX.postGetQuizUserAttempts)) {
      startTimeCalls++;
      return jsonResponse({
        NameX.attempts: [
          {
            NameX.state: 'inprogress',
            NameX.timeStart: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          },
        ],
      });
    }
    if (stage == function(DBEndPointX.postQuizSubmitQuestionAnswer)) {
      answerCalls++;
      answerBody = Map.of(request.bodyFields);
      return onAnswer?.call() ??
          jsonResponse({'status': 'success', 'message': 'Answer saved'});
    }
    if (stage == function(DBEndPointX.postSubmitQuiz)) {
      finalizeCalls++;
      return onFinalize?.call() ??
          jsonResponse({'status': 'success', 'message': 'Submitted'});
    }
    if (stage == function(DBEndPointX.postGetQuizResult)) {
      resultCalls++;
      return onResult?.call() ?? jsonResponse(results);
    }
    if (stage == function(DBEndPointX.postGetQuizDetails)) {
      infoCalls++;
      return onInfo?.call() ?? jsonResponse(quiz.toJson());
    }
    throw StateError('Unexpected synthetic request stage');
  });
  Future<void> mount(
    WidgetTester tester,
    String screen, {
    QuizX? overrideQuiz,
  }) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        initialRoute: '/quiz-base',
        getPages: [
          GetPage(
            name: '/quiz-base',
            page: () => const Scaffold(body: Text('Synthetic base')),
          ),
          GetPage(
            name: RouteNameX.testQuestions,
            page: () => const TestQuestionsView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => TestQuestionsController());
            }),
          ),
          GetPage(
            name: RouteNameX.testResults,
            page: () => const TestResultsView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => TestResultsController());
            }),
          ),
          GetPage(
            name: RouteNameX.testInfo,
            page: () => const TestInfoView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => TestInfoController());
            }),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed(
      screen,
      arguments:
          screen == RouteNameX.testQuestions
              ? [overrideQuiz ?? quiz, 'synthetic-quiz', 'synthetic-course']
              : screen == RouteNameX.testResults
              ? [
                quiz,
                'synthetic-quiz',
                attempt,
                <int?>[null, 1],
                10,
                'synthetic-course',
              ]
              : ['synthetic-quiz', 'synthetic-course'],
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> finish(WidgetTester tester) async {
    if (Get.isRegistered<TestQuestionsController>()) {
      await Get.delete<TestQuestionsController>(force: true);
    }
    if (Get.isRegistered<TestResultsController>()) {
      await Get.delete<TestResultsController>(force: true);
    }
    if (Get.isRegistered<TestInfoController>()) {
      await Get.delete<TestInfoController>(force: true);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late QuizHarness h;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-quiz-test-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    await HiveX.box.clear();
    await HiveX.box.put('userid', 'synthetic-user');
    await HiveX.box.put('token', 'synthetic-token');
    Get.put(
      AppControllerX()
        ..user =
            UserX(
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
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  testWidgets('duplicate labels select and send the second zero-based option', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await h.mount(tester, RouteNameX.testQuestions);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('question_option_0_1')));
      await tester.pump();
      final c = Get.find<TestQuestionsController>();
      await c.onNextQuestion();
      await tester.pumpAndSettle();
      expect(h.answerBody?['answer[0][value]'], '1');
      expect(h.answerBody?[NameX.slot], '2');
      expect(c.selectedAnswers, [1, null]);
      expect(c.currentQuestionIndex, 1);
      await h.finish(tester);
    }, h.client);
  });
  testWidgets(
    'deadline waits for in-flight answer and transitions/finalizes once',
    (tester) async {
      final pending = Completer<http.Response>();
      h.onAnswer = () => pending.future;
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testQuestions);
        await tester.pumpAndSettle();
        final c = Get.find<TestQuestionsController>();
        c.onChangeAnswer(1);
        final save = c.onNextQuestion();
        await tester.pump();
        c.onChangeAnswer(0);
        c.submitQuiz();
        c.submitQuiz();
        await tester.pump();
        expect(h.finalizeCalls, 0);
        pending.complete(
          h.jsonResponse({'status': 'success', 'message': 'Saved'}),
        );
        await save;
        await tester.pumpAndSettle();
        expect(h.answerCalls, 1);
        expect(h.finalizeCalls, 1);
        expect(h.resultCalls, 1);
        expect(Get.find<TestResultsController>().selectedAnswers, [1, null]);
        c.submitQuiz();
        await tester.pump();
        expect(h.finalizeCalls, 1);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'answer rejection keeps selection and question without advancing',
    (tester) async {
      h.onAnswer =
          () async => h.jsonResponse({
            'status': 'error',
            'message': 'Synthetic rejection',
          });
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testQuestions);
        await tester.pumpAndSettle();
        final c = Get.find<TestQuestionsController>();
        c.onChangeAnswer(1);
        await c.onNextQuestion();
        expect(tester.takeException(), isNotNull);
        await tester.pump();
        expect(c.currentQuestionIndex, 0);
        expect(find.text('Synthetic rejection'), findsOneWidget);
        expect(c.selectedAnswer.value, 1);
        expect(c.selectedAnswers, [null, null]);
        expect(h.finalizeCalls, 0);
        expect(c.needsRecovery, isFalse);
        h.onAnswer = null;
        await c.onNextQuestion();
        await tester.pumpAndSettle();
        expect(h.answerCalls, 2);
        expect(c.currentQuestionIndex, 1);
        expect(c.selectedAnswers, [1, null]);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'known resumed attempt shows recovery and makes no guessed answer/start',
    (tester) async {
      final resumed = QuizX.fromJson(
        h.quiz.toJson()
          ..[NameX.lastAttemptStatus] = QuizAttemptStatusX.inProgress,
      );
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testQuestions, overrideQuiz: resumed);
        await tester.pumpAndSettle();
        expect(
          find.text(
            'Your existing test attempt needs recovery. Return to test information.',
          ),
          findsOneWidget,
        );
        expect(find.text('Return to test information'), findsOneWidget);
        expect(h.startCalls, 0);
        expect(h.answerCalls, 0);
        expect(h.finalizeCalls, 0);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'late start response after session ABA cannot populate or continue',
    (tester) async {
      final pending = Completer<http.Response>();
      h.onStart = () => pending.future;
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testQuestions);
        final c = Get.find<TestQuestionsController>();
        await tester.runAsync(
          () => LocalDataX.put(LocalKeyX.token, 'other-synthetic'),
        );
        await tester.runAsync(
          () => LocalDataX.put(LocalKeyX.token, 'synthetic-token'),
        );
        pending.complete(h.jsonResponse(h.attempt.toJson()));
        await tester.pumpAndSettle();
        expect(c.selectedAnswers, isEmpty);
        expect(h.startTimeCalls, 0);
        expect(h.finalizeCalls, 0);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets('concurrent result loads share a single finalization', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    h.onFinalize = () => pending.future;
    await http.runWithClient(() async {
      await h.mount(tester, RouteNameX.testResults);
      final c = Get.find<TestResultsController>();
      final a = c.getData();
      final b = c.getData();
      expect(h.finalizeCalls, 1);
      pending.complete(
        h.jsonResponse({'status': 'success', 'message': 'Submitted'}),
      );
      await Future.wait([a, b]);
      await tester.pumpAndSettle();
      expect(h.finalizeCalls, 1);
      expect(h.resultCalls, 1);
      expect(c.result, isNotNull);
      await h.finish(tester);
    }, h.client);
  });
  testWidgets(
    '2xx status:error rejects finalization and only explicit retry repeats it',
    (tester) async {
      h.onFinalize =
          () async => h.jsonResponse({
            'status': 'error',
            'message': 'Synthetic rejection',
          });
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testResults);
        expect(tester.takeException(), isNotNull);
        await tester.pumpAndSettle();
        final c = Get.find<TestResultsController>();
        expect(c.canRetrySubmission, isTrue);
        expect(h.resultCalls, 0);
        await c.getData();
        expect(h.finalizeCalls, 1);
        h.onFinalize = null;
        c.retryRejectedSubmission();
        await c.getData();
        expect(h.finalizeCalls, 2);
        expect(h.resultCalls, 1);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'ambiguous timeout shows recovery and never automatically finalizes again',
    (tester) async {
      h.onFinalize = () async => throw TimeoutException('Synthetic timeout');
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testResults);
        expect(tester.takeException(), isNotNull);
        await tester.pumpAndSettle();
        final c = Get.find<TestResultsController>();
        expect(c.needsSubmissionRecovery, isTrue);
        expect(
          find.text(
            'Submission status is unknown. Return to test information before trying again.',
          ),
          findsOneWidget,
        );
        expect(find.text('Try again'), findsNothing);
        c.retryRejectedSubmission();
        await c.getData();
        await c.getData();
        expect(h.finalizeCalls, 1);
        expect(h.resultCalls, 0);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'read failure after acknowledged finalization retries only the read',
    (tester) async {
      h.onResult =
          () async => h.jsonResponse({
            'status': 'error',
            'message': 'Synthetic read rejection',
          });
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testResults);
        expect(tester.takeException(), isNotNull);
        await tester.pumpAndSettle();
        final c = Get.find<TestResultsController>();
        h.onResult = null;
        await c.getData();
        expect(h.finalizeCalls, 1);
        expect(h.resultCalls, 2);
        expect(c.result, isNotNull);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets('late result response after account change is ignored', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    h.onResult = () => pending.future;
    await http.runWithClient(() async {
      await h.mount(tester, RouteNameX.testResults);
      final c = Get.find<TestResultsController>();
      await tester.runAsync(
        () => LocalDataX.put(LocalKeyX.token, 'other-synthetic'),
      );
      pending.complete(h.jsonResponse(h.results));
      await tester.pumpAndSettle();
      expect(c.result, isNull);
      expect(find.byKey(const ValueKey('result-question-2')), findsNothing);
      c.onTapButton();
      expect(Get.currentRoute, RouteNameX.testResults);
      await h.finish(tester);
    }, h.client);
  });
  testWidgets(
    'unknown pass wording has explicit recovery without failed/success conclusion',
    (tester) async {
      h.results[NameX.passed] = 'Pending review';
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testResults);
        await tester.pumpAndSettle();
        expect(find.text('Test result not confirmed yet'), findsOneWidget);
        expect(find.text('Go to next lesson'), findsNothing);
        expect(find.text('Retake the test'), findsNothing);
        expect(h.finalizeCalls, 1);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'a failed attempt (real server body) shows grade, counts and per-question marks',
    (tester) async {
      h.results = capturedFailedResult();
      h.attempt = QuizStartAttemptX(
        attemptId: 'synthetic-attempt',
        state: 'inprogress',
        status: 'success',
        totalQuestions: 2,
        questions: [
          QuestionX(
            slot: 1,
            id: 11,
            number: 1,
            text: 'First question',
            answers: ['A', 'B'],
          ),
          QuestionX(
            slot: 2,
            id: 12,
            number: 2,
            text: 'Second question',
            answers: ['C', 'D'],
          ),
        ],
        correctAnswers: 0,
        wrongAnswers: 0,
      );
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testResults);
        await tester.pumpAndSettle();
        final c = Get.find<TestResultsController>();
        expect(c.hasConfirmedOutcome, isTrue);
        expect(c.isSuccess, isFalse);
        expect(find.text('Test result not confirmed yet'), findsNothing);
        expect(find.text('Retake the test'), findsOneWidget);
        expect(find.text('Go to next lesson'), findsNothing);
        expect(c.correctAnswers, 1);
        expect(c.wrongAnswers, 1);
        Finder countOf(String label) => find.descendant(
          of: find.ancestor(
            of: find.text(label),
            matching: find.byType(ContainerX),
          ),
          matching: find.text('1'),
        );
        expect(countOf('Correct answers'), findsWidgets);
        expect(countOf('Wrong answers'), findsWidgets);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('result-question-1')),
            matching: find.text('Correct answer'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('result-question-2')),
            matching: find.text('Incorrect answer'),
          ),
          findsOneWidget,
        );
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'result widgets map reordered slots and preserve unanswered/duplicate labels',
    (tester) async {
      h.results = resultJson(
        answers: [answerJson(7, selected: 1, right: true), null, answerJson(2)],
      );
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testResults);
        await tester.pumpAndSettle();
        final first = find.byKey(const ValueKey('result-question-2'));
        expect(
          find.descendant(of: first, matching: find.text('Not answered')),
          findsOneWidget,
        );
        final choices = tester.widgetList<RadioButtonX<int>>(
          find.descendant(
            of: first,
            matching: find.byWidgetPredicate((w) => w is RadioButtonX<int>),
          ),
        );
        expect(choices.map((w) => w.groupValue), everyElement(isNull));
        final second = find.byKey(const ValueKey('result-question-7'));
        expect(
          find.descendant(of: second, matching: find.text('Correct answer')),
          findsOneWidget,
        );
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'zero max grade and absent answer entries render neutral values without crash',
    (tester) async {
      h.results = resultJson(answers: [null])..[NameX.maxgrade] = 0;
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testResults);
        await tester.pumpAndSettle();
        expect(find.text('Answer details unavailable'), findsNWidgets(2));
        expect(Get.find<TestResultsController>().scoreFraction, isNull);
        expect(Get.find<TestResultsController>().correctAnswers, isNull);
        expect(tester.takeException(), isNull);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'test information uses neutral zero denominator and guarded navigation',
    (tester) async {
      final quizJson = h.quiz.toJson()..[NameX.gradeTotal] = 0;
      h.onInfo = () async => h.jsonResponse(quizJson);
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testInfo);
        await tester.pumpAndSettle();
        final c = Get.find<TestInfoController>();
        expect(c.passRate, '--');
        expect(find.text('--'), findsOneWidget);
        await tester.runAsync(
          () => LocalDataX.put(LocalKeyX.token, 'other-synthetic'),
        );
        c.onStartTest();
        await tester.pump();
        expect(Get.currentRoute, RouteNameX.testInfo);
        expect(h.startCalls, 0);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'late answer after controller closes cannot advance or navigate',
    (tester) async {
      final pending = Completer<http.Response>();
      h.onAnswer = () => pending.future;
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testQuestions);
        await tester.pumpAndSettle();
        final c = Get.find<TestQuestionsController>();
        c.onChangeAnswer(1);
        final saving = c.onNextQuestion();
        await tester.pump();
        await Get.delete<TestQuestionsController>(force: true);
        pending.complete(
          h.jsonResponse({'status': 'success', 'message': 'Saved'}),
        );
        await saving;
        await tester.pump();
        expect(c.selectedAnswers, [null, null]);
        expect(c.currentQuestionIndex, 0);
        expect(h.finalizeCalls, 0);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'late finalization acknowledgement after close cannot fetch results',
    (tester) async {
      final pending = Completer<http.Response>();
      h.onFinalize = () => pending.future;
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testResults);
        final c = Get.find<TestResultsController>();
        final loading = c.getData();
        await Get.delete<TestResultsController>(force: true);
        pending.complete(
          h.jsonResponse({'status': 'success', 'message': 'Submitted'}),
        );
        await loading;
        await tester.pump();
        expect(c.result, isNull);
        expect(h.resultCalls, 0);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'known rejected finalization retries through its visible action',
    (tester) async {
      h.onFinalize =
          () async => h.jsonResponse({
            'status': 'error',
            'message': 'Synthetic rejection',
          });
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testResults);
        expect(tester.takeException(), isNotNull);
        await tester.pumpAndSettle();
        h.onFinalize = null;
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(h.finalizeCalls, 2);
        expect(h.resultCalls, 1);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets('locale change reloads result text without finalizing twice', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    h.onResult = () => pending.future;
    await http.runWithClient(() async {
      await h.mount(tester, RouteNameX.testResults);
      final c = Get.find<TestResultsController>();
      final loading = c.getData();
      unawaited(Get.updateLocale(const Locale('ar')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      h.onResult = null;
      pending.complete(
        h.jsonResponse(
          Map<String, dynamic>.of(h.results)..[NameX.message] = 'Old locale',
        ),
      );
      await loading;
      await tester.pumpAndSettle();
      expect(h.finalizeCalls, 1);
      expect(h.resultCalls, 2);
      expect(c.result?.message, 'Synthetic result');
      await h.finish(tester);
    }, h.client);
  });
  testWidgets('late information response after close cannot initialize', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    h.onInfo = () => pending.future;
    await http.runWithClient(() async {
      await h.mount(tester, RouteNameX.testInfo);
      final c = Get.find<TestInfoController>();
      await Get.delete<TestInfoController>(force: true);
      pending.complete(h.jsonResponse(h.quiz.toJson()));
      await tester.pumpAndSettle();
      expect(c.isInit.value, isFalse);
      expect(h.startCalls, 0);
      await h.finish(tester);
    }, h.client);
  });
  testWidgets('late information response cannot overwrite the newer locale', (
    tester,
  ) async {
    final old = Completer<http.Response>();
    h.onInfo = () => old.future;
    await http.runWithClient(() async {
      await h.mount(tester, RouteNameX.testInfo);
      final c = Get.find<TestInfoController>();
      h.onInfo =
          () async =>
              h.jsonResponse(h.quiz.toJson()..[NameX.quizName] = 'New locale');
      unawaited(Get.updateLocale(const Locale('ar')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      old.complete(
        h.jsonResponse(h.quiz.toJson()..[NameX.quizName] = 'Old locale'),
      );
      await tester.pumpAndSettle();
      expect(c.quiz.name, 'New locale');
      expect(h.infoCalls, 2);
      await h.finish(tester);
    }, h.client);
  });
  testWidgets(
    'ambiguous result slots and out-of-range selections stay unavailable',
    (tester) async {
      h.results = resultJson(
        answers: [
          answerJson(2, selected: 0, right: true),
          answerJson(2, selected: 1),
          answerJson(7, selected: 9, right: true),
        ],
      );
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testResults);
        await tester.pumpAndSettle();
        expect(find.text('Answer details unavailable'), findsNWidgets(2));
        expect(find.text('Correct answer'), findsNothing);
        expect(find.text('Incorrect answer'), findsNothing);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'empty question response exposes recovery without indexing or timer',
    (tester) async {
      final json = h.attempt.toJson()..[NameX.questions] = [];
      h.onStart = () async => h.jsonResponse(json);
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testQuestions);
        await tester.pumpAndSettle();
        expect(find.text('Return to test information'), findsOneWidget);
        expect(h.finalizeCalls, 0);
        expect(tester.takeException(), isNull);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'single question completes exactly once with its acknowledged index',
    (tester) async {
      h.attempt = QuizStartAttemptX(
        attemptId: h.attempt.attemptId,
        state: 'inprogress',
        status: 'success',
        totalQuestions: 1,
        questions: [h.attempt.questions.first],
        correctAnswers: 0,
        wrongAnswers: 0,
      );
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testQuestions);
        await tester.pumpAndSettle();
        final c = Get.find<TestQuestionsController>();
        c.onChangeAnswer(1);
        await c.onNextQuestion();
        await tester.pumpAndSettle();
        expect(h.finalizeCalls, 1);
        expect(Get.find<TestResultsController>().selectedAnswers, [1]);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets(
    'exhausted attempt policy remains enforced by the authoritative canStart flag',
    (tester) async {
      h.onInfo =
          () async => h.jsonResponse(
            h.quiz.toJson()
              ..[NameX.canStart] = false
              ..[NameX.lastAttemptStatus] = 'finished',
          );
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testInfo);
        await tester.pumpAndSettle();
        final c = Get.find<TestInfoController>();
        expect(c.canEnterTest, isFalse);
        c.onStartTest();
        await tester.pump();
        expect(Get.currentRoute, RouteNameX.testInfo);
        expect(h.startCalls, 0);
        await h.finish(tester);
      }, h.client);
    },
  );
  for (final finishRequested in [false, true]) {
    testWidgets(
      'real answer deadline locks uncertain delivery, finish=$finishRequested',
      (tester) async {
        final pending = Completer<http.Response>();
        h.onAnswer = () => pending.future;
        await http.runWithClient(() async {
          await h.mount(tester, RouteNameX.testQuestions);
          await tester.pumpAndSettle();
          final c = Get.find<TestQuestionsController>();
          c.onChangeAnswer(1);
          final saving = c.onNextQuestion();
          await tester.pump();
          if (finishRequested) c.submitQuiz();
          // Exercise HttpX's actual15s wrapper, not an exception from the mock.
          await tester.pump(const Duration(seconds: 16));
          await saving;
          expect(tester.takeException(), isNotNull);
          await tester.pumpAndSettle();
          final transportStillPending = !pending.isCompleted;
          final visibleRecovery =
              find
                  .text(
                    'Answer saving status is unknown. Return to test information before trying again.',
                  )
                  .evaluate()
                  .length;
          final visibleAction =
              find.text('Return to test information').evaluate().length;
          final recovery = c.needsRecovery;
          c.onChangeAnswer(0);
          final retry = c.onNextQuestion();
          c.submitQuiz();
          c.startTimer();
          await tester.pump();
          pending.complete(
            h.jsonResponse({
              'status': 'success',
              'message': 'Late acknowledgement',
            }),
          );
          await retry;
          await tester.pumpAndSettle();
          final calls = (h.answerCalls, h.finalizeCalls, h.resultCalls);
          final saved = List<int?>.of(c.selectedAnswers);
          await h.finish(tester);
          expect(transportStillPending, isTrue);
          expect(recovery, isTrue);
          expect(visibleRecovery, 1);
          expect(visibleAction, 1);
          expect(calls, (1, 0, 0));
          expect(saved, [null, null]);
        }, h.client);
      },
    );
  }
  for (final slot in [2.4, -1, true, 'invalid']) {
    testWidgets(
      'invalid inbound slot $slot exposes recovery without sending an altered slot',
      (tester) async {
        final json = h.attempt.toJson();
        (json[NameX.questions] as List).first[NameX.slot] = slot;
        h.onStart = () async => h.jsonResponse(json);
        await http.runWithClient(() async {
          await h.mount(tester, RouteNameX.testQuestions);
          tester.takeException();
          await tester.pumpAndSettle();
          final c = Get.find<TestQuestionsController>();
          final recovery = c.needsRecovery;
          final action =
              find.text('Return to test information').evaluate().length;
          c.onChangeAnswer(1);
          await c.onNextQuestion();
          c.submitQuiz();
          await tester.pumpAndSettle();
          final calls = (h.answerCalls, h.finalizeCalls, h.resultCalls);
          await h.finish(tester);
          expect(recovery, isTrue);
          expect(action, 1);
          expect(calls, (0, 0, 0));
        }, h.client);
      },
    );
  }
  testWidgets(
    'locale changes retain the live attempt without repeating a start mutation',
    (tester) async {
      await http.runWithClient(() async {
        await h.mount(tester, RouteNameX.testQuestions);
        await tester.pumpAndSettle();
        final c = Get.find<TestQuestionsController>();
        c.onChangeAnswer(1);
        await c.onNextQuestion();
        await tester.pumpAndSettle();
        unawaited(Get.updateLocale(const Locale('ar')));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        expect(h.startCalls, 1);
        expect(c.currentQuestionIndex, 1);
        expect(c.selectedAnswers, [1, null]);
        await h.finish(tester);
      }, h.client);
    },
  );
  testWidgets('explicit answer errorcode rejection remains safely retryable', (
    tester,
  ) async {
    h.onAnswer =
        () async => h.jsonResponse({
          'errorcode': 'synthetic_rejection',
          'message': 'Synthetic answer rejection',
        });
    await http.runWithClient(() async {
      await h.mount(tester, RouteNameX.testQuestions);
      await tester.pumpAndSettle();
      final c = Get.find<TestQuestionsController>();
      c.onChangeAnswer(1);
      await c.onNextQuestion();
      expect(tester.takeException(), isNotNull);
      await tester.pumpAndSettle();
      expect(c.needsRecovery, isFalse);
      expect(c.currentQuestionIndex, 0);
      h.onAnswer = null;
      await c.onNextQuestion();
      await tester.pumpAndSettle();
      expect(h.answerCalls, 2);
      expect(h.finalizeCalls, 0);
      expect(c.selectedAnswers, [1, null]);
      await h.finish(tester);
    }, h.client);
  });
}
