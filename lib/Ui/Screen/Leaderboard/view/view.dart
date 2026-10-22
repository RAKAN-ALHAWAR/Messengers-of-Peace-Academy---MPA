import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Data/Model/leaderboard.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: 'Leaderboard'),
      body: SafeArea(
        /// Get data from the controller
        child: FutureBuilderX<List<LeaderboardX>>(
          future: controller.getData,
          requestKey: (controller, TranslationX.getLanguageCode),

          /// Loading state
          loading: const LeaderboardLoading(),

          /// Data state
          child: (data) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: StyleX.vPaddingApp,
                    left: StyleX.hPaddingApp,
                    right: StyleX.hPaddingApp,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title
                        TextX(
                          'Top learners ranked by points 🏆',
                          style: TextStyleX.titleMedium,
                        ),

                        /// Spacer
                        const SizedBox(height: 12),

                        /// Description
                        TextX(
                          'Leaderboard description',
                          style: TextStyleX.bodyMedium,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),

                        /// Spacer
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: StyleX.hPaddingApp,
                    right: StyleX.hPaddingApp,
                    bottom: StyleX.vPaddingApp,
                  ),
                  sliver: SliverList.builder(
                    itemCount: data.length,
                    itemBuilder:
                        (context, index) => KeyedSubtree(
                          key: ValueKey(data[index].id),
                          child:
                              ContainerX(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                margin: EdgeInsets.only(bottom: 12),
                                radius: StyleX.radiusMd,
                                child: Row(
                                  children: [
                                    /// Rank
                                    TextX(
                                      data[index].rank.toString(),
                                      style: TextStyleX.labelLarge,
                                      fontWeight: FontWeight.w600,
                                    ),

                                    /// Spacer
                                    const SizedBox(width: 12),

                                    /// User Image
                                    ImageNetworkX(
                                      imageUrl: data[index].userImage,
                                      width: 42,
                                      height: 42,
                                      radius: 100,
                                    ),

                                    /// Spacer
                                    const SizedBox(width: 12),

                                    /// Username
                                    Expanded(
                                      child: TextX(
                                        data[index].username,
                                        style: TextStyleX.titleSmall,
                                      ),
                                    ),

                                    /// Spacer
                                    const SizedBox(width: 12),

                                    /// Points
                                    Column(
                                      children: [
                                        /// Points
                                        TextX(
                                          FunctionX.formatLargeNumber(
                                            data[index].points,
                                          ),
                                          style: TextStyleX.labelLarge,
                                          fontWeight: FontWeight.w600,
                                        ),

                                        /// Spacer
                                        const SizedBox(height: 4),

                                        /// Points label
                                        TextX(
                                          'points',
                                          style: TextStyleX.labelMedium,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ).fadeAnimation200,
                        ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
