import 'package:get/get.dart';

import '../../../../../Config/config.dart';
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
  Future<void> getData() async {
    myCourses.value = await DatabaseX.getMyCourses();
  }

  /// On tap course
  void onTapCourse(MyCourse course) {
    Get.toNamed(RouteNameX.courseDetails, arguments: course.id);
  }
}
