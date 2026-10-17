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
  Timer? _resetButtonTimer;

  // Form key
  late GlobalKey<FormState> formKey;

  // Autovalidate mode
  AutovalidateMode autoValidate = AutovalidateMode.disabled;

  // Text editing controllers
  TextEditingController email = TextEditingController();

  //============================================================================
  // Functions

  /// Request a code for the submitted email; ignore abandoned screen work.
  Future<void> onResetPassword() async {
    if (isClosed || isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) {
      autoValidate = AutovalidateMode.always;
      return;
    }

    final submittedEmail = email.text.trim();
    _resetButtonTimer?.cancel();
    isLoading.value = true;
    buttonState.value = ButtonStateEX.loading;

    try {
      final message = await DatabaseX.forgetPassword(email: submittedEmail);
      if (isClosed) return;

      ToastX.success(message: message);
      buttonState.value = ButtonStateEX.success;
      await Future<void>.delayed(
        const Duration(seconds: StyleX.successButtonSecond),
      );
      if (isClosed) return;

      Get.toNamed(
        RouteNameX.otp,
        arguments: OtpX(email: submittedEmail, isSignUp: false, isPhone: false),
      );
    } catch (error) {
      if (isClosed) return;
      buttonState.value = ButtonStateEX.failed;
      ToastX.error(message: error);
    } finally {
      if (!isClosed) {
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
    email.dispose();
    super.onClose();
  }
}
