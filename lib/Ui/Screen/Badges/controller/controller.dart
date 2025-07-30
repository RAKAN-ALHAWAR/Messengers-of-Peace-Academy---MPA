import 'package:get/get.dart';
import '../../../../Data/Model/badge.dart';
import '../../../../Data/data.dart';

class BadgesController extends GetxController {
  //============================================================================
  // Functions

  /// Get badges from database
  Future<List<BadgeX>> getData() async {
    return await DatabaseX.getBadges();
  }
}
