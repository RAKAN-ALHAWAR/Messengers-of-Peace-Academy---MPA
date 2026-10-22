import 'package:get/get.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
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

  late final SessionLeaseX _ownerLease;
  int _loadGeneration = 0;
  bool get ownsCurrentSession => _ownerLease.isCurrent;

  Future<void> getData() async {
    final generation = ++_loadGeneration;
    final locale = TranslationX.getLanguageCode;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              ownsCurrentSession &&
              generation == _loadGeneration &&
              locale == TranslationX.getLanguageCode,
    );
    if (!lease.isCurrent) return;
    try {
      isInit.value = false;
      final loaded = await DatabaseX.getQuizDetails(quizId: quizId);
      if (!lease.isCurrent) return;
      quiz = loaded;
      isInit.value = true;
    } catch (error) {
      if (!lease.isCurrent) return;
      ErrorX.console(error);
      rethrow;
    }
  }

  String get passRate {
    if (quiz.gradeTotal <= 0 ||
        quiz.gradeToPass < 0 ||
        quiz.gradeToPass > quiz.gradeTotal) {
      return '--';
    }
    return (quiz.gradeToPass / quiz.gradeTotal * 100).toInt().toString();
  }

  /// Whether the user can enter the test screen.
  ///
  /// The backend reports `can_start: false` once an attempt is in progress,
  /// but `start_or_get_quiz_attempt` resumes that attempt, so an in progress
  /// attempt must stay reachable, otherwise the user is locked out of it.
  bool get canEnterTest =>
      quiz.canStart || quiz.lastAttemptStatus == QuizAttemptStatusX.inProgress;

  /// Handle start test
  void onStartTest() {
    if (!ownsCurrentSession || !isInit.value || !canEnterTest) return;
    Get.offAndToNamed(
      RouteNameX.testQuestions,
      arguments: [quiz, quizId, courseId],
    );
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
              Get.isRegistered<TestInfoController>() &&
              identical(Get.find<TestInfoController>(), this) &&
              Get.isRegistered<AppControllerX>() &&
              identical(Get.find<AppControllerX>(), app) &&
              app.user.value.id == accountId,
    );
  }
}
