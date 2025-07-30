import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart';
import '../../../../../Ui/Widget/widget.dart';
import '../controller/controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarX(title: "Update Password"),
      body: Obx(() {
        /// Lock screen when loading
        return AbsorbPointer(
          absorbing: controller.isLoading.value,

          /// Content
          child: SingleChildScrollView(
            padding: StyleX.paddingApp,
            child: Column(
              children: [
                /// Form fields
                Form(
                  key: controller.formKey,
                  autovalidateMode: controller.autoValidate,
                  child: Column(
                    children: [
                      /// Old password input
                      TextFieldX(
                        controller: controller.oldPassword,
                        hint: "Old Password",
                        validate: ValidatorX.password,
                        textInputType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                      ).fadeAnimation200,

                      /// New password input
                      TextFieldX(
                        hint: "New Password",
                        controller: controller.newPassword,
                        validate: ValidatorX.password,
                        textInputType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        color: Get.theme.cardTheme.color,
                      ).marginSymmetric(vertical: 10.0).fadeAnimation250,

                      /// Confirm new password input
                      TextFieldX(
                        controller: controller.reNewPassword,
                        hint: "Confirm new password",
                        textInputType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        validate:
                            (val) => ValidatorX.rePassword(
                              val,
                              controller.newPassword.text,
                            ),
                      ).fadeAnimation300,
                    ],
                  ),
                ).fadeAnimation100,

                /// Spacer
                SizedBox(height: 24),

                /// Save & Cancel Buttons
                Row(
                  children: [
                    /// Save button
                    Flexible(
                      child: ButtonStateX(
                        state: controller.buttonState.value,
                        onTap: controller.onEdit,
                        text: "Save",
                      ),
                    ),

                    /// Spacer
                    const SizedBox(width: 10),

                    /// Cancel button
                    Flexible(
                      child: ButtonX.gray(onTap: Get.back, text: "Cancel"),
                    ),
                  ],
                ).fadeAnimation400,
              ],
            ),
          ),
        );
      }),
    );
  }
}
