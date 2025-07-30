import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class BadgeX {
  final String id;
  final String name;
  final int requiredPoints;
  final String description;
  final bool earned;

  BadgeX({
    required this.id,
    required this.name,
    required this.requiredPoints,
    required this.description,
    required this.earned,
  });

  factory BadgeX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => BadgeX(
        id: json[NameX.id].toStrX,
        name: json[NameX.badgeName].toStrX,
        requiredPoints: json[NameX.requiredPoints].toIntX,
        description: json[NameX.description].toStrX,
        earned: json[NameX.earned].toBoolX,
      ),
      requiredDataKeys: [NameX.id],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.id: id,
      NameX.badgeName: name,
      NameX.requiredPoints: requiredPoints,
      NameX.description: description,
      NameX.earned: earned,
    };
  }
}
