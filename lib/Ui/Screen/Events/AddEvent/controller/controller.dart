import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Data/data.dart';

import '../../../../../Config/config.dart';
import '../../../../Widget/widget.dart';

class AddEventController extends GetxController {
  //============================================================================
  // Variables

  /// Start date
  DateTime? dateTimeStart;
  TimeOfDay? timeOfDayStart;

  /// End date
  DateTime? dateTimeEnd;
  TimeOfDay? timeOfDayEnd;

  /// Loading state
  RxBool isLoading = false.obs;

  /// Repeated state
  RxBool isRepeated = false.obs;

  /// Button state
  Rx<ButtonStateEX> buttonState = ButtonStateEX.normal.obs;

  /// Form key
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Autovalidate mode
  AutovalidateMode autovalidate = AutovalidateMode.disabled;

  /// Text editing controllers
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController dateStart = TextEditingController();
  TextEditingController dateEnd = TextEditingController();
  TextEditingController timeStart = TextEditingController();
  TextEditingController timeEnd = TextEditingController();
  TextEditingController repeatCount = TextEditingController();
  // TextEditingController meetingUrl = TextEditingController();

  //============================================================================
  // Functions

  /// Handle add event
  Future<void> onAddEvent() async {
    /// Check if the loading state is true
    if (isLoading.isTrue) {
      return;
    }

    /// Validate form
    if (formKey.currentState!.validate()) {
      try {
        /// Validate date
        if (validateDate() == false) {
          return;
        }

        /// Set loading state to true
        isLoading.value = true;

        /// Set button state to loading
        buttonState.value = ButtonStateEX.loading;

        /// Add event to database
        var message = await DatabaseX.addEvent(
          title: title.text,
          description: description.text,
          location: location.text,
          endTime: dateTimeEnd!.millisecondsSinceEpoch ~/ 1000,
          startTime: dateTimeStart!.millisecondsSinceEpoch ~/ 1000,
          repeatCount: int.parse(
            repeatCount.text.isEmpty ? '0' : repeatCount.text,
          ),
          isRepeated: isRepeated.value,
        );

        /// Set button state to success
        buttonState.value = ButtonStateEX.success;
        await Future.delayed(
          const Duration(seconds: StyleX.successButtonSecond),
        );

        /// Back to previous screen with result
        Get.back(result: true);

        /// Show success message
        ToastX.success(message: message);
      } catch (e) {
        /// Set button state to failed
        buttonState.value = ButtonStateEX.failed;

        /// Show error message to user
        ToastX.error(message: e);

        /// Set loading state to false
        isLoading.value = false;

        /// Reset button state
        Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () => buttonState.value = ButtonStateEX.normal,
        );
      }
    } else {
      /// Set autovalidate mode to always
      autovalidate = AutovalidateMode.always;
    }
  }

  /// Validate date
  bool validateDate() {
    /// Set start date
    dateTimeStart = DateTime(
      dateTimeStart!.year,
      dateTimeStart!.month,
      dateTimeStart!.day,
      timeOfDayStart!.hour,
      timeOfDayStart!.minute,
    );

    /// Set end date
    dateTimeEnd = DateTime(
      dateTimeEnd!.year,
      dateTimeEnd!.month,
      dateTimeEnd!.day,
      timeOfDayEnd!.hour,
      timeOfDayEnd!.minute,
    );

    /// Check if the start date and end date are the same
    if (dateTimeStart!.isAtSameMomentAs(dateTimeEnd!)) {
      ToastX.error(message: "Start time and end time must not be the same");
      return false;
    }

    /// Check if the start date is after the end date
    if (dateTimeStart!.isAfter(dateTimeEnd!)) {
      ToastX.error(message: "Start time must be before end time");
      return false;
    }

    /// Check if the start date and end date are in the future
    DateTime now = DateTime.now();

    /// Check if the start date is in the future
    if (dateTimeStart!.isBefore(now)) {
      ToastX.error(message: "Start time must be in the future");
      return false;
    }

    /// Check if the end date is in the future
    if (dateTimeEnd!.isBefore(now)) {
      ToastX.error(message: "End time must be in the future");
      return false;
    }

    /// Check if the duration is valid
    int durationMinutes = dateTimeEnd!.difference(dateTimeStart!).inMinutes;

    /// Check if the duration is at least 10 minutes
    if (durationMinutes < 10) {
      ToastX.error(message: "Event duration must be at least 10 minutes");
      return false;
    }

    /// Check if the duration is less than 12 hours
    if (durationMinutes > 720) {
      ToastX.error(message: "Event duration must not exceed 12 hours");
      return false;
    }

    /// Return true if the date is valid
    return true;
  }

  /// Handle change start date
  onChangeDateStart(DateTime? date) => dateTimeStart = date;

  /// Handle change end date
  onChangeDateEnd(DateTime? date) => dateTimeEnd = date;

  /// Handle change start time
  onChangeTimeStart(TimeOfDay? time) => timeOfDayStart = time;

  /// Handle change end time
  onChangeTimeEnd(TimeOfDay? time) => timeOfDayEnd = time;
}
