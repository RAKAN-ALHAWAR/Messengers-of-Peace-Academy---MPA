import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../../../Config/config.dart';

class CourseDetailsLoading extends StatelessWidget {
  const CourseDetailsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    /// Loading course details
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Course image
          ShimmerAnimationX(
            height: 200,
            borderRadius: BorderRadius.circular(StyleX.radiusLg),
          ).fadeAnimation100,

          /// Spacer
          SizedBox(height: 24),

          /// Course name
          ShimmerAnimationShapeX.label(
            height: 24,
            margin: EdgeInsets.only(bottom: 12),
          ).fadeAnimation100,

          /// Course level name
          ShimmerAnimationShapeX.label(
            height: 12,
            margin: EdgeInsets.only(bottom: 24),
          ).fadeAnimation100,

          /// Course completion percentage card
          ShimmerAnimationX(
            height: 92,
            borderRadius: BorderRadius.circular(StyleX.radiusLg),
          ).fadeAnimation150,

          /// Spacer
          SizedBox(height: 24),

          /// Course content title
          ShimmerAnimationShapeX.label(
            height: 20,
            margin: EdgeInsets.only(bottom: 16),
          ).fadeAnimation150,

          /// Course content count
          for (var i = 0; i < 8; i++)
            ShimmerAnimationX(
              height: 78,
              margin: EdgeInsetsDirectional.only(bottom: 12),
            ).fadeAnimation150,
        ],
      ),
    );
  }
}
