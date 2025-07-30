import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

import 'activity.dart';

class CourseX {
  final String id;
  final String name;
  final String levelId;
  final String levelName;
  final double completionPercent;
  final int numCompletionActivities;
  final String image;
  final List<ActivityX> activities;

  CourseX({
    required this.id,
    required this.name,
    required this.levelId,
    required this.levelName,
    required this.completionPercent,
    required this.numCompletionActivities,
    required this.image,
    required this.activities,
  });

  factory CourseX.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> activitiesJson = List<Map<String, dynamic>>.from(
      json[NameX.activities] ?? [],
    );
    return ModelUtilX.checkFromJson(
      json,
      (json) => CourseX(
        id: json[NameX.courseId].toStrX,
        name: json[NameX.courseName].toStrX,
        levelId: json[NameX.levelId].toStrX,
        levelName: json[NameX.levelName].toStrX,
        completionPercent: json[NameX.completionPercent].toDoubleX,
        image: json[NameX.courseImage].toStrDefaultX(""),
        numCompletionActivities: json[NameX.completedTopicsTotal].toIntX,
        activities: ModelUtilX.generateItems(
          activitiesJson,
          ActivityX.fromJson,
        ),
      ),
      requiredDataKeys: [
        NameX.courseId,
        NameX.courseName,
        NameX.levelId,
        NameX.levelName,
        NameX.completionPercent,
        NameX.activities,
        NameX.completedTopicsTotal,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.courseId: id,
      NameX.courseName: name,
      NameX.levelId: levelId,
      NameX.levelName: levelName,
      NameX.completionPercent: completionPercent,
      NameX.courseImage: image,
      NameX.activities: activities.map((e) => e.toJson()).toList(),
      NameX.completedTopicsTotal: numCompletionActivities,
    };
  }
}
