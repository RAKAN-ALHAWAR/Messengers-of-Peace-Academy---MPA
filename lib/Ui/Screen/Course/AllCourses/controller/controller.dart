import 'package:messengersofpeace/Core/Service/controller_lease.dart';
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

  /// Levels with their courses
  RxList<LevelX> levels = RxList<LevelX>([]);

  /// The newest load wins
  int _loadGeneration = 0;

  /// The newest course tap wins
  int _navigationGeneration = 0;

  /// A course page is open, ignore taps
  bool _openingCourse = false;

  /// Account and language of the levels now shown
  (int, String)? _ownerKey;

  //============================================================================
  // Functions

  /// Get levels with courses from database
  Future<void> getData({SessionLeaseX? owner}) async {
    if (isClosed || owner?.isCurrent == false) return;
    final locale = TranslationX.getLanguageCode;
    final key = (LocalDataX.sessionRevision, locale);
    final generation = ++_loadGeneration;
    final lease = ControllerLeaseX.capture(
      this,
      owner: owner,
      locale: true,
      also: () => generation == _loadGeneration,
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
    final generation = ++_navigationGeneration;
    final lease = ControllerLeaseX.capture(
      this,
      origin: origin,
      locale: true,
      also: () => generation == _navigationGeneration,
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
