import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Config/config.dart';
import '../../../../Data/Model/course/mini_course.dart';
import '../../widget.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, required this.onTap});
  final MiniCourseX course;
  final Function(MiniCourseX) onTap;

  @override
  Widget build(BuildContext context) {
    /// Build course card
    return GestureDetector(
      onTap: () => onTap(course),
      child: ContainerX(
        width: 290,
        radius: StyleX.radiusLg,
        padding: EdgeInsets.all(16),
        margin: EdgeInsetsDirectional.only(end: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                /// Course image
                ImageNetworkX(
                  imageUrl: course.image,
                  width: double.maxFinite,
                  height: 160,
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
                        "${course.numSections}/${course.numCompletionSections}",
                        style: TextStyleX.labelSmall,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),

                      /// Completion percentage
                      TextX(
                        "${course.completionPercent}%",
                        style: TextStyleX.labelSmall,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),

                  /// Spacer
                  SizedBox(height: 4, width: double.infinity),

                  /// Completion percentage
                  LinearProgressIndicator(
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

            /// Course lessons
            Row(
              children: [
                /// Lesson icon
                Icon(IconX.videocam, size: 16),

                /// Spacer
                SizedBox(width: 4),

                /// Lesson text
                TextX(
                  "${course.numSections} ${"lesson".tr}",
                  style: TextStyleX.labelMedium,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
