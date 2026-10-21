import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ConvertExtensionX on DateTime {
  /// Display a localized month/period while retaining the app's Latin digits.
  String formatDateAndTime(String locale) =>
      (DateFormat('d MMMM . hh:mm a', locale)
        ..useNativeDigits = false).format(this);

  DateTime get toDateOnly {
    return DateTime(year, month, day);
  }

  DateTime addTime(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute);
  }

  bool isSameDate(DateTime date) {
    return toDateOnly.isAtSameMomentAs(date.toDateOnly);
  }

  bool isSameDateTime(DateTime date) {
    return isAtSameMomentAs(date);
  }
}

/// Consistent 12-hour presentation for picker inputs and event surfaces.
extension TimeDisplayExtensionX on TimeOfDay {
  String format12Hour({required String am, required String pm}) {
    final displayHour = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${period == DayPeriod.am ? am : pm}';
  }
}
