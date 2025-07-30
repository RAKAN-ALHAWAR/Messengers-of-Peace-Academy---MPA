import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/config.dart';
import '../../../../../Animation/animation.dart';

class MyCertificatesLoading extends StatelessWidget {
  const MyCertificatesLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Labels
          ShimmerAnimationShapeX.label().fadeAnimation150,

          /// Cards
          for (var i = 0; i < 10; i++)
            ShimmerAnimationX(
              height: 78,
              margin: EdgeInsets.only(bottom: 12),
            ).fadeAnimation150,
        ],
      ),
    );
  }
}
