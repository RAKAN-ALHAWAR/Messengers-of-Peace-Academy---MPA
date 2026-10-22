import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/sectinos/levels_progress.dart';
import '../../../Widget/Basic/Utils/future_builder.dart';
import '../../../Widget/widget.dart';
import '../../../Widget/Custom/Other/empty_message.dart';
import '../controller/controller.dart';
import 'sectinos/appbar_card.dart';
import 'sectinos/current_level.dart';
import 'sectinos/loading.dart';
import 'sectinos/meetings.dart';
import 'sectinos/my_progress.dart';
import 'sectinos/nav_cards.dart';
import 'sectinos/level_progress_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(
        isBack: false,
        leadingWidth: double.infinity,
        leading: AppBarCard(),
      ),
      body: FutureBuilderX(
        future: controller.getData,
        requestKey: (controller, TranslationX.getLanguageCode),

        /// Loading
        loading: const HomeLoading(),

        /// Build body
        child: (_) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: StyleX.vPaddingApp),
            child: Column(
              children: [
                /// Empty levels are valid data, not a fabricated first level.
                Obx(
                  () =>
                      controller.levels.isEmpty
                          ? const Padding(
                            padding: StyleX.paddingApp,
                            child: EmptyMessage('No courses found'),
                          )
                          : const Column(
                            children: [
                              LevelProgressCard(),
                              LevelsProgressSection(),
                            ],
                          ),
                ),

                /// My progress section
                MyProgressSection(),

                /// Nav cards section
                NavCardsSection(),

                /// Current level section
                Obx(
                  () =>
                      controller.currentLevel.value == null
                          ? const SizedBox.shrink()
                          : const CurrentLevelSection(),
                ),

                /// Meetings section
                MeetingsSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}
