import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class MiniCourseX {
  final String id;
  final String name;
  final String image;
  final int numSections;
  final int numCompletionSections;
  final double completionPercent;
  bool isOpen;
  final bool isCompleted;

  MiniCourseX({
    required this.id,
    required this.name,
    required this.image,
    required this.numSections,
    required this.completionPercent,
    required this.isOpen,
    required this.isCompleted,
    required this.numCompletionSections,
  });

  factory MiniCourseX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => MiniCourseX(
        id: json[NameX.courseId].toStrX,
        name: json[NameX.courseName].toStrX,
        image: json[NameX.image].toStrDefaultX(""),
        numSections: json[NameX.numSections].toIntX,
        completionPercent: json[NameX.completionPercent].toDoubleX,
        isOpen: json[NameX.isOpen].toBoolX,
        isCompleted: json[NameX.isCompleted].toBoolX,
        numCompletionSections: json[NameX.completedTopicsTotal].toIntX,
      ),
      requiredDataKeys: [
        NameX.courseId,
        NameX.courseName,
        NameX.numSections,
        NameX.completionPercent,
        NameX.isOpen,
        NameX.isCompleted,
        NameX.completedTopicsTotal,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.courseId: id,
      NameX.courseName: name,
      NameX.image: image,
      NameX.numSections: numSections,
      NameX.completionPercent: completionPercent,
      NameX.isOpen: isOpen,
      NameX.isCompleted: isCompleted,
      NameX.completedTopicsTotal: numCompletionSections,
    };
  }
}
