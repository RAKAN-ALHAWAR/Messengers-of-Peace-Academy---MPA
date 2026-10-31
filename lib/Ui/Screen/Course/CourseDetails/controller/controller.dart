import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Core/Service/controller_lease.dart';
import '../../../../../Core/Service/download_file_form_url.dart';
import '../../../../../Core/core.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Data/Model/course/activity.dart';
import '../../../../../Data/Model/course/course.dart';
import '../../../../../Data/Model/user/user_statistics.dart';
import '../../../../../Data/data.dart';
import '../../VideoPlayer /controller/controller.dart';

class CourseDetailsController extends GetxController {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  bool isLoading = false;

  /// The file download, replaceable so tests can run without a network
  Future<bool> Function(String url, String fileName) downloadFile =
      DownloadFileFormUrl.download;

  /// Saves the time spent on a lesson video, replaceable so tests skip the disk
  Future<void> Function(int seconds) addLearnedSeconds =
      UserStatisticsX.addLocalLearnedSeconds;
  String courseId = Get.arguments;
  Rx<CourseX?> course = Rx<CourseX?>(null);

  /// A refetch of the shown course is pending, so the page shows its loading sign
  final RxBool isRefreshing = false.obs;

  /// A newer load retires older loads; a newer video tap retires older taps
  int _loadGeneration = 0;
  int _visitGeneration = 0;

  /// A newer refetch retires older ones, only the newest turns the sign off
  int _refreshGeneration = 0;

  /// A lesson video is open, so further video taps are ignored
  bool _videoBusy = false;

  /// The lease the shown course was published under
  SessionLeaseX? _contentLease;

  /// Route parameter carrying the passed quiz id, so the activity after it opens
  static const nextAfterQuizParam = 'nextAfterQuiz';
  String? _nextAfterQuizId;

  //============================================================================
  // Functions

  /// Open, still the registered course page, with the live app controller
  bool get _ownsCourse => ControllerLeaseX.owns(this, app: app);

  /// A lease for course [id] in the current language, plus [operation]
  SessionLeaseX _captureScope(String id, {bool Function()? operation}) =>
      ControllerLeaseX.capture(
        this,
        registered: true,
        app: app,
        locale: true,
        also: () => courseId == id && (operation?.call() ?? true),
      );

  void _publishCourse(CourseX value, String id) {
    if (value.id != id) throw ErrorX.sessionChanged();
    _contentLease = _captureScope(id);
    _applyLocalProgress(value);
    course.value = value;
  }

  /// TEMP(backend): local progress the server does not send yet.
  /// - A file activity is never marked completed, so a downloaded file is
  ///   remembered on the device (per user and cmid). The backend must send
  ///   is_completed true for a file the user opened.
  /// - video_duration is "0:00", so the real length the video player learned
  ///   is used. The backend must send the real duration.
  /// Both local values are removed once the backend sends the real data.
  void _applyLocalProgress(CourseX value) {
    for (final activity in value.activities) {
      if (activity.downloadUrl.isNotEmpty) {
        activity.isFileDownloaded = LocalDataX.get<bool>(
          LocalKeyX.fileDone(activity.cmId),
          defaultData: false,
        );
      }
      if (activity.videoUrl.isNotEmpty) {
        activity.localDurationSeconds = LocalDataX.get<int>(
          LocalKeyX.videoSeconds(activity.videoUrl),
          defaultData: 0,
        );
      }
    }
  }

  /// Loads the course; a newer load also retires the video taps still in flight
  Future<void> getData() async {
    if (!_ownsCourse) return;
    final request = ++_loadGeneration;
    _visitGeneration++;
    _videoBusy = false;
    isLoading = false;
    // This load shows its own loading, it retires any refetch sign
    _refreshGeneration++;
    isRefreshing.value = false;
    final id = courseId;
    final lease = _captureScope(
      id,
      operation: () => request == _loadGeneration,
    );
    if (_contentLease?.isCurrent != true) course.value = null;
    if (!lease.hasAuthenticatedIdentity) throw ErrorX.sessionChanged();
    try {
      final value = await DatabaseX.getCourse(courseId: id);
      if (!lease.isCurrent) return;
      _publishCourse(value, id);
    } catch (_) {
      if (!lease.isCurrent) return;
      rethrow;
    }
    _openNextAfterPassedQuiz();
  }

