import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../Config/config.dart';
import '../../../Ui/Widget/widget.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this screen }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// A generic component for dealing with missing data cases
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.buttonText,
    this.onTap,
    this.isMargin = true,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });
  final String message;
  final String? buttonText;
  final bool isMargin;
  final MainAxisAlignment mainAxisAlignment;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          isMargin
              ? const EdgeInsets.symmetric(
                horizontal: StyleX.hPaddingApp,
                vertical: StyleX.vPaddingApp,
              )
              : EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          /// Message Card
          ContainerX(
            color: Theme.of(context).colorScheme.onPrimary,
            child: Row(
              children: [
                Icon(Icons.info_rounded, color: ColorX.primary, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: TextX(message, maxLines: 5, color: ColorX.primary),
                ),
              ],
            ),
          ).fadeAnimation200,

          /// Action Button
          if (buttonText != null && onTap != null)
            Column(
              children: [
                const SizedBox(height: 10),
                ButtonX(onTap: onTap!, text: buttonText),
              ],
            ).fadeAnimation300,
        ],
      ),
    );
  }
}
