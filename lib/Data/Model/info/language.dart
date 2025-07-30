import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';

import '../../data.dart';

class Language {
  final String code;
  final String name;

  Language({required this.code, required this.name});

  factory Language.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => Language(
        code: json[NameX.code].toStrX,
        name: json[NameX.name].toStrX,
      ),
      requiredDataKeys: [NameX.code, NameX.name],
    );
  }

  Map<String, dynamic> toJson() {
    return {NameX.code: code, NameX.name: name};
  }
}
