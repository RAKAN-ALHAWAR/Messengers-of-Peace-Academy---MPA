import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Data/Model/badge.dart';
import '../../../Widget/Basic/Utils/future_builder.dart';
import '../../../Widget/Custom/Other/empty_message.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class BadgesView extends GetView<BadgesController> {
  const BadgesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: 'Badges List'),
      body: SafeArea(
        /// Get data from the controller
        child: FutureBuilderX<List<BadgeX>>(
          future: controller.getData,

          /// Loading state
          loading: const BadgesLoading(),

          /// Data state
          child: (data) {
            /// Empty message
            if (data.isEmpty) {
              return const EmptyMessage('No badges currently');
            }

            /// Content
            return SingleChildScrollView(
              padding: StyleX.paddingApp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  TextX('Badges List', style: TextStyleX.titleMedium),
                  const SizedBox(height: 12),

                  /// Description
                  TextX(
                    'Badges description',
                    style: TextStyleX.bodyMedium,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 18),

                  /// Badge Cards
                  for (var badge in data)
                    ContainerX(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      margin: EdgeInsets.only(bottom: 12),
                      radius: StyleX.radiusMd,
                      child: Row(
                        children: [
                          /// Badge image
                          Image.asset(ImageX.badge3, width: 60),

                          /// Spacer
                          const SizedBox(width: 15),

                          /// Badge name and description
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Badge name
                                TextX(
                                  badge.name,
                                  style: TextStyleX.titleMedium,
                                ),

                                /// Spacer
                                const SizedBox(height: 4),

                                /// Badge description
                                TextX(
                                  "${"Awarded upon reaching".tr} ${FunctionX.formatLargeNumber(badge.requiredPoints)} ${"points".tr} - ${badge.description}",
                                  style: TextStyleX.labelMedium,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
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
