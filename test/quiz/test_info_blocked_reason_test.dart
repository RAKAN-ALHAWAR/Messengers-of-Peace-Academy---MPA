import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/Model/quiz/quiz.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestInfo/controller/controller.dart';

QuizX quizWith({
  required int attemptsAllowed,
  required String status,
  required bool canStart,
}) => QuizX(
  name: 'Synthetic quiz',
  description: 'Synthetic description',
  timelimit: 3600,
  attemptsAllowed: attemptsAllowed,
  lastAttemptStatus: status,
  canStart: canStart,
  totalQuestions: 2,
  gradeTotal: 2,
  gradeToPass: 1,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final directory = await Directory.systemTemp.createTemp('mopa-blocked-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('blocked-reason');
  });

  setUp(() {
    Get.testMode = true;
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
    Get.routing.args = ['synthetic-quiz', 'synthetic-course'];
  });

  tearDown(Get.reset);

  TestInfoController controllerFor(QuizX quiz) =>
      Get.put(TestInfoController())..quiz = quiz;

  test('explains that the allowed attempts are used up', () {
    final c = controllerFor(
      quizWith(attemptsAllowed: 1, status: 'finished', canStart: false),
    );
    expect(c.canEnterTest, isFalse);
    expect(
      c.blockedReason,
      'You have used all the attempts allowed for this test, so it cannot be taken again. Contact the academy if you need a new attempt.',
    );
  });

  test('gives the generic reason for any other block', () {
    final c = controllerFor(
      quizWith(
        attemptsAllowed: 0,
        status: QuizAttemptStatusX.notAttempted,
        canStart: false,
      ),
    );
    expect(c.canEnterTest, isFalse);
    expect(c.blockedReason, 'This test is not available to start right now.');
  });

  test('gives no reason when the user can enter', () {
    final fresh = controllerFor(
      quizWith(
        attemptsAllowed: 1,
        status: QuizAttemptStatusX.notAttempted,
        canStart: true,
      ),
    );
    expect(fresh.blockedReason, isNull);

    // An attempt in progress is resumed, so it is not blocked either.
    final resumed = quizWith(
      attemptsAllowed: 1,
      status: QuizAttemptStatusX.inProgress,
      canStart: false,
    );
    fresh.quiz = resumed;
    expect(fresh.canEnterTest, isTrue);
    expect(fresh.blockedReason, isNull);
  });
}
