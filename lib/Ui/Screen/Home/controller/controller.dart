import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../Config/Translation/translation.dart';
import '../../../../Config/config.dart';
import '../../../../Core/core.dart';
import '../../../../Core/Error/error.dart';
import '../../../../Core/Service/session_lease.dart';
import '../../../Widget/widget.dart';
import '../../../../Data/Enum/meeting_option.dart';
import '../../../../Data/Model/course/level.dart';
import '../../../../Data/Model/course/mini_course.dart';
import '../../../../Data/Model/meeting.dart';
import '../../../../Data/Model/notification.dart';
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
  final Rx<LevelX?> currentLevel = Rx<LevelX?>(null);

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
  String currentLanguage = TranslationX.getLanguageCode;

  //============================================================================
  // Functions

  static const _cacheLifetime = Duration(minutes: 1);
  SessionLeaseX? _cacheLease;
  SessionLeaseX? _pendingLease;
  Future<void>? _pendingLoad;
  int _loadGeneration = 0;
  int _notificationGeneration = 0;
  int _unreadRevision = 0;
  int _progressNavigationGeneration = 0;

  bool get _ownsHome =>
      !isClosed &&
      Get.isRegistered<HomeController>() &&
      identical(Get.find<HomeController>(), this) &&
      Get.isRegistered<AppControllerX>() &&
      identical(Get.find<AppControllerX>(), app);

  /// Keep one owned snapshot. Independent responses must never partly replace
  /// another account's state or be published with the wrong locale.
  Future<void> getData({bool force = false}) {
    if (!_ownsHome) return Future.value();
    final language = TranslationX.getLanguageCode;
    final ownedCache =
        isInit && _cacheLease?.isCurrent == true && currentLanguage == language;
    if (!force &&
        ownedCache &&
        lastUpdate.isAfter(DateTime.now().subtract(_cacheLifetime))) {
      return Future.value();
    }
    if (!force && _pendingLease?.isCurrent == true && _pendingLoad != null) {
      return _pendingLoad!;
    }
    final request = ++_loadGeneration;
    final id = LocalDataX.userid;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              _ownsHome &&
              request == _loadGeneration &&
              TranslationX.getLanguageCode == language,
    );
    _pendingLease = lease;
    if (!ownedCache) {
      isInit = false;
      _cacheLease = null;
      levels.clear();
      currentLevel.value = null;
      meetings.clear();
      unreadNotificationsCount.value = 0;
      user.value = app.user.value;
    }
    final pending = _loadSnapshot(
      lease,
      id,
      language,
      ownedCache,
      _unreadRevision,
    ).whenComplete(() {
      if (request == _loadGeneration) {
        _pendingLoad = null;
        _pendingLease = null;
      }
    });
    _pendingLoad = pending;
    return pending;
  }

  Future<void> _loadSnapshot(
    SessionLeaseX lease,
    String id,
    String language,
    bool ownedCache,
    int unreadRevision,
  ) async {
    try {
      if (!lease.hasAuthenticatedIdentity) {
        throw ErrorX(message: 'Session changed. Please try again.');
      }
      final values = await Future.wait<Object>([
        DatabaseX.getUser(userId: id),
        DatabaseX.getUserStatistics(),
        DatabaseX.getLevelsWithCourses(),
        DatabaseX.getMeetings(option: MeetingOptionEX.all),
        DatabaseX.getNotifications(),
      ]);
      if (!lease.isCurrent) return;
      final profile = values[0] as UserX;
      if (profile.id != id) {
        throw ErrorX(message: 'Session changed. Please try again.');
      }
      final nextLevels = values[2] as List<LevelX>;
      LevelX? selected;
      if (nextLevels.isNotEmpty) {
        selected = nextLevels.firstWhere(
          (level) => level.isOpen && !level.isCompleted,
          orElse:
              () => nextLevels.firstWhere(
                (level) => level.isCompleted,
                orElse: () => nextLevels.first,
              ),
        );
      }
      user.value = profile;
      app.user.value = profile;
      statistics = (values[1] as UserStatisticsX).obs;
      levels.assignAll(nextLevels);
      currentLevel.value = selected;
      meetings.assignAll(values[3] as List<MeetingX>);
      // A later notification return is newer than this batch's unread count.
      if (unreadRevision == _unreadRevision) {
        unreadNotificationsCount.value =
            (values[4] as List<NotificationX>)
                .where((item) => !item.read)
                .length;
      }
      currentLanguage = language;
      lastUpdate = DateTime.now();
      isInit = true;
      // Cache ownership is independent of the next refresh's request generation.
      _cacheLease = SessionLeaseX.capture(
        isActive: () => _ownsHome && TranslationX.getLanguageCode == language,
      );
    } catch (e) {
      if (!lease.isCurrent) return;
      if (!ownedCache) rethrow;
      // An expired, same-owner snapshot remains available after a failed refresh;
      // its timestamp is not renewed, so a retry still performs the request.
      ErrorX.console(e);
    }
  }

  Future<void> onNotifications() async {
    final request = ++_notificationGeneration;
    final language = TranslationX.getLanguageCode;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              _ownsHome &&
              request == _notificationGeneration &&
              TranslationX.getLanguageCode == language,
    );
    if (!lease.isCurrent || !lease.hasAuthenticatedIdentity) return;
    try {
      final result = await Get.toNamed(RouteNameX.notifications);
      if (!lease.isCurrent) return;
      if (result is int && result >= 0) {
        _unreadRevision++;
        unreadNotificationsCount.value = result;
      } else {
        final notifications = await DatabaseX.getNotifications();
        if (!lease.isCurrent) return;
        _unreadRevision++;
        unreadNotificationsCount.value =
            notifications.where((item) => !item.read).length;
      }
    } catch (e) {
      if (!lease.isCurrent) return;
      ErrorX.console(e);
      ToastX.error(message: e);
    }
  }

  /// Handle tap on course
  Future<void> onCourseTap(MiniCourseX course) =>
      _openAndRefreshProgress(RouteNameX.courseDetails, arguments: course.id);

  /// A course may be removed by quiz-result navigation while Home is covered.
  /// Route lifetime, rather than top-route equality, owns this read-only refresh.
  Future<void> _openAndRefreshProgress(
    String destination, {
    Object? arguments,
  }) async {
    final route = Get.rawRoute;
    final language = TranslationX.getLanguageCode;
    final request = ++_progressNavigationGeneration;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              _ownsHome &&
              route?.isActive == true &&
              request == _progressNavigationGeneration &&
              TranslationX.getLanguageCode == language,
    );
    if (!lease.isCurrent || !lease.hasAuthenticatedIdentity) return;
    try {
      await Get.toNamed(destination, arguments: arguments);
      if (!lease.isCurrent) return;
      await getData(force: true);
    } catch (e) {
      if (!lease.isCurrent) return;
      ErrorX.console(e);
      ToastX.error(message: e);
    }
  }

  /// Handle tap on blog
  onBlog() => Get.toNamed(RouteNameX.blog);

  /// Handle tap on achievements
  onAchievements() => Get.toNamed(RouteNameX.myAchievements);

  /// Handle tap on my courses
  Future<void> onMyCourses() => _openAndRefreshProgress(RouteNameX.myCourses);

  /// Handle tap on my certificates
  onMyCertificates() => Get.toNamed(RouteNameX.myCertificates);

  /// Handle tap on all meetings
  onAllMeetings() => Get.toNamed(RouteNameX.allMeetings);

  /// Handle tap on points
  onPointsTap() => Get.toNamed(RouteNameX.myAchievements);

  //============================================================================
  // Lifecycle

  @override
  void onClose() {
    _loadGeneration++;
    _notificationGeneration++;
    _progressNavigationGeneration++;
    complaintController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    /// Initialize date formatting
    initializeDateFormatting(TranslationX.getLanguageCode, null);
  }
}
