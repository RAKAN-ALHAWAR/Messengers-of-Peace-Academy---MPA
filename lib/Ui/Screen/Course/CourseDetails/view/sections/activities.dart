import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../../Config/Translation/translation.dart';
import '../../../../../../Config/config.dart';
import '../../../../../Widget/Custom/Other/lesson_item_on_accordion.dart';
import '../../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class CourseDetailsActivitiesSection extends GetView<CourseDetailsController> {
  const CourseDetailsActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Activities list
        for (int i = 0; i < controller.course.value!.activities.length; i++)
          AccordionX(
            height: 78,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            titleWidget: Row(
              children: [
                /// Lock icon
                if (controller.course.value!.activities[i].isOpen == false)
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.12),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(IconX.lock, size: 20),
                    ),
                  )
                else
                  /// Course completion percentage progress bar
                  Center(
                    child: CircularPercentIndicator(
                      radius: 24.0,
                      lineWidth: 5.0,
                      animation: true,
                      percent:
                          controller
                              .course
                              .value!
                              .activities[i]
                              .completionPercent /
                          100,
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Theme.of(context).colorScheme.primary,
                      center: TextX(
                        "%${controller.course.value!.activities[i].completionPercent}",
                        style: TextStyleX.labelMedium,
                        textDirection: TextDirection.ltr,
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
                    /// Lesson item name
                    TextX(
                      "${"Lesson".tr} ${controller.course.value!.activities[i].activityNumber}",
                      style: TextStyleX.labelLarge,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),

                    /// Spacer
                    if (controller
                        .course
                        .value!
                        .activities[i]
                        .topicName
                        .isNotEmpty)
                      SizedBox(height: 4),

                    /// Lesson item topic name
                    if (controller
                        .course
                        .value!
                        .activities[i]
                        .topicName
                        .isNotEmpty)
                      TextX(
                        controller.course.value!.activities[i].topicName,
                        style: TextStyleX.titleSmall,
                      ),
                  ],
                ),
              ],
            ),
            child: Column(
              children: [
                /// Lesson item video
                if (controller.course.value!.activities[i].videoUrl.isNotEmpty)
                  LessonItemOnAccordion(
                    icon: IconX.play_arrow_filled,
                    name: controller.course.value!.activities[i].name,
                    videoDuration:
                        controller.course.value!.activities[i].videoDuration,
                    isCompleted:
                        controller.course.value!.activities[i].isCompleted,
                    onTap: () async {
                      await controller.onTapLessonVideo(i);
                    },
                  ).fadeAnimation100,

                /// Lesson item quiz
                if (controller.course.value!.activities[i].quizId != null)
                  LessonItemOnAccordion(
                    icon: IconX.quiz,
                    name:
                        TranslationX.getLanguageCode == "ar"
                            ? "${"Test".tr} ${controller.course.value!.activities[i].topicName}"
                            : "${controller.course.value!.activities[i].topicName} ${"Test".tr}",
                    // isCompleted: controller.course.value!.activities[i].isCompleted,
                    isCompleted:
                        controller
                            .course
                            .value!
                            .activities[i]
                            .completionPercent >=
                        100,
                    onTap: () {
                      controller.onTapLessonQuiz(
                        controller.course.value!.activities[i],
                      );
                    },
                  ).fadeAnimation100,

                /// Check if there is a summary file
                if (controller
                    .course
                    .value!
                    .activities[i]
                    .downloadUrl
                    .isNotEmpty)
                  /// Lesson item summary
                  LessonItemOnAccordion(
                    icon: IconX.description,
                    name:
                        TranslationX.getLanguageCode == "ar"
                            ? "${"Summary File".tr} ${controller.course.value!.activities[i].topicName}"
                            : "${controller.course.value!.activities[i].topicName} ${"Summary File".tr}",
                    onTap: () {
                      controller.onTapLessonSummary(
                        controller.course.value!.activities[i],
                      );
                    },
                  ).fadeAnimation100,
              ],
            ),
          ).fadeAnimation250,
      ],
    );
  }
}
