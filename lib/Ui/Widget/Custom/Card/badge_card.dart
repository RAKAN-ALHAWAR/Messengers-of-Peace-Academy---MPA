import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Core/core.dart';

import '../../../../Config/config.dart';
import '../../../../Data/Model/badge.dart';
import '../../widget.dart';

class BadgeCardX extends StatelessWidget {
  const BadgeCardX({super.key, required this.badge});
  final BadgeX badge;

  @override
  Widget build(BuildContext context) {
    return ContainerX(
      width: 114,
      height: 170,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      radius: StyleX.radiusMd,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AddParentX(
            isAdd: !badge.earned,
            parent:
                (child) => Opacity(
                  opacity: 0.6,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix([
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: child,
                  ),
                ),
            child: Image.asset(ImageX.badge3, width: 75),
          ),

          SizedBox(height: 12),
          FittedBox(
            child: TextX(
              badge.name,
              style: TextStyleX.labelMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          FittedBox(
            child: TextX(
              "${"Required".tr} ${FunctionX.formatLargeNumber(badge.requiredPoints)} ${"points".tr}",
              style: TextStyleX.labelMedium,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
