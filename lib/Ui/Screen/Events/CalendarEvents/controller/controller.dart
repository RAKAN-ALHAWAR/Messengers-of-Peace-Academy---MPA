import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/Extension/date_time.dart';

import '../../../../../Config/Translation/translation.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Data/Model/event.dart';
import '../../../../../Data/data.dart';

class CalendarController extends GetxController {
  //============================================================================
  // Variables

  /// Selected date
  final Rx<DateTime> selectedDate = DateTime.now().toDateOnly.obs;

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
  (int, String)? _loadedKey;
  int _loadGeneration = 0;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData({bool isMust = false}) async {
    if (isClosed) return;
    final locale = TranslationX.getLanguageCode;
    final key = (LocalDataX.sessionRevision, locale);
    if (!isMust &&
        isInit &&
        _loadedKey == key &&
        lastUpdate.isAfter(
          DateTime.now().subtract(const Duration(minutes: 1)),
        )) {
      return;
    }
    final generation = ++_loadGeneration;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              generation == _loadGeneration &&
              TranslationX.getLanguageCode == locale,
    );
    try {
      final loadedEvents = await DatabaseX.getEvents();
      if (!lease.isCurrent) return;
      events.value = loadedEvents;
      getHours();
      getEventsOfDay();
      indexColorCardEvent = 0;
      lastUpdate = DateTime.now();
      _loadedKey = key;
      isInit = true;
    } catch (_) {
      if (!lease.isCurrent) return;
      // An older account or locale is never a fallback for this request.
      if (!isInit || _loadedKey != key) rethrow;
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
  String getHourShow(int val) =>
      TimeOfDay(hour: val, minute: 0).format12Hour(am: 'AM'.tr, pm: 'PM'.tr);

  /// Get events of day
  void getEventsOfDay() {
    /// Set index color card event
    indexColorCardEvent = 0;

    /// Get events of selected day
    List<EventX> dayEvents =
        events
            .where(
              (event) => selectedDate.value.isSameDate(event.dateTimeStart),
            )
            .toList();

    /// إزالة التكرارات بناءً على id و timeStart و name و location
    /// Remove duplicates based on id, timeStart, name, and location
    Map<String, EventX> uniqueEvents = {};
    for (var event in dayEvents) {
      /// إنشاء مفتاح فريد لكل حدث بناءً على id و timeStart و name و location
      /// Create unique key for each event based on id, timeStart, name, and location
      String key =
          '${event.id}_${event.timeStart}_${event.name}_${event.location}';

      /// إذا لم يكن المفتاح موجوداً، أضف الحدث
      /// If key doesn't exist, add the event
      if (!uniqueEvents.containsKey(key)) {
        uniqueEvents[key] = event;
      }
    }

    /// Set events of day without duplicates
    eventsOfDay.value = uniqueEvents.values.toList();
  }

  /// Handle add event
  Future<void> onAddEvent() async {
    final lease = SessionLeaseX.capture(isActive: () => !isClosed);

    /// Open add event screen
    var result = await Get.toNamed(RouteNameX.addEvent);

    /// If the result is not null, get data
    if (lease.isCurrent && result != null) {
      await getData(isMust: true);
    }
  }

  /// Handle open event
  void onOpenEvent(EventX event) async {
    if (isClosed) return;
    final lease = SessionLeaseX.capture(isActive: () => !isClosed);

    /// Check if the event is system
    if (event.isSystem) {
      Get.toNamed(RouteNameX.meetingDetails, arguments: event.id);
    } else {
      /// Open event details screen
      var result = await Get.toNamed(RouteNameX.eventDetails, arguments: event);

      /// If the result is true, get data
      // Native Back/gestures carry no result. Re-read instead of inventing a
      // changed flag; explicit false is the toolbar's known-unchanged result.
      if (lease.isCurrent && (result == true || result == null)) {
        await getData(isMust: true);
      }
    }
  }

  /// Handle change date from picker
  void onChangeDateFromPicker(DateTime date) {
    selectDay(date);
    Get.back();
  }

  /// Change a civil day instead of adding 24-hour blocks across DST boundaries.
  void onPreviousWeek() {
    final date = selectedDate.value;
    selectDay(DateTime(date.year, date.month, date.day - 7));
  }

  void onNextWeek() {
    final date = selectedDate.value;
    selectDay(DateTime(date.year, date.month, date.day + 7));
  }

  /// Get week days
  List<DateTime> getWeekDays() {
    /// Get current date
    DateTime current = selectedDate.value;

    /// Get days since saturday
    int daysSinceSaturday = (current.weekday + 1) % 7;
    DateTime startOfWeek = DateTime(
      current.year,
      current.month,
      current.day - daysSinceSaturday,
    );

    /// Add week days to list
    List<DateTime> weekDays = [];
    for (int i = 0; i < 7; i++) {
      weekDays.add(
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i),
      );
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
    selectedDate.value = day.toLocal().toDateOnly;

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
