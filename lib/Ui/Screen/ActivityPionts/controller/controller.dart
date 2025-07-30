import 'package:get/get.dart';
import '../../../../Data/Model/activity_point.dart';
import '../../../../Data/data.dart';

class ActivityPiontsController extends GetxController {
  //============================================================================
  // Functions

  /// Get activity points from database
  Future<List<ActivityPointX>> getData() async {
    return await DatabaseX.getActivityPoints();
  }
}
