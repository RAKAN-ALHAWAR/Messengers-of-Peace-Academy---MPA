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

  /// Get activity count name
  String get getActivityCountName {
    int totalActivities = course.value?.activities.length ?? 0;
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
    if (course.value!.activities[index].isOpen) {
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

        // إذا لم يكن الفيديو مكتمل وتمت مشاهدته أكثر من ٣٠ ثانية، يتم تحديث قاعدة البيانات
        if (!course.value!.activities[index].isCompleted &&
            watchDuration.inSeconds >= 30) {
          try {
            await DatabaseX.completeVideoOfCourse(
              cmId: course.value!.activities[index].cmId,
            );
          } catch (_) {}
          course.value!.activities[index].isCompleted = true;
        }
      }
    }
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
