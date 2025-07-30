import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class EventX {
  final String id;
  final String name;
  final String description;
  final String location;
  final int timeStart;
  final int? timeDuration;
  final int? courseId;
  final int instance;
  final String source;
  final String meetingUrl;
  final bool isNow;
  final bool isRepeated;
  final int repeatCount;
  final int? endTime;
  late DateTime dateTimeStart;
  late DateTime dateTimeEnd;
  final String? userId;

  EventX({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.timeStart,
    required this.timeDuration,
    required this.courseId,
    required this.instance,
    required this.source,
    required this.meetingUrl,
    required this.isNow,
    required this.isRepeated,
    required this.repeatCount,
    required this.endTime,
    required this.userId,
  }) {
    dateTimeStart = DateTime.fromMillisecondsSinceEpoch(timeStart * 1000);
    dateTimeEnd = DateTime.fromMillisecondsSinceEpoch(
      (endTime != null
          ? endTime! * 1000
          : timeStart * 1000 + (timeDuration ?? 0) * 1000),
    );
  }

  bool get isSystem => source != "user";
  int get hour => dateTimeStart.hour;

  factory EventX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => EventX(
        id: json[NameX.id].toStrX,
        name: json[NameX.name].toStrDefaultX(
          json[NameX.title].toStrDefaultX(""),
        ),
        description: json[NameX.description].toStrDefaultX(""),
        location: json[NameX.location].toStrX,
        timeStart: json[NameX.timestart].toIntDefaultX(
          json[NameX.startTime].toIntDefaultX(0),
        ),
        timeDuration: json[NameX.timeduration].toIntNullableX,
        courseId: json[NameX.courseid].toIntNullableX,
        instance: json[NameX.instance].toIntDefaultX(0),
        source: json[NameX.source].toStrX,
        meetingUrl: json[NameX.meetingurl].toStrDefaultX(""),
        isNow: json[NameX.isnow].toBoolX,
        isRepeated: json[NameX.isrepeated].toBoolDefaultX(false),
        repeatCount: json[NameX.repeatCount].toIntDefaultX(0),
        endTime: json[NameX.endTime].toIntNullableX,
        userId: json[NameX.userId].toStrDefaultX(""),
      ),
      requiredDataKeys: [NameX.id],
    );
  }
}
