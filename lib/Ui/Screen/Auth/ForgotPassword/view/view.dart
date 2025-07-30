import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../../Core/core.dart';
import '../../../../../Ui/Widget/widget.dart';
import '../controller/controller.dart';
import '../../../../Section/AuthLayout/auth_layout.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayoutX(
      title: "Forgot password?",
      subtitle: "Enter your registered email address to reset your password.",
      formKey: controller.formKey,
      autoValidateMode: controller.autoValidate,
      isBackIcon: true,
      child: Obx(
        /// Lock the screen when loading
        () => AbsorbPointer(
          absorbing: controller.isLoading.value,
          child: Column(
            children: [
              // Email input field
              TextFieldX(
                controller: controller.email,
                hint: 'Email',
                validate: ValidatorX.email,
                textInputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                margin: EdgeInsets.only(bottom: 12),
              ).fadeAnimation200,

              // Next button
              ButtonStateX(
                text: "Next",
                state: controller.buttonState.value,
                onTap: controller.onResetPassword,
              ).fadeAnimation200,
            ],
          ),
        ),
      ),
    );
  }
}
