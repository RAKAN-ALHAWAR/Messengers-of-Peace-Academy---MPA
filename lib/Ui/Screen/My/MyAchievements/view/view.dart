import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Widget/Basic/Utils/future_builder.dart';
import '../../../../Widget/Custom/Other/points_card.dart';
import '../controller/controller.dart';
import 'sections/activities.dart';
import 'sections/badges.dart';
import 'sections/loading.dart';

class MyAchievementsView extends GetView<MyAchievementsController> {
  const MyAchievementsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: 'Achievements Board'),
      body: SafeArea(
        /// Get data from the controller
        child: FutureBuilderX(
          future: controller.getData,
          requestKey: (controller, TranslationX.getLanguageCode),

          /// Loading state
          loading: const MyAchievementsLoading(),

          /// Data state
          child: (_) {
            return CustomScrollView(
              key: PageStorageKey((
                controller,
                LocalDataX.sessionRevision,
                TranslationX.getLanguageCode,
                'achievement-history',
              )),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: StyleX.hPaddingApp,
                    right: StyleX.hPaddingApp,
                    top: StyleX.vPaddingApp,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.currentBadge != null)
                          PointsCardX(
                            points: controller.app.user.value.points,
                            badge: controller.currentBadge!,
                          ).fadeAnimation150.marginOnly(bottom: 24),
                        const MyAchievementsBadgesSection(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.only(
                    left: StyleX.hPaddingApp,
                    right: StyleX.hPaddingApp,
                    bottom: StyleX.vPaddingApp,
                  ),
                  sliver: MyAchievementsActivitiesSection(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
