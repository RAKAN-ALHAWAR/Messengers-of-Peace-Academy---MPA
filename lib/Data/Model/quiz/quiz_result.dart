import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'answer.dart';

class QuizResultX {
  final String status;
  final String message;
  final double grade;
  final double maxgrade;
  final double gradepass;
  final String passed;
  final String feedback;
  final List<AnswerX> answers;

  QuizResultX({
    required this.status,
    required this.message,
    required this.grade,
    required this.maxgrade,
    required this.gradepass,
    required this.passed,
    required this.feedback,
    required this.answers,
  });
  factory QuizResultX.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> answers = List<Map<String, dynamic>>.from(
      json[NameX.answers] ?? [],
    );
    return ModelUtilX.checkFromJson(
      json,
      (json) => QuizResultX(
        status: json[NameX.status].toStrX,
        message: json[NameX.message].toStrX,
        grade: json[NameX.grade].toDoubleX,
        maxgrade: json[NameX.maxgrade].toDoubleX,
        gradepass: json[NameX.gradepass].toDoubleX,
        passed: json[NameX.passed].toStrX,
        feedback: json[NameX.feedback].toStrX,
        answers: ModelUtilX.generateItems(answers, AnswerX.fromJson),
      ),
      requiredDataKeys: [
        NameX.status,
        NameX.message,
        NameX.grade,
        NameX.maxgrade,
        NameX.gradepass,
        NameX.passed,
        NameX.feedback,
        NameX.answers,
      ],
    );
  }
}
