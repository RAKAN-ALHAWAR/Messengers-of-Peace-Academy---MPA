import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
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
        child: Column(
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

            Expanded(
              child: FutureBuilderX<void>(
                future: controller.getData,
                requestKey: (controller, TranslationX.getLanguageCode),
                loading: const AllMeetingsLoading(),
                child:
                    (_) => Obx(() {
                      if (controller.selectedMeetings.isEmpty) {
                        /// Empty state, in a Column so it sits at the top with
                        /// the original 150 margin instead of the page centre
                        return Column(
                          children: [
                            Center(
                              child: TextX(
                                'No meetings and encounters currently',
                                style: TextStyleX.titleMedium,
                                color: Theme.of(context).colorScheme.secondary,
                              ).fadeAnimation200.marginOnly(top: 150),
                            ),
                          ],
                        );
                      }
                      return ListView.builder(
                        key: PageStorageKey((
                          LocalDataX.sessionRevision,
                          TranslationX.getLanguageCode,
                          controller.tabController.value,
                        )),
                        padding: EdgeInsets.only(
                          left: StyleX.hPaddingApp,
                          right: StyleX.hPaddingApp,
                          bottom: StyleX.vPaddingApp,
                        ),
                        itemCount: controller.selectedMeetings.length,
                        itemBuilder:
                            (_, index) =>
                                MeetingCardX(
                                  meeting: controller.selectedMeetings[index],
                                ).fadeAnimation200,
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
