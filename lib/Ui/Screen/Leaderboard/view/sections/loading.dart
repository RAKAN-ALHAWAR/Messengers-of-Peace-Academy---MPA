import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Config/config.dart';

class LeaderboardLoading extends StatelessWidget {
  const LeaderboardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    /// Build leaderboard loading section
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          TextX(
            'Top learners ranked by points 🏆',
            style: TextStyleX.titleMedium,
          ).fadeAnimation150,
          const SizedBox(height: 12),

          /// Description
          TextX(
            'Leaderboard description',
            style: TextStyleX.bodyMedium,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ).fadeAnimation150,
          const SizedBox(height: 18),

          /// Shimmer animation
          for (var i = 0; i < 10; i++)
            ShimmerAnimationX(
              height: 66,
              margin: EdgeInsets.only(bottom: 12),
            ).fadeAnimation200,
        ],
      ),
    );
  }
}
