import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Widget/Basic/Utils/future_builder.dart';
import '../../../../Widget/Custom/Card/icon_and_title_card.dart';
import '../controller/controller.dart';
import 'sections/actions_button.dart';
import 'sections/loading.dart';

class EventDetailsView extends GetView<EventDetailsController> {
  const EventDetailsView({super.key});

  /// Event details view
  @override
  Widget build(BuildContext context) {
    /// Event details view
    return Obx(() {
      return Scaffold(
        /// App bar
        appBar: AppBarX(
          title: 'Event Details',
          backValue: controller.isChanged.value,
        ),

        /// Actions button
        floatingActionButton: EventDetailsActionsButtonSection(),

        /// Body
        body: SafeArea(
          child: FutureBuilderX(
            /// Get data from database
            future: controller.getData,

            /// Loading
            loading: const EventDetailsLoading(),

            /// Build body
            child: (_) {
              return SingleChildScrollView(
                padding: StyleX.paddingApp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Event name
                    TextX(
                      controller.eventDetails.value.name,
                      style: TextStyleX.titleLarge,
                    ).fadeAnimation150,

                    /// Spacer
                    SizedBox(height: 16),

                    /// Date
                    IconAndTitleCard(
                      icon: IconX.today,
                      value: DateFormat(
                        'EEEE ,d MMMM y',
                        TranslationX.getLanguageCode,
                      ).format(controller.eventDetails.value.dateTimeStart),
                    ).fadeAnimation200,

                    /// Spacer
                    SizedBox(height: 10),

                    /// Time
                    IconAndTitleCard(
                      icon: IconX.schedule,
                      value:
                          "${"From".tr} ${controller.getTimeShow(controller.eventDetails.value.dateTimeStart)} ${"to".tr} ${controller.getTimeShow(controller.eventDetails.value.dateTimeEnd)}",
                    ).fadeAnimation200,

                    /// Repeated
                    if (controller.eventDetails.value.isRepeated &&
                        controller.eventDetails.value.repeatCount > 0)
                      IconAndTitleCard(
                        icon: IconX.repeat,
                        value:
                            "${"Repeated weekly for".tr} ${controller.eventDetails.value.repeatCount} ${"weeks".tr}",
                        isPrimary: true,
                      ).marginOnly(top: 10).fadeAnimation200,

                    /// Spacer
                    SizedBox(height: 24),

                    /// Event details title
                    TextX(
                      "Event Details",
                      style: TextStyleX.titleMedium,
                    ).fadeAnimation250,

                    /// Spacer
                    SizedBox(height: 4),

                    /// Description
                    TextX(
                      controller.eventDetails.value.description,
                      style: TextStyleX.bodyMedium,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ).fadeAnimation250,

                    /// Spacer
                    SizedBox(height: 24),

                    /// Join meeting button
                    if (controller.eventDetails.value.isNow &&
                        controller.eventDetails.value.meetingUrl.isNotEmpty)
                      ButtonX(
                        onTap: controller.onOpenMeeting,
                        text: "Join the meeting".tr,
                        iconData: IconX.videocam,
                      ).fadeAnimation250.marginOnly(top: 24),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
