import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

import 'mini_course.dart';

class LevelX {
  final String id;
  final String name;
  final int totalCourses;
  final int completedCourses;
  final double completionPercent;
  bool isOpen;
  final bool isCompleted;
  final List<MiniCourseX> courses;

  LevelX({
    required this.id,
    required this.name,
    required this.totalCourses,
    required this.completedCourses,
    required this.completionPercent,
    required this.isOpen,
    required this.isCompleted,
    required this.courses,
  });

  factory LevelX.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> coursesJson = List<Map<String, dynamic>>.from(
      json[NameX.courses] ?? [],
    );
    return ModelUtilX.checkFromJson(
      json,
      (json) => LevelX(
        id: json[NameX.levelId].toStrX,
        name: json[NameX.levelName].toStrX,
        totalCourses: json[NameX.totalCourses].toIntX,
        completedCourses: json[NameX.completedCourses].toIntX,
        completionPercent: json[NameX.completionPercent].toDoubleX,
        isOpen: json[NameX.isOpen].toBoolX,
        isCompleted: json[NameX.isCompleted].toBoolX,
        courses: ModelUtilX.generateItems(coursesJson, MiniCourseX.fromJson),
      ),
      requiredDataKeys: [
        NameX.levelId,
        NameX.levelName,
        NameX.totalCourses,
        NameX.completedCourses,
        NameX.completionPercent,
        NameX.isOpen,
        NameX.isCompleted,
        NameX.courses,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.levelId: id,
      NameX.levelName: name,
      NameX.totalCourses: totalCourses,
      NameX.completedCourses: completedCourses,
      NameX.completionPercent: completionPercent,
      NameX.isOpen: isOpen,
      NameX.isCompleted: isCompleted,
      NameX.courses: courses.map((e) => e.toJson()).toList(),
    };
  }
}
