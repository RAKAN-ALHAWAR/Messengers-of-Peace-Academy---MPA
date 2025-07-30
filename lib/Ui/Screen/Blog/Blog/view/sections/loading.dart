import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../../../Config/config.dart';

class BlogLoading extends StatelessWidget {
  const BlogLoading({super.key});

  @override
  Widget build(BuildContext context) {
    /// Loading blogs
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Blog Cards
          for (var i = 0; i < 10; i++)
            ShimmerAnimationX(
              height: 124,
              borderRadius: BorderRadius.circular(StyleX.radiusLg),
              margin: EdgeInsets.only(bottom: 16),
            ).fadeAnimation200,
        ],
      ),
    );
  }
}
