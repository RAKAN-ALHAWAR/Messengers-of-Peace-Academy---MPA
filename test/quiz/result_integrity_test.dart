import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Data/Model/quiz/question.dart';
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

/// Real get_quiz_result body of a failed attempt (captured from the server);
/// only the feedback HTML is shortened.
Map<String, dynamic> capturedFailedResult() => {
  'status': 'ok',
  'message': 'Result fetched successfully.',
  'grade': '5.00',
  'maxgrade': '10.00',
  'gradepass': '6.00',
  'passed': 'Failed',
  'feedback': '<p>Try again.</p>',
  'answers': [
    {
      'slot': 1,
      'questionname': 'First question',
      'right': true,
      'response_summary': 'First response\n\n',
      'selected_answer_index': 1,
    },
    {
      'slot': 2,
      'questionname': 'Second question',
      'right': false,
      'response_summary': 'Second response\n\n',
      'selected_answer_index': 0,
    },
  ],
};

void main() {
  test('the real server body of a failed attempt parses as failed', () {
    final result = QuizResultX.fromJson(capturedFailedResult());
    expect(result.passed, 'Failed');
    expect(result.isSuccess, isFalse);
    expect(result.answers, hasLength(2));
    expect(result.answerForSlot(1)?.right, isTrue);
    expect(result.answerForSlot(2)?.right, isFalse);
  });
  test('backend labels Passed, Failed, empty and unknown map as documented', () {
    bool? parse(Object? passed) =>
        QuizResultX.fromJson(resultJson(passed: passed)).isSuccess;
    expect(parse('Passed'), isTrue);
    expect(parse('Failed'), isFalse);
    expect(parse(' failed '), isFalse);
    expect(parse(''), isNull);
    expect(parse('Pending review'), isNull);
  });
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
  Map<String, dynamic> questionJson(Object? slot) => {
    NameX.slot: slot,
    NameX.questionId: 12,
    NameX.questionNumber: 1,
    NameX.questionText: 'Synthetic question',
    NameX.answers: ['First', 'Second'],
  };
  for (final slot in [2.4, -1, true, 'invalid', '2.4', null]) {
    test('question parser rejects invalid slot $slot', () {
      expect(
        () => QuestionX.fromJson(questionJson(slot)),
        throwsA(isA<ErrorX>()),
      );
    });
  }
  for (final slot in [0, 2, '0', '2']) {
    test('question parser preserves integer slot $slot', () {
      expect(
        QuestionX.fromJson(questionJson(slot)).slot,
        int.parse(slot.toString()),
      );
    });
  }
}
