import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class QuestionX {
  final int slot;
  final int id;
  final int number;
  final String text;
  final List<String> answers;

  QuestionX({
    required this.slot,
    required this.id,
    required this.number,
    required this.text,
    required this.answers,
  });

  factory QuestionX.fromJson(Map<String, dynamic> json) {
    List<String> answers = List<String>.from(json[NameX.answers] ?? []);
    return ModelUtilX.checkFromJson(
      json,
      (json) => QuestionX(
        slot: json[NameX.slot].toIntX,
        id: json[NameX.questionId].toIntX,
        number: json[NameX.questionNumber].toIntX,
        text: json[NameX.questionText].toStrX,
        answers: answers,
      ),
      requiredDataKeys: [
        NameX.slot,
        NameX.questionId,
        NameX.questionNumber,
        NameX.questionText,
        NameX.answers,
      ],
    );
  }
}
