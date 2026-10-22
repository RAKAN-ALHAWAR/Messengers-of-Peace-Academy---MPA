import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../Config/Translation/translation.dart';
import '../../../../../Config/config.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Core/core.dart';
import '../../../../../Core/Service/session_lease.dart';
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

  Timer? _resetTimer;

  /// Inputs and route lifetime belong to one submission, including its delay.
  Future<void> onSignUp() async {
    if (isLoading.value || isClosed) return;
    if (formKey.currentState?.validate() != true) {
      autovalidate = AutovalidateMode.always;
      return;
    }
    final route = Get.currentRoute;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              Get.currentRoute == route &&
              Get.isRegistered<AppControllerX>() &&
              identical(Get.find<AppControllerX>(), app),
    );
    final submittedFirst = firstName.text;
    final submittedLast = lastName.text;
    final submittedEmail = email.text;
    final submittedPassword = password.text;
    final language = TranslationX.backendLanguageCode;
    final method = verificationMethod;
    isLoading.value = true;
    buttonState.value = ButtonStateEX.loading;
    try {
      if (method.isEmpty) {
        throw ErrorX(
          message: 'Please select your account verification method.',
        );
      }
      final userid = await DatabaseX.signUp(
        firstName: submittedFirst,
        lastName: submittedLast,
        email: submittedEmail,
        password: submittedPassword,
        username: submittedEmail,
        lang: language,
      );
      if (!lease.isCurrent) return;
      if (userid.trim().isEmpty) {
        throw ErrorX(
          message: 'Unable to start a secure session. Please sign in again.',
        );
      }
      buttonState.value = ButtonStateEX.success;
      await Future<void>.delayed(
        const Duration(seconds: StyleX.successButtonSecond),
      );
      if (!lease.isCurrent) return;
      isLoading.value = false;
      buttonState.value = ButtonStateEX.normal;
      Get.toNamed(
        RouteNameX.otp,
        arguments: OtpX(
          isSignUp: true,
          isPhone: false,
          email: submittedEmail,
          userid: userid,
        ),
      );
    } catch (e) {
      if (!lease.isCurrent) return;
      var error = e.toErrorX;
      if (error.details[NameX.errorcode] == 'useralreadyexists') {
        error = ErrorX(
          message: 'Email is already in use, please use another email',
        );
      }
      buttonState.value = ButtonStateEX.failed;
      ToastX.error(message: error.message);
    } finally {
      if (lease.isCurrent) {
        isLoading.value = false;
        _resetTimer?.cancel();
        _resetTimer = Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () {
            if (lease.isCurrent) buttonState.value = ButtonStateEX.normal;
          },
        );
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
    final route = Get.currentRoute;
    var url = Uri.parse('https://mopacademy.org/mod/page/view.php?id=80');
    if (await canLaunchUrl(url) && !isClosed && Get.currentRoute == route) {
      await launchUrl(url);
    }
  }

  /// Navigate to terms and conditions screen
  void onTermsAccepted() async {
    final route = Get.currentRoute;
    var url = Uri.parse('https://mopacademy.org/mod/page/view.php?id=1829');
    if (await canLaunchUrl(url) && !isClosed && Get.currentRoute == route) {
      await launchUrl(url);
    }
  }

  /// Navigate to privacy policy screen
  void onPrivacyPolicy() async {
    final route = Get.currentRoute;
    var url = Uri.parse('https://mopacademy.org/mod/page/view.php?id=1831');
    if (await canLaunchUrl(url) && !isClosed && Get.currentRoute == route) {
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
    _resetTimer?.cancel();

    /// Dispose controllers
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
