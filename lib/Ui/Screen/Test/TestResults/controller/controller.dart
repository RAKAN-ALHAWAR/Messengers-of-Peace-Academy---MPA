import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Data/Model/quiz/answer.dart';
import 'package:messengersofpeace/Data/Model/quiz/question.dart';
import 'package:messengersofpeace/Data/Model/quiz/quiz_start_attempt.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/controller/controller.dart';

import '../../../../../Data/Model/quiz/quiz.dart';
import '../../../../../Data/Model/quiz/quiz_result.dart';
import '../../../../../Data/data.dart';

enum QuizSubmissionStateX {
  notStarted,
  finalizing,
  acknowledged,
  rejected,
  uncertain,
}

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
  List<Object?> selectedAnswers = List<Object?>.from(Get.arguments[3]);

  /// Time taken
  int timeTaken = Get.arguments[4];

  /// Course Id
  String courseId = Get.arguments[5];

  /// Quiz result
  QuizResultX? result;
  QuizResultX get quizResult => result!;
  Object? loadError;
  QuizSubmissionStateX submissionState = QuizSubmissionStateX.notStarted;
  Future<void>? _inFlight;
  late final SessionLeaseX _ownerLease;

  /// Is success
  bool get isSuccess => result?.isSuccess == true;
  bool get hasConfirmedOutcome => result?.isSuccess != null;
  bool get ownsCurrentSession => _ownerLease.isCurrent;
  bool get canRetrySubmission =>
      submissionState == QuizSubmissionStateX.rejected;
  bool get needsSubmissionRecovery =>
      submissionState == QuizSubmissionStateX.uncertain;

  /// Correct answers
  int? get correctAnswers => _gradedCount(true);

  /// Wrong answers
  int? get wrongAnswers => _gradedCount(false);

  AnswerX? answerForQuestion(QuestionX question) =>
      result?.answerForSlot(question.slot);

  int? selectedIndexForQuestion(QuestionX question) {
    final selected = answerForQuestion(question)?.selectedAnswerIndex;
    return selected != null && selected < question.answers.length
        ? selected
        : null;
  }

  int? _gradedCount(bool right) {
    final answers = quizStartAttempt.questions.map(answerForQuestion).toList();
    if (answers.any((answer) => answer?.right == null)) return null;
    return answers.where((answer) => answer!.right == right).length;
  }

  double? get scoreFraction {
    final value = result;
    if (value == null ||
        !value.grade.isFinite ||
        !value.maxgrade.isFinite ||
        value.maxgrade <= 0 ||
        value.grade < 0 ||
        value.grade > value.maxgrade) {
      return null;
    }
    return value.grade / value.maxgrade;
  }

  //============================================================================
  // Functions

  Future<void> getData() =>
      _inFlight ??= _loadData().whenComplete(() {
        if (ownsCurrentSession) _inFlight = null;
      });

  Future<void> _loadData() async {
    final lease = SessionLeaseX.capture(isActive: () => _ownerLease.isCurrent);
    if (!lease.isCurrent) return;
    if (submissionState == QuizSubmissionStateX.rejected ||
        needsSubmissionRecovery) {
      return;
    }
    loadError = null;
    if (submissionState == QuizSubmissionStateX.notStarted) {
      submissionState = QuizSubmissionStateX.finalizing;
      try {
        await DatabaseX.submitQuiz(attemptId: quizStartAttempt.attemptId);
        if (!lease.isCurrent) return;
        submissionState = QuizSubmissionStateX.acknowledged;
      } catch (error) {
        if (!lease.isCurrent) return;
        final explicitRejection =
            error is ErrorX &&
            (error.details['status'] == 'error' ||
                error.details['status'] == false ||
                error.details['status'] == 'false' ||
                error.details['errorcode'] != null);
        submissionState =
            explicitRejection
                ? QuizSubmissionStateX.rejected
                : QuizSubmissionStateX.uncertain;
        loadError =
            explicitRejection
                ? error
                : ErrorX(
                  message:
                      'Submission status is unknown. Return to test information before trying again.',
                );
        ErrorX.console(error);
        return;
      }
    }
    final locale = TranslationX.getLanguageCode;
    try {
      final loaded = await DatabaseX.getQuizResult(quizId: quizId);
      if (!lease.isCurrent) return;
      if (locale != TranslationX.getLanguageCode) return _loadData();
      if (loaded.status == 'error' || loaded.status == 'false') {
        throw ErrorX(message: loaded.message);
      }
      result = loaded;
    } catch (error) {
      if (!lease.isCurrent) return;
      if (locale != TranslationX.getLanguageCode) return _loadData();
      loadError = error;
      ErrorX.console(error);
    }
  }

  /// Only the explicit recovery action may repeat a known rejected mutation.
  /// Locale changes/read retries cannot silently resubmit an attempt.
  void retryRejectedSubmission() {
    if (!ownsCurrentSession || !canRetrySubmission || _inFlight != null) return;
    submissionState = QuizSubmissionStateX.notStarted;
    loadError = null;
    result = null;
  }

  onTapButton() {
    if (!ownsCurrentSession) return;
    if (isSuccess) {
      // After a confirmed pass go back to the course page below this screen and
      // let it refetch and open the next activity. A second course page would
      // share the controller with the old one, and the old route's disposal
      // would delete it.
      final details =
          Get.isRegistered<CourseDetailsController>()
              ? Get.find<CourseDetailsController>()
              : null;
      if (details != null && details.courseId == courseId) {
        Get.until((route) => route.settings.name == RouteNameX.courseDetails);
        details.continueAfterPassedQuiz(quizId);
        return;
      }
      // No course page below (opened another way): load a fresh one.
      Get.offNamedUntil(
        RouteNameX.courseDetails,
        (route) => route.settings.name == RouteNameX.root,
        arguments: courseId,
        parameters: {CourseDetailsController.nextAfterQuizParam: quizId},
      );
    } else {
      returnToTestInfo();
    }
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
              Get.isRegistered<TestResultsController>() &&
              identical(Get.find<TestResultsController>(), this) &&
              Get.isRegistered<AppControllerX>() &&
              identical(Get.find<AppControllerX>(), app) &&
              app.user.value.id == accountId,
    );
  }
}
