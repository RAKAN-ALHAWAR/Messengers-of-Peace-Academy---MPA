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

  //============================================================================
  // Functions

  /// Get data from the database
  Future<void> getData() async {
    try {
      /// Get all meetings from the database
      allMeetings = await DatabaseX.getMeetings(option: MeetingOptionEX.all);

      /// Get upcoming meetings from the database
      upcomingMeetings = await DatabaseX.getMeetings(
        option: MeetingOptionEX.future,
      );

      /// Get ended meetings from the database
      endedMeetings = await DatabaseX.getMeetings(
        option: MeetingOptionEX.ended,
      );

      /// Set selected meetings
      selectedMeetings.value =
          isAll.value
              ? allMeetings
              : isUpcoming.value
              ? upcomingMeetings
              : endedMeetings;

      /// Set loading to false
      isLoading.value = false;
    } catch (e) {
      rethrow;
    }
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Tab controller listener
    tabController.addListener(() {
      isAll.value = tabController.value == 1;
      isUpcoming.value = tabController.value == 2;
      isEnded.value = tabController.value == 3;
      selectedMeetings.value =
          isAll.value
              ? allMeetings
              : isUpcoming.value
              ? upcomingMeetings
              : endedMeetings;
    });

    /// Initialize date format
    initializeDateFormatting(TranslationX.getLanguageCode, null);
  }
}
