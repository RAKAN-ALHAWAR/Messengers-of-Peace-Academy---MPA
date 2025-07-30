import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class MeetingX {
  final String id;
  final String courseId;
  final String name;
  final String description;
  final String lecturer;
  final DateTime datetime;
  final String day;
  final String date;
  final String timeRange;
  final String type;
  final String location;
  final String url;
  final String status;

  bool get isEnded => datetime.isBefore(DateTime.now());

  MeetingX({
    required this.id,
    required this.courseId,
    required this.name,
    required this.description,
    required this.lecturer,
    required this.datetime,
    required this.day,
    required this.date,
    required this.timeRange,
    required this.type,
    required this.location,
    required this.url,
    required this.status,
  });

  factory MeetingX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => MeetingX(
        id: json[NameX.id].toStrX,
        courseId: json[NameX.courseId].toStrX,
        name: json[NameX.name].toStrX,
        description: json[NameX.description].toStrX,
        lecturer: json[NameX.lecturer].toStrX,
        datetime: DateTime.fromMillisecondsSinceEpoch(
          json[NameX.datetime].toIntX * 1000,
        ),
        day: json[NameX.day].toStrX,
        date: json[NameX.date].toStrX,
        timeRange: json[NameX.timeRange].toStrX,
        type: json[NameX.type].toStrX,
        location: json[NameX.location].toStrX,
        url: json[NameX.url].toStrX,
        status: json[NameX.status].toStrX,
      ),
      requiredDataKeys: [NameX.id],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.id: id,
      NameX.courseId: courseId,
      NameX.name: name,
      NameX.description: description,
      NameX.lecturer: lecturer,
      NameX.dateTime: datetime.millisecondsSinceEpoch ~/ 1000,
      NameX.day: day,
      NameX.date: date,
      NameX.timeRange: timeRange,
      NameX.type: type,
      NameX.location: location,
      NameX.url: url,
      NameX.status: status,
    };
  }
}
