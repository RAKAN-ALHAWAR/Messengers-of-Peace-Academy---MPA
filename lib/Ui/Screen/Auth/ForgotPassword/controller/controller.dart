import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Config/config.dart';
import '../../../../../Data/Model/auth/otp.dart';
import '../../../../../Data/data.dart';
import '../../../../Widget/widget.dart';

class ForgotPasswordController extends GetxController {
  //============================================================================
  // Variables

  // Loading state
  final isLoading = false.obs;

  // Button states
  final buttonState = ButtonStateEX.normal.obs;

  // Form key
  late GlobalKey<FormState> formKey;

  // Autovalidate mode
  AutovalidateMode autoValidate = AutovalidateMode.disabled;

  // Text editing controllers
  TextEditingController email = TextEditingController();

  //============================================================================
  // Functions

  /// Handle reset password
  void onResetPassword() async {
    /// Check if loading is false
    if (isLoading.isFalse) {
      /// Check if form is valid
      if (formKey.currentState!.validate()) {
        /// Set Loading to true
        isLoading.value = true;

        /// Set Button State to loading
        buttonState.value = ButtonStateEX.loading;

        /// Try to reset password
        try {
          var message = await DatabaseX.forgetPassword(
            email: email.text.trim(),
          );

          /// Show success message
          ToastX.success(message: message);

          /// The time delay here is aesthetically beneficial
          buttonState.value = ButtonStateEX.success;
          await Future.delayed(
            const Duration(seconds: StyleX.successButtonSecond),
          );

          /// Create OTP object
          OtpX otp = OtpX(
            email: email.text.trim(),
            isSignUp: false,
            isPhone: false,
          );

          /// Navigate to OTP Screen
          Get.toNamed(RouteNameX.otp, arguments: otp);
        } catch (e) {
          /// Set Button State to failed
          buttonState.value = ButtonStateEX.failed;

          /// Show error message
          ToastX.error(message: e);
        }

        /// Set Loading to false
        isLoading.value = false;

        /// Reset the button state
        Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () => buttonState.value = ButtonStateEX.normal,
        );
      } else {
        /// Set Autovalidate to always
        autoValidate = AutovalidateMode.always;
      }
    }
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Initialize form key
    formKey = GlobalKey<FormState>();
  }

  @override
  void onClose() {
    /// Dispose controllers
    email.dispose();
    super.onClose();
  }
}
