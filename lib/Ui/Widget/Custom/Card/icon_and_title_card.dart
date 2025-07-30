import 'package:flutter/material.dart';

import '../../../../Config/config.dart';
import '../../widget.dart';

class IconAndTitleCard extends StatelessWidget {
  const IconAndTitleCard({
    super.key,
    required this.icon,
    required this.value,
    this.isPrimary = false,
    this.iconSize,
  });
  final IconData icon;
  final double? iconSize;
  final String value;
  final bool isPrimary;

  /// Row event card
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Icon
        Icon(
          icon,
          size: iconSize,
          color:
              isPrimary
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
        ),

        /// Spacer
        SizedBox(width: 11),

        /// Text value
        TextX(
          value,
          style: TextStyleX.bodyMedium,
          color:
              isPrimary
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}
