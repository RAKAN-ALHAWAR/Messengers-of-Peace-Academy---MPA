import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/config.dart';
import '../../../../../Animation/animation.dart';

class MyCoursesLoading extends StatelessWidget {
  const MyCoursesLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        children: [
          for (var i = 0; i < 10; i++)
            ShimmerAnimationX(
              height: 124,
              margin: EdgeInsets.only(bottom: 16),
            ).fadeAnimation150,
        ],
      ),
    );
  }
}
