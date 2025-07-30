import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Config/config.dart';

import '../../../../../Config/Translation/translation.dart';
import '../../../../../Core/core.dart';
import '../../../../../Data/Model/badge.dart';
import '../../../../../Data/Model/my_activity_point.dart';
import '../../../../../Data/data.dart';

class MyAchievementsController extends GetxController {
  //============================================================================
  // Injection of required controls

  final AppControllerX app = Get.find();

  //============================================================================
  // Variables

  /// Current badge
  BadgeX? currentBadge;

  /// All badges
  List<BadgeX> badges = [];

  /// My activity points
  List<MyActivityPointX> myActivityPoints = [];

  //============================================================================
  // Functions

  /// Get data from the database
  Future<void> getData() async {
    /// Get all badges from the database
    badges = await DatabaseX.getBadges();

    /// Get my activity points from the database
    myActivityPoints = await DatabaseX.getMyActivityPoints();

    /// Get the current badge
    if (badges.isNotEmpty) {
      currentBadge = badges.firstWhere(
        (badge) =>
            badge.requiredPoints > app.user.value.points &&
            badge.earned == false,
        orElse: () => badges.last,
      );
    }
  }

  /// Group activity points by month
  Map<String, List<MyActivityPointX>> groupActivityPointsByMonth() {
    /// Sort activity points by date
    myActivityPoints.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    /// Group activity points by month
    Map<String, List<MyActivityPointX>> grouped = {};

    for (var point in myActivityPoints) {
      final month = DateFormat.MMMM(
        TranslationX.getLanguageCode,
      ).format(point.dateTime);
      final year = point.dateTime.year;
      final now = DateTime.now();

      /// If the year is the same as the current year, show only the month
      /// If the year is different, show "month - year"
      final key = (year == now.year) ? month : '$month - $year';

      /// If the key is not in the grouped map, add it
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      /// Add the point to the grouped map
      grouped[key]!.add(point);
    }

    /// Return the grouped map
    return grouped;
  }

  /// Navigate to all badges screen
  void onAllBadges() => Get.toNamed(RouteNameX.badges);

  /// Navigate to all activity points screen
  void onAllActivityPoints() => Get.toNamed(RouteNameX.activityPoints);

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Initialize date format
    initializeDateFormatting(TranslationX.getLanguageCode, null);
  }
}
