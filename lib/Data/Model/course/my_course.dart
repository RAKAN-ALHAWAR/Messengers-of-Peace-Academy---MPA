import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class MyCourse {
  final String id;
  final String fullName;
  final String lang;
  final String image;
  final int totalSections;
  final int completedSections;
  final int completionPercent;
  final bool enrolled;

  MyCourse({
    required this.id,
    required this.fullName,
    required this.lang,
    required this.image,
    required this.totalSections,
    required this.completedSections,
    required this.completionPercent,
    required this.enrolled,
  });

  factory MyCourse.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => MyCourse(
        id: json[NameX.courseid].toStrX,
        fullName: json[NameX.fullName].toStrX,
        lang: json[NameX.lang].toStrDefaultX('en'),
        image: json[NameX.image].toStrDefaultX(''),
        totalSections: json[NameX.totalSections].toIntX,
        completedSections: json[NameX.completedSections].toIntX,
        completionPercent: json[NameX.completionPercent].toIntX,
        enrolled: json[NameX.enrolled].toBoolX,
      ),
      requiredDataKeys: [
        NameX.courseid,
        NameX.fullName,
        NameX.totalSections,
        NameX.completedSections,
        NameX.completionPercent,
        NameX.enrolled,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.courseid: id,
      NameX.fullName: fullName,
      NameX.lang: lang,
      NameX.image: image,
      NameX.totalSections: totalSections,
      NameX.completedSections: completedSections,
      NameX.completionPercent: completionPercent,
      NameX.enrolled: enrolled,
    };
  }
}
