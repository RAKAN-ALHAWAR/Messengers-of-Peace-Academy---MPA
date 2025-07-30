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
  final BadgeX badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: ColorX.goldGradient,
        borderRadius: BorderRadius.circular(StyleX.radiusMd),
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              ImageX.background,
              height: 160,
              width: double.infinity,
              fit: BoxFit.fitHeight,
              alignment: Alignment.center,
            ),
          ),
          Container(
            height: 160,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
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
                      "${"You have".tr} ${FunctionX.formatLargeNumber(badge.requiredPoints - points)} ${"points left to get".tr} ${badge.name}",
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
                      value: points / badge.requiredPoints,
                    ),
                  ),
                ).marginSymmetric(vertical: 4),
                TextX(
                  "${FunctionX.formatLargeNumber(badge.requiredPoints)}/${FunctionX.formatLargeNumber(points)} ${"points".tr}",
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
