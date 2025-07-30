import 'dart:math';

import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../../../Config/config.dart';

class CalendarEventsLoading extends StatelessWidget {
  const CalendarEventsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    /// Loading calendar events
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        children: [
          /// Events by hour timeline
          for (int i = 0; i < 24; i++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Hour text
                ShimmerAnimationShapeX.label(
                  width: 60,
                  height: 12,
                  margin: EdgeInsets.only(top: 4),
                ),

                /// Spacer
                SizedBox(width: 12),

                /// Timeline events
                Expanded(
                  child: Column(
                    children: [
                      /// Hour separator
                      Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.8),
                        height: 2,
                      ),

                      /// Event card
                      for (int j = 0; j < Random().nextInt(2) + 1; j++)
                        ShimmerAnimationX(
                          height: 60,
                          margin: EdgeInsets.only(top: 8),
                        ),

                      /// Spacer
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ).fadeAnimation150,
        ],
      ),
    );
  }
}
