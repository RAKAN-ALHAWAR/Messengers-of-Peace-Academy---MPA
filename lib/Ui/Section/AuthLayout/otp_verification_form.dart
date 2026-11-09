import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Config/config.dart';
import '../../../Data/data.dart';
import '../../Animation/fade/fade_animation.dart';
import '../../Widget/widget.dart';

class OtpVerificationFormX extends StatelessWidget {
  const OtpVerificationFormX({
    super.key,
    required this.fields,
    required this.action,
    required this.onVerify,
    required this.canVerify,
    required this.state,
    required this.resend,
  });

  final Widget fields;
  final String action;
  final VoidCallback onVerify;
  final bool canVerify;
  final ButtonStateEX state;
  final Widget resend;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        fields,
        const SizedBox(height: 16),
        ButtonStateX(
          text: action,
          onTap: onVerify,
          state: state,
          disabled: !canVerify && state != ButtonStateEX.loading,
          colorDisabledBorder: Colors.transparent,
          colorDisabledButton: ColorX.primary.withValues(
            alpha: context.isDarkMode ? 0.2 : 0.4,
          ),
          colorDisabledText: context.isDarkMode ? Colors.white38 : Colors.white,
        ).fadeAnimation300,
        const SizedBox(height: 16),
        resend,
      ],
    );
  }
}
