import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/sectinos/levels_progress.dart';
import '../../../Widget/Basic/Utils/future_builder.dart';
import '../../../Widget/widget.dart';
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

        /// Loading
        loading: const HomeLoading(),

        /// Build body
        child: (_) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: StyleX.vPaddingApp),
            child: Column(
              children: [
                /// Level progress card
                LevelProgressCard(),

                /// Levels progress section
                LevelsProgressSection(),

                /// My progress section
                MyProgressSection(),

                /// Nav cards section
                NavCardsSection(),

                /// Current level section
                CurrentLevelSection(),

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
