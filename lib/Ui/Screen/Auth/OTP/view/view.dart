import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Section/AuthLayout/auth_layout.dart';
import '../../../../Section/AuthLayout/otp_verification_form.dart';
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
          child: OtpVerificationFormX(
            fields: const OtpFieldsSection(),
            action: 'Verify',
            onVerify: controller.onVerify,
            state: controller.buttonState.value,
            canVerify: controller.isDoneInput.value,
            resend: const ResendSection(),
          ),
        ),
      ),
    );
  }
}
