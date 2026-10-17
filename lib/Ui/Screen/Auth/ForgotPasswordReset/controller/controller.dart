import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Config/config.dart';
import '../../../../../Data/data.dart';
import '../../../../Widget/widget.dart';

class ForgotPasswordResetController extends GetxController {
  //============================================================================
  // Variables

  // Loading state
  final isLoading = false.obs;

  // Button states
  final buttonState = ButtonStateEX.normal.obs;

  // An acknowledged reset may have consumed the OTP. Never submit it again,
  // including while the sign-in route is replacing this screen.
  bool _resetAccepted = false;
  Timer? _resetButtonTimer;

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

  /// Reset the password independently of starting a new authenticated session.
  Future<void> onResetPassword() async {
    if (isClosed || isLoading.value || _resetAccepted) return;
    if (!(formKey.currentState?.validate() ?? false)) {
      autoValidate = AutovalidateMode.always;
      return;
    }

    _resetButtonTimer?.cancel();
    isLoading.value = true;
    buttonState.value = ButtonStateEX.loading;

    try {
      await DatabaseX.resetForgetPassword(
        email: email,
        password: password.text,
        otpCode: otp,
      );
      if (isClosed) return;

      // Reset acceptance is final even if presenting the next screen fails.
      // Sign-in remains an explicit, separate action by the account owner.
      _resetAccepted = true;
      buttonState.value = ButtonStateEX.success;
      Get.offAllNamed(RouteNameX.login);
      ToastX.success(
        message:
            'Password changed successfully. Please sign in with your new password.',
      );
    } catch (error) {
      if (isClosed || _resetAccepted) return;
      buttonState.value = ButtonStateEX.failed;
      ToastX.error(message: error);
    } finally {
      // Keep an accepted reset locked until its route is disposed. Failures
      // retain the entered password and permit an intentional retry.
      if (!isClosed && !_resetAccepted) {
        isLoading.value = false;
        _resetButtonTimer = Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () {
            if (!isClosed && !isLoading.value) {
              buttonState.value = ButtonStateEX.normal;
            }
          },
        );
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
    _resetButtonTimer?.cancel();

    /// Dispose controllers
    password.dispose();
    rePassword.dispose();
    super.onClose();
  }
}
