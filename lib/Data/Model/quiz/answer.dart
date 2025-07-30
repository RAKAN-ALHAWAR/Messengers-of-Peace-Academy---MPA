import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class AnswerX {
  final int slot;
  final String questionName;
  final bool right;
  final String? responseSummary;
  final int? selectedAnswerIndex;
  AnswerX({
    required this.questionName,
    required this.slot,
    required this.right,
    required this.responseSummary,
    required this.selectedAnswerIndex,
  });

  factory AnswerX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => AnswerX(
        slot: json[NameX.slot].toIntX,
        questionName: json[NameX.questionName].toStrX,
        right: json[NameX.right].toBoolX,
        responseSummary: json[NameX.responseSummary].toStrNullableX,
        selectedAnswerIndex: json[NameX.selectedAnswerIndex].toIntX,
      ),
      requiredDataKeys: [NameX.questionName, NameX.right],
    );
  }
}
