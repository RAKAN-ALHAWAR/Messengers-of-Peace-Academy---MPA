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
import '../../../../../Data/data.dart';

class CourseDetailsController extends GetxController {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  bool isLoading = false;
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
    course.value = value;
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
  }

  /// Checkmarks and unlocking come only from the current backend snapshot. A
  /// failed refresh retains prior content and leaves retry available.
  Future<void> _refreshCourse(
    SessionLeaseX lease,
    String id,
    String language,
  ) async {
    try {
      final value = await DatabaseX.getCourse(courseId: id);
      if (!lease.isCurrent) return;
      _publishCourse(value, id, language);
    } catch (e) {
      if (!lease.isCurrent) return;
      ErrorX.console(e);
      ToastX.error(message: '${"Something wrong".tr}. ${"Try again".tr}');
    }
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
    try {
      await Get.toNamed(RouteNameX.videoPlayer, arguments: url);
      if (!lease.isCurrent) return;
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      if (!lease.isCurrent) return;
      final dwell = DateTime.now().difference(startTime);
      if (!activity.isCompleted && dwell.inSeconds >= 5) {
        await DatabaseX.completeVideoOfCourse(cmId: moduleId);
        if (!lease.isCurrent) return;
        await _refreshCourse(lease, id, language);
      }
    } catch (e) {
      if (!lease.isCurrent) return;
      ErrorX.console(e);
      ToastX.error(message: '${"Something wrong".tr}. ${"Try again".tr}');
    } finally {
      if (_ownsCourse && visit == _visitGeneration) _videoBusy = false;
    }
  }

  /// Navigate to lesson quiz
  void onTapLessonQuiz(ActivityX activity) {
    if (_ownsCourse &&
        _contentLease?.isCurrent == true &&
        course.value?.activities.contains(activity) == true &&
        activity.isOpen) {
      Get.toNamed(RouteNameX.testInfo, arguments: [activity.quizId, courseId]);
    }
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
    final lease = _captureScope(
      courseId,
      TranslationX.getLanguageCode,
      operation: () => identical(course.value, selectedCourse),
    );

    /// Download lesson summary
    try {
      isLoading = true;
      await DownloadFileFormUrl.download(url, fileName);
    } catch (e) {
      if (!lease.isCurrent) return;
      ErrorX.console(e);
    } finally {
      if (lease.isCurrent) isLoading = false;
    }
  }

  @override
  void onClose() {
    _loadGeneration++;
    _visitGeneration++;
    super.onClose();
  }
}
