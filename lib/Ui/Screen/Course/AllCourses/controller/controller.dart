import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/Model/course/level.dart';
import '../../../../../Data/Model/course/mini_course.dart';

import '../../../../../Data/data.dart';

class AllCoursesController extends GetxController {
  //============================================================================
  // Variables

  RxList<LevelX> levels = RxList<LevelX>([]);
  int _loadGeneration = 0;
  int _navigationGeneration = 0;
  bool _openingCourse = false;
  (int, String)? _ownerKey;

  //============================================================================
  // Functions

  /// Get levels with courses from database
  Future<void> getData() async {
    if (isClosed) return;
    final locale = TranslationX.getLanguageCode;
    final key = (LocalDataX.sessionRevision, locale);
    final generation = ++_loadGeneration;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              generation == _loadGeneration &&
              TranslationX.getLanguageCode == locale,
    );
    if (_ownerKey != key || !lease.hasAuthenticatedIdentity) {
      levels.clear();
      _ownerKey = key;
    }
    if (!lease.hasAuthenticatedIdentity) return;
    List<LevelX> loaded;
    try {
      loaded = await DatabaseX.getLevelsWithCourses();
    } catch (_) {
      if (!lease.isCurrent) return;
      rethrow;
    }
    if (!lease.isCurrent) return;

    /// Check if has any level open for open first course manual
    if (loaded
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
      var index = loaded.indexWhere(
        (element) =>
            element.isCompleted == false &&
            element.courses.map((e) => e.isCompleted == false).isNotEmpty,
      );

      /// If found level index
      if (index != -1) {
        /// Get index of first course close but not completed
        var indexCourse = loaded[index].courses.indexWhere(
          (e) => e.isCompleted == false,
        );

        /// If found course index
        if (indexCourse != -1) {
          /// Open level and course manual
          loaded[index].isOpen = true;
          loaded[index].courses[indexCourse].isOpen = true;
        }
      }
    }
    levels.assignAll(loaded);
  }

  /// Navigate to course details
  Future<void> onCourseTap(MiniCourseX course) async {
    if (isClosed || _openingCourse) return;
    final origin = Get.rawRoute;
    final locale = TranslationX.getLanguageCode;
    final generation = ++_navigationGeneration;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              generation == _navigationGeneration &&
              (origin?.isActive ?? false) &&
              TranslationX.getLanguageCode == locale,
    );
    if (!lease.hasAuthenticatedIdentity || !lease.isCurrent) return;
    _openingCourse = true;
    try {
      await Get.toNamed(RouteNameX.courseDetails, arguments: course.id);
      if (!lease.isCurrent) return;
      await getData();
    } catch (error) {
      if (lease.isCurrent) ToastX.error(message: error);
    } finally {
      _openingCourse = false;
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
