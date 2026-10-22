import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

import 'question.dart';

class QuizStartAttemptX {
  final String attemptId;
  final String state;
  final String status;
  final int totalQuestions;
  final List<QuestionX> questions;
  final int correctAnswers;
  final int wrongAnswers;

  QuizStartAttemptX({
    required this.attemptId,
    required this.state,
    required this.status,
    required this.totalQuestions,
    required this.questions,
    required this.correctAnswers,
    required this.wrongAnswers,
  });

  factory QuizStartAttemptX.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> questionsJson = List<Map<String, dynamic>>.from(
      json[NameX.questions] ?? [],
    );
    return ModelUtilX.checkFromJson(
      json,
      (json) => QuizStartAttemptX(
        attemptId: json[NameX.attemptId].toStrX,
        state: json[NameX.state].toStrX,
        status: json[NameX.status].toStrX,
        totalQuestions: json[NameX.totalQuestions].toIntX,
        // Every question must retain its authoritative slot. Never silently
        // shorten an invalid question set and continue submitting answers.
        questions: questionsJson.map(QuestionX.fromJson).toList(),
        correctAnswers: json[NameX.correctAnswers].toIntDefaultX(0),
        wrongAnswers: json[NameX.wrongAnswers].toIntDefaultX(0),
      ),
      requiredDataKeys: [
        NameX.attemptId,
        NameX.state,
        NameX.status,
        NameX.totalQuestions,
        NameX.questions,
      ],
    );
  }
  toJson() {
    return {
      NameX.attemptId: attemptId,
      NameX.state: state,
      NameX.status: status,
      NameX.totalQuestions: totalQuestions,
      NameX.questions: questions.map((e) => e.toJson()).toList(),
      NameX.correctAnswers: correctAnswers,
      NameX.wrongAnswers: wrongAnswers,
    };
  }
}
