import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Core/Service/download_file_form_url.dart';
import '../../../../../Core/core.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Config/Translation/translation.dart';
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
  String courseId = Get.arguments;
  Rx<CourseX?> course = Rx<CourseX?>(null);

  //============================================================================
  // Functions

  int _loadGeneration = 0;
  int _visitGeneration = 0;
  bool _videoBusy = false;
  SessionLeaseX? _contentLease;

  bool get _ownsCourse =>
      !isClosed &&
      Get.isRegistered<CourseDetailsController>() &&
      identical(Get.find<CourseDetailsController>(), this) &&
      Get.isRegistered<AppControllerX>() &&
      identical(Get.find<AppControllerX>(), app);

  SessionLeaseX _captureScope(
    String id,
    String language, {
    bool Function()? operation,
  }) => SessionLeaseX.capture(
    isActive:
        () =>
            _ownsCourse &&
            courseId == id &&
            TranslationX.getLanguageCode == language &&
            (operation?.call() ?? true),
  );

  void _publishCourse(CourseX value, String id, String language) {
    if (value.id != id) {
      throw ErrorX(message: 'Session changed. Please try again.');
    }
    _contentLease = _captureScope(id, language);
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

  /// The request owns its account, course and locale. A same-course reload also
  /// retires an older navigation callback; its old index cannot target new data.
  Future<void> getData() async {
    if (!_ownsCourse) return;
    final request = ++_loadGeneration;
    _visitGeneration++;
    _videoBusy = false;
    isLoading = false;
    final id = courseId;
    final language = TranslationX.getLanguageCode;
    final lease = _captureScope(
      id,
      language,
      operation: () => request == _loadGeneration,
    );
    if (_contentLease?.isCurrent != true) course.value = null;
    if (!lease.hasAuthenticatedIdentity) {
      throw ErrorX(message: 'Session changed. Please try again.');
    }
    try {
      final value = await DatabaseX.getCourse(courseId: id);
      if (!lease.isCurrent) return;
      _publishCourse(value, id, language);
    } catch (_) {
      if (!lease.isCurrent) return;
      rethrow;
    }
    _openNextAfterPassedQuiz();
  }

  /// Checkmarks and unlocking come only from the current backend snapshot. A
  /// failed refresh retains prior content and leaves retry available.
  /// Returns true only when the fresh course was published.
  Future<bool> _refreshCourse(
    SessionLeaseX lease,
    String id,
    String language,
  ) async {
    try {
      final value = await DatabaseX.getCourse(courseId: id);
      if (!lease.isCurrent) return false;
      _publishCourse(value, id, language);
      return true;
    } catch (e) {
      if (!lease.isCurrent) return false;
      ErrorX.console(e);
      ToastX.error(message: '${"Something wrong".tr}. ${"Try again".tr}');
      return false;
    }
  }

  //============================================================================
  // Next activity

  /// Route parameter the passed-quiz screen sends (the quiz id) so this page
  /// opens the activity after that quiz once the fresh course is loaded.
  static const nextAfterQuizParam = 'nextAfterQuiz';
  String? _nextAfterQuizId;

  /// The activity that follows [cmId] in course order, or null when [cmId] is
  /// the last one, is unknown, or the next activity is still locked.
  /// Activities without any content (no video, quiz or file) are skipped.
  static ActivityX? nextActivityAfter(List<ActivityX> activities, String cmId) {
    final index = activities.indexWhere((a) => a.cmId == cmId);
    if (index < 0) return null;
    for (var i = index + 1; i < activities.length; i++) {
      if (!activities[i].hasContent) continue;
      return activities[i].isOpen ? activities[i] : null;
    }
    return null;
  }

  /// Open the activity after [cmId]: a video opens the player, a quiz opens its
  /// test info and a file starts its download. When there is none, or it is
  /// locked, nothing happens and the user stays on this page.
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

  /// Arriving from a passed quiz: continue with the activity after that quiz.
  /// Not awaited by getData, so the page finishes loading underneath.
  void _openNextAfterPassedQuiz() {
    final quizId = _nextAfterQuizId;
    _nextAfterQuizId = null;
    if (quizId == null) return;
    final quiz = course.value?.activities.firstWhereOrNull(
      (a) => a.quizId == quizId,
    );
    if (quiz != null) openNextActivity(quiz.cmId);
  }

  /// The passed-quiz screen sits right above this page. After it goes back
  /// here: refetch, then continue with the activity after [quizId].
  Future<void> continueAfterPassedQuiz(String quizId) async {
    if (!_ownsCourse || _contentLease?.isCurrent != true) return;
    final id = courseId;
    final language = TranslationX.getLanguageCode;
    final route = Get.currentRoute;
    final request = _loadGeneration;
    final lease = _captureScope(
      id,
      language,
      operation: () => request == _loadGeneration && Get.currentRoute == route,
    );
    if (!await _refreshCourse(lease, id, language)) return;
    final quiz = course.value?.activities.firstWhereOrNull(
      (a) => a.quizId == quizId,
    );
    if (quiz != null) await openNextActivity(quiz.cmId);
  }

  /// Lessons are the topics of the course (the "Lesson 1", "Lesson 2" rows).
  /// A topic counts as one lesson when it has at least one activity with
  /// content: a video, a quiz or a file. Activities without content are skipped.
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

  /// Lessons whose content activities are all done on the server
  /// (is_completed or completion_percent 100)
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

  /// Keep the existing five-second route-dwell trigger until the backend owner
  /// supplies a playback completion contract. This is not measured watch time:
  /// paused/background/seeking rules, minutes and unlocking remain blocked.
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
    final language = TranslationX.getLanguageCode;
    final route = Get.currentRoute;
    final request = _loadGeneration;
    final visit = ++_visitGeneration;
    final lease = _captureScope(
      id,
      language,
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
      // saving it never holds the navigation back. It runs in the root zone
      // because a test clock (fake async) would never finish the disk write
      // and would block the next write to the box.
      Zone.root.run(
        () => UserStatisticsX.addLocalLearnedSeconds(dwell.inSeconds),
      );
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

      /// Back on the course page: always refetch so the checkmark and the
      /// unlocked next lesson show without leaving the page
      final refreshed = await _refreshCourse(lease, id, language);

      /// The player's Next button: continue only with fresh data, and only if
      /// this page is still the one the user came back to
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
    final language = TranslationX.getLanguageCode;
    final route = Get.currentRoute;
    final request = _loadGeneration;
    final lease = _captureScope(
      id,
      language,
      operation: () => request == _loadGeneration && Get.currentRoute == route,
    );
    await Get.toNamed(RouteNameX.testInfo, arguments: [activity.quizId, id]);
    if (!lease.isCurrent) return;
    await _refreshCourse(lease, id, language);
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
      TranslationX.getLanguageCode,
      operation: () => identical(course.value, selectedCourse),
    );

    /// Download lesson summary
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
  /// now. Removed together with [_applyLocalFileFlags].
  Future<void> _markFileDownloaded(String key, String cmId) async {
    await LocalDataX.put<bool>(key, true);
    // Another account may be signed in by now, its page must not change
    if (!_ownsCourse || key != LocalKeyX.fileDone(cmId)) return;
    for (final activity in course.value?.activities ?? <ActivityX>[]) {
      if (activity.cmId == cmId) activity.isFileDownloaded = true;
    }
    course.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    _nextAfterQuizId = Get.parameters[nextAfterQuizParam];
  }

  @override
  void onClose() {
    _loadGeneration++;
    _visitGeneration++;
    super.onClose();
  }
}
