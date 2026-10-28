import 'package:messengersofpeace/Core/Error/error.dart';
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

  /// TEMP(backend): the server minutes stay 0, so the app counts the time spent
  /// on lesson videos on the device (per user). The backend must send the real
  /// learning minutes in get_user_statistics; this local total is removed once
  /// it does.
  static int get localLearnedSeconds =>
      LocalDataX.get<int>(LocalKeyX.learnedSeconds, defaultData: 0);

  static Future<void> addLocalLearnedSeconds(int seconds) async {
    if (seconds <= 0) return;
    try {
      await LocalDataX.put<int>(
        LocalKeyX.learnedSeconds,
        localLearnedSeconds + seconds,
      );
    } catch (e) {
      // Only a statistic, never break the lesson flow for it
      ErrorX.console(e);
    }
  }

  /// The server minutes when above zero, else the local total in whole minutes
  String minutesShown(int localSeconds) {
    if ((int.tryParse(minutes) ?? 0) > 0) return minutes;
    return (localSeconds ~/ 60).toString();
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
