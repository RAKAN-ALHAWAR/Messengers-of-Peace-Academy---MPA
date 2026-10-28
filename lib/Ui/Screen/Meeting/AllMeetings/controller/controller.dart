import 'package:messengersofpeace/Core/Service/controller_lease.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messengersofpeace/Data/Model/meeting.dart';

import '../../../../../Config/Translation/translation.dart';
import '../../../../../Data/Enum/meeting_option.dart';
import '../../../../../Data/data.dart';

class AllMeetingsController extends GetxController {
  //============================================================================
  // Variables

  /// All meetings
  List<MeetingX> allMeetings = [];

  /// Upcoming meetings
  List<MeetingX> upcomingMeetings = [];

  /// Ended meetings
  List<MeetingX> endedMeetings = [];

  /// Selected meetings
  RxList<MeetingX> selectedMeetings = <MeetingX>[].obs;

  /// Tab controller
  final tabController = ValueNotifier(1);

  /// Is all meetings
  RxBool isAll = true.obs;

  /// Is upcoming meetings
  RxBool isUpcoming = false.obs;

  /// Is ended meetings
  RxBool isEnded = false.obs;

  /// Is loading
  RxBool isLoading = true.obs;
  int _loadGeneration = 0;

  /// Session revision and language that own the loaded meetings
  (int, String)? _ownerKey;

  //============================================================================
  // Functions

  /// Get data from the database
  Future<void> getData() async {
    if (isClosed) return;
    final locale = TranslationX.getLanguageCode;
    final key = (LocalDataX.sessionRevision, locale);
    final generation = ++_loadGeneration;
    final lease = ControllerLeaseX.capture(
      this,
      locale: true,
      also: () => generation == _loadGeneration,
    );
    if (_ownerKey != key || !lease.hasAuthenticatedIdentity) {
      allMeetings = [];
      upcomingMeetings = [];
      endedMeetings = [];
      selectedMeetings.clear();
      _ownerKey = key;
    }
    if (!lease.hasAuthenticatedIdentity) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      final loadedAll = await DatabaseX.getMeetings(
        option: MeetingOptionEX.all,
      );
      if (!lease.isCurrent) return;
      final loadedUpcoming = await DatabaseX.getMeetings(
        option: MeetingOptionEX.future,
      );
      if (!lease.isCurrent) return;
      final loadedEnded = await DatabaseX.getMeetings(
        option: MeetingOptionEX.ended,
      );
      if (!lease.isCurrent) return;
      allMeetings = loadedAll;
      upcomingMeetings = loadedUpcoming;
      endedMeetings = loadedEnded;
      _selectMeetings();
    } catch (_) {
      if (!lease.isCurrent) return;
      rethrow;
    } finally {
      if (lease.isCurrent) isLoading.value = false;
    }
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Tab controller listener
    tabController.addListener(_onTabChanged);

    /// Initialize date format
    initializeDateFormatting(TranslationX.getLanguageCode, null);
  }

  void _onTabChanged() {
    isAll.value = tabController.value == 1;
    isUpcoming.value = tabController.value == 2;
    isEnded.value = tabController.value == 3;
    _selectMeetings();
  }

  void _selectMeetings() {
    selectedMeetings.value =
        isAll.value
            ? allMeetings
            : isUpcoming.value
            ? upcomingMeetings
            : endedMeetings;
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }
}
