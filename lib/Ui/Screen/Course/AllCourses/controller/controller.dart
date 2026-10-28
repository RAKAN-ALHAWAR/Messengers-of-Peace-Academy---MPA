import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Core/Service/route_origin.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/Model/course/first_course_unlock.dart';
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
  Future<void> getData({SessionLeaseX? owner}) async {
    if (isClosed || owner?.isCurrent == false) return;
    final locale = TranslationX.getLanguageCode;
    final key = (LocalDataX.sessionRevision, locale);
    final generation = ++_loadGeneration;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              owner?.isCurrent != false &&
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

    // TEMP(backend): the backend should return is_open for the first course.
    openFirstCourseIfNoneOpen(loaded);
    levels.assignAll(loaded);
  }

  /// Navigate to course details
  Future<void> onCourseTap(MiniCourseX course) async {
    if (isClosed || _openingCourse) return;
    final origin = RouteOriginX.capture();
    final locale = TranslationX.getLanguageCode;
    final generation = ++_navigationGeneration;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              generation == _navigationGeneration &&
              origin.isActive &&
              TranslationX.getLanguageCode == locale,
    );
    if (!lease.hasAuthenticatedIdentity || !lease.isCurrent) return;
    _openingCourse = true;
    try {
      await Get.toNamed(RouteNameX.courseDetails, arguments: course.id);
      if (!lease.isCurrent) return;
      await getData(owner: lease);
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
