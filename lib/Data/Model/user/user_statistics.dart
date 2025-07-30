import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class UserStatisticsX {
  final String completedCourses;
  final String minutes;
  final String points;
  final String certificates;
  final String quizzes;

  UserStatisticsX({
    required this.completedCourses,
    required this.minutes,
    required this.points,
    required this.certificates,
    required this.quizzes,
  });

  factory UserStatisticsX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => UserStatisticsX(
        completedCourses: json[NameX.completedCourses].toStrX,
        minutes: json[NameX.minutes].toStrX,
        points: json[NameX.points].toStrX,
        certificates: json[NameX.certificates].toStrX,
        quizzes: json[NameX.quizzes].toStrX,
      ),
      requiredDataKeys: [
        NameX.completedCourses,
        NameX.minutes,
        NameX.points,
        NameX.certificates,
        NameX.quizzes,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.completedCourses: completedCourses,
      NameX.minutes: minutes,
      NameX.points: points,
      NameX.certificates: certificates,
      NameX.quizzes: quizzes,
    };
  }
}
