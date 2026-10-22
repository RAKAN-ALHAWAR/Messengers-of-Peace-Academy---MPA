import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:get/get.dart';
import '../../../../Core/core.dart';
import '../../../../Data/Model/badge.dart';
import '../../../../Data/data.dart';

class BadgesController extends GetxController {
  int _loadGeneration = 0;
  //============================================================================
  // Functions

  /// Get badges from database
  Future<List<BadgeX>> getData() async {
    if (isClosed) return [];
    final locale = TranslationX.getLanguageCode;
    final generation = ++_loadGeneration;
    final ownerId = LocalDataX.userid;
    final app =
        Get.isRegistered<AppControllerX>() ? Get.find<AppControllerX>() : null;
    bool ownsAppUser() {
      if (app == null ||
          !Get.isRegistered<AppControllerX>() ||
          !identical(Get.find<AppControllerX>(), app)) {
        return false;
      }
      // Startup can register AppController before initializing its late user.
      // An uninitialized profile cannot own a personal badge response.
      try {
        return app.user.value.id == ownerId;
      } catch (_) {
        return false;
      }
    }

    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              generation == _loadGeneration &&
              TranslationX.getLanguageCode == locale &&
              ownsAppUser(),
    );
    if (!lease.hasAuthenticatedIdentity || !lease.isCurrent) return [];
    try {
      final loaded = await DatabaseX.getBadges();
      return lease.isCurrent ? loaded : [];
    } catch (_) {
      // Retired results cannot be exposed through the next account's view.
      if (!lease.isCurrent) return [];
      rethrow;
    }
  }
}
