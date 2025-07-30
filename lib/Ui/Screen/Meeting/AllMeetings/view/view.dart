import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Widget/Basic/Utils/future_builder.dart';
import '../../../../Widget/Custom/Card/meeting_card.dart';
import '../../../../Widget/Custom/Other/tab_segment.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class AllMeetingsView extends GetView<AllMeetingsController> {
  const AllMeetingsView({super.key});

  /// Build all meetings view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: 'Meetings and Encounters'),
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              /// Tab meetings segment
              Padding(
                padding: EdgeInsets.only(
                  left: StyleX.hPaddingApp,
                  right: StyleX.hPaddingApp,
                  top: StyleX.vPaddingApp,
                  bottom: 16,
                ),
                child: TabSegmentX(
                  controller: controller.tabController,
                  tabs: {1: 'All'.tr, 2: 'Upcoming'.tr, 3: 'Ended'.tr},
                ),
              ).fadeAnimation150,

              /// Get data from the database and show loading state
              if (controller.isLoading.value)
                Expanded(
                  child: FutureBuilderX(
                    future: controller.getData,

                    /// Loading state
                    loading: const AllMeetingsLoading(),
                    child: (_) => SizedBox(),
                  ),
                ),

              /// Content if not loading
              if (!controller.isLoading.value)
                Expanded(
                  child: Obx(
                    () => Column(
                      children: [
                        /// Empty state
                        if (controller.selectedMeetings.isEmpty)
                          Center(
                            child: TextX(
                              "No meetings and encounters currently",
                              style: TextStyleX.titleMedium,
                              color: Theme.of(context).colorScheme.secondary,
                            ).fadeAnimation200.marginOnly(top: 150),
                          ),

                        /// Meetings list by tab
                        if (controller.selectedMeetings.isNotEmpty)
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(
                                left: StyleX.hPaddingApp,
                                right: StyleX.hPaddingApp,
                                bottom: StyleX.vPaddingApp,
                              ),
                              child: Column(
                                children: [
                                  /// Meetings cards
                                  for (var meeting
                                      in controller.selectedMeetings)
                                    MeetingCardX(
                                      meeting: meeting,
                                    ).fadeAnimation200,
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
