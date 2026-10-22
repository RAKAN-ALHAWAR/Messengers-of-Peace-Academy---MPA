import 'package:messengersofpeace/Core/Service/session_lease.dart';
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
  int _loadGeneration = 0;
  (int, String)? _ownerKey;

  //============================================================================
  // Functions

  /// Get data from the database
  Future<void> getData() async {
    if (isClosed) return;
    final locale = TranslationX.getLanguageCode;
    final ownerId = LocalDataX.userid;
    final key = (LocalDataX.sessionRevision, locale);
    final generation = ++_loadGeneration;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              generation == _loadGeneration &&
              TranslationX.getLanguageCode == locale &&
              Get.isRegistered<AppControllerX>() &&
              identical(Get.find<AppControllerX>(), app) &&
              app.user.value.id == ownerId,
    );
    if (_ownerKey != key || !lease.hasAuthenticatedIdentity) {
      _clearSnapshot();
      _ownerKey = key;
    }
    if (!lease.hasAuthenticatedIdentity || !lease.isCurrent) {
      _clearSnapshot();
      return;
    }
    try {
      final loadedBadges = await DatabaseX.getBadges();
      if (!lease.isCurrent) return;
      final loadedPoints = await DatabaseX.getMyActivityPoints();
      if (!lease.isCurrent) return;
      // Preserve the existing selector and publish one coherent owned snapshot.
      final selectedBadge =
          loadedBadges.isEmpty
              ? null
              : loadedBadges.firstWhere(
                (badge) =>
                    badge.requiredPoints > app.user.value.points &&
                    !badge.earned,
                orElse: () => loadedBadges.last,
              );
      badges = loadedBadges;
      myActivityPoints = loadedPoints;
      currentBadge = selectedBadge;
    } catch (_) {
      // The retained FutureBuilder surfaces current failures. Retired loads
      // cannot write state or start another protected request.
      if (!lease.isCurrent) return;
      rethrow;
    }
  }

  void _clearSnapshot() {
    badges = [];
    myActivityPoints = [];
    currentBadge = null;
  }

  /// Group activity points by month
  Map<String, List<MyActivityPointX>> groupActivityPointsByMonth() {
    /// Sort activity points by date
    final sortedPoints = [...myActivityPoints]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    /// Group activity points by month
    Map<String, List<MyActivityPointX>> grouped = {};

    for (var point in sortedPoints) {
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
