import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Config/config.dart';
import '../../../../Data/Model/course/mini_course.dart';
import '../../widget.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.width = preferredWidth,
  });
  // Existing visual dimensions are shared with the carousel's text metrics.
  static const preferredWidth = 290.0;
  static const cardPadding = 16.0;
  static const imageHeight = 160.0;
  static const cardGap = 16.0;
  static double progressHeight(BuildContext context) =>
      ProgressIndicatorTheme.of(context).linearMinHeight ?? 4.0;
  final double width;
  final MiniCourseX course;
  final Function(MiniCourseX) onTap;

  /// Lessons the user finished and the lessons the course has
  ///
  /// TEMP(backend): a quiz-only course (like the entry exam) comes with
  /// numsections 0, so the card would read 0/0. Until the server counts the
  /// quiz in numsections we show 1 lesson and done only when the course is
  /// completed. Remove this once get_user_categories_summary counts quizzes.
  (int done, int total) get _lessons {
    if (course.numSections == 0) return (course.isCompleted ? 1 : 0, 1);
    return (course.numCompletionSections, course.numSections);
  }

  @override
  Widget build(BuildContext context) {
    /// Build course card
    return GestureDetector(
      onTap: () async {
        if (course.isOpen) {
          await onTap(course);
        }
      },
      child: ContainerX(
        width: width,
        radius: StyleX.radiusLg,
        padding: const EdgeInsets.all(cardPadding),
        margin: const EdgeInsetsDirectional.only(end: cardGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                /// Course image
                ImageNetworkX(
                  imageUrl: course.image,
                  width: double.maxFinite,
                  height: imageHeight,
                  radius: StyleX.radiusLg,
                ),

                /// Course lock icon
                if (!course.isOpen)
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    end: 14,
                    top: 14,
                    child: BlurX(
                      blur: 10,
                      color: Colors.black.withValues(alpha: 0.2),
                      radius: BorderRadius.circular(100),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        child: Row(
                          children: [
                            /// Lock icon
                            Icon(IconX.lock, size: 14, color: Colors.white),

                            /// Spacer
                            SizedBox(width: 6),

                            /// Closed text
                            TextX(
                              "Closed",
                              style: TextStyleX.labelMedium,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            /// Spacer
            if (!course.isOpen) Spacer(),

            /// Spacer
            SizedBox(height: 16),

            /// Course sections and completion percentage
            if (course.isOpen)
              Column(
                children: [
                  /// Course sections and completion percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Course sections
                      TextX(
                        "${_lessons.$1}/${_lessons.$2}",
                        textDirection: TextDirection.ltr,
                        style: TextStyleX.labelSmall,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),

                      /// Completion percentage
                      TextX(
                        "${course.completionPercent.toInt()}%",
                        style: TextStyleX.labelSmall,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),

                  /// Spacer
                  SizedBox(height: 4, width: double.infinity),

                  /// Completion percentage
                  LinearProgressIndicator(
                    minHeight: progressHeight(context),
                    value: course.completionPercent / 100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  SizedBox(height: 16),
                ],
              ),

            /// Course name
            TextX(
              course.name,
              style: TextStyleX.titleMedium,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),

            /// Spacer
            SizedBox(height: 4),

            /// Course lessons (hidden if no lessons)
            if (course.numSections > 0)
              Row(
                children: [
                  /// Lesson icon
                  Icon(IconX.videocam, size: 16),

                  /// Spacer
                  SizedBox(width: 4),

                  /// Lesson text
                  Expanded(
                    child: TextX(
                      "${course.numSections} ${"lesson".tr}",
                      style: TextStyleX.labelMedium,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

            /// Spacer
            if (!course.isOpen) Spacer(),
          ],
        ),
      ),
    );
  }
}
