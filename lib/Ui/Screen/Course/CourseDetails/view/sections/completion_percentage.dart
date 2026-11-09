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
    final progress = controller.progress;
    if (progress.total == 0) return const SizedBox.shrink();

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
          Wrap(
            spacing: 6,
            children: [
              TextX(
                progress.isAssessment ? 'Test progress' : 'Lesson progress',
                style: TextStyleX.labelMedium,
                color: ColorX.yellow.shade900,
              ),
              TextX(
                '${progress.percent}%',
                textDirection: TextDirection.ltr,
                style: TextStyleX.labelMedium,
                color: ColorX.yellow.shade900,
              ),
            ],
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
                    child: GradientProgressBar(value: progress.fraction),
                  ),

                  /// Spacer
                  SizedBox(width: 10),

                  /// Course completion percentage text
                  /// Done lessons out of all lessons (digits stay left to right)
                  TextX(
                    "${progress.done}/${progress.total}",
                    textDirection: TextDirection.ltr,
                    style: TextStyleX.labelMedium,
                    color: ColorX.onSurfaceVariant,
                  ),

                  /// Spacer
                  SizedBox(width: 4),

                  /// Lesson word
                  TextX(
                    progress.isAssessment ? "Test" : "lesson",
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
