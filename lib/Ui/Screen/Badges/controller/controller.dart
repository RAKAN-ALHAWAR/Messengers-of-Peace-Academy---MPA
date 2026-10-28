import 'package:messengersofpeace/Core/Service/controller_lease.dart';
import 'package:get/get.dart';
import '../../../../Core/core.dart';
import '../../../../Data/Model/badge.dart';
import '../../../../Data/data.dart';

class BadgesController extends GetxController {
  //============================================================================
  // Variables

  int _loadGeneration = 0;

  //============================================================================
  // Functions

  /// Get badges from database
  Future<List<BadgeX>> getData() async {
    if (isClosed) return [];
    final generation = ++_loadGeneration;
    final ownerId = LocalDataX.userid;
    final app =
        Get.isRegistered<AppControllerX>() ? Get.find<AppControllerX>() : null;

    /// A late app user (startup) or a missing app owns no personal badge
    bool ownsUser() {
      try {
        return app?.user.value.id == ownerId;
      } catch (_) {
        return false;
      }
    }

    final lease = ControllerLeaseX.capture(
      this,
      withApp: true,
      app: app,
      locale: true,
      also: () => generation == _loadGeneration && ownsUser(),
    );
    if (!lease.hasAuthenticatedIdentity || !lease.isCurrent) return [];
    try {
      final loaded = await DatabaseX.getBadges();
      return lease.isCurrent ? loaded : [];
    } catch (_) {
      /// A retired result is never shown to the next account
      if (!lease.isCurrent) return [];
      rethrow;
    }
  }
}
