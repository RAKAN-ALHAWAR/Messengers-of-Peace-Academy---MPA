import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Config/config.dart';
import '../../../../Data/Model/course/course_progress.dart';
import '../../../../Data/Model/course/mini_course.dart';
import '../Other/course_progress_loader.dart';
import '../Other/course_progress_bar.dart';
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
  final double width;
  final MiniCourseX course;
  final Function(MiniCourseX) onTap;

  @override
  Widget build(BuildContext context) {
    if (!course.isOpen) return _buildCard(context, null);
    return CourseProgressLoader(
      courseId: course.id,
      snapshot: course,
      builder: (progress) => _buildCard(context, progress),
    );
  }

  Widget _buildCard(BuildContext context, CourseProgressX? progress) {
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

            if (course.isOpen) ...[
              CourseProgressBar(progress: progress),
              const SizedBox(height: 16),
            ],

            /// Course name
            TextX(
              course.name,
              style: TextStyleX.titleMedium,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),

            /// Spacer
            SizedBox(height: 4),

            if (progress != null && progress.total > 0)
              Row(
                children: [
                  /// Lesson icon
                  Icon(
                    progress.isAssessment ? IconX.quiz : IconX.videocam,
                    size: 16,
                  ),

                  /// Spacer
                  SizedBox(width: 4),

                  /// Lesson text
                  Expanded(
                    child: TextX(
                      "${progress.total} ${(progress.isAssessment ? 'Test' : 'lesson').tr}",
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
