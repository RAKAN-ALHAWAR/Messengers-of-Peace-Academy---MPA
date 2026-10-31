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

  /// Only the exact known pass labels are understood: the server sends
  /// "Passed" or "Failed" (verified on a real get_quiz_result body), and an
  /// empty value when the review options hide it. Other/empty/missing values
  /// remain unresolved. "Not passed" is kept as a legacy failure label.
  bool? get isSuccess => switch (passed?.trim().toLowerCase()) {
    'passed' => true,
    'failed' || 'not passed' => false,
    _ => null,
  };

  late final Map<int, AnswerX?> _answersBySlot = _indexAnswers();

  Map<int, AnswerX?> _indexAnswers() {
    final indexed = <int, AnswerX?>{};
    for (final answer in answers.whereType<AnswerX>()) {
      indexed.update(answer.slot, (_) => null, ifAbsent: () => answer);
    }
    return Map.unmodifiable(indexed);
  }

  /// Duplicate slots are ambiguous and must not grade a different question.
  AnswerX? answerForSlot(int slot) => _answersBySlot[slot];

  QuizResultX({
    required this.status,
    required this.message,
    required this.grade,
    required this.maxgrade,
    required this.gradepass,
    required this.passed,
    required this.feedback,
    required List<AnswerX?> answers,
  }) : answers = List.unmodifiable(answers);
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
