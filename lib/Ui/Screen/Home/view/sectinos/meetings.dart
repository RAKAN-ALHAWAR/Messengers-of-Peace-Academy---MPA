import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/meeting_card.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Config/config.dart';
import '../../../../Widget/Basic/Other/label.dart';
import '../../controller/controller.dart';

class MeetingsSection extends GetView<HomeController> {
  const MeetingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Build meetings section
    return Column(
      children: [
        /// Meetings label and view all button
        Padding(
          padding: EdgeInsets.only(
            left: StyleX.hPaddingApp,
            right: StyleX.hPaddingApp,
            bottom: 12,
          ),
          child:
              Row(
                children: [
                  /// Meetings label
                  Expanded(child: LabelX("Upcoming Meetings and Encounters")),

                  /// View all button
                  GestureDetector(
                    onTap: controller.onAllMeetings,
                    child: TextX(
                      "View All",
                      style: TextStyleX.labelLarge,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ).fadeAnimation450,
        ),

        /// Meetings cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsetsDirectional.only(start: StyleX.hPaddingApp),
          child: IntrinsicHeight(
            child: Row(
              children: [
                /// Meetings cards
                for (var meeting in controller.meetings.take(3))
                  MeetingCardX(meeting: meeting, isSmall: true),
              ],
            ),
          ),
        ).fadeAnimation400,
      ],
    );
  }
}
