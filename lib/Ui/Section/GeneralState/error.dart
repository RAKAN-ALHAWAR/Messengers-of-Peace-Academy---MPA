import 'package:flutter/material.dart';

import '../../../Config/config.dart';
import '../../../Core/Error/error.dart';
import '../../../Ui/Widget/widget.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this screen }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// A general component for dealing with errors
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.error,
    this.onTapButton,
    this.buttonText = "Try again",
    super.key,
  });
  final Object? error;
  final Function? onTapButton;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    ErrorX errorX = (error ?? "").toErrorX;
    errorX.log();
    IconData getIcon() {
      switch (errorX.errorType) {
        case ErrorTypeStatusX.network:
          return Icons.network_wifi_sharp;

        case ErrorTypeStatusX.input:
          return Icons.keyboard_hide;

        case ErrorTypeStatusX.server:
          return Icons.dns_rounded;

        case ErrorTypeStatusX.unknown:
          return Icons.report_problem_rounded;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Message Card
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              width: double.maxFinite,
              child: Column(
                children: [
                  Icon(getIcon(), color: ColorX.danger, size: 110.0),
                  const SizedBox(height: 20),
                  TextX(
                    errorX.title,
                    maxLines: 1,
                    style: TextStyleX.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextX(
                    errorX.message,
                    color: ColorX.danger,
                    maxLines: 10,
                    // style: TextStyleX.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            /// Action Button
            ButtonX(onTap: onTapButton ?? () {}, text: buttonText),
          ],
        ),
      ),
    );
  }
}
