import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/config.dart';

class MyAchievementsLoading extends StatelessWidget {
  const MyAchievementsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Points Card
          ShimmerAnimationX(
            height: 148,
            margin: EdgeInsets.only(bottom: 24),
          ).fadeAnimation100,

          /// Badges Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerAnimationShapeX.label(),
              ShimmerAnimationShapeX.label(),
            ],
          ).fadeAnimation100.marginOnly(bottom: 12),

          /// Badges List
          Wrap(
            runSpacing: 8,
            spacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 6; i++)
                ShimmerAnimationX(width: 114, height: 170),
            ],
          ).fadeAnimation150.marginOnly(bottom: 24),

          /// My Activity Points Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerAnimationShapeX.label(),
              ShimmerAnimationShapeX.label(),
            ],
          ).fadeAnimation150.marginOnly(bottom: 12),

          /// Month
          ShimmerAnimationX(
            height: 12,
            width: 50,
          ).fadeAnimation200.marginOnly(bottom: 12),

          /// My Activity Points List
          for (var i = 0; i < 10; i++)
            ShimmerAnimationX(
              height: 66,
              margin: EdgeInsets.only(bottom: 12),
            ).fadeAnimation200,
        ],
      ),
    );
  }
}
