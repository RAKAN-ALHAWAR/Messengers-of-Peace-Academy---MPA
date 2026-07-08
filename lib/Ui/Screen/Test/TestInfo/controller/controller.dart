import 'dart:developer';

import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/data.dart';

import '../../../../../Data/Model/quiz/quiz.dart';

class TestInfoController extends GetxController {
  //============================================================================
  // Variables

  /// Quiz ID from previous screen
  String quizId = Get.arguments[0];
  String courseId = Get.arguments[1];

  /// Quiz
  late QuizX quiz;

  /// Is initialized
  RxBool isInit = false.obs;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData() async {
    try {
      isInit.value = false;
      quiz = await DatabaseX.getQuizDetails(quizId: quizId);
      isInit.value = true;
    } catch (e) {
      log(
        "error getQuizDetails for quiz $quizId: $e",
        name: runtimeType.toString(),
      );

      /// Rethrow so FutureBuilderX shows the error state
      /// instead of building the view with an uninitialized [quiz]
      rethrow;
    }
  }

  /// Whether the user can enter the test screen.
  ///
  /// The backend reports `can_start: false` once an attempt is in progress,
  /// but `start_or_get_quiz_attempt` resumes that attempt, so an in progress
  /// attempt must stay reachable, otherwise the user is locked out of it.
  bool get canEnterTest =>
      quiz.canStart || quiz.lastAttemptStatus == QuizAttemptStatusX.inProgress;

  /// Handle start test
  void onStartTest() => Get.offAndToNamed(
    RouteNameX.testQuestions,
    arguments: [quiz, quizId, courseId],
  );
}
