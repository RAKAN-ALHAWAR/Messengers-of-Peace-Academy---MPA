import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../Config/Translation/translation.dart';
import '../../../../Config/config.dart';
import '../../../../Core/core.dart';
import '../../../../Data/Enum/meeting_option.dart';
import '../../../../Data/Model/course/level.dart';
import '../../../../Data/Model/course/mini_course.dart';
import '../../../../Data/Model/meeting.dart';
import '../../../../Data/Model/user/user.dart';
import '../../../../Data/Model/user/user_statistics.dart';
import '../../../../Data/data.dart';

class HomeController extends GetxController {
  //============================================================================
  // Injection of required controls

  final AppControllerX app = Get.find();

  //============================================================================
  // Variables

  /// User
  late Rx<UserX> user = app.user.value.obs;

  /// Statistics
  late Rx<UserStatisticsX> statistics;

  /// Levels
  RxList<LevelX> levels = <LevelX>[].obs;

  /// Current level
  late Rx<LevelX> currentLevel;

  /// Unread notifications count
  Rx<int> unreadNotificationsCount = 0.obs;

  /// Meetings
  RxList<MeetingX> meetings = <MeetingX>[].obs;

  /// Complaint controller
  final TextEditingController complaintController = TextEditingController();

  /// Last update
  DateTime lastUpdate = DateTime.now();

  /// Is initialized
  bool isInit = false;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData() async {
    try {
      /// If initialized and last update is after 1 minute, return
      if (isInit &&
          lastUpdate.isAfter(DateTime.now().subtract(Duration(minutes: 1)))) {
        return;
      }

      /// Get data from database
      await Future.wait<void>([
        /// Update user
        DatabaseX.getUser().then((value) {
          user.value = value;
          app.user.value = value;
        }),

        /// Get statistics
        DatabaseX.getUserStatistics().then((value) => statistics = value.obs),

        /// Get levels
        DatabaseX.getLevelsWithCourses().then((value) => levels = value.obs),

        /// Get meetings
        DatabaseX.getMeetings(
          option: MeetingOptionEX.all,
        ).then((value) => meetings = value.obs),

        /// Get unread notifications count
        _getUnreadNotificationsCount(),
      ]);

      /// Get current level
      currentLevel =
          levels
              .firstWhere(
                (element) => element.isOpen && element.isCompleted == false,
                orElse:
                    () => levels.firstWhere(
                      (element) => element.isCompleted,
                      orElse: () => levels.first,
                    ),
              )
              .obs;

      /// Update last update and is initialized
      lastUpdate = DateTime.now();
      isInit = true;
    } catch (e) {
      if (!isInit) rethrow;
    }
  }

  /// Get unread notifications count
  Future<void> _getUnreadNotificationsCount() async {
    /// Get notifications from database
    var notifications = await DatabaseX.getNotifications();

    /// Update unread notifications count
    unreadNotificationsCount.value =
        notifications.where((e) => e.read == false).length;
  }

  /// Handle tap on notifications
  onNotifications() async {
    /// Go to notifications screen
    var result = await Get.toNamed(RouteNameX.notifications);

    /// If result is not null, update unread notifications count
    if (result != null) {
      unreadNotificationsCount.value = result;
    } else {
      await _getUnreadNotificationsCount();
    }
  }

  /// Handle tap on course
  onCourseTap(MiniCourseX course) =>
      Get.toNamed(RouteNameX.courseDetails, arguments: course.id);

  /// Handle tap on blog
  onBlog() => Get.toNamed(RouteNameX.blog);

  /// Handle tap on achievements
  onAchievements() => Get.toNamed(RouteNameX.myAchievements);

  /// Handle tap on my courses
  onMyCourses() => Get.toNamed(RouteNameX.myCourses);

  /// Handle tap on my certificates
  onMyCertificates() => Get.toNamed(RouteNameX.myCertificates);

  /// Handle tap on all meetings
  onAllMeetings() => Get.toNamed(RouteNameX.allMeetings);

  /// Handle tap on points
  onPointsTap() => Get.toNamed(RouteNameX.myAchievements);

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Initialize date formatting
    initializeDateFormatting(TranslationX.getLanguageCode, null);
  }
}
