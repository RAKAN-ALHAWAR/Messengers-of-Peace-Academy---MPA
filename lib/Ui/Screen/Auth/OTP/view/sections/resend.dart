import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/config.dart';
import '../../../../../../Core/core.dart';
import '../../../../../../Ui/Widget/widget.dart';
import '../../controller/controller.dart';

class ResendSection extends GetView<OTPController> {
  const ResendSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Resend Section
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Resend Title and Time
          if (!controller.isResendAgain.value &&
              !controller.isLoadingResendAgain.value)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Title
                TextX("Didn't receive the code?", style: TextStyleX.labelLarge),
                const SizedBox(width: 5),

                /// Resend Time
                Row(
                  children: [
                    TextX("( ", style: TextStyleX.labelLarge),
                    TextX(
                      FunctionX.formatTime(controller.start.value),
                      style: TextStyleX.labelLarge,
                      color: ColorX.primary,
                    ),
                    TextX(" ) ", style: TextStyleX.labelLarge),
                  ],
                ),
              ],
            ).fadeAnimation400.marginOnly(bottom: 4),

          /// Resend Button
          if (!controller.isLoadingResendAgain.value)
            AbsorbPointer(
              absorbing: !controller.isResendAgain.value,
              child:
                  InkWell(
                    onTap: controller.onResend,
                    borderRadius: BorderRadius.circular(StyleX.radius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 1.0,
                        horizontal: 5,
                      ),
                      child: TextX(
                        "Resend code",
                        style: TextStyleX.bodySmall,
                        textDecoration: TextDecoration.underline,
                        color:
                            controller.isResendAgain.value
                                ? Theme.of(context).primaryColor
                                : null,
                      ),
                    ),
                  ).fadeAnimation450,
            ),

          /// Resend Loading
          if (controller.isLoadingResendAgain.value)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
