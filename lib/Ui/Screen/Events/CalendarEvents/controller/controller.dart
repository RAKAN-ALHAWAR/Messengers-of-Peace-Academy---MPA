import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/Extension/date_time.dart';

import '../../../../../Config/Translation/translation.dart';
import '../../../../../Data/Model/event.dart';
import '../../../../../Data/data.dart';

class CalendarController extends GetxController {
  //============================================================================
  // Variables

  /// Selected date
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  /// Week days
  late RxList<DateTime> weekDays;

  /// Events
  final RxList<EventX> events = RxList<EventX>([]);

  /// Events of day
  final RxList<EventX> eventsOfDay = RxList<EventX>([]);

  /// Hours
  final RxList<int> hours = RxList<int>([]);

  /// Index color card event
  int indexColorCardEvent = 0;

  /// Colors card event
  final List<MaterialColor> colorsCardEvent = [
    MaterialColor(0xFF294B78, {100: Color(0xFFEFF8FF), 900: Color(0xFF294B78)}),
    MaterialColor(0xFF362978, {100: Color(0xFFEEEAFF), 900: Color(0xFF362978)}),
    MaterialColor(0xFF442106, {100: Color(0xFFFFFBED), 900: Color(0xFF442106)}),
    MaterialColor(0xFF053321, {100: Color(0xFFECFDF3), 900: Color(0xFF053321)}),
  ];

  /// Last update
  DateTime lastUpdate = DateTime.now();

  /// Is initialized
  bool isInit = false;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData({bool isMust = false}) async {
    try {
      /// Check if the data is not initialized or the last update is less than 1 minute
      if (isMust == false &&
          isInit &&
          lastUpdate.isAfter(DateTime.now().subtract(Duration(minutes: 1)))) {
        return;
      }

      /// Get events from database
      events.value = await DatabaseX.getEvents();

      /// Get hours
      getHours();

      /// Get events of day
      getEventsOfDay();

      /// Set index color card event
      indexColorCardEvent = 0;

      /// Set last update
      lastUpdate = DateTime.now();

      /// Set is initialized
      isInit = true;
    } catch (e) {
      /// If the data is not initialized, rethrow the error
      if (!isInit) rethrow;
    }
  }

  /// Get hours
  void getHours() {
    hours.clear();
    for (int i = 8; i < 24; i++) {
      hours.add(i);
    }
    for (int i = 0; i < 8; i++) {
      hours.add(i);
    }
  }

  /// Get event by hour
  List<EventX> getEventByHour(int val) {
    return eventsOfDay.where((e) => e.hour == val).toList();
  }

  /// Get hour show
  String getHourShow(int val) {
    /// Get symbol
    String sym = val > 12 ? "PM" : "AM";

    /// Get hour
    String hour =
        "${val > 12
            ? (val - 12)
            : val == 0
            ? 12
            : val}:00";

    /// Add zero to hour
    hour = hour.length == 4 ? "0$hour" : hour;

    /// Return hour and symbol
    return "$hour ${sym.tr}";
  }

  /// Get events of day
  void getEventsOfDay() {
    /// Set index color card event
    indexColorCardEvent = 0;

    /// Set events of day
    eventsOfDay.value =
        events
            .where(
              (event) => selectedDate.value.isSameDate(
                DateTime.fromMillisecondsSinceEpoch(event.timeStart * 1000),
              ),
            )
            .toList();
  }

  /// Handle add event
  Future<void> onAddEvent() async {
    /// Open add event screen
    var result = await Get.toNamed(RouteNameX.addEvent);

    /// If the result is not null, get data
    if (result != null) {
      await getData(isMust: true);
    }
  }

  /// Handle open event
  void onOpenEvent(EventX event) async {
    /// Check if the event is system
    if (event.isSystem) {
      Get.toNamed(RouteNameX.meetingDetails, arguments: event.id);
    } else {
      /// Open event details screen
      var result = await Get.toNamed(RouteNameX.eventDetails, arguments: event);

      /// If the result is true, get data
      if (result == true) {
        await getData(isMust: true);
      }
    }
  }

  /// Handle change date from picker
  void onChangeDateFromPicker(DateTime date) {
    /// Set selected date
    selectedDate.value = date;

    /// Set week days
    weekDays.value = getWeekDays();

    /// Back to previous screen
    Get.back();
  }

  /// Handle previous week
  void onPreviousWeek() {
    /// Set selected date
    selectedDate.value = selectedDate.value.subtract(Duration(days: 7));

    /// Set week days
    weekDays.value = getWeekDays();

    /// Get events of day
    getEventsOfDay();
  }

  /// Handle next week
  void onNextWeek() {
    /// Set selected date
    selectedDate.value = selectedDate.value.add(Duration(days: 7));

    /// Set week days
    weekDays.value = getWeekDays();

    /// Get events of day
    getEventsOfDay();
  }

  /// Get week days
  List<DateTime> getWeekDays() {
    /// Get current date
    DateTime current = selectedDate.value;

    /// Get days since saturday
    int daysSinceSaturday = (current.weekday + 1) % 7;
    DateTime startOfWeek = current.subtract(Duration(days: daysSinceSaturday));

    /// Add week days to list
    List<DateTime> weekDays = [];
    for (int i = 0; i < 7; i++) {
      weekDays.add(startOfWeek.add(Duration(days: i)));
    }

    /// Return week days
    return weekDays;
  }

  /// Check if the day is selected
  bool isSelectedDay(DateTime day) {
    /// Return true if the day is selected
    return day.day == selectedDate.value.day &&
        day.month == selectedDate.value.month &&
        day.year == selectedDate.value.year;
  }

  /// Select day
  void selectDay(DateTime day) {
    /// Set selected date
    selectedDate.value = day;

    /// Set week days
    weekDays.value = getWeekDays();

    /// Get events of day
    getEventsOfDay();
  }

  /// Get day name
  String getDayName(DateTime day) {
    /// Get day names
    final dayNames = [
      'saturday',
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
    ];

    /// Get adjusted weekday
    int adjustedWeekday = (day.weekday + 1) % 7;

    /// Return day name
    return dayNames[adjustedWeekday].tr;
  }

  /// Get short day name
  String getShortDayName(DateTime day) => getDayName(day);

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Initialize date format
    initializeDateFormatting(TranslationX.getLanguageCode, null);

    /// Set week days
    weekDays = RxList<DateTime>(getWeekDays());
  }
}
