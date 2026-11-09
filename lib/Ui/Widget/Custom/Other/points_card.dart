import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/Model/badge.dart';

import '../../../../Config/config.dart';
import '../../widget.dart';
import 'gradient_progress_bar.dart';

class PointsCardX extends StatelessWidget {
  const PointsCardX({super.key, required this.points, required this.badge});
  final int points;
  final BadgeX? badge;

  @override
  Widget build(BuildContext context) {
    final target = badge;
    final hasTarget = target != null && target.hasPointsTarget;
    final targetPoints = hasTarget ? target.requiredPoints : 0;
    final progressPoints = points.clamp(0, targetPoints);

    return Container(
      decoration: BoxDecoration(
        gradient: ColorX.goldGradient,
        borderRadius: BorderRadius.circular(StyleX.radiusMd),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                ImageX.background,
                fit: BoxFit.fitHeight,
                alignment: Alignment.center,
              ),
            ),
          ),
          Container(
            // Keep the original compact geometry while allowing full scaled
            // translations and long badge names to determine the card height.
            constraints: const BoxConstraints(minHeight: 160),
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: 4),
                    TextX(
                      "${"My current points".tr} $points",
                      style: TextStyleX.titleMedium,
                      color: ColorX.yellow.shade900,
                    ),
                    SizedBox(height: 6),
                    TextX(
                      hasTarget
                          ? "${"You have".tr} ${FunctionX.formatLargeNumber(targetPoints - progressPoints)} ${"points left to get".tr} ${target.name}"
                          : "No current points target",
                      style: TextStyleX.labelMedium,
                      color: ColorX.yellow.shade900,
                    ),
                  ],
                ),
                GlassX(
                  isLight: true,
                  opacity: 0.35,
                  radius: BorderRadius.circular(100),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: GradientProgressBar(
                      value: hasTarget ? progressPoints / targetPoints : 0,
                    ),
                  ),
                ).marginSymmetric(vertical: 4),
                TextX(
                  // Isolate the fraction so it keeps its order in RTL text.
                  hasTarget
                      ? '\u2066${FunctionX.formatLargeNumber(progressPoints)}/${FunctionX.formatLargeNumber(targetPoints)}\u2069 ${"points".tr}'
                      : 'Points progress unavailable',
                  style: TextStyleX.labelMedium,
                  fontWeight: FontWeight.w600,
                  color: ColorX.yellow.shade900,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
