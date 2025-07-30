import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';

import '../../data.dart';

class Country {
  final String code;
  final String name;

  Country({required this.code, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) =>
          Country(code: json[NameX.code].toStrX, name: json[NameX.name].toStrX),
      requiredDataKeys: [NameX.code, NameX.name],
    );
  }

  Map<String, dynamic> toJson() {
    return {NameX.code: code, NameX.name: name};
  }
}
