import 'package:flutter/material.dart';
import '../../../../Config/config.dart';
import '../../../../Core/core.dart';
import '../../widget.dart';

/// Shared presentation for a catalog activity or an earned-history entry.
class ActivityPointsCard extends StatelessWidget {
  const ActivityPointsCard({
    super.key,
    required this.name,
    required this.points,
    this.secondaryText = '',
    this.secondaryDirection,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  final String name;
  final int points;
  final String secondaryText;
  final TextDirection? secondaryDirection;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return ContainerX(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: margin,
      radius: StyleX.radiusMd,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextX(
                  name,
                  style: TextStyleX.labelLarge,
                  fontWeight: FontWeight.w600,
                ),
                if (secondaryText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextX(
                      secondaryText,
                      style: TextStyleX.labelMedium,
                      textDirection: secondaryDirection,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(ImageX.point, width: 11, height: 11),
              const SizedBox(width: 6),
              TextX(
                '${FunctionX.formatLargeNumber(points)}+',
                style: TextStyleX.labelLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
