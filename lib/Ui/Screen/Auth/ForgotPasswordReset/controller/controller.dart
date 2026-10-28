import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart';
import '../../../../../Data/data.dart';
import '../../../../../Core/Service/session_lease.dart';
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

      // Reset acceptance is final even if signing in or presenting the next
      // screen fails: the OTP may be consumed, so it is never submitted again.
      _resetAccepted = true;

      // Sign in with the new password. If that fails the password is already
      // changed, so go to login with the success message, never an error.
      // The button keeps loading until sign-in ends, so the wait never looks
      // like a frozen success state.
      final signedIn = await _signIn();
      if (isClosed) return;
      buttonState.value = ButtonStateEX.success;
      if (signedIn) {
        // The time delay here is aesthetically beneficial
        await Future.delayed(
          const Duration(seconds: StyleX.successButtonSecond),
        );
        if (isClosed) return;
        Get.offAllNamed(RouteNameX.root);
      } else {
        if (isClosed) return;

        // Login is still open under this flow, so go back to it. A second Login
        // page would share the first one's controller (GetX keys controllers by
        // type) and removing the old page would dispose the new page's text
        // fields. Only when no Login page exists is a new one opened.
        Get.until(
          (route) => route.settings.name == RouteNameX.login || route.isFirst,
        );
        if (Get.currentRoute != RouteNameX.login) {
          Get.offAllNamed(RouteNameX.login);
        }
        ToastX.success(
          message:
              'Password changed successfully. Please sign in with your new password.',
        );
      }
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

  /// Sign in with the new password. The credentials are provisional until the
  /// profile is verified, and are removed again on any failure (or when the
  /// screen was left meanwhile), so a half-finished sign-in never stays saved.
  Future<bool> _signIn() async {
    SessionLeaseX? owner;
    try {
      final data = await DatabaseX.login(email: email, password: password.text);
      if (isClosed || data.$1.trim().isEmpty || data.$2.trim().isEmpty) {
        return false;
      }

      /// The token must be stored **before** any authenticated request,
      /// because it is the `wstoken` used by [DBEndPointX.mainAPI]
      app.isLogin.value = false;
      final writes = [
        LocalDataX.put(LocalKeyX.userid, data.$1),
        LocalDataX.put(LocalKeyX.token, data.$2),
        LocalDataX.put(LocalKeyX.route, RouteNameX.login),
      ];
      owner = SessionLeaseX.capture();
      await Future.wait(writes);

      final user = await DatabaseX.getUser(userId: data.$1);
      if (isClosed || !owner.isCurrent || user.id != data.$1) {
        throw StateError('The sign-in after the reset was not completed.');
      }
      await LocalDataX.put(LocalKeyX.route, RouteNameX.root);
      app.user = user.obs;
      app.isLogin.value = true;
      return true;
    } catch (_) {
      // Does nothing when another sign-in has taken over the credentials.
      if (owner != null) await app.clearLocalSession(owner, navigate: false);
      return false;
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
