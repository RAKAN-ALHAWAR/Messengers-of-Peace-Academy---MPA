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
  final String? passed;
  final String feedback;
  final List<AnswerX?> answers;

  /// Only the exact existing pass labels are understood. Other/missing values
  /// remain unresolved until the backend's authoritative enum is confirmed.
  bool? get isSuccess => switch (passed?.trim().toLowerCase()) {
    'passed' => true,
    'not passed' => false,
    _ => null,
  };

  /// Duplicate slots are ambiguous and must not grade a different question.
  AnswerX? answerForSlot(int slot) {
    final matches = answers.whereType<AnswerX>().where(
      (answer) => answer.slot == slot,
    );
    return matches.length == 1 ? matches.single : null;
  }

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
    return ModelUtilX.checkFromJson(
      json,
      (json) => QuizResultX(
        status: json[NameX.status].toStrX,
        message: json[NameX.message].toStrX,
        grade: json[NameX.grade].toDoubleX,
        maxgrade: json[NameX.maxgrade].toDoubleX,
        gradepass: json[NameX.gradepass].toDoubleX,
        passed: json[NameX.passed].toStrNullableX,
        feedback: json[NameX.feedback].toStrX,
        answers: [
          for (final answer in (json[NameX.answers] as List? ?? []))
            _answerOrNull(answer),
        ],
      ),
      requiredDataKeys: [
        NameX.status,
        NameX.message,
        NameX.grade,
        NameX.maxgrade,
        NameX.gradepass,
        NameX.feedback,
        NameX.answers,
      ],
    );
  }

  static AnswerX? _answerOrNull(Object? value) {
    if (value is! Map) return null;
    try {
      return AnswerX.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      // Keep a placeholder rather than shortening/reordering result answers.
      return null;
    }
  }
}
