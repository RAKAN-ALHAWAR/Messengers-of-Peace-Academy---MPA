import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class ActivityPointX {
  final String id;
  final String activityName;
  final String note;
  final int points;

  ActivityPointX({
    required this.id,
    required this.activityName,
    required this.note,
    required this.points,
  });

  factory ActivityPointX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => ActivityPointX(
        id: json[NameX.id].toStrX,
        activityName: json[NameX.myActivityName].toStrX,
        note: json[NameX.note].toStrX,
        points: json[NameX.points].toIntX,
      ),
      requiredDataKeys: [NameX.id],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.id: id,
      NameX.activityName: activityName,
      NameX.note: note,
      NameX.points: points,
    };
  }
}
