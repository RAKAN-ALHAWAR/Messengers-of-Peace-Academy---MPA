import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Config/Translation/translation.dart';
import '../../../../Data/Model/notification.dart';

class NotificationsController extends GetxController {
  //============================================================================
  // Variables

  /// Is loading
  RxBool isLoading = false.obs;

  /// Notifications
  RxList<NotificationX> notifications = <NotificationX>[].obs;
  int _loadGeneration = 0;
  int _readGeneration = 0;
  SessionLeaseX? _readLease;

  //============================================================================
  // Functions

  /// Get data from database
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
    if (isLoading.value && !(_readLease?.isCurrent ?? false)) {
      isLoading.value = false;
    }
    try {
      final loaded = await DatabaseX.getNotifications();
      if (!lease.isCurrent) return;
      notifications.value = loaded;
    } catch (_) {
      if (!lease.isCurrent) return;
      rethrow;
    }
  }

  /// Get count of unread notifications
  int get getCountUnreadNotifications =>
      notifications.where((e) => e.read == false).length;

  /// Mark all as read
  void onMarkAllAsRead() async {
    /// If loading, return
    if (isClosed || (isLoading.value && (_readLease?.isCurrent ?? false))) {
      return;
    }
    final generation = ++_readGeneration;
    final lease = SessionLeaseX.capture(isActive: () => !isClosed);
    _readLease = lease;
    try {
      /// Set loading to true
      isLoading.value = true;

      /// Mark all as read
      await DatabaseX.readNotifications();
      if (!lease.isCurrent) return;

      /// Show the localized message instead of the raw backend one
      ToastX.success(message: "All notifications have been marked as read".tr);

      /// Update notifications
      notifications.value =
          notifications.map((e) {
            e.read = true;
            return e;
          }).toList();

      /// Update controller
      update();
    } catch (e) {
      if (!lease.isCurrent) return;

      /// Show error toast
      ToastX.error(message: e);
    } finally {
      /// Set loading to false
      if (!isClosed && generation == _readGeneration) {
        isLoading.value = false;
      }
    }
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Initialize date format
    initializeDateFormatting(TranslationX.getLanguageCode, null);
  }
}
