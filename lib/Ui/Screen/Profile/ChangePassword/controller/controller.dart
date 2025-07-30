import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart';
import '../../../../../Data/data.dart';
import '../../../../Widget/widget.dart';

class ChangePasswordController extends GetxController {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  /// Is loading
  RxBool isLoading = false.obs;

  /// Button state
  Rx<ButtonStateEX> buttonState = ButtonStateEX.normal.obs;

  /// Form key
  late GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Autovalidate mode
  AutovalidateMode autoValidate = AutovalidateMode.disabled;

  /// Text editing controllers
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController reNewPassword = TextEditingController();

  //============================================================================
  // Functions

  /// Handle change password
  onEdit() async {
    /// If loading, return
    if (isLoading.isTrue) {
      return;
    }

    /// If form is valid, proceed
    if (formKey.currentState!.validate()) {
      /// Set loading to true
      isLoading.value = true;
      buttonState.value = ButtonStateEX.loading;
      try {
        /// Update password in database
        String? message = await DatabaseX.updatePassword(
          username: app.user.value.username,
          oldPassword: oldPassword.text,
          newPassword: newPassword.text,
        );

        /// The time delay here is aesthetically beneficial
        buttonState.value = ButtonStateEX.success;
        await Future.delayed(
          const Duration(seconds: StyleX.successButtonSecond),
        );

        /// Close the change password screen
        Get.back();

        /// Show success toast
        ToastX.success(message: message);
      } catch (error) {
        /// Show error toast
        ToastX.error(message: error.toString());
        buttonState.value = ButtonStateEX.failed;
      }

      /// Set loading to false
      isLoading.value = false;

      /// Reset the button state
      Timer(
        const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
        () => buttonState.value = ButtonStateEX.normal,
      );
    } else {
      /// Set autovalidate mode to always
      autoValidate = AutovalidateMode.always;
    }
  }
}
