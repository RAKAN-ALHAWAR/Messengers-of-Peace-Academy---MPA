import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Config/config.dart';

class BadgesLoading extends StatelessWidget {
  const BadgesLoading({super.key});

  @override
  Widget build(BuildContext context) {
    /// Loading badges
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          TextX('Badges List', style: TextStyleX.titleMedium).fadeAnimation150,
          const SizedBox(height: 12),

          /// Description
          TextX(
            'Badges description',
            style: TextStyleX.bodyMedium,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ).fadeAnimation150,
          const SizedBox(height: 18),

          /// Badge Cards
          for (var i = 0; i < 10; i++)
            ShimmerAnimationX(
              height: 93,
              margin: EdgeInsets.only(bottom: 12),
            ).fadeAnimation200,
        ],
      ),
    );
  }
}
