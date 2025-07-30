import 'package:get/get.dart';

import '../../../../Data/Model/leaderboard.dart';
import '../../../../Data/data.dart';

class LeaderboardController extends GetxController {
  //============================================================================
  // Functions

  /// Get leaderboard data from the database
  Future<List<LeaderboardX>> getData() async {
    return await DatabaseX.getLeaderboard();
  }
}
