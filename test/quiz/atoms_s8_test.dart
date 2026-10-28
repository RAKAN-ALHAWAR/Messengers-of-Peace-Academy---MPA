import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestInfo/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestQuestions/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestResults/controller/controller.dart';

import 'quiz_flow_test.dart' show QuizHarness;

/// How a controller stops owning its session while a request is in flight.
enum Loss { none, closed, secondInstance, appReplaced, accountChanged }

UserX user(String id) => UserX(
  id: id,
  username: 'synthetic',
  firstname: 'Test',
  lastname: 'User',
  email: 'test@example.invalid',
  lang: 'en',
  customfields: [],
  city: '',
  image: '',
  points: 0,
);

void lose(Loss loss, GetxController controller, void Function() putSecond) {
  switch (loss) {
    case Loss.none:
      break;
    case Loss.closed:
      // Closed but still registered, so only the closed atom can see it.
      controller.onDelete();
    case Loss.secondInstance:
      putSecond();
    case Loss.appReplaced:
      Get.delete<AppControllerX>(force: true);
      Get.put(AppControllerX()..user = user('synthetic-user').obs);
    case Loss.accountChanged:
      Get.find<AppControllerX>().user.value = user('other-user');
  }
}

/// The way a replaced route registers its new controller: the old one is
/// marked dirty, still open, but no longer the registered instance.
void putSecondInstance<T extends GetxController>(T Function() make) {
  GetInstance().markAsDirty<T>();
  Get.put<T>(make());
}

Future<void> waitUntil(bool Function() done) async {
  for (var i = 0; i < 50 && !done(); i++) {
    await pumpEventQueue();
  }
  expect(done(), isTrue, reason: 'the request was never issued');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late QuizHarness h;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-atoms-s8-');
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
    Get.put(AppControllerX()..user = user('synthetic-user').obs);
    h = QuizHarness();
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  group('TestInfo getData lease', () {
    Future<void> run(Loss loss) async {
      final pending = Completer<http.Response>();
      h.onInfo = () => pending.future;
      await http.runWithClient(() async {
        Get.routing.args = ['synthetic-quiz', 'synthetic-course'];
        final c = Get.put(TestInfoController());
        final load = c.getData();
        await waitUntil(() => h.infoCalls == 1);
        lose(loss, c, () => putSecondInstance(TestInfoController.new));
        pending.complete(h.jsonResponse(h.quiz.toJson()));
        await load;
        expect(c.isInit.value, loss == Loss.none);
      }, h.client);
    }

    for (final loss in Loss.values) {
      test('late response with $loss', () => run(loss));
    }

    test(
      'an older load cannot overwrite a newer load of the same language',
      () async {
        final old = Completer<http.Response>();
        h.onInfo = () => old.future;
        await http.runWithClient(() async {
          Get.routing.args = ['synthetic-quiz', 'synthetic-course'];
          final c = Get.put(TestInfoController());
          final first = c.getData();
          await waitUntil(() => h.infoCalls == 1);
          h.onInfo = () async =>
              h.jsonResponse(h.quiz.toJson()..[NameX.quizName] = 'Newer load');
          await c.getData();
          old.complete(
            h.jsonResponse(h.quiz.toJson()..[NameX.quizName] = 'Older load'),
          );
          await first;
          expect(c.quiz.name, 'Newer load');
        }, h.client);
      },
    );

    test(
      'a language change retires the load without starting another',
      () async {
        final pending = Completer<http.Response>();
        h.onInfo = () => pending.future;
        await http.runWithClient(() async {
          Get.routing.args = ['synthetic-quiz', 'synthetic-course'];
          final c = Get.put(TestInfoController());
          final load = c.getData();
          await waitUntil(() => h.infoCalls == 1);
          Get.locale = const Locale('ar');
          pending.complete(h.jsonResponse(h.quiz.toJson()));
          await load;
          expect(c.isInit.value, isFalse);
          expect(h.infoCalls, 1);
        }, h.client);
      },
    );
  });

  group('TestQuestions leases', () {
    Future<void> runAnswer(Loss loss) async {
      final pending = Completer<http.Response>();
      h.onAnswer = () => pending.future;
      await http.runWithClient(() async {
        Get.routing.args = [h.quiz, 'synthetic-quiz', 'synthetic-course'];
        final c = Get.put(TestQuestionsController());
        addTearDown(c.onClose);
        await c.getData();
        c.onChangeAnswer(0);
        final send = c.onNextQuestion();
        await waitUntil(() => h.answerCalls == 1);
        lose(loss, c, () => putSecondInstance(TestQuestionsController.new));
        pending.complete(
          h.jsonResponse({'status': 'success', 'message': 'Answer saved'}),
        );
        await send;
        expect(c.currentQuestionIndex, loss == Loss.none ? 1 : 0);
        expect(c.selectedAnswers, loss == Loss.none ? [0, null] : [null, null]);
      }, h.client);
    }

    for (final loss in Loss.values) {
      test('late answer with $loss', () => runAnswer(loss));
    }

    test(
      'a late start response after close does not read the start time',
      () async {
        final pending = Completer<http.Response>();
        h.onStart = () => pending.future;
        await http.runWithClient(() async {
          Get.routing.args = [h.quiz, 'synthetic-quiz', 'synthetic-course'];
          final c = Get.put(TestQuestionsController());
          addTearDown(c.onClose);
          final load = c.getData();
          await waitUntil(() => h.startCalls == 1);
          await Get.delete<TestQuestionsController>(force: true);
          pending.complete(h.jsonResponse(h.attempt.toJson()));
          await load;
          expect(h.startTimeCalls, 0);
        }, h.client);
      },
    );
  });

  group('TestResults getData lease', () {
    Future<void> run(Loss loss) async {
      final pending = Completer<http.Response>();
      h.onResult = () => pending.future;
      await http.runWithClient(() async {
        Get.routing.args = [
          h.quiz,
          'synthetic-quiz',
          h.attempt,
          <int?>[null, 1],
          10,
          'synthetic-course',
        ];
        final c = Get.put(TestResultsController());
        final load = c.getData();
        await waitUntil(() => h.resultCalls == 1);
        lose(loss, c, () => putSecondInstance(TestResultsController.new));
        pending.complete(h.jsonResponse(h.results));
        await load;
        expect(c.result == null, loss != Loss.none);
      }, h.client);
    }

    for (final loss in Loss.values) {
      test('late result with $loss', () => run(loss));
    }
  });
}
