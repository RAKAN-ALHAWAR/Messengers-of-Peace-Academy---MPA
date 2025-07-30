import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/Model/course/level.dart';
import '../../../../../Data/Model/course/mini_course.dart';

import '../../../../../Data/data.dart';

class AllCoursesController extends GetxController {
  //============================================================================
  // Variables

  RxList<LevelX> levels = RxList<LevelX>([]);

  //============================================================================
  // Functions

  /// Get levels with courses from database
  Future<void> getData() async {
    levels.value = await DatabaseX.getLevelsWithCourses();

    /// Check if has any level open for open first course manual
    if (levels
        .map(
          (element) =>
              element.isOpen &&
              element.isCompleted == false &&
              element.courses
                  .map((e) => e.isOpen && e.isCompleted == false)
                  .isNotEmpty,
        )
        .isEmpty) {
      /// Get index of first level has course close but not completed
      var index = levels.indexWhere(
        (element) =>
            element.isCompleted == false &&
            element.courses.map((e) => e.isCompleted == false).isNotEmpty,
      );

      /// If found level index
      if (index != -1) {
        /// Get index of first course close but not completed
        var indexCourse = levels[index].courses.indexWhere(
          (e) => e.isCompleted == false,
        );

        /// If found course index
        if (indexCourse != -1) {
          /// Open level and course manual
          levels[index].isOpen = true;
          levels[index].courses[indexCourse].isOpen = true;
        }
      }
    }
  }

  /// Navigate to course details
  void onCourseTap(MiniCourseX course) {
    if (course.isOpen) {
      Get.toNamed(RouteNameX.courseDetails, arguments: course.id);
    }
  }

  /// Get course count name
  String getCourseCountName(int totalCourses) {
    switch (totalCourses) {
      case 0:
        return "No Course";
      case 1:
        return "One Course";
      case 2:
        return "Two Courses";
      default:
        return "$totalCourses ${"num-courses".tr}";
    }
  }
}
