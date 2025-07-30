import 'package:flutter/material.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

class NotificationsLoading extends StatelessWidget {
  const NotificationsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// Mark all as read button
          ShimmerAnimationShapeX.label().fadeAnimation100,

          /// Notifications list cards
          for (var i = 0; i < 10; i++)
            ShimmerAnimationX(
              height: 97,
              margin: EdgeInsets.only(bottom: 12),
            ).fadeAnimation150,
        ],
      ),
    );
  }
}
