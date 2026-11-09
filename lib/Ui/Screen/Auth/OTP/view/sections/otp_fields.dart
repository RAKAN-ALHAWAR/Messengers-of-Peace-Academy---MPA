import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Animation/fade/fade_animation.dart';
import '../../../../../Widget/Basic/Input/otp_fields.dart';
import '../../controller/controller.dart';

class OtpFieldsSection extends GetView<OTPController> {
  const OtpFieldsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return OtpFieldsX(
      pinKey: controller.otpKey,
      onChanged: (value) {
        final complete = value.length == 6;
        controller.otpCode.text = complete ? value : '';
        controller.isDoneInput.value = complete;
      },
    ).fadeAnimation250;
  }
}
