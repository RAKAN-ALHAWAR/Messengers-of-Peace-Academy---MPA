import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../../Core/core.dart';
import '../../../../../Ui/Widget/widget.dart';
import '../../../../Section/AuthLayout/auth_layout.dart';
import '../controller/controller.dart';

class ForgotPasswordResetView extends GetView<ForgotPasswordResetController> {
  const ForgotPasswordResetView({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthLayoutX(
      title: 'Reset password',
      subtitle: 'Enter new password',
      formKey: controller.formKey,
      autoValidateMode: controller.autoValidate,
      child: Obx(
        /// Lock the screen when loading
        () => AbsorbPointer(
          absorbing: controller.isLoading.value,
          child: Column(
            children: [
              /// New Password
              TextFieldX(
                controller: controller.password,
                validate: ValidatorX.password,
                hint: 'New Password',
                textInputType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                margin: EdgeInsets.only(bottom: 12),
              ).fadeAnimation200,

              /// Confirm new password
              TextFieldX(
                controller: controller.rePassword,
                hint: 'Confirm new password',
                textInputType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                margin: EdgeInsets.only(bottom: 12),
                validate: (val) {
                  return ValidatorX.rePassword(val, controller.password.text);
                },
              ).fadeAnimation200,

              /// Confirm button
              ButtonStateX(
                text: 'Confirm',
                state: controller.buttonState.value,
                onTap: controller.onResetPassword,
              ).marginOnly(top: 2).fadeAnimation250,
            ],
          ),
        ),
      ),
    );
  }
}
