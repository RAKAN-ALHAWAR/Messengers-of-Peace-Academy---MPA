import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/config.dart';

class TestInfoLoading extends StatelessWidget {
  const TestInfoLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: StyleX.paddingApp,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Quiz image
          ShimmerAnimationX(height: 116, width: 130).fadeAnimation100,

          /// Spacer
          SizedBox(height: 24),

          /// Quiz name
          ShimmerAnimationShapeX.label(
            margin: EdgeInsets.only(bottom: 8),
          ).fadeAnimation100,

          /// Quiz description
          ShimmerAnimationShapeX.label(
            height: 16,
            width: 200,
            margin: EdgeInsets.only(bottom: 24),
          ).fadeAnimation100,

          /// Quiz statistics
          Row(
            children: [
              Expanded(child: ShimmerAnimationX(height: 136)),
              SizedBox(width: 12),
              Expanded(child: ShimmerAnimationX(height: 136)),
            ],
          ).fadeAnimation150,

          /// Spacer
          SizedBox(height: 24),

          /// Start test button
          ShimmerAnimationShapeX.button().fadeAnimation150,
        ],
      ),
    );
  }
}
