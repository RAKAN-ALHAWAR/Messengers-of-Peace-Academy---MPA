import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../Config/Translation/translation.dart';
import '../../../../../Config/config.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Core/core.dart';
import '../../../../../Data/Model/auth/otp.dart';
import '../../../../../Data/data.dart';
import '../../../../Widget/widget.dart';

class SignUpController extends GetxController {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  // Loading state
  final isLoading = false.obs;

  // Button states
  final buttonState = ButtonStateEX.normal.obs;

  // Form key
  late GlobalKey<FormState> formKey;

  // Text editing controllers
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  // Terms and conditions
  final isTermsAccepted = false.obs;

  // Verification method
  String verificationMethod = "";

  // Verification methods
  final verificationMethods = [
    "Email",

    /// TODO: Add whatsapp verification
    // "Whatsapp",
  ];

  // Autovalidate mode
  AutovalidateMode autovalidate = AutovalidateMode.disabled;

  //============================================================================
  // Functions

  /// Handle sign up
  Future<void> onSignUp() async {
    /// Check if loading is false
    if (isLoading.isFalse) {
      /// Check if form is valid
      if (formKey.currentState!.validate()) {
        /// Set Loading to true
        isLoading.value = true;

        /// Set Button State to loading
        buttonState.value = ButtonStateEX.loading;

        try {
          /// Check Verification Method
          if (verificationMethod.isEmpty) {
            /// Set Error
            throw ErrorX(
              message: 'Please select your account verification method.',
            );
          }

          /// Sign up
          var userid = await DatabaseX.signUp(
            firstName: firstName.text,
            lastName: lastName.text,
            email: email.text,
            password: password.text,
            username: email.text,
            lang: TranslationX.getLanguageCode,
          );

          /// Set Button State to success
          buttonState.value = ButtonStateEX.success;
          await Future.delayed(
            const Duration(seconds: StyleX.successButtonSecond),
          );

          /// Navigate to OTP Screen
          Get.toNamed(
            RouteNameX.otp,
            arguments: OtpX(
              isSignUp: true,
              isPhone: false,
              email: email.text,
              userid: userid,

              /// TODO: Add whatsapp verification
              // isPhone: verificationMethod == "Whatsapp" ? true : false,
            ),
          );
        } catch (e) {
          var error = e.toErrorX;

          /// Check Error Code
          if (error.details[NameX.errorcode] == 'useralreadyexists') {
            error = ErrorX(
              message: 'Email is already in use, please use another email',
            );
          }

          /// Set Button State to failed
          buttonState.value = ButtonStateEX.failed;
          ToastX.error(message: error.message);
        }

        /// Set Loading to false
        isLoading.value = false;

        /// Reset button state
        Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () {
            buttonState.value = ButtonStateEX.normal;
          },
        );
      } else {
        /// Set Autovalidate to always
        autovalidate = AutovalidateMode.always;
      }
    }
  }

  /// Navigate to login screen
  void onLogin() => Get.offAndToNamed(RouteNameX.login);

  /// Handle terms accepted
  void onChangeTermsAccepted(bool value) => isTermsAccepted.value = value;

  /// Handle verification method
  void onVerificationMethod(String value) => verificationMethod = value;

  /// Navigate to contact us screen
  void onContactUs() async {
    var url = Uri.parse('https://mopacademy.org/mod/page/view.php?id=80');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Navigate to terms and conditions screen
  void onTermsAccepted() async {
    var url = Uri.parse('https://mopacademy.org/mod/page/view.php?id=1829');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Navigate to privacy policy screen
  void onPrivacyPolicy() async {
    var url = Uri.parse('https://mopacademy.org/mod/page/view.php?id=1831');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
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
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
