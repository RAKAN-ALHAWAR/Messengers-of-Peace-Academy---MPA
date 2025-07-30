import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/config.dart';

class AllMeetingsLoading extends StatelessWidget {
  const AllMeetingsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: StyleX.hPaddingApp,
        right: StyleX.hPaddingApp,
        bottom: StyleX.vPaddingApp,
      ),
      child: Column(
        children: [
          for (var i = 0; i < 10; i++)
            ShimmerAnimationX(
              height: 140,
              margin: EdgeInsets.only(bottom: 12),
            ).fadeAnimation200,
        ],
      ),
    );
  }
}
