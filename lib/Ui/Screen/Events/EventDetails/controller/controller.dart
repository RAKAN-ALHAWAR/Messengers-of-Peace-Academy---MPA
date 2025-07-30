import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/Enum/event_option.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../Config/Translation/translation.dart';
import '../../../../../Data/Model/event.dart';
import '../../../../../Data/data.dart';

class EventDetailsController extends GetxController {
  //============================================================================
  // Variables

  /// Get event form previous screen
  EventX event = Get.arguments;

  /// Event details
  late Rx<EventX> eventDetails = event.obs;

  /// Show actions button
  RxBool isShowActions = false.obs;

  /// Is loading
  RxBool isLoading = false.obs;

  /// Is changed
  RxBool isChanged = false.obs;

  /// Button state delete single
  Rx<ButtonStateEX> buttonStateDeleteSingle = ButtonStateEX.normal.obs;

  /// Button state delete future
  Rx<ButtonStateEX> buttonStateDeleteFuture = ButtonStateEX.normal.obs;

  /// Button state delete all
  Rx<ButtonStateEX> buttonStateDeleteAll = ButtonStateEX.normal.obs;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData() async {
    try {
      /// Get event details from database
      eventDetails.value = await DatabaseX.getEventDetails(eventId: event.id);
    } catch (_) {}

    /// Show actions button
    isShowActions.value =
        eventDetails.value.userId == LocalDataX.userid &&
        eventDetails.value.isSystem == false;
  }

  /// Handle open meeting
  void onOpenMeeting() {
    try {
      if (eventDetails.value.meetingUrl.isNotEmpty) {
        launchUrl(Uri.parse(eventDetails.value.meetingUrl));
      }
    } catch (_) {}
  }

  /// Handle delete event
  Future<void> onDeleteEvent(EventOptionEX delete) async {
    try {
      if (isLoading.value) return;
      isLoading.value = true;

      /// Set button state
      switch (delete) {
        case EventOptionEX.single:
          buttonStateDeleteSingle.value = ButtonStateEX.loading;
          break;
        case EventOptionEX.future:
          buttonStateDeleteFuture.value = ButtonStateEX.loading;
          break;
        case EventOptionEX.all:
          buttonStateDeleteAll.value = ButtonStateEX.loading;
          break;
      }

      /// Delete event from database
      await DatabaseX.deleteEvent(
        eventId: eventDetails.value.id,
        deleteOption: delete,
      );

      /// Set is changed to true
      isChanged.value = true;

      /// Go back to previous screen with result
      Get.back(result: isChanged.value);
    } catch (e) {
      /// Show error message
      ToastX.error(message: e);

      /// Set button state
      switch (delete) {
        case EventOptionEX.single:
          buttonStateDeleteSingle.value = ButtonStateEX.failed;
          break;
        case EventOptionEX.future:
          buttonStateDeleteFuture.value = ButtonStateEX.failed;
          break;
        case EventOptionEX.all:
          buttonStateDeleteAll.value = ButtonStateEX.failed;
          break;
      }
    } finally {
      /// Set loading to false
      isLoading.value = false;

      /// Reset button state
      Timer(
        const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
        () {
          switch (delete) {
            case EventOptionEX.single:
              buttonStateDeleteSingle.value = ButtonStateEX.normal;
              break;
            case EventOptionEX.future:
              buttonStateDeleteFuture.value = ButtonStateEX.normal;
              break;
            case EventOptionEX.all:
              buttonStateDeleteAll.value = ButtonStateEX.normal;
              break;
          }
        },
      );
    }
  }

  /// Handle edit event
  void onEdit() async {
    /// Go to edit event screen
    var result = await Get.toNamed(
      RouteNameX.editEvent,
      arguments: eventDetails.value,
    );

    /// Check if the result is true
    if (result == true) {
      isChanged.value = true;

      /// Get data from database
      await getData();
    }
  }

  /// Get time show
  String getTimeShow(DateTime val) {
    /// Get symbol
    String sym = val.hour > 12 ? "PM" : "AM";

    /// Get hour
    String hour =
        "${val.hour > 12
            ? (val.hour - 12).toString().padLeft(2, '0')
            : val.hour == 0
            ? 12
            : val.hour.toString().padLeft(2, '0')}:${val.minute.toString().padLeft(2, '0')}";

    /// Return time show
    return "$hour ${sym.tr}";
  }

  //============================================================================
  // Lifecycle
  @override
  void onInit() {
    super.onInit();

    /// Initialize date format
    initializeDateFormatting(TranslationX.getLanguageCode, null);
  }

  /// On close
  @override
  void onClose() {
    /// Go back to previous screen with result
    Get.back(result: isChanged.value);
    super.onClose();
  }
}
