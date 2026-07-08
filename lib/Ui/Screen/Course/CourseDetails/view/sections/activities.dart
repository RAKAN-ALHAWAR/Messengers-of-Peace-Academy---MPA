import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../../Config/Translation/translation.dart';
import '../../../../../../Config/config.dart';
import '../../../../../../Data/Model/course/activity.dart';
import '../../../../../Widget/Custom/Other/lesson_item_on_accordion.dart';
import '../../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class CourseDetailsActivitiesSection extends GetView<CourseDetailsController> {
  const CourseDetailsActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Group activities by topicId
    final activities = controller.course.value!.activities;
    final Map<int, List<ActivityX>> groupedActivities = {};
    final Map<ActivityX, int> activityIndexMap = {};

    for (int i = 0; i < activities.length; i++) {
      final activity = activities[i];
      // Use topicId as the grouping key
      final topicKey = activity.topicId;

      if (!groupedActivities.containsKey(topicKey)) {
        groupedActivities[topicKey] = [];
      }
      groupedActivities[topicKey]!.add(activity);
      activityIndexMap[activity] = i;
    }

    return Column(
      children: [
        /// Grouped activities list
        for (var topicEntry in groupedActivities.entries)
          if (_hasRenderableContent(topicEntry.value))
            AccordionX(
              height: 78,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              titleWidget: Row(
                children: [
                  /// Lock icon (show if any activity in group is locked)
                  if (topicEntry.value.any((activity) => !activity.isOpen))
                    Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.12),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(IconX.lock, size: 20),
                      ),
                    )
                  else
                    /// Course completion percentage progress bar (average of all activities in group)
                    Center(
                      child: CircularPercentIndicator(
                        radius: 24.0,
                        lineWidth: 5.0,
                        animation: true,
                        percent:
                            (topicEntry.value
                                    .map((a) => a.completionPercent)
                                    .fold<double>(
                                      0.0,
                                      (sum, val) => sum + val,
                                    ) /
                                topicEntry.value.length /
                                100),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Theme.of(context).colorScheme.primary,
                        center: TextX(
                          "%${((topicEntry.value.map((a) => a.completionPercent).fold<double>(0.0, (sum, val) => sum + val) / topicEntry.value.length)).toInt()}",
                          style: TextStyleX.labelMedium,
                          textDirection: TextDirection.ltr,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ),

                  /// Spacer
                  SizedBox(width: 12),

                  /// Lesson item
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Topic name (if available)
                      if (topicEntry.value.first.topicName.isNotEmpty)
                        TextX(
                          topicEntry.value.first.topicName,
                          style: TextStyleX.titleSmall,
                        )
                      else
                        /// Lesson item name (if no topic name)
                        TextX(
                          "${"Lesson".tr} ${topicEntry.value.first.activityNumber}",
                          style: TextStyleX.labelLarge,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),

                      /// Spacer
                      if (_getLessonsCountInGroup(topicEntry.value) > 0)
                        SizedBox(height: 4),

                      /// Activity count (only count lessons with videos, not quizzes)
                      if (_getLessonsCountInGroup(topicEntry.value) > 0)
                        TextX(
                          "${_getLessonsCountInGroup(topicEntry.value)} ${"Lessons".tr}",
                          style: TextStyleX.labelMedium,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ],
              ),
              child: Column(
                children: [
                  /// All activities in this topic group
                  for (int i = 0; i < topicEntry.value.length; i++)
                    ..._buildActivityItems(
                      context,
                      topicEntry.value[i],
                      activityIndexMap[topicEntry.value[i]]!,
                    ),
                ],
              ),
            ).fadeAnimation250,
      ],
    );
  }

  /// Whether a group has any renderable content (video, quiz, or summary file)
  bool _hasRenderableContent(List<ActivityX> activities) {
    return activities.any(
      (a) =>
          a.videoUrl.isNotEmpty || a.quizId != null || a.downloadUrl.isNotEmpty,
    );
  }

  /// Get count of lessons in a group
  /// Rules:
  /// - If there are videos, count the number of videos
  /// - If no videos but there are files (downloadUrl), count as 1 lesson
  /// - Quizzes are never counted
  int _getLessonsCountInGroup(List<ActivityX> activities) {
    // Count videos (excluding quizzes)
    final videoCount =
        activities
            .where(
              (activity) =>
                  activity.videoUrl.isNotEmpty && activity.quizId == null,
            )
            .length;

    // If there are videos, return video count
    if (videoCount > 0) {
      return videoCount;
    }

    // Otherwise, no lessons (only quizzes or empty)
    return 0;
  }

  /// Build activity items (video, quiz, summary) for a single activity
  List<Widget> _buildActivityItems(
    BuildContext context,
    ActivityX activity,
    int originalIndex,
  ) {
    return [
      /// Lesson item video
      if (activity.videoUrl.isNotEmpty)
        LessonItemOnAccordion(
          icon: IconX.play_arrow_filled,
          name: activity.name,
          videoDuration: activity.videoDuration,
          isCompleted: activity.isCompleted,
          onTap: () async {
            await controller.onTapLessonVideo(originalIndex);
          },
        ).fadeAnimation100,

      /// Lesson item quiz
      if (activity.quizId != null)
        LessonItemOnAccordion(
          icon: IconX.quiz,
          name:
              TranslationX.getLanguageCode == "ar"
                  ? "${"Test".tr} ${activity.topicName}"
                  : "${activity.topicName} ${"Test".tr}",
          isCompleted: activity.completionPercent >= 100,
          onTap: () {
            controller.onTapLessonQuiz(activity);
          },
        ).fadeAnimation100,

      /// Check if there is a summary file
      if (activity.downloadUrl.isNotEmpty)
        /// Lesson item summary
        LessonItemOnAccordion(
          icon: IconX.description,
          name:
              TranslationX.getLanguageCode == "ar"
                  ? "${"Summary File".tr} ${activity.topicName}"
                  : "${activity.topicName} ${"Summary File".tr}",
          onTap: () {
            controller.onTapLessonSummary(activity);
          },
        ).fadeAnimation100,
    ];
  }
}
