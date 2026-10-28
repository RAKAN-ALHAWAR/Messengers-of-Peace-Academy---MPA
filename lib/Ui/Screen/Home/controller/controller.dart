import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../Config/Translation/translation.dart';
import '../../../../Config/config.dart';
import '../../../../Core/core.dart';
import '../../../../Core/Error/error.dart';
import '../../../../Core/Service/controller_lease.dart';
import '../../../../Core/Service/route_origin.dart';
import '../../../../Core/Service/session_lease.dart';
import '../../../Widget/widget.dart';
import '../../../../Data/Enum/meeting_option.dart';
import '../../../../Data/Model/course/first_course_unlock.dart';
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
  bool _statisticsInitialized = false;

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
  SessionLeaseX? _pendingOwner;
  Future<void>? _pendingLoad;
  int _loadGeneration = 0;
  int _notificationGeneration = 0;
  int _unreadRevision = 0;
  int _progressNavigationGeneration = 0;
  bool _openingProgressRoute = false;

  /// One owned snapshot: a late answer of a changed owner is dropped.
  Future<void> getData({bool force = false, SessionLeaseX? owner}) {
    if (!ControllerLeaseX.owns(this, app: app) || owner?.isCurrent == false) {
      return Future.value();
    }
    final language = TranslationX.getLanguageCode;
    final ownedCache =
        isInit && _cacheLease?.isCurrent == true && currentLanguage == language;
    if (!force &&
        ownedCache &&
        lastUpdate.isAfter(DateTime.now().subtract(_cacheLifetime))) {
      return Future.value();
    }
    if (!force &&
        identical(_pendingOwner, owner) &&
        _pendingLease?.isCurrent == true &&
        _pendingLoad != null) {
      return _pendingLoad!;
    }
    final request = ++_loadGeneration;
    final id = LocalDataX.userid;
    final lease = ControllerLeaseX.capture(
      this,
      registered: true,
      app: app,
      owner: owner,
      locale: true,
      also: () => request == _loadGeneration,
    );
    _pendingLease = lease;
    _pendingOwner = owner;
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
      force,
    ).whenComplete(() {
      if (request == _loadGeneration) {
        _pendingLoad = null;
        _pendingLease = null;
        _pendingOwner = null;
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
    bool force,
  ) async {
    try {
      if (!lease.hasAuthenticatedIdentity) throw ErrorX.sessionChanged();
      final values = await Future.wait<Object>([
        DatabaseX.getUser(userId: id),
        DatabaseX.getUserStatistics(),
        DatabaseX.getLevelsWithCourses(),
        DatabaseX.getMeetings(option: MeetingOptionEX.all),
        DatabaseX.getNotifications(),
      ]);
      if (!lease.isCurrent) return;
      final profile = values[0] as UserX;
      if (profile.id != id) throw ErrorX.sessionChanged();
      final nextLevels = values[2] as List<LevelX>;
      // TEMP(backend): the backend should return is_open for the first course.
      openFirstCourseIfNoneOpen(nextLevels);
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
      // Mounted Obx consumers retain this Rx subscription across refreshes.
      final nextStatistics = values[1] as UserStatisticsX;
      if (_statisticsInitialized) {
        statistics.value = nextStatistics;
      } else {
        statistics = nextStatistics.obs;
        _statisticsInitialized = true;
      }
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
      _cacheLease = ControllerLeaseX.capture(
        this,
        registered: true,
        app: app,
        locale: true,
      );
    } catch (e) {
      if (!lease.isCurrent) return;
      if (!ownedCache || force) rethrow;
      // A failed refresh keeps the old snapshot and its time, so a retry asks.
      ErrorX.console(e);
    }
  }

  Future<void> onNotifications() async {
    final request = ++_notificationGeneration;
    final lease = ControllerLeaseX.capture(
      this,
      registered: true,
      app: app,
      locale: true,
      also: () => request == _notificationGeneration,
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

  /// Open a page, then refresh progress while the tapped route is still alive.
  Future<void> _openAndRefreshProgress(
    String destination, {
    Object? arguments,
  }) async {
    if (_openingProgressRoute || !ControllerLeaseX.owns(this, app: app)) return;
    final route = RouteOriginX.capture();
    final request = ++_progressNavigationGeneration;
    final lease = ControllerLeaseX.capture(
      this,
      registered: true,
      app: app,
      origin: route,
      locale: true,
      also: () => request == _progressNavigationGeneration,
    );
    if (!lease.isCurrent || !lease.hasAuthenticatedIdentity) return;
    _openingProgressRoute = true;
    try {
      await Get.toNamed(destination, arguments: arguments);
      if (!lease.isCurrent) return;
      await getData(force: true, owner: lease);
    } catch (e) {
      if (!lease.isCurrent) return;
      ErrorX.console(e);
      ToastX.error(message: e);
    } finally {
      if (!isClosed) _openingProgressRoute = false;
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
