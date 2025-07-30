import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

class LoadingCompleteAccountInfo extends StatelessWidget {
  const LoadingCompleteAccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    /// Loading complete account info
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Profile image
          Center(
            child: ShimmerAnimationX(
              height: 100,
              width: 100,
              borderRadius: BorderRadius.circular(100),
              margin: const EdgeInsetsDirectional.only(bottom: 24),
            ),
          ).fadeAnimation100,

          /// Personal information label
          ShimmerAnimationShapeX.label(width: 100).fadeAnimation100,

          /// Date of birth
          ShimmerAnimationShapeX.filedInput().fadeAnimation100,

          /// Whatsapp number
          Row(
            children: [
              Expanded(child: ShimmerAnimationShapeX.filedInput()),
              SizedBox(width: 8),
              ShimmerAnimationShapeX.filedInput(width: 100),
            ],
          ).marginOnly(bottom: 12).fadeAnimation100,

          /// Gender label
          ShimmerAnimationShapeX.label(width: 100).fadeAnimation150,

          /// Gender radio buttons
          Row(
            children: [
              Flexible(child: ShimmerAnimationShapeX.filedInput()),
              SizedBox(width: 8),
              Flexible(child: ShimmerAnimationShapeX.filedInput()),
            ],
          ).marginOnly(bottom: 12).fadeAnimation150,

          /// Others information label
          ShimmerAnimationShapeX.label(width: 100).fadeAnimation150,

          /// Country dropdown
          ShimmerAnimationShapeX.filedInput().fadeAnimation200,

          /// City text field
          ShimmerAnimationShapeX.filedInput().fadeAnimation200,

          /// Native language dropdown
          ShimmerAnimationShapeX.filedInput().fadeAnimation200,

          /// How did you hear about us dropdown
          ShimmerAnimationShapeX.filedInput().fadeAnimation200,

          /// Telegram ID text field
          ShimmerAnimationShapeX.filedInput().fadeAnimation200,

          /// Telegram name text field
          ShimmerAnimationShapeX.filedInput().fadeAnimation200,

          /// Saudi universities label
          ShimmerAnimationShapeX.label(width: 100, height: 14).fadeAnimation250,

          /// Saudi universities radio buttons
          Row(
            children: [
              Flexible(child: ShimmerAnimationShapeX.filedInput()),
              SizedBox(width: 8),
              Flexible(child: ShimmerAnimationShapeX.filedInput()),
            ],
          ).marginOnly(bottom: 20).fadeAnimation250,

          /// Save and complete later buttons
          Row(
            children: [
              Flexible(child: ShimmerAnimationShapeX.button()),
              SizedBox(width: 12),
              Flexible(child: ShimmerAnimationShapeX.button()),
            ],
          ).fadeAnimation300,
        ],
      ),
    );
  }
}
