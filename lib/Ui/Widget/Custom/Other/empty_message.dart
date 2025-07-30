import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../Config/config.dart';
import '../../widget.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextX(
        message,
        style: TextStyleX.titleMedium,
        color: Theme.of(context).colorScheme.secondary,
      ),
    ).fadeAnimation150;
  }
}
