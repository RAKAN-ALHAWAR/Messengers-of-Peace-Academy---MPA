import 'package:flutter/material.dart';

import '../../../../Config/config.dart';
import '../../../../Data/Model/course/course_progress.dart';
import '../../widget.dart';

class CourseProgressBar extends StatelessWidget {
  const CourseProgressBar({super.key, required this.progress});

  final CourseProgressX? progress;

  static double barHeight(BuildContext context) =>
      ProgressIndicatorTheme.of(context).linearMinHeight ?? 4.0;

  @override
  Widget build(BuildContext context) {
    final progress = this.progress;
    final hasProgress = progress != null && progress.total > 0;
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: TextX(
                hasProgress ? '${progress.done}/${progress.total}' : '–',
                textDirection: TextDirection.ltr,
                style: TextStyleX.labelSmall,
                color: color,
              ),
            ),
            Flexible(
              child: TextX(
                hasProgress ? '${progress.percent}%' : '–',
                textDirection: TextDirection.ltr,
                style: TextStyleX.labelSmall,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          minHeight: barHeight(context),
          value: progress?.fraction ?? 0,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}