  /// Refetches the course, a failed refresh keeps the shown one; true if published
  ///
  /// The page shows its loading sign meanwhile, the server stays the truth
  Future<bool> _refreshCourse(SessionLeaseX lease, String id) async {
    final refresh = ++_refreshGeneration;
    isRefreshing.value = true;
    try {
      final value = await DatabaseX.getCourse(courseId: id);
      if (!lease.isCurrent) return false;
      _publishCourse(value, id);
      return true;
    } catch (e) {
      if (!lease.isCurrent) return false;
      ErrorX.console(e);
      ToastX.error(message: '${"Something wrong".tr}. ${"Try again".tr}');
      return false;
    } finally {
      if (refresh == _refreshGeneration) isRefreshing.value = false;
    }
  }

  //============================================================================
  // Next activity

  /// The open activity after [cmId] in course order (empty ones skipped), else null
  static ActivityX? nextActivityAfter(List<ActivityX> activities, String cmId) {
    final index = activities.indexWhere((a) => a.cmId == cmId);
    if (index < 0) return null;
    for (var i = index + 1; i < activities.length; i++) {
      if (!activities[i].hasContent) continue;
      return activities[i].isOpen ? activities[i] : null;
    }
    return null;
  }

  /// Opens the activity after [cmId]: a video, a quiz's test info or a file download
  Future<void> openNextActivity(String cmId) async {
    final current = course.value;
    if (current == null) return;
    final next = nextActivityAfter(current.activities, cmId);
    if (next == null) return;
    if (next.videoUrl.isNotEmpty) {
      return onTapLessonVideo(current.activities.indexOf(next));
    }
    if (next.quizId != null) return onTapLessonQuiz(next);
    return onTapLessonSummary(next);
  }

  /// Arriving from a passed quiz: open the activity after it (not awaited by getData)
  void _openNextAfterPassedQuiz() {
    final quizId = _nextAfterQuizId;
    _nextAfterQuizId = null;
    if (quizId == null) return;
    final quiz = course.value?.activities.firstWhereOrNull(
      (a) => a.quizId == quizId,
    );
    if (quiz != null) openNextActivity(quiz.cmId);
  }

  /// Back from the passed quiz: refetch, then open the activity after [quizId]
  Future<void> continueAfterPassedQuiz(String quizId) async {
    if (!_ownsCourse || _contentLease?.isCurrent != true) return;
    final id = courseId;
    final route = Get.currentRoute;
    final request = _loadGeneration;
    final lease = _captureScope(
      id,
      operation: () => request == _loadGeneration && Get.currentRoute == route,
    );
    if (!await _refreshCourse(lease, id)) return;
    final quiz = course.value?.activities.firstWhereOrNull(
      (a) => a.quizId == quizId,
    );
    if (quiz != null) await openNextActivity(quiz.cmId);
  }

  /// Lessons are the topics that have a video, quiz or file activity
  Map<int, List<ActivityX>> get _lessonTopics {
    final topics = <int, List<ActivityX>>{};
    for (final activity in course.value?.activities ?? <ActivityX>[]) {
      if (activity.hasContent) {
        topics.putIfAbsent(activity.topicId, () => []).add(activity);
      }
    }
    return topics;
  }

  /// Total lessons of the course
  int get lessonsTotal => _lessonTopics.length;

  /// Lessons whose content activities are all done (is_completed or 100 percent)
  int get lessonsDone => _lessonTopics.values
      .where((topic) => topic.every((a) => a.isDone))
      .length;

  /// Get activity count name
  String get getActivityCountName {
    int totalActivities = lessonsTotal;
    switch (totalActivities) {
      case 0:
        return "No Lesson";
      case 1:
        return "One Lesson";
      case 2:
        return "Two Lessons";
      default:
        return "$totalActivities ${"Lessons".tr}";
    }
  }

