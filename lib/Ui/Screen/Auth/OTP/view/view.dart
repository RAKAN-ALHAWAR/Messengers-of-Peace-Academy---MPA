import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../../Config/config.dart';
import '../../../../../Ui/Widget/widget.dart';
import '../../../../Section/AuthLayout/auth_layout.dart';
import '../controller/controller.dart';
import 'sections/otp_fields.dart';
import 'sections/resend.dart';

class OTPView extends GetView<OTPController> {
  const OTPView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayoutX(
      title: 'Account verification',
      subtitle: controller.getSubTitle(),
      child: Obx(
        /// Lock the screen when loading
        () => AbsorbPointer(
          absorbing: controller.isLoading.value,
          child: Column(
            children: [
              /// Code Field
              OtpFieldsSection(),

              /// Spacer
              const SizedBox(height: 16.0),

              /// Button Login
              ButtonStateX(
                text: 'Verify',
                onTap: controller.onVerify,
                state: controller.buttonState.value,
                disabled: controller.isDoneInput.isFalse,
                colorDisabledBorder: Colors.transparent,
                colorDisabledButton:
                    context.isDarkMode
                        ? ColorX.primary.withValues(alpha: 0.2)
                        : ColorX.primary.withValues(alpha: 0.4),
                colorDisabledText:
                    context.isDarkMode ? Colors.white38 : Colors.white,
              ).fadeAnimation300,

              /// Spacer
              const SizedBox(height: 16.0),

              /// Resend Code
              ResendSection(),
            ],
          ),
        ),
      ),
    );
  }
}
