import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/meeting_status.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../../Config/Translation/translation.dart';
import '../../../../Widget/Custom/Card/icon_and_title_card.dart';
import '../controller/controller.dart';

class MeetingDetailsView extends GetView<MeetingDetailsController> {
  const MeetingDetailsView({super.key});

  /// Build meeting details view
  @override
  Widget build(BuildContext context) {
    /// Meeting details view
    return Scaffold(
      appBar: AppBarX(title: 'Meeting Details'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: StyleX.paddingApp,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Meeting status
              MeetingStatusX(
                isEnded: controller.meeting.isEnded,
                status: controller.meeting.status,
              ).fadeAnimation150,

              /// Meeting name
              TextX(
                controller.meeting.name,
                style: TextStyleX.titleMedium,
              ).fadeAnimation150,
              SizedBox(height: 8),

              /// Meeting lecturer
              TextX(
                "${"Lecturer".tr}: ${controller.meeting.lecturer}",
                style: TextStyleX.bodyMedium,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ).fadeAnimation200,
              SizedBox(height: 10),

              /// Meeting date
              IconAndTitleCard(
                icon: IconX.today,
                iconSize: 20,
                value: DateFormat(
                  'EEEE ,d MMMM y',
                  TranslationX.getLanguageCode,
                ).format(controller.meeting.datetime),
                isPrimary: true,
              ).fadeAnimation200,

              /// Spacer
              SizedBox(height: 10),

              /// Range time
              IconAndTitleCard(
                icon: IconX.schedule,
                iconSize: 20,
                value: controller.meeting.timeRange,
              ).fadeAnimation200,

              /// Spacer
              SizedBox(height: 10),

              /// Location
              IconAndTitleCard(
                icon: IconX.location_on,
                iconSize: 20,
                value: controller.meeting.location,
              ).fadeAnimation250,

              /// Spacer
              SizedBox(height: 24),

              /// Encounter details title
              TextX(
                "Encounter Details",
                style: TextStyleX.titleMedium,
              ).fadeAnimation250,

              /// Spacer
              SizedBox(height: 4),

              /// Encounter description
              TextX(
                controller.meeting.description,
                style: TextStyleX.bodyMedium,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ).fadeAnimation250,

              /// Join the meeting button
              if (!controller.meeting.isEnded &&
                  controller.meeting.url.isNotEmpty)
                ButtonX(
                  text: "Join the meeting".tr,
                  iconData: IconX.videocam,
                  onTap: controller.onOpenMeetingUrl,
                ).fadeAnimation250.marginOnly(top: 24),
            ],
          ),
        ),
      ),
    );
  }
}
