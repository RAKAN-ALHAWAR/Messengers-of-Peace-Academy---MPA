import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Config/config.dart';
import '../../../../../Widget/Custom/Other/gradient_progress_bar.dart';
import '../../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class CourseDetailsCompletionPercentageSection
    extends GetView<CourseDetailsController> {
  const CourseDetailsCompletionPercentageSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Course completion percentage section
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ColorX.goldGradient,
        borderRadius: BorderRadius.circular(StyleX.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Course completion percentage text
          TextX(
            "${"You have completed".tr} ${controller.course.value!.completionPercent.toInt()}% ${"of the course.".tr}",
            style: TextStyleX.labelMedium,
            color: ColorX.yellow.shade900,
          ),

          /// Spacer
          SizedBox(height: 10),

          /// Course completion percentage progress bar
          GlassX(
            isLight: true,
            opacity: 0.35,
            radius: BorderRadius.circular(100),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  /// Course completion percentage progress bar
                  Flexible(
                    child: GradientProgressBar(
                      value: controller.course.value!.completionPercent / 100,
                    ),
                  ),

                  /// Spacer
                  SizedBox(width: 10),

                  /// Course completion percentage text
                  /// Done lessons out of all lessons (digits stay left to right)
                  TextX(
                    "${controller.lessonsDone}/${controller.lessonsTotal}",
                    textDirection: TextDirection.ltr,
                    style: TextStyleX.labelMedium,
                    color: ColorX.onSurfaceVariant,
                  ),

                  /// Spacer
                  SizedBox(width: 4),

                  /// Lesson word
                  TextX(
                    "lesson",
                    style: TextStyleX.labelMedium,
                    color: ColorX.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
