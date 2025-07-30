import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Data/Model/event.dart';
import 'package:messengersofpeace/Data/data.dart';

import '../../../../../Config/config.dart';
import '../../../../../Data/Enum/event_option.dart';
import '../../../../Widget/widget.dart';

class EditEventController extends GetxController {
  //============================================================================
  // Variables

  /// Event from previous screen
  EventX event = Get.arguments;

  /// Date and time start
  late DateTime dateTimeStart = event.dateTimeStart;
  late TimeOfDay timeOfDayStart = TimeOfDay.fromDateTime(event.dateTimeStart);

  /// Date and time end
  late DateTime dateTimeEnd = event.dateTimeEnd;
  late TimeOfDay timeOfDayEnd = TimeOfDay.fromDateTime(event.dateTimeEnd);

  /// Loading
  RxBool isLoading = false.obs;

  /// Is repeated
  late RxBool isRepeated = event.isRepeated.obs;

  /// Button state
  Rx<ButtonStateEX> buttonState = ButtonStateEX.normal.obs;

  /// Form key
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidate = AutovalidateMode.disabled;

  Rx<EventOptionEX> editOption = EventOptionEX.single.obs;

  /// Text editing controllers
  late TextEditingController dateStart = TextEditingController();
  late TextEditingController dateEnd = TextEditingController();
  late TextEditingController timeStart = TextEditingController();
  late TextEditingController timeEnd = TextEditingController();
  late TextEditingController title = TextEditingController(text: event.name);
  late TextEditingController description = TextEditingController(
    text: event.description,
  );
  late TextEditingController location = TextEditingController(
    text: event.location,
  );
  late TextEditingController repeatCount = TextEditingController(
    text: event.repeatCount.toString(),
  );
  // late TextEditingController meetingUrl = TextEditingController(text: event.meetingUrl);

  //============================================================================
  // Functions

  /// Handle edit event
  Future<void> onEditEvent() async {
    /// Check if the loading
    if (isLoading.isTrue) {
      return;
    }

    /// Check if the form is valid
    if (formKey.currentState!.validate()) {
      try {
        /// Check if the date is valid
        if (validateDate() == false) {
          return;
        }

        /// Set loading
        isLoading.value = true;
        buttonState.value = ButtonStateEX.loading;

        /// Edit event in database
        var message = await DatabaseX.editEvent(
          title: title.text,
          description: description.text,
          location: location.text,
          endTime: dateTimeEnd.millisecondsSinceEpoch ~/ 1000,
          startTime: dateTimeStart.millisecondsSinceEpoch ~/ 1000,
          eventId: event.id,
          repeatCount: int.parse(
            repeatCount.text.isEmpty ? '0' : repeatCount.text,
          ),
          isRepeated: isRepeated.value,
          editOption: editOption.value,
        );

        /// Set button state to success
        buttonState.value = ButtonStateEX.success;
        await Future.delayed(
          const Duration(seconds: StyleX.successButtonSecond),
        );

        /// Back to previous screen
        Get.back(result: true);

        /// Show success message
        ToastX.success(message: message);
      } catch (e) {
        /// Set button state to failed
        buttonState.value = ButtonStateEX.failed;

        /// Show error message
        ToastX.error(message: e);

        /// Set loading to false
        isLoading.value = false;

        /// Reset button state
        Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () => buttonState.value = ButtonStateEX.normal,
        );
      }
    } else {
      /// Set autovalidate to always
      autovalidate = AutovalidateMode.always;
    }
  }

  /// Validate date
  bool validateDate() {
    /// Set date and time start
    dateTimeStart = DateTime(
      dateTimeStart.year,
      dateTimeStart.month,
      dateTimeStart.day,
      timeOfDayStart.hour,
      timeOfDayStart.minute,
    );

    /// Set date and time end
    dateTimeEnd = DateTime(
      dateTimeEnd.year,
      dateTimeEnd.month,
      dateTimeEnd.day,
      timeOfDayEnd.hour,
      timeOfDayEnd.minute,
    );

    /// Check if the start time and end time are the same
    if (dateTimeStart.isAtSameMomentAs(dateTimeEnd)) {
      ToastX.error(message: "Start time and end time must not be the same");
      return false;
    }

    /// Check if the start time is after the end time
    if (dateTimeStart.isAfter(dateTimeEnd)) {
      ToastX.error(message: "Start time must be before end time");
      return false;
    }

    /// Check if the start time and end time are in the future
    DateTime now = DateTime.now();

    /// Check if the start time is in the future
    if (dateTimeStart.isBefore(now)) {
      ToastX.error(message: "Start time must be in the future");
      return false;
    }

    /// Check if the end time is in the future
    if (dateTimeEnd.isBefore(now)) {
      ToastX.error(message: "End time must be in the future");
      return false;
    }

    /// Check if the duration is logical (at least 10 minutes and less than 12 hours)
    int durationMinutes = dateTimeEnd.difference(dateTimeStart).inMinutes;

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

    /// Return true
    return true;
  }

  /// Handle change edit option
  onChangeEditOption(EventOptionEX? value) =>
      editOption.value = value ?? editOption.value;

  /// Handle change date start
  onChangeDateStart(DateTime? date) => dateTimeStart = date ?? dateTimeStart;

  /// Handle change date end
  onChangeDateEnd(DateTime? date) => dateTimeEnd = date ?? dateTimeEnd;

  /// Handle change time start
  onChangeTimeStart(TimeOfDay? time) => timeOfDayStart = time ?? timeOfDayStart;

  /// Handle change time end
  onChangeTimeEnd(TimeOfDay? time) => timeOfDayEnd = time ?? timeOfDayEnd;
}
