import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/Translation/translation.dart';
import '../../../../../../Config/config.dart';
import '../../../../../../Core/core.dart';
import '../../../../../Widget/Custom/Other/empty_message.dart';
import '../../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class MyAchievementsActivitiesSection
    extends GetView<MyAchievementsController> {
  const MyAchievementsActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// My Activity Points Label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Points History Label
            TextX('Points History', style: TextStyleX.titleMedium),

            /// Activities List
            GestureDetector(
              onTap: controller.onAllActivityPoints,
              child: TextX(
                'Activities List',
                style: TextStyleX.labelLarge,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ).fadeAnimation250.marginOnly(bottom: 8),

        /// No activities
        if (controller.myActivityPoints.isEmpty)
          EmptyMessage(
            'No activities currently',
          ).fadeAnimation250.marginSymmetric(vertical: 40),

        /// Activities
        if (controller.myActivityPoints.isNotEmpty)
          Column(
            children: [
              for (var activitiesMonth
                  in controller.groupActivityPointsByMonth().entries)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Month
                    TextX(
                      activitiesMonth.key,
                      style: TextStyleX.labelLarge,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ).marginOnly(bottom: 12, top: 4).fadeAnimation300,

                    /// Activities Cards
                    for (var activity in activitiesMonth.value)
                      ContainerX(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        margin: EdgeInsets.only(bottom: 8),
                        radius: StyleX.radiusMd,
                        child: Row(
                          children: [
                            /// Activity Name and Date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  /// Name
                                  TextX(
                                    activity.activityName,
                                    style: TextStyleX.labelLarge,
                                    fontWeight: FontWeight.w600,
                                  ),

                                  /// Date
                                  TextX(
                                    DateFormat(
                                      'dd MMMM yyyy  h:mma',
                                      TranslationX.getLanguageCode,
                                    ).format(activity.dateTime),
                                    style: TextStyleX.labelMedium,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ).marginOnly(top: 4),
                                ],
                              ),
                            ),

                            /// Spacer
                            const SizedBox(width: 12),

                            /// Activity Points
                            Row(
                              children: [
                                /// Points Icon
                                Image.asset(
                                  ImageX.point,
                                  width: 11,
                                  height: 11,
                                ),

                                /// Spacer
                                const SizedBox(width: 6),

                                /// Points Value
                                TextX(
                                  "${FunctionX.formatLargeNumber(activity.points)}+",
                                  style: TextStyleX.labelLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).fadeAnimation300,
                  ],
                ),
            ],
          ),
      ],
    );
  }
}
