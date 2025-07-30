import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Config/config.dart';
import '../../../../Data/Model/event.dart';
import '../../widget.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.color,
    required this.onTap,
  });
  final EventX event;
  final MaterialColor color;
  final Function(EventX) onTap;

  /// Get time show
  String getTimeShow(DateTime val) {
    /// Get symbol
    String sym = val.hour > 12 ? "PM" : "AM";

    /// Get hour
    String hour =
        "${val.hour > 12
            ? (val.hour - 12).toString().padLeft(2, '0')
            : val.hour == 0
            ? 12
            : val.hour.toString().padLeft(2, '0')}:${val.minute.toString().padLeft(2, '0')}";

    /// Return hour and symbol
    return "$hour ${sym.tr}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(event),
      child: ContainerX(
        minHeight: 60,
        width: double.infinity,
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(12),
        color: context.isDarkMode ? color.shade900 : color.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Event name
            TextX(
              event.name,
              style: TextStyleX.labelMedium,
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? color.shade100 : color.shade900,
            ),

            /// Spacer
            SizedBox(height: 4),

            /// Event time
            TextX(
              "${getTimeShow(event.dateTimeStart)} - ${getTimeShow(event.dateTimeEnd)}",
              style: TextStyleX.labelMedium,
              color: context.isDarkMode ? color.shade100 : color.shade900,
            ),
          ],
        ),
      ),
    );
  }
}
