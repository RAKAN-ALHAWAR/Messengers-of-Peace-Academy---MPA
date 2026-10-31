import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class ActivityX {
  final int topicId;
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
  final String? quizId;

  /// TEMP(backend): the server never marks a file (resource) activity as
  /// completed, so the course page sets this after the user downloaded the
  /// file. Remove it once the server sends is_completed for files.
  bool isFileDownloaded = false;

  /// TEMP(backend): the server sends video_duration "0:00", so the course page
  /// sets the real length (seconds) the video player learned. Remove it once
  /// the server sends the real duration.
  int localDurationSeconds = 0;

  ActivityX({
    required this.topicId,
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

  /// Whether the activity has anything to open (a video, a quiz or a file)
  bool get hasContent =>
      videoUrl.isNotEmpty || quizId != null || downloadUrl.isNotEmpty;

  /// The server state of the video and quiz rows: is_completed or 100 percent.
  /// A downloaded file never counts here, one activity can feed a video, a
  /// quiz and a file row.
  bool get isServerDone => isCompleted || completionPercent >= 100;

  /// The state of the file row only: the local TEMP(backend) flag of a
  /// downloaded file. A file only activity also follows the server flags, in
  /// case the server starts to send is_completed for files.
  bool get isFileDone =>
      isFileDownloaded || (!_hasVideoOrQuiz && isServerDone);

  bool get _hasVideoOrQuiz => videoUrl.isNotEmpty || quizId != null;

  /// Whether the activity is done for the lesson counter: the server state,
  /// and for a file only activity the downloaded flag as well. A file next to
  /// a video or quiz never decides it.
  bool get isDone => _hasVideoOrQuiz ? isServerDone : isFileDone;

  /// The percent the section ring counts for this activity: the server percent
  /// of its video or quiz, and for a file only activity 100 once downloaded
  /// (the server never sends a percent for a file).
  double get progressPercent =>
      !_hasVideoOrQuiz && isFileDownloaded ? 100 : completionPercent;

  /// The section ring percent: the average of [progressPercent] over the
  /// section's activities, 0 for an empty section
  static double topicPercent(List<ActivityX> activities) {
    if (activities.isEmpty) return 0;
    final sum = activities.fold<double>(0, (s, a) => s + a.progressPercent);
    return sum / activities.length;
  }

  /// The duration text for the lesson row, or null when there is nothing to
  /// show. A real server value wins; the server sends "0:00" for every video
  /// today, then the length the player learned is shown.
  String? get durationText {
    final server = videoDuration.trim();
    if (server.replaceAll(RegExp(r'[0:\s]'), '').isNotEmpty) return server;
    if (localDurationSeconds <= 0) return null;
    final time = Duration(seconds: localDurationSeconds);
    final seconds = (time.inSeconds % 60).toString().padLeft(2, '0');
    if (time.inHours == 0) return '${time.inMinutes}:$seconds';
    final minutes = (time.inMinutes % 60).toString().padLeft(2, '0');
    return '${time.inHours}:$minutes:$seconds';
  }

  factory ActivityX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => ActivityX(
        topicId: json[NameX.topicId].toIntX,
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
        quizId: json[NameX.quizId].toStrNullableX,
      ),
      requiredDataKeys: [
        NameX.topicId,
        NameX.activityName,
        NameX.completionPercent,
        NameX.isOpen,
        NameX.isCompleted,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.topicId: topicId,
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
