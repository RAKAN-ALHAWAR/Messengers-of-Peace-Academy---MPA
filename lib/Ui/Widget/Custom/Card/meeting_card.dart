import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';

import '../../../../Config/config.dart';
import '../../../../Data/Model/meeting.dart';
import '../../widget.dart';
import '../Other/meeting_status.dart';

class MeetingCardX extends StatelessWidget {
  const MeetingCardX({super.key, required this.meeting, this.isSmall = false});
  final MeetingX meeting;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteNameX.meetingDetails, arguments: meeting);
      },
      child: ContainerX(
        width: isSmall ? 320 : double.infinity,
        padding: EdgeInsets.all(16),
        margin: EdgeInsetsDirectional.only(
          bottom: isSmall ? 0 : 12,
          end: isSmall ? 12 : 0,
        ),
        radius: StyleX.radiusLg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerX(
              width: 50,
              height: 60,
              radius: StyleX.radiusMd,
              padding: EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextX(
                    meeting.datetime.day.toString(),
                    style: TextStyleX.labelLarge,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4),
                  FittedBox(
                    child: TextX(
                      DateFormat.MMM(
                        TranslationX.getLanguageCode,
                      ).format(meeting.datetime),
                      style: TextStyleX.labelLarge,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSmall)
                    MeetingStatusX(
                      isEnded: meeting.isEnded,
                      status: meeting.status,
                    ),
                  TextX(meeting.name, style: TextStyleX.titleMedium),
                  SizedBox(height: 6),
                  TextX(
                    "${"Lecturer".tr}: ${meeting.lecturer}",
                    style: TextStyleX.labelLarge,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        IconX.schedule,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 8),
                      TextX(
                        meeting.timeRange,
                        style: TextStyleX.labelLarge,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
