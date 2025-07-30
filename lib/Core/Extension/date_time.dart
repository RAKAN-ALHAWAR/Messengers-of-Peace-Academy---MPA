import 'package:flutter/material.dart';

extension ConvertExtensionX on DateTime {
  DateTime get toDateOnly{
    return DateTime(year, month, day);
  }
  DateTime addTime(TimeOfDay time){
    return DateTime(year, month, day,time.hour,time.minute);
  }
  bool isSameDate(DateTime date){
    return toDateOnly.isAtSameMomentAs(date.toDateOnly);
  }
  bool isSameDateTime(DateTime date){
    return isAtSameMomentAs(date);
  }
}