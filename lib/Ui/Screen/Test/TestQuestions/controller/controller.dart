import 'dart:async';
import 'dart:developer';

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
    try {
      /// Get quiz start attempt (starts a new attempt or resumes the running one)
      quizStartAttempt = await DatabaseX.getQuizStartAttempt(quizId: quizId);

      selectedAnswers.addAll(
        quizStartAttempt.questions.map((e) => "").toList(),
      );

      /// Set start time and end time
      ///
      /// A resumed attempt keeps the deadline of the moment it was created on
      /// the server, otherwise the app would grant a fresh [quiz.timelimit]
      /// while the backend keeps counting from the original start
      _startTime = await _attemptStartTime();
      _endTime = _startTime.add(Duration(seconds: quiz.timelimit));

      /// Show the real remaining time on the first frame, the timer only
      /// ticks after one second and would otherwise flash the full time limit
      _updateRemaining(_endTime.difference(DateTime.now()));

      /// A resumed attempt may already be expired, [_updateRemaining] then
      /// submitted it and there is nothing left to count down
      if (remainingTime > 0) startTimer();
    } catch (e) {
      log(
        "error getQuizStartAttempt for quiz $quizId: $e",
        name: runtimeType.toString(),
      );

      /// Rethrow so FutureBuilderX shows the error state
      /// instead of building the view with an uninitialized [quizStartAttempt]
      rethrow;
    }
  }

  /// Real start time of the running attempt.
  ///
  /// Falls back to "now" when the backend does not report it, which is the
  /// correct value for a freshly created attempt anyway.
  Future<DateTime> _attemptStartTime() async {
    try {
      return await DatabaseX.getQuizAttemptStartTime(quizId: quizId) ??
          DateTime.now();
    } catch (e) {
      /// Never block the quiz because of this secondary lookup
      log("error getQuizAttemptStartTime: $e", name: runtimeType.toString());
      return DateTime.now();
    }
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

      var question = quizStartAttempt.questions[currentQuestionIndex];

      /// Submit question answer
      await DatabaseX.submitQuizQuestionAnswer(
        quizId: quizId,
        attemptId: quizStartAttempt.attemptId,
        questionNumber: question.slot,
        answerIndex: question.answers.indexOf(selectedAnswer.value),
      );

      /// Add selected answer to list
      selectedAnswers[currentQuestionIndex] = selectedAnswer.value;

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
      log("error submitQuizQuestionAnswer: $e", name: runtimeType.toString());
      buttonState.value = ButtonStateEX.failed;
      await Future.delayed(const Duration(seconds: 2));
    }

    /// Reset loading
    isLoading.value = false;
    buttonState.value = ButtonStateEX.normal;
  }

  /// Refresh the countdown, submitting the quiz once the deadline has passed
  void _updateRemaining(Duration remaining) {
    remainingTime = remaining.inSeconds;

    /// Check if time is up
    if (remaining.isNegative) {
      /// Submit quiz if time is up
      submitQuiz();
    } else {
      /// Update time remaining
      timeRemaining.value = FunctionX.formatDuration(remaining);
    }
  }

  /// Start timer for quiz
  void startTimer() {
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (_) => _updateRemaining(_endTime.difference(DateTime.now())),
    );
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
