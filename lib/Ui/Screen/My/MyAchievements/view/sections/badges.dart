import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/empty_message.dart';

import '../../../../../../Config/config.dart';
import '../../../../../Widget/Custom/Card/badge_card.dart';
import '../../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class MyAchievementsBadgesSection extends GetView<MyAchievementsController> {
  const MyAchievementsBadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Badges Label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Badges Label
            TextX('Achieved Badges', style: TextStyleX.titleMedium),

            /// See all badges button
            if (controller.badges.isNotEmpty)
              GestureDetector(
                onTap: controller.onAllBadges,
                child: TextX(
                  'Badges List',
                  style: TextStyleX.labelLarge,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ).fadeAnimation150,

        /// Spacer
        SizedBox(height: 12),

        /// No badges
        if (controller.badges.isEmpty)
          EmptyMessage(
            'No badges currently',
          ).fadeAnimation200.marginSymmetric(vertical: 40),

        /// Spacer
        SizedBox(height: 24),

        /// Badges List
        if (controller.badges.isNotEmpty)
          Column(
            children: [
              /// Fix the width of the badges list
              SizedBox(width: double.infinity),

              /// Badges List
              Wrap(
                runSpacing: 8,
                spacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  for (
                    var i = 0;
                    i <
                        (controller.badges.length >= 3
                            ? 3
                            : controller.badges.length);
                    i++
                  )
                    BadgeCardX(badge: controller.badges[i]),
                ],
              ).fadeAnimation200.marginOnly(bottom: 8),

              /// If there are more than 3 badges, show the rest
              if (controller.badges.length > 3)
                Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (
                      var i = 3;
                      i <
                          (controller.badges.length >= 6
                              ? 6
                              : controller.badges.length);
                      i++
                    )
                      BadgeCardX(badge: controller.badges[i]),
                  ],
                ).fadeAnimation200.marginOnly(bottom: 8),
            ],
          ),
      ],
    );
  }
}
