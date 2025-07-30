import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class NotificationX {
  final String id;
  final String eventtype;
  final String subject;
  final String fullmessage;
  final String timecreated;
  bool read;

  NotificationX({
    required this.id,
    required this.eventtype,
    required this.subject,
    required this.fullmessage,
    required this.timecreated,
    required this.read,
  });

  factory NotificationX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => NotificationX(
        id: json[NameX.id].toStrX,
        eventtype: json[NameX.eventType].toStrDefaultX(""),
        subject: json[NameX.subject].toStrX,
        fullmessage: json[NameX.fullMessage].toStrDefaultX(""),
        timecreated: json[NameX.timeCreated].toStrX,
        read: json[NameX.read].toBoolDefaultX(false),
      ),
      requiredDataKeys: [NameX.id, NameX.subject, NameX.timeCreated],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.id: id,
      NameX.eventType: eventtype,
      NameX.subject: subject,
      NameX.fullMessage: fullmessage,
      NameX.timeCreated: timecreated,
      NameX.read: read,
    };
  }
}
