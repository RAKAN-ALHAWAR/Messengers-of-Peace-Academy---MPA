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
    await Future.delayed(Duration(seconds: 4));
    isInit.value = false;
    quiz = await DatabaseX.getQuizDetails(quizId: quizId);
    isInit.value = true;
  }

  /// Handle start test
  void onStartTest() => Get.offAndToNamed(
    RouteNameX.testQuestions,
    arguments: [quiz, quizId, courseId],
  );
}
