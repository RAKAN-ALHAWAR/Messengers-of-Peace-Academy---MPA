import 'activity.dart';

/// The learner-facing progress shown in the catalog and in course details.
/// Moodle still owns course completion and unlocks.
class CourseProgressX {
  const CourseProgressX._(this.done, this.total, {this.isAssessment = false});

  static const empty = CourseProgressX._(0, 0);

  factory CourseProgressX.fromActivities(List<ActivityX> activities) {
    final lessonTopics = <int>{};
    final incompleteTopics = <int>{};
    var tests = 0;
    var finishedTests = 0;
    for (final activity in activities) {
      if (activity.isLesson) lessonTopics.add(activity.topicId);
      if ((activity.isLesson || activity.quizId != null) &&
          !activity.isServerDone) {
        incompleteTopics.add(activity.topicId);
      }
      if (activity.quizId != null) {
        tests++;
        if (activity.isServerDone) finishedTests++;
      }
    }
    if (lessonTopics.isNotEmpty) {
      final incomplete = lessonTopics.intersection(incompleteTopics).length;
      return CourseProgressX._(
        lessonTopics.length - incomplete,
        lessonTopics.length,
      );
    }
    if (tests == 0) return empty;
    return CourseProgressX._(finishedTests, tests, isAssessment: true);
  }

  final int done;
  final int total;
  final bool isAssessment;

  int get lessonsTotal => isAssessment ? 0 : total;
  int get lessonsDone => isAssessment ? 0 : done;
  double get fraction => total == 0 ? 0 : done / total;
  int get percent => total == 0 ? 0 : done * 100 ~/ total;
}
