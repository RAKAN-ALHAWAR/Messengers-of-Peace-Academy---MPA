import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/Model/activity_point.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Core/core.dart';
import '../../../Widget/Basic/Utils/future_builder.dart';
import '../../../Widget/Custom/Other/empty_message.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class ActivityPiontsView extends GetView<ActivityPiontsController> {
  const ActivityPiontsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: 'Activities and Points List'),
      body: SafeArea(
        /// Get data from the controller
        child: FutureBuilderX<List<ActivityPointX>>(
          future: controller.getData,

          /// Loading state
          loading: const ActivityPiontsLoading(),

          /// Data state
          child: (data) {
            /// Empty message
            if (data.isEmpty) {
              return const EmptyMessage('No activities currently');
            }

            /// Content
            return SingleChildScrollView(
              padding: StyleX.paddingApp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  TextX(
                    'List of activities that give you points',
                    style: TextStyleX.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  /// Description
                  TextX(
                    'Points description',
                    style: TextStyleX.bodyMedium,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 18),

                  /// Activities and Points Cards
                  for (var activity in data)
                    ContainerX(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      margin: EdgeInsets.only(bottom: 12),
                      radius: StyleX.radiusMd,
                      child: Row(
                        children: [
                          /// Name and note
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

                                /// Note
                                if (activity.note.isNotEmpty)
                                  TextX(
                                    activity.note,
                                    style: TextStyleX.labelMedium,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ).marginOnly(top: 4),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          /// Points
                          Row(
                            children: [
                              /// Point icon
                              Image.asset(ImageX.point, width: 11, height: 11),

                              /// Spacer
                              const SizedBox(width: 6),

                              /// Points number
                              TextX(
                                "${FunctionX.formatLargeNumber(activity.points)}+",
                                style: TextStyleX.labelLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).fadeAnimation200,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
