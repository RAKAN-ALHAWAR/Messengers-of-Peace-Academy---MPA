import 'dart:developer';

import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/Model/quiz/quiz_start_attempt.dart';

import '../../../../../Data/Model/quiz/quiz.dart';
import '../../../../../Data/Model/quiz/quiz_result.dart';
import '../../../../../Data/data.dart';

class TestResultsController extends GetxController {
  //============================================================================
  // Injection of required controls

  //============================================================================
  // Variables

  /// Quiz
  QuizX quiz = Get.arguments[0];

  /// Quiz id
  String quizId = Get.arguments[1];

  /// Quiz start attempt
  QuizStartAttemptX quizStartAttempt = Get.arguments[2];

  /// Selected answers
  List<String> selectedAnswers = Get.arguments[3];

  /// Time taken
  int timeTaken = Get.arguments[4];

  /// Course Id
  String courseId = Get.arguments[5];

  /// Quiz result
  late QuizResultX quizResult;

  /// Is success
  bool isSuccess = false;

  /// Correct answers
  int get correctAnswers =>
      quizResult.answers.where((answer) => answer.right).length;

  /// Wrong answers
  int get wrongAnswers =>
      quizResult.answers.where((answer) => !answer.right).length;

  //============================================================================
  // Functions

  /// Guard against submitting the same attempt twice when the user retries
  /// after [getQuizResult] failed, the attempt is already finished by then
  bool _isSubmitted = false;

  Future<void> getData() async {
    try {
      if (!_isSubmitted) {
        await DatabaseX.submitQuiz(attemptId: quizStartAttempt.attemptId);
        _isSubmitted = true;
      }
      quizResult = await DatabaseX.getQuizResult(quizId: quizId);
      isSuccess = quizResult.isSuccess;
    } catch (e) {
      log("error submitQuiz / getQuizResult: $e", name: runtimeType.toString());

      /// Rethrow so FutureBuilderX shows the error state
      /// instead of building the view with an uninitialized [quizResult]
      rethrow;
    }
  }

  onTapButton() {
    if (isSuccess) {
      /// إغلاق شاشة المعلومات وإعادة تحميل بيانات تفاصيل الدورة
      Get.offNamedUntil(
        RouteNameX.courseDetails,
        (route) => route.settings.name == RouteNameX.root,
        arguments: courseId,
      );
    } else {
      /// Close the screen and navigate to test info screen
      Get.offAndToNamed(RouteNameX.testInfo, arguments: [quizId, courseId]);
    }
  }
}
