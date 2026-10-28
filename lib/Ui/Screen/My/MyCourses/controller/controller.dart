import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Config/config.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Core/Service/controller_lease.dart';
import '../../../../../Core/Service/route_origin.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Data/Model/course/my_course.dart';
import '../../../../../Data/data.dart';

class MyCoursesController extends GetxController {
  //============================================================================
  // Variables

  /// My courses
  final RxList<MyCourse> myCourses = <MyCourse>[].obs;

  /// The newest load wins
  int _loadGeneration = 0;

  /// A course page is open, ignore taps
  bool _openingCourse = false;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData({SessionLeaseX? owner}) async {
    if (isClosed || owner?.isCurrent == false) return;
    final generation = ++_loadGeneration;
    final lease = ControllerLeaseX.capture(
      this,
      owner: owner,
      locale: true,
      also: () => generation == _loadGeneration,
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
    final origin = RouteOriginX.capture();
    final lease = ControllerLeaseX.capture(
      this,
      origin: origin,
      registered: true,
      locale: true,
    );
    if (!lease.hasAuthenticatedIdentity) return;
    _openingCourse = true;
    try {
      await Get.toNamed(RouteNameX.courseDetails, arguments: course.id);
      if (lease.isCurrent) await getData(owner: lease);
    } catch (error) {
      if (lease.isCurrent) ToastX.error(message: error);
    } finally {
      if (!isClosed) _openingCourse = false;
    }
  }
}
