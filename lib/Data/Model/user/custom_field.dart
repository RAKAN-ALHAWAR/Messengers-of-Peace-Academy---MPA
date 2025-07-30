import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import '../../../Core/Helper/model/model.dart';
import '../../data.dart';

// نموذج للحقول المخصصة
class CustomField {
  CustomField({required this.name, required this.value});

  String name;
  String value;

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(json, (json) {
      return CustomField(
        name: json[NameX.name].toStrDefaultX(''),
        value: json[NameX.value].toStrDefaultX(''),
      );
    }, requiredDataKeys: [NameX.name, NameX.value]);
  }

  Map<String, dynamic> toJson() {
    return {NameX.name: name, NameX.value: value};
  }
}
