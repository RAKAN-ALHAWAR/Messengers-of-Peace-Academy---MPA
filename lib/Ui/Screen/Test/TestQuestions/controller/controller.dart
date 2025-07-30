import 'dart:async';

import 'package:get/get.dart';
import 'package:messengersofpeace/Data/data.dart';

import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart';
import '../../../../../Data/Model/quiz/quiz.dart';
import '../../../../../Data/Model/quiz/quiz_start_attempt.dart';

class TestQuestionsController extends GetxController {
  //============================================================================
  // Injection of required controls

  //============================================================================
  // Variables

  /// Quiz
  QuizX quiz = Get.arguments[0];
  String quizId = Get.arguments[1];
  String courseId = Get.arguments[2];
  late QuizStartAttemptX quizStartAttempt;
  List<String> selectedAnswers = [];

  /// Current question index
  int currentQuestionIndex = 0;

  /// Time remaining
  late RxString timeRemaining =
      FunctionX.formatDuration(Duration(seconds: quiz.timelimit)).obs;

  /// Selected answer
  RxString selectedAnswer = "".obs;

  /// Start time and end time for quiz
  late DateTime _startTime;
  late DateTime _endTime;
  Timer? _timer;
  int remainingTime = 0;

  RxBool isLoading = false.obs;
  Rx<ButtonStateEX> buttonState = ButtonStateEX.normal.obs;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData() async {
    /// Get quiz start attempt
    quizStartAttempt = await DatabaseX.getQuizStartAttempt(quizId: quizId);

    /// Set start time and end time
    _startTime = DateTime.now();
    _endTime = _startTime.add(Duration(minutes: quiz.timelimit ~/ 60));
    startTimer();
  }

  /// Handle change answer
  void onChangeAnswer(String? value) =>
      selectedAnswer.value = value ?? selectedAnswer.value;

  /// Handle next question
  Future<void> onNextQuestion() async {
    /// Check if button is loading
    if (isLoading.value) return;
    try {
      isLoading.value = true;

      /// Set button state to loading
      buttonState.value = ButtonStateEX.loading;

      /// Submit question answer
      await DatabaseX.submitQuizQuestionAnswer(
        quizId: quizId,
        attemptId: quizStartAttempt.attemptId,
        questionNumber: quizStartAttempt.questions[currentQuestionIndex].slot,
        answerIndex: quizStartAttempt.questions[currentQuestionIndex].answers
            .indexOf(selectedAnswer.value),
      );

      /// Add selected answer to list
      selectedAnswers.add(selectedAnswer.value);

      /// Reset selected answer
      selectedAnswer.value = "";

      /// Check if there is a next question
      if (currentQuestionIndex < quizStartAttempt.questions.length - 1) {
        /// Increment current question index
        currentQuestionIndex++;
      } else {
        /// Submit quiz if there is no next question
        submitQuiz();
      }
    } catch (e) {
      buttonState.value = ButtonStateEX.failed;
      await Future.delayed(const Duration(seconds: 2));
    }

    /// Reset loading
    isLoading.value = false;
    buttonState.value = ButtonStateEX.normal;
  }

  /// Start timer for quiz
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final remaining = _endTime.difference(now);
      remainingTime = remaining.inSeconds;

      /// Check if time is up
      if (remaining.isNegative) {
        /// Submit quiz if time is up
        submitQuiz();
      } else {
        /// Update time remaining
        timeRemaining.value = FunctionX.formatDuration(remaining);
      }
    });
  }

  /// Submit quiz
  void submitQuiz() {
    _timer?.cancel();
    Get.offAndToNamed(
      RouteNameX.testResults,
      arguments: [
        quiz,
        quizId,
        quizStartAttempt,
        selectedAnswers,
        (quiz.timelimit - remainingTime),
        courseId,
      ],
    );
  }

  //============================================================================
  // Lifecycle

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
