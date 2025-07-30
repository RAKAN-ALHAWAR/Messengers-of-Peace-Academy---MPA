import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/config.dart';

class EventDetailsLoading extends StatelessWidget {
  const EventDetailsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Event name
          ShimmerAnimationShapeX.label(width: 150, height: 28).fadeAnimation100,

          /// Spacer
          SizedBox(height: 14, width: double.infinity),

          /// Date
          ShimmerAnimationX(width: 250, height: 25).fadeAnimation100,

          /// Spacer
          SizedBox(height: 10),

          /// Time
          ShimmerAnimationX(width: 250, height: 25).fadeAnimation100,

          /// Spacer
          SizedBox(height: 10),

          /// Repeated
          ShimmerAnimationX(width: 250, height: 25).fadeAnimation150,

          /// Spacer
          SizedBox(height: 24),

          /// Event details title
          ShimmerAnimationShapeX.label(width: 150).fadeAnimation150,

          /// Spacer
          SizedBox(height: 4),

          /// Description
          for (var i = 0; i < 6; i++)
            ShimmerAnimationX(
              width: double.infinity,
              height: 20,
              margin: EdgeInsets.only(bottom: 6),
            ).fadeAnimation150,

          /// Spacer
          SizedBox(height: 24),

          /// Join meeting button
          ShimmerAnimationShapeX.button().fadeAnimation150,
        ],
      ),
    );
  }
}
