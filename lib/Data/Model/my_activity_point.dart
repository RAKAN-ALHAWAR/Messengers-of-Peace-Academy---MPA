import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class MyActivityPointX {
  final String id;
  final String activityName;
  final int points;
  final DateTime dateTime;

  MyActivityPointX({
    required this.id,
    required this.activityName,
    required this.points,
    required this.dateTime,
  });

  factory MyActivityPointX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => MyActivityPointX(
        id: json[NameX.id].toStrX,
        activityName: json[NameX.myActivityName].toStrX,
        points: json[NameX.points].toIntX,
        dateTime: json[NameX.dateTime].toDateTimeX,
      ),
      requiredDataKeys: [NameX.id],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.id: id,
      NameX.activityName: activityName,
      NameX.points: points,
      NameX.dateTime: dateTime,
    };
  }
}
