import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Core/Service/download_file_form_url.dart';
import '../../../../../Core/core.dart';
import '../../../../../Data/Model/course/activity.dart';
import '../../../../../Data/Model/course/course.dart';
import '../../../../../Data/data.dart';

class CourseDetailsController extends GetxController {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  bool isLoading = false;
  String courseId = Get.arguments;
  Rx<CourseX?> course = Rx<CourseX?>(null);

  //============================================================================
  // Functions

  /// Get course data from database
  Future<void> getData() async {
    course = (await DatabaseX.getCourse(courseId: courseId)).obs;
  }

  /// Get total lessons count across all topics
  /// Rules:
  /// - If there are videos in a topic, count the number of videos
  /// - If no videos but there are files (downloadUrl) in a topic, count as 1 lesson
  /// - Quizzes are never counted
  int get getUniqueTopicsCount {
    if (course.value == null) return 0;

    // Group activities by topicId
    final Map<int, List<ActivityX>> groupedByTopic = {};
    for (var activity in course.value!.activities) {
      if (!groupedByTopic.containsKey(activity.topicId)) {
        groupedByTopic[activity.topicId] = [];
      }
      groupedByTopic[activity.topicId]!.add(activity);
    }

    int totalLessons = 0;

    // Count lessons for each topic
    for (var topicActivities in groupedByTopic.values) {
      // Count videos (excluding quizzes)
      final videoCount =
          topicActivities
              .where(
                (activity) =>
                    activity.videoUrl.isNotEmpty && activity.quizId == null,
              )
              .length;

      if (videoCount > 0) {
        // If there are videos, count them
        totalLessons += videoCount;
      }
    }

    return totalLessons;
  }

  /// Get activity count name
  String get getActivityCountName {
    int totalActivities = getUniqueTopicsCount;
    switch (totalActivities) {
      case 0:
        return "No Lesson";
      case 1:
        return "One Lesson";
      case 2:
        return "Two Lessons";
      default:
        return "$totalActivities ${"Lessons".tr}";
    }
  }

  /// Navigate to lesson video
  Future<void> onTapLessonVideo(int index) async {
    // if (course.value!.activities[index].isOpen) {
    if (course.value!.activities[index].videoUrl.isEmpty) {
      ToastX.error(message: "Video is not available");
    } else {
      // إضافة مؤقت لحساب مدة مشاهدة الفيديو
      final DateTime startTime = DateTime.now();

      await Get.toNamed(
        RouteNameX.videoPlayer,
        arguments: course.value!.activities[index].videoUrl,
      );

      // إعادة تعيين اتجاه الشاشة للوضع الرأسي بعد إغلاق الفيديو
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // حساب مدة المشاهدة
      final Duration watchDuration = DateTime.now().difference(startTime);

      // إذا لم يكن الفيديو مكتمل وتمت مشاهدته أكثر من 5 ثواني، يتم تحديث قاعدة البيانات
      if (!course.value!.activities[index].isCompleted &&
          watchDuration.inSeconds >= 5) {
        try {
          await DatabaseX.completeVideoOfCourse(
            cmId: course.value!.activities[index].cmId,
          );
        } catch (_) {}
        course.value!.activities[index].isCompleted = true;
      }
    }
    // }
  }

  /// Navigate to lesson quiz
  void onTapLessonQuiz(ActivityX activity) {
    if (activity.isOpen) {
      Get.toNamed(RouteNameX.testInfo, arguments: [activity.quizId, courseId]);
    }
  }

  /// Download lesson summary
  Future<void> onTapLessonSummary(ActivityX activity) async {
    if (isLoading) return;

    /// Download lesson summary
    try {
      isLoading = true;
      await DownloadFileFormUrl.download(
        activity.downloadUrl,
        "${course.value?.name}_${activity.name}",
      );
    } catch (_) {}
    isLoading = false;
  }
}
