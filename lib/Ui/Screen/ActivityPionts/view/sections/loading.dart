import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Config/config.dart';

class ActivityPiontsLoading extends StatelessWidget {
  const ActivityPiontsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    /// Loading activity points
    return SingleChildScrollView(
      padding: StyleX.paddingApp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          TextX(
            'List of activities that give you points',
            style: TextStyleX.titleMedium,
          ).fadeAnimation150,
          const SizedBox(height: 12),

          /// Description
          TextX(
            'Points description',
            style: TextStyleX.bodyMedium,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ).fadeAnimation150,
          const SizedBox(height: 18),

          /// Activity points cards loading
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
