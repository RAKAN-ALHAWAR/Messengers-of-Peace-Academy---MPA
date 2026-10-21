import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/quiz/answer.dart';
import 'package:messengersofpeace/Data/Model/quiz/quiz_result.dart';

Map<String, dynamic> resultJson({
  Object? passed = 'Passed',
  List<Object?> answers = const [],
}) => {
  NameX.status: 'success',
  NameX.message: 'Synthetic result',
  NameX.grade: 1,
  NameX.maxgrade: 2,
  NameX.gradepass: 1,
  NameX.passed: passed,
  NameX.feedback: 'Synthetic feedback',
  NameX.answers: answers,
};

Map<String, dynamic> answerJson(
  int slot, {
  Object? selected,
  Object? right = false,
}) => {
  NameX.slot: slot,
  NameX.questionName: 'Synthetic question $slot',
  NameX.right: right,
  NameX.responseSummary: null,
  NameX.selectedAnswerIndex: selected,
};

void main() {
  test('explicit Passed remains a pass', () {
    expect(QuizResultX.fromJson(resultJson()).isSuccess, isTrue);
  });
  test('Not passed never becomes a pass through substring matching', () {
    expect(
      QuizResultX.fromJson(resultJson(passed: 'Not passed')).isSuccess,
      isFalse,
    );
  });
  test('unknown pass wording remains unresolved', () {
    expect(
      QuizResultX.fromJson(resultJson(passed: 'Pending review')).isSuccess,
      isNull,
    );
  });
  test('unanswered result index is preserved as null', () {
    final answer = AnswerX.fromJson(answerJson(3));
    expect(answer.selectedAnswerIndex, isNull);
  });
  test('null result entries retain their original positions', () {
    final result = QuizResultX.fromJson(
      resultJson(answers: [null, answerJson(7, selected: 1)]),
    );
    expect(result.answers.length, 2);
    expect(result.answers.first, isNull);
    expect(result.answers.last?.slot, 7);
  });
  test('missing pass status remains unresolved', () {
    final json = resultJson()..remove(NameX.passed);
    expect(QuizResultX.fromJson(json).isSuccess, isNull);
  });
  test('answers map by slot even when reordered or incomplete', () {
    final result = QuizResultX.fromJson(
      resultJson(
        answers: [answerJson(7, selected: 1), null, answerJson(2, selected: 0)],
      ),
    );
    expect(result.answerForSlot(2)?.selectedAnswerIndex, 0);
    expect(result.answerForSlot(7)?.selectedAnswerIndex, 1);
    expect(result.answerForSlot(4), isNull);
  });
  test('duplicate slots remain ambiguous', () {
    final result = QuizResultX.fromJson(
      resultJson(
        answers: [answerJson(2, selected: 0), answerJson(2, selected: 1)],
      ),
    );
    expect(result.answerForSlot(2), isNull);
  });
  test(
    'unknown grading and absent selection do not become false or unanswered',
    () {
      final answer = AnswerX.fromJson(
        answerJson(2, right: 'pending')..remove(NameX.selectedAnswerIndex),
      );
      expect(answer.right, isNull);
      expect(answer.hasSelectionDetails, isFalse);
    },
  );
  for (final malformed in [-1, 0.5, true, 'not an index']) {
    test('malformed selection $malformed remains unavailable', () {
      final answer = AnswerX.fromJson(answerJson(2, selected: malformed));
      expect(answer.selectedAnswerIndex, isNull);
      expect(answer.hasSelectionDetails, isFalse);
    });
  }
  test('malformed result entry stays a placeholder without shifting slots', () {
    final result = QuizResultX.fromJson(
      resultJson(
        answers: [
          answerJson(2)..[NameX.slot] = 2.4,
          answerJson(7, selected: 1),
        ],
      ),
    );
    expect(result.answers.first, isNull);
    expect(result.answers.last?.slot, 7);
  });
}
