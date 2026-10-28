import 'package:messengersofpeace/Core/Service/controller_lease.dart';
import 'package:messengersofpeace/Core/Extension/date_time.dart';
import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
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
  int _loadGeneration = 0;
  bool _deleteAccepted = false;
  Timer? _buttonResetTimer;

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
    if (isClosed) return;
    final generation = ++_loadGeneration;
    final lease = ControllerLeaseX.capture(
      this,
      locale: true,
      also: () => generation == _loadGeneration,
    );
    try {
      final loaded = await DatabaseX.getEventDetails(eventId: event.id);
      if (!lease.isCurrent) return;
      eventDetails.value = loaded;
    } catch (_) {
      if (!lease.isCurrent) return;
    }
    isShowActions.value =
        eventDetails.value.userId == LocalDataX.userid &&
        !eventDetails.value.isSystem;
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
  Future<bool> onDeleteEvent(EventOptionEX delete) async {
    /// Ignored taps return before try so they cannot unlock the active request
    if (isClosed || isLoading.value || _deleteAccepted) return false;
    final lease = ControllerLeaseX.capture(this);
    _buttonResetTimer?.cancel();
    isLoading.value = true;
    _setDeleteState(delete, ButtonStateEX.loading);
    try {
      await DatabaseX.deleteEvent(
        eventId: eventDetails.value.id,
        deleteOption: delete,
      );
      if (!lease.isCurrent) return false;
      _deleteAccepted = true;
      isChanged.value = true;
      return true;
    } catch (error) {
      if (!lease.isCurrent) return false;
      ToastX.error(message: error);
      _setDeleteState(delete, ButtonStateEX.failed);
      return false;
    } finally {
      if (!isClosed && lease.isCurrent) {
        isLoading.value = false;
        if (!_deleteAccepted) {
          _buttonResetTimer = Timer(
            const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
            () {
              if (lease.isCurrent) {
                _setDeleteState(delete, ButtonStateEX.normal);
              }
            },
          );
        }
      }
    }
  }

  void _setDeleteState(EventOptionEX option, ButtonStateEX state) {
    switch (option) {
      case EventOptionEX.single:
        buttonStateDeleteSingle.value = state;
        break;
      case EventOptionEX.future:
        buttonStateDeleteFuture.value = state;
        break;
      case EventOptionEX.all:
        buttonStateDeleteAll.value = state;
        break;
    }
  }

  /// Handle edit event
  void onEdit() async {
    if (isClosed) return;
    final lease = ControllerLeaseX.capture(this);

    /// Go to edit event screen
    var result = await Get.toNamed(
      RouteNameX.editEvent,
      arguments: eventDetails.value,
    );

    /// Check if the result is true
    if (lease.isCurrent && result == true) {
      isChanged.value = true;

      /// Get data from database
      await getData();
    }
  }

  /// Get time show
  String getTimeShow(DateTime val) =>
      TimeOfDay.fromDateTime(val).format12Hour(am: 'AM'.tr, pm: 'PM'.tr);

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
    _buttonResetTimer?.cancel();
    super.onClose();
  }
}
