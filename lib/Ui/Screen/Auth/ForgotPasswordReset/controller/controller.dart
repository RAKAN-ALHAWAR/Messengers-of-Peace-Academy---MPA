import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart';
import '../../../../../Data/data.dart';
import '../../../../Widget/widget.dart';

class ForgotPasswordResetController extends GetxController {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  // Loading state
  final isLoading = false.obs;

  // Button states
  final buttonState = ButtonStateEX.normal.obs;

  // Email
  String email = Get.arguments[NameX.email] ?? '';

  // Otp
  String otp = Get.arguments[NameX.otp] ?? '';

  // Form key
  late GlobalKey<FormState> formKey;

  // Autovalidate mode
  AutovalidateMode autoValidate = AutovalidateMode.disabled;

  // Text editing controllers
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();

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
          /// Reset forget password
          await DatabaseX.resetForgetPassword(
            email: email,
            password: password.text,
            otpCode: otp,
          );

          /// Login to get user id and token
          var data = await DatabaseX.login(
            email: email,
            password: password.text,
          );

          /// Set user on app controller
          app.user = (await DatabaseX.getUser(userId: data.$1)).obs;

          /// Set login state
          app.isLogin.value = true;

          /// Save data on local
          LocalDataX.put(LocalKeyX.userid, data.$1);
          LocalDataX.put(LocalKeyX.token, data.$2);
          LocalDataX.put(LocalKeyX.route, RouteNameX.root);

          /// The time delay here is aesthetically beneficial
          buttonState.value = ButtonStateEX.success;
          await Future.delayed(
            const Duration(seconds: StyleX.successButtonSecond),
          );

          /// Navigate to root screen
          Get.offAllNamed(RouteNameX.root);
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
    password.dispose();
    rePassword.dispose();
    super.onClose();
  }
}
