import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Config/config.dart';
import '../../../Core/core.dart';
import '../../Animation/fade/fade_animation.dart';
import '../../Widget/widget.dart';

class OtpResendX extends StatelessWidget {
  const OtpResendX({
    super.key,
    required this.seconds,
    required this.onResend,
    this.loading = false,
  });

  final int seconds;
  final VoidCallback? onResend;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      );
    }
    return Column(
      children: [
        if (seconds > 0)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            children: [
              TextX("Didn't receive the code?", style: TextStyleX.labelLarge),
              TextX(
                '( ${FunctionX.formatTime(seconds)} )',
                style: TextStyleX.labelLarge,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ).fadeAnimation400.marginOnly(bottom: 4),
        InkWell(
          onTap: onResend,
          borderRadius: BorderRadius.circular(StyleX.radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
            child: TextX(
              'Resend code',
              style: TextStyleX.bodySmall,
              textDecoration: onResend == null
                  ? TextDecoration.underline
                  : null,
              color: onResend == null ? null : Theme.of(context).primaryColor,
            ),
          ),
        ).fadeAnimation450,
      ],
    );
  }
}
