import 'package:flutter/material.dart';

import '../../../../Config/config.dart';
import '../../widget.dart';

class LessonItemOnAccordion extends StatelessWidget {
  const LessonItemOnAccordion({
    super.key,
    required this.icon,
    required this.name,
    this.videoDuration,
    this.isCompleted = false,
    this.onTap,
  });
  final IconData icon;
  final String name;
  final String? videoDuration;
  final bool isCompleted;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 12),
                Expanded(child: TextX(name, style: TextStyleX.titleSmall)),
                SizedBox(width: 12),
                if (videoDuration != null)
                  TextX(
                    videoDuration!,
                    style: TextStyleX.labelLarge,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                if (isCompleted)
                  Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: EdgeInsetsDirectional.only(start: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        gradient: ColorX.primaryGradient2,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(IconX.check, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }
}
