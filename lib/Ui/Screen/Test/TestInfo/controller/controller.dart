import 'package:get/get.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Service/controller_lease.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
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

  /// Lease of this screen: open, registered, same app controller and account.
  late final SessionLeaseX _ownerLease;
  int _loadGeneration = 0;
  bool get ownsCurrentSession => _ownerLease.isCurrent;

  Future<void> getData() async {
    final generation = ++_loadGeneration;
    final lease = ControllerLeaseX.capture(
      this,
      owner: _ownerLease,
      locale: true,
      also: () => generation == _loadGeneration,
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

  /// Can enter the test; an in progress attempt stays reachable (the backend resumes it).
  bool get canEnterTest =>
      quiz.canStart || quiz.lastAttemptStatus == QuizAttemptStatusX.inProgress;

  /// Why the user cannot enter the test (null when they can); 0 attempts allowed means unlimited.
  String? get blockedReason {
    if (canEnterTest) return null;
    final status = quiz.lastAttemptStatus;
    final hasFinishedAttempt =
        status.isNotEmpty &&
        status != QuizAttemptStatusX.notAttempted &&
        status != QuizAttemptStatusX.inProgress;
    if (quiz.attemptsAllowed > 0 && hasFinishedAttempt) {
      return 'You have used all the attempts allowed for this test, so it cannot be taken again. Contact the academy if you need a new attempt.';
    }
    return 'This test is not available to start right now.';
  }

  /// Handle start test
  void onStartTest() {
    if (!ownsCurrentSession || !isInit.value || !canEnterTest) return;
    Get.offAndToNamed(
      RouteNameX.testQuestions,
      arguments: [quiz, quizId, courseId],
    );
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    final app = Get.find<AppControllerX>();
    final accountId = app.user.value.id;
    _ownerLease = ControllerLeaseX.capture(
      this,
      registered: true,
      app: app,
      also: () => app.user.value.id == accountId,
    );
  }
}
