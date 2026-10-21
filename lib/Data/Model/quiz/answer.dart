import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class AnswerX {
  final int slot;
  final String questionName;
  final bool? right;
  final String? responseSummary;
  final int? selectedAnswerIndex;
  final bool hasSelectionDetails;
  AnswerX({
    required this.questionName,
    required this.slot,
    required this.right,
    required this.responseSummary,
    required this.selectedAnswerIndex,
    this.hasSelectionDetails = true,
  });

  factory AnswerX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => AnswerX(
        slot:
            _selectedIndex(json[NameX.slot]) ??
            (throw const FormatException('Invalid answer slot')),
        questionName: json[NameX.questionName].toStrX,
        right: json[NameX.right].toBoolNullableX,
        responseSummary: json[NameX.responseSummary].toStrNullableX,
        selectedAnswerIndex: _selectedIndex(json[NameX.selectedAnswerIndex]),
        hasSelectionDetails:
            json.containsKey(NameX.selectedAnswerIndex) &&
            (json[NameX.selectedAnswerIndex] == null ||
                _selectedIndex(json[NameX.selectedAnswerIndex]) != null),
      ),
      requiredDataKeys: [NameX.slot, NameX.questionName],
    );
  }

  static int? _selectedIndex(Object? value) {
    final parsed =
        value is int
            ? value
            : value is String
            ? int.tryParse(value.trim())
            : null;
    return parsed != null && parsed >= 0 ? parsed : null;
  }
}
