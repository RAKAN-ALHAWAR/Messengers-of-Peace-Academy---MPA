import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Config/config.dart';
import '../../../../../Config/Translation/translation.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Data/Model/course/my_course.dart';
import '../../../../../Data/data.dart';

class MyCoursesController extends GetxController {
  //============================================================================
  // Variables

  /// My courses
  final RxList<MyCourse> myCourses = <MyCourse>[].obs;

  //============================================================================
  // Functions

  /// Get data from database
  int _loadGeneration = 0;
  bool _openingCourse = false;
  Future<void> getData() async {
    if (isClosed) return;
    final generation = ++_loadGeneration;
    final locale = TranslationX.getLanguageCode;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              generation == _loadGeneration &&
              TranslationX.getLanguageCode == locale,
    );
    if (!lease.hasAuthenticatedIdentity) {
      throw ErrorX.createErrorByCode(ErrorCodesX.unauthorized);
    }
    if (!lease.isCurrent) return;
    try {
      final loaded = await DatabaseX.getMyCourses();
      if (lease.isCurrent) myCourses.value = loaded;
    } catch (_) {
      if (lease.isCurrent) rethrow;
    }
  }

  /// On tap course
  Future<void> onTapCourse(MyCourse course) async {
    if (_openingCourse || isClosed) return;
    final origin = Get.rawRoute;
    final locale = TranslationX.getLanguageCode;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              Get.isRegistered<MyCoursesController>() &&
              identical(Get.find<MyCoursesController>(), this) &&
              TranslationX.getLanguageCode == locale,
    );
    if (!lease.hasAuthenticatedIdentity) return;
    _openingCourse = true;
    try {
      await Get.toNamed(RouteNameX.courseDetails, arguments: course.id);
      if (lease.isCurrent && origin?.isActive == true) await getData();
    } catch (error) {
      if (lease.isCurrent) ToastX.error(message: error);
    } finally {
      if (!isClosed) _openingCourse = false;
    }
  }
}
