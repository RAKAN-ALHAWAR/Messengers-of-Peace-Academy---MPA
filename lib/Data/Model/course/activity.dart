import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class ActivityX {
  final String name;
  final String topicName;
  final int activityNumber;
  final double completionPercent;
  final bool isOpen;
  bool isCompleted;
  // bool isVideoCompleted;
  final String videoUrl;
  final String videoDuration;
  final String downloadUrl;
  final String cmId;
  final String quizId;

  ActivityX({
    required this.name,
    required this.topicName,
    required this.activityNumber,
    required this.completionPercent,
    required this.isOpen,
    required this.isCompleted,
    // required this.isVideoCompleted,
    required this.videoUrl,
    required this.videoDuration,
    required this.downloadUrl,
    required this.cmId,
    required this.quizId,
  });

  factory ActivityX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => ActivityX(
        name: json[NameX.activityName].toStrX,
        topicName: json[NameX.topicName].toStrDefaultX(""),
        activityNumber: json[NameX.activityNumber].toIntDefaultX(1),
        completionPercent: json[NameX.completionPercent].toDoubleX,
        isOpen: json[NameX.isOpen].toBoolX,
        isCompleted: json[NameX.isCompleted].toBoolX,
        // isVideoCompleted: json[NameX.isVideoCompleted].toBoolDefaultX(false),
        videoUrl: json[NameX.videoUrl].toStrDefaultX(""),
        videoDuration: json[NameX.videoDuration].toStrDefaultX(""),
        downloadUrl: json[NameX.downloadUrl].toStrDefaultX(""),
        cmId: json[NameX.cmId].toStrX,
        quizId: json[NameX.quizId].toStrX,
      ),
      requiredDataKeys: [
        NameX.activityName,
        NameX.completionPercent,
        NameX.isOpen,
        NameX.isCompleted,
        NameX.quizId,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.activityName: name,
      NameX.topicName: topicName,
      NameX.activityNumber: activityNumber,
      NameX.completionPercent: completionPercent,
      NameX.isOpen: isOpen,
      NameX.isCompleted: isCompleted,
      NameX.videoUrl: videoUrl,
      NameX.videoDuration: videoDuration,
      NameX.downloadUrl: downloadUrl,
      NameX.cmId: cmId,
      NameX.quizId: quizId,
    };
  }
}
