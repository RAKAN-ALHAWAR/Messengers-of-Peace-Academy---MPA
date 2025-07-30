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

  //============================================================================
  // Functions

  /// Get data from database
  Future getData() async {
    notifications.value = await DatabaseX.getNotifications();
  }

  /// Get count of unread notifications
  int get getCountUnreadNotifications =>
      notifications.where((e) => e.read == false).length;

  /// Mark all as read
  void onMarkAllAsRead() async {
    /// If loading, return
    if (isLoading.value) return;
    try {
      /// Set loading to true
      isLoading.value = true;

      /// Mark all as read
      var message = await DatabaseX.readNotifications();

      /// Show success toast
      ToastX.success(message: message);

      /// Update notifications
      notifications.value =
          notifications.map((e) {
            e.read = true;
            return e;
          }).toList();

      /// Update controller
      update();
    } catch (e) {
      /// Show error toast
      ToastX.error(message: e);
    } finally {
      /// Set loading to false
      isLoading.value = false;
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
