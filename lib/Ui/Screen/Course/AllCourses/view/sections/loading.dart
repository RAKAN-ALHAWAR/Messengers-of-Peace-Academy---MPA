import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../../../Config/config.dart';

class AllCoursesLoading extends StatelessWidget {
  const AllCoursesLoading({super.key});

  @override
  Widget build(BuildContext context) {
    /// Loading all courses
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: StyleX.vPaddingApp),
      child: Column(
        children: [
          /// Level sections
          for (var i = 0; i < 10; i++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Level name
                ShimmerAnimationShapeX.label().paddingSymmetric(
                  horizontal: StyleX.hPaddingApp,
                ),

                /// Course cards for each level
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.only(
                    start: StyleX.hPaddingApp,
                    top: 14,
                    bottom: 24,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        /// Course cards
                        for (var i = 0; i < 10; i++)
                          ShimmerAnimationX(
                            height: 250,
                            width: 290,
                            margin: EdgeInsetsDirectional.only(end: 16),
                            borderRadius: BorderRadius.circular(
                              StyleX.radiusLg,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ).fadeAnimation150,
        ],
      ),
    );
  }
}
