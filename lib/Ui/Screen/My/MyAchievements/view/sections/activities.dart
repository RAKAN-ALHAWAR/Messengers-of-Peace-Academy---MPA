import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/Translation/translation.dart';
import '../../../../../../Config/config.dart';
import '../../../../../../Data/Model/my_activity_point.dart';
import '../../../../../Widget/Custom/Card/activity_points_card.dart';
import '../../../../../Widget/Custom/Other/empty_message.dart';
import '../../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class MyAchievementsActivitiesSection
    extends GetView<MyAchievementsController> {
  const MyAchievementsActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Flatten lightweight group entries, not widgets. SliverList constructs
    // only the month headings and activity cards near the current viewport.
    final rows = <Object>[
      for (final group in controller.groupActivityPointsByMonth().entries) ...[
        group.key,
        ...group.value,
      ],
    ];
    final dateFormat = DateFormat(
      'dd MMMM yyyy  h:mma',
      TranslationX.getLanguageCode,
    )..useNativeDigits = false;
    return SliverList.builder(
      itemCount: rows.isEmpty ? 2 : rows.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: [
              TextX('Points History', style: TextStyleX.titleMedium),
              GestureDetector(
                onTap: controller.onAllActivityPoints,
                child: TextX(
                  'Activities List',
                  style: TextStyleX.labelLarge,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ).fadeAnimation250.marginOnly(bottom: 8);
        }
        if (rows.isEmpty) {
          return const EmptyMessage(
            'No activities currently',
          ).fadeAnimation250.marginSymmetric(vertical: 40);
        }
        final row = rows[index - 1];
        if (row is String) {
          return TextX(
            row,
            style: TextStyleX.labelLarge,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ).marginOnly(bottom: 12, top: 4).fadeAnimation300;
        }
        final activity = row as MyActivityPointX;
        return ActivityPointsCard(
          name: activity.activityName,
          points: activity.points,
          secondaryText: dateFormat.format(activity.dateTime),
          secondaryDirection: TextDirection.ltr,
          margin: const EdgeInsets.only(bottom: 8),
        ).fadeAnimation300;
      },
    );
  }
}
