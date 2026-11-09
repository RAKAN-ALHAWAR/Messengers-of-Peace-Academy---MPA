import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Section/AuthLayout/otp_resend.dart';
import '../../controller/controller.dart';

class ResendSection extends GetView<OTPController> {
  const ResendSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canResend = controller.isResendAgain.value;
      return OtpResendX(
        seconds: canResend ? 0 : controller.start.value,
        loading: controller.isLoadingResendAgain.value,
        onResend: canResend ? controller.onResend : null,
      );
    });
  }
}
