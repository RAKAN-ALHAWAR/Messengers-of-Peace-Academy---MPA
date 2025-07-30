import 'package:flutter/material.dart';
import '../../../../Config/config.dart';
import '../../widget.dart';

class StatisticsCardX extends StatelessWidget {
  final String title;
  final String value;
  final String subValue;
  final IconData icon;

  const StatisticsCardX({
    required this.title,
    required this.value,
    required this.subValue,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerX(
      width: double.maxFinite,
      padding: EdgeInsets.all(16),
      radius: StyleX.radiusLg,
      isBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
          SizedBox(height: 28),
          Spacer(),
          TextX(title, style: TextStyleX.labelLarge),
          SizedBox(height: 4),
          Row(
            children: [
              TextX(value, style: TextStyleX.titleMedium),
              SizedBox(width: 4),
              TextX(subValue, style: TextStyleX.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}