  /// Opens the player; five seconds on its route count as watched
  Future<void> onTapLessonVideo(int index) async {
    if (!_ownsCourse || _videoBusy || _contentLease?.isCurrent != true) return;
    final selectedCourse = course.value;
    if (selectedCourse == null ||
        index < 0 ||
        index >= selectedCourse.activities.length) {
      return;
    }
    final activity = selectedCourse.activities[index];
    if (!activity.isOpen) return;
    final url = activity.videoUrl;
    final moduleId = activity.cmId;
    if (url.isEmpty) {
      ToastX.error(message: 'Video is not available');
      return;
    }
    final id = courseId;
    final route = Get.currentRoute;
    final request = _loadGeneration;
    final visit = ++_visitGeneration;
    final lease = _captureScope(
      id,
      operation:
          () =>
              visit == _visitGeneration &&
              request == _loadGeneration &&
              Get.currentRoute == route &&
              identical(course.value, selectedCourse) &&
              selectedCourse.activities.contains(activity),
    );
    final startTime = DateTime.now();
    _videoBusy = true;
    var openNext = false;
    try {
      final result = await Get.toNamed(RouteNameX.videoPlayer, arguments: url);
      if (!lease.isCurrent) return;
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      if (!lease.isCurrent) return;
      final dwell = DateTime.now().difference(startTime);
      // TEMP(backend): see UserStatisticsX.localLearnedSeconds. Not awaited, so
      // saving it never holds the navigation back.
      unawaited(addLearnedSeconds(dwell.inSeconds));
      if (!activity.isCompleted && dwell.inSeconds >= 5) {
        try {
          await DatabaseX.completeVideoOfCourse(cmId: moduleId);
        } catch (e) {
          // Report it, but still refetch below
          if (!lease.isCurrent) return;
          ErrorX.console(e);
          ToastX.error(message: '${"Something wrong".tr}. ${"Try again".tr}');
        }
        if (!lease.isCurrent) return;
      }

      // Back on the course page: always refetch, so the checkmark and unlock show
      final refreshed = await _refreshCourse(lease, id);

      // Not lease.isCurrent: it rejects the course the refetch just published
      openNext =
          refreshed &&
          result == VideoPlayerController.nextResult &&
          _ownsCourse &&
          courseId == id &&
          visit == _visitGeneration &&
          request == _loadGeneration &&
          Get.currentRoute == route;
    } catch (e) {
      if (!lease.isCurrent) return;
      ErrorX.console(e);
      ToastX.error(message: '${"Something wrong".tr}. ${"Try again".tr}');
    } finally {
      if (_ownsCourse && visit == _visitGeneration) _videoBusy = false;
    }
    if (openNext) await openNextActivity(moduleId);
  }

  /// Navigate to lesson quiz, then refetch when the user comes back
  Future<void> onTapLessonQuiz(ActivityX activity) async {
    if (!_ownsCourse ||
        _contentLease?.isCurrent != true ||
        course.value?.activities.contains(activity) != true ||
        !activity.isOpen) {
      return;
    }
    final id = courseId;
    final route = Get.currentRoute;
    final request = _loadGeneration;
    final lease = _captureScope(
      id,
      operation: () => request == _loadGeneration && Get.currentRoute == route,
    );
    await Get.toNamed(RouteNameX.testInfo, arguments: [activity.quizId, id]);
    if (!lease.isCurrent) return;
    await _refreshCourse(lease, id);
  }

  /// Download lesson summary
  Future<void> onTapLessonSummary(ActivityX activity) async {
    if (isLoading ||
        !_ownsCourse ||
        _contentLease?.isCurrent != true ||
        course.value?.activities.contains(activity) != true) {
      return;
    }
    final selectedCourse = course.value!;
    final url = activity.downloadUrl;
    final fileName = '${selectedCourse.name}_${activity.name}';
    // Built before the download so the flag lands on the user who tapped
    final doneKey = LocalKeyX.fileDone(activity.cmId);
    final lease = _captureScope(
      courseId,
      operation: () => identical(course.value, selectedCourse),
    );

    try {
      isLoading = true;
      final saved = await downloadFile(url, fileName);
      if (saved) await _markFileDownloaded(doneKey, activity.cmId);
    } catch (e) {
      if (!lease.isCurrent) return;
      ErrorX.console(e);
    } finally {
      if (lease.isCurrent) isLoading = false;
    }
  }

  /// TEMP(backend): remember the downloaded file locally and show the checkmark
  /// now. Removed together with [_applyLocalProgress].
  Future<void> _markFileDownloaded(String key, String cmId) async {
    await LocalDataX.put<bool>(key, true);
    // Another account may be signed in by now, its page must not change
    if (!_ownsCourse || key != LocalKeyX.fileDone(cmId)) return;
    for (final activity in course.value?.activities ?? <ActivityX>[]) {
      if (activity.cmId == cmId) activity.isFileDownloaded = true;
    }
    course.refresh();
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    _nextAfterQuizId = Get.parameters[nextAfterQuizParam];
  }

  @override
  void onClose() {
    _loadGeneration++;
    _visitGeneration++;
    _refreshGeneration++;
    super.onClose();
  }
}
