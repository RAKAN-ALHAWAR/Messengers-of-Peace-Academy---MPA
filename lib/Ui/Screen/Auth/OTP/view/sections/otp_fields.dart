import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Package/otp_pin_field_widget/src/otp_pin_field_input_type.dart';
import 'package:messengersofpeace/Ui/Widget/Package/otp_pin_field_widget/src/otp_pin_field_widget.dart';

import '../../../../../../Config/config.dart';
import '../../../../../Widget/Package/otp_pin_field_widget/src/otp_pin_field_style.dart';
import '../../controller/controller.dart';

class OtpFieldsSection extends GetView<OTPController> {
  const OtpFieldsSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Otp Fields
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            child: SizedBox(
              height: 60,
              width: Get.width,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: OtpPinField(
                  key: controller.otpKey,
                  fieldHeight: 54,
                  fieldWidth: 58,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  showCursor: true,
                  cursorColor: ColorX.primary,
                  cursorWidth: 2,
                  mainAxisAlignment: MainAxisAlignment.center,
                  otpPinFieldDecoration: OtpPinFieldDecoration.custom,
                  onChange: (val) {
                    if (val.length == 6) {
                      controller.otpCode.text = val;
                      controller.isDoneInput.value = true;
                    } else {
                      controller.otpCode.text = '';
                      controller.isDoneInput.value = false;
                    }
                  },
                  otpPinFieldStyle: OtpPinFieldStyle(
                    showHintText: false,
                    defaultFieldBackgroundColor:
                        Theme.of(context).cardTheme.color ?? Colors.transparent,
                    activeFieldBackgroundColor:
                        Theme.of(context).cardTheme.color ?? Colors.transparent,
                    activeFieldBorderColor: ColorX.primary,
                    defaultFieldBorderColor: ColorX.grey.shade200,
                    filledFieldBorderColor: ColorX.grey.shade200,
                    fieldBorderWidth: StyleX.borderWidth,
                    fieldPadding: 8,
                    fieldBorderRadius: 8,
                    textStyle: TextStyleX.titleMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ).fadeAnimation250;
  }
}
