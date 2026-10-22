import 'dart:async';

import 'package:get/get.dart';
import 'package:messengersofpeace/Data/data.dart';
import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Data/Model/quiz/quiz.dart';
import '../../../../../Data/Model/quiz/quiz_start_attempt.dart';

class TestQuestionsController extends GetxController {
  QuizX quiz = Get.arguments[0];
  String quizId = Get.arguments[1];
  String courseId = Get.arguments[2];
  late QuizStartAttemptX quizStartAttempt;
  List<int?> selectedAnswers = [];
  int currentQuestionIndex = 0;
  late RxString timeRemaining =
      FunctionX.formatDuration(Duration(seconds: quiz.timelimit)).obs;
  final selectedAnswer = Rxn<int>();
  late DateTime _endTime;
  Timer? _timer;
  int remainingTime = 0;
  final isLoading = false.obs;
  final answerError = Rxn<String>();
  final buttonState = ButtonStateEX.normal.obs;
  late final SessionLeaseX _ownerLease;
  Future<void>? _loading;
  bool _hasAttempt = false;
  bool _ready = false;
  bool _finishRequested = false;
  bool _transitioned = false;
  bool needsRecovery = false;
  bool get ownsCurrentSession => _ownerLease.isCurrent;

  Future<void> getData() =>
      _loading ??= _loadData().whenComplete(() {
        if (ownsCurrentSession) _loading = null;
      });

  Future<void> _loadData() async {
    final lease = SessionLeaseX.capture(isActive: () => ownsCurrentSession);
    if (!lease.isCurrent || _ready || needsRecovery) return;
    // The current response has no authoritative saved selections/current slot.
    // Replaying a known resumed attempt from question zero could overwrite it.
    if (quiz.lastAttemptStatus == QuizAttemptStatusX.inProgress) {
      needsRecovery = true;
      return;
    }
    try {
      if (!_hasAttempt) {
        final attempt = await DatabaseX.getQuizStartAttempt(quizId: quizId);
        if (!lease.isCurrent) return;
        quizStartAttempt = attempt;
        _hasAttempt = true;
        selectedAnswers = List<int?>.filled(attempt.questions.length, null);
      }
      final questions = quizStartAttempt.questions;
      if (questions.isEmpty ||
          quizStartAttempt.totalQuestions != questions.length ||
          questions.any((q) => q.answers.isEmpty) ||
          questions.map((q) => q.slot).toSet().length != questions.length) {
        needsRecovery = true;
        return;
      }
      final started = await _attemptStartTime();
      if (!lease.isCurrent) return;
      _endTime = started.add(Duration(seconds: quiz.timelimit));
      _ready = true;
      _updateRemaining(_endTime.difference(DateTime.now()));
      if (remainingTime > 0 && !_finishRequested) startTimer();
    } catch (error) {
      if (!lease.isCurrent) return;
      ErrorX.console(error);
      rethrow;
    }
  }

  Future<DateTime> _attemptStartTime() async {
    try {
      return await DatabaseX.getQuizAttemptStartTime(quizId: quizId) ??
          DateTime.now();
    } catch (error) {
      if (ownsCurrentSession) ErrorX.console(error);
      // Preserve the existing fresh-attempt fallback; server timing semantics
      // (including zero time limits) require a backend contract.
      return DateTime.now();
    }
  }

  void onChangeAnswer(int? value) {
    if (!ownsCurrentSession ||
        !_ready ||
        isLoading.value ||
        _finishRequested ||
        value == null) {
      return;
    }
    if (value >= 0 &&
        value <
            quizStartAttempt.questions[currentQuestionIndex].answers.length) {
      selectedAnswer.value = value;
    }
  }

  Future<void> onNextQuestion() async {
    if (!ownsCurrentSession || !_ready || _finishRequested || isLoading.value) {
      return;
    }
    final index = currentQuestionIndex;
    final question = quizStartAttempt.questions[index];
    final answer = selectedAnswer.value;
    if (answer == null || answer < 0 || answer >= question.answers.length) {
      return;
    }
    final lease = SessionLeaseX.capture(isActive: () => ownsCurrentSession);
    isLoading.value = true;
    answerError.value = null;
    buttonState.value = ButtonStateEX.loading;
    try {
      await DatabaseX.submitQuizQuestionAnswer(
        quizId: quizId,
        attemptId: quizStartAttempt.attemptId,
        questionNumber: question.slot,
        answerIndex: answer,
      );
      if (!lease.isCurrent) return;
      selectedAnswers[index] = answer;
      if (!_finishRequested && index < quizStartAttempt.questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer.value = null;
      } else {
        _finishRequested = true;
      }
      buttonState.value = ButtonStateEX.normal;
    } catch (error) {
      if (!lease.isCurrent) return;
      ErrorX.console(error);
      answerError.value = error.toString();
      buttonState.value = ButtonStateEX.failed;
    } finally {
      if (lease.isCurrent) {
        isLoading.value = false;
        if (_finishRequested) _showResults();
      }
    }
  }

  void _updateRemaining(Duration remaining) {
    if (!ownsCurrentSession || _finishRequested) {
      _timer?.cancel();
      return;
    }
    remainingTime = remaining.inSeconds;
    if (remaining.isNegative) {
      submitQuiz();
    } else {
      timeRemaining.value = FunctionX.formatDuration(remaining);
    }
  }

  void startTimer() {
    if (!ownsCurrentSession || !_ready || _finishRequested) return;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(_endTime.difference(DateTime.now())),
    );
  }

  void submitQuiz() {
    if (!ownsCurrentSession || !_ready || _transitioned) return;
    _finishRequested = true;
    _timer?.cancel();
    // Wait for the bounded in-flight answer before finalizing the same attempt.
    if (!isLoading.value) _showResults();
  }

  void _showResults() {
    if (!ownsCurrentSession || _transitioned) return;
    _transitioned = true;
    _timer?.cancel();
    Get.offAndToNamed(
      RouteNameX.testResults,
      arguments: [
        quiz,
        quizId,
        quizStartAttempt,
        List<int?>.of(selectedAnswers),
        quiz.timelimit - remainingTime,
        courseId,
      ],
    );
  }

  void returnToTestInfo() {
    if (!ownsCurrentSession) return;
    Get.offAndToNamed(RouteNameX.testInfo, arguments: [quizId, courseId]);
  }

  @override
  void onInit() {
    super.onInit();
    final app = Get.find<AppControllerX>();
    final accountId = app.user.value.id;
    _ownerLease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              Get.isRegistered<TestQuestionsController>() &&
              identical(Get.find<TestQuestionsController>(), this) &&
              Get.isRegistered<AppControllerX>() &&
              identical(Get.find<AppControllerX>(), app) &&
              app.user.value.id == accountId,
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
