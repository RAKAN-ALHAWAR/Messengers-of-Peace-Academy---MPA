import 'package:flutter/material.dart';
import 'package:messengersofpeace/Config/config.dart';

class GradientProgressBar extends StatelessWidget {
  final double value; // من 0.0 إلى 1.0
  final double height;
  final BorderRadius borderRadius;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 12,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7), // الخلفية
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerRight,
          widthFactor: value.clamp(0.0, 1.0), // نسبة التقدم
          child: Container(
            decoration: BoxDecoration(
              gradient: ColorX.primaryGradient,
              borderRadius: borderRadius,
            ),
          ),
        ),
      ),
    );
  }
}
