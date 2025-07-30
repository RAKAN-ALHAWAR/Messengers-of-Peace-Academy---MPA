import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class QuizX {
  final String name;
  final String description;
  final int timelimit;
  final int attemptsAllowed;
  final String lastAttemptStatus;
  final bool canStart;
  final int totalQuestions;
  final int gradeTotal;
  final int gradeToPass;
  QuizX({
    required this.name,
    required this.description,
    required this.timelimit,
    required this.attemptsAllowed,
    required this.lastAttemptStatus,
    required this.canStart,
    required this.totalQuestions,
    required this.gradeTotal,
    required this.gradeToPass,
  });

  factory QuizX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => QuizX(
        name: json[NameX.quizName].toStrX,
        description: json[NameX.quizDescription].toStrX,
        timelimit: json[NameX.timelimit].toIntX,
        attemptsAllowed: json[NameX.attemptsAllowed].toIntX,
        lastAttemptStatus: json[NameX.lastAttemptStatus].toStrX,
        canStart: json[NameX.canStart].toBoolX,
        totalQuestions: json[NameX.totalQuestions].toIntX,
        gradeTotal: json[NameX.gradeTotal].toIntX,
        gradeToPass: json[NameX.gradeToPass].toIntX,
      ),
      requiredDataKeys: [
        NameX.quizName,
        NameX.quizDescription,
        NameX.timelimit,
        NameX.attemptsAllowed,
        NameX.lastAttemptStatus,
        NameX.canStart,
        NameX.totalQuestions,
        NameX.gradeTotal,
        NameX.gradeToPass,
      ],
    );
  }
}
