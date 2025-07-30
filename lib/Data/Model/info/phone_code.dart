import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';

import '../../data.dart';

class PhoneCode {
  final String code;
  final String name;
  final String dialCode;

  PhoneCode({required this.code, required this.name, required this.dialCode});

  factory PhoneCode.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => PhoneCode(
        code: json[NameX.code].toStrX,
        name: json[NameX.name].toStrX,
        dialCode: json[NameX.dialCode].toStrX,
      ),
      requiredDataKeys: [NameX.code, NameX.name, NameX.dialCode],
    );
  }

  Map<String, dynamic> toJson() {
    return {NameX.code: code, NameX.name: name, NameX.dialCode: dialCode};
  }
}
