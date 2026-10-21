import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Data/Model/auth/otp.dart';
import '../../../../../Data/data.dart';
import '../../../../Widget/Package/otp_pin_field_widget/src/otp_pin_field_state.dart';
import '../../../../Widget/widget.dart';

class OTPController extends GetxController with WidgetsBindingObserver {
  AppControllerX app = Get.find();
  final isLoading = false.obs;
  final isLoadingResendAgain = false.obs;
  final isResendAgain = false.obs;
  final isDoneInput = false.obs;
  final buttonState = ButtonStateEX.normal.obs;
  final OtpX otp = Get.arguments;
  final otpCode = TextEditingController();
  late GlobalKey<OtpPinFieldState> otpKey;
  Timer? timer;
  Timer? _resetTimer;
  SessionLeaseX? _provisional;
  final start = 120.obs;
  DateTime? _timerStartTime;
  int _initialDuration = 120;

  SessionLeaseX _capture(String route) => SessionLeaseX.capture(
    isActive:
        () =>
            !isClosed &&
            Get.currentRoute == route &&
            Get.isRegistered<AppControllerX>() &&
            identical(Get.find<AppControllerX>(), app),
  );

  String getSubTitle() =>
      otp.isPhone
          ? '${"Please enter the verification code sent to your WhatsApp number".tr}\n ${otp.phone}'
          : '${"Please enter the verification code sent to your email".tr}\n ${otp.email}';

  Future<void> onVerify() async {
    if (isLoading.value || isLoadingResendAgain.value || isClosed) return;
    final route = Get.currentRoute;
    var lease = _capture(route);
    final signUp = otp.isSignUp;
    final id = otp.userid?.trim() ?? '';
    final email = otp.email ?? '';
    final code = otpCode.text;
    isLoading.value = true;
    buttonState.value = ButtonStateEX.loading;
    try {
      if (signUp) {
        if (id.isEmpty) {
          throw ErrorX(
            message:
                'Your account still needs verification. Please contact support to recover verification access.',
          );
        }
        final token = await DatabaseX.verifyOtpSignUp(
          userId: id,
          otpCode: code,
        );
        if (!lease.isCurrent) return;
        if (token.trim().isEmpty) {
          // Verification can succeed without a login token. It is a separate
          // state, never permission to fetch a profile with a shared credential.
          buttonState.value = ButtonStateEX.success;
          ToastX.success(
            message: 'Account verified. Please sign in to continue.',
          );
          await Future<void>.delayed(
            const Duration(seconds: StyleX.successButtonSecond),
          );
          if (!lease.isCurrent) return;
          Get.offAllNamed(RouteNameX.login);
          return;
        }
        app.isLogin.value = false;
        final writes = [
          LocalDataX.put(LocalKeyX.userid, id),
          LocalDataX.put(LocalKeyX.token, token),
          LocalDataX.put(LocalKeyX.route, RouteNameX.login),
        ];
        _provisional = SessionLeaseX.capture();
        lease = _capture(route);
        await Future.wait(writes);
        if (!lease.isCurrent) return;
        final user = await DatabaseX.getUser(userId: id);
        if (!lease.isCurrent) return;
        if (user.id != id) {
          throw ErrorX(
            message: 'Unable to start a secure session. Please sign in again.',
          );
        }
        await LocalDataX.put(LocalKeyX.route, RouteNameX.completeAccountInfo);
        if (!lease.isCurrent) return;
        app.user = user.obs;
        app.isLogin.value = true;
        _provisional = null;
      } else {
        await DatabaseX.verifyOtpForgetPassword(email: email, otpCode: code);
        if (!lease.isCurrent) return;
      }
      buttonState.value = ButtonStateEX.success;
      await Future<void>.delayed(
        const Duration(seconds: StyleX.successButtonSecond),
      );
      if (!lease.isCurrent) return;
      if (signUp) {
        Get.offAllNamed(RouteNameX.completeAccountInfo);
      } else {
        Get.offAndToNamed(
          RouteNameX.forgotPasswordReset,
          arguments: {NameX.email: email, NameX.otp: code},
        );
      }
    } catch (e) {
      if (!lease.isCurrent) return;
      final pending = _provisional;
      if (pending?.isCurrent == true) {
        final clearing = app.clearLocalSession(pending!, navigate: false);
        lease = _capture(route);
        await clearing;
        if (!lease.isCurrent) return;
      }
      _provisional = null;
      buttonState.value = ButtonStateEX.failed;
      ToastX.error(message: e);
    } finally {
      final pending = _provisional;
      if (!lease.isCurrent && pending?.isCurrent == true) {
        await app.clearLocalSession(pending!, navigate: false);
        _provisional = null;
      }
      if (lease.isCurrent) {
        isLoading.value = false;
        _resetTimer?.cancel();
        final resetLease = lease;
        _resetTimer = Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () {
            if (resetLease.isCurrent) buttonState.value = ButtonStateEX.normal;
          },
        );
      }
    }
  }

  Future<void> onResend() async {
    if (isLoadingResendAgain.value || isLoading.value || isClosed) return;
    final lease = _capture(Get.currentRoute);
    isLoadingResendAgain.value = true;
    try {
      final message = await sendCode() ?? '';
      if (!lease.isCurrent) return;
      isResendAgain.value = false;
      start.value = 120;
      startTimer();
      if (message.isNotEmpty) ToastX.success(message: message);
    } catch (e) {
      if (lease.isCurrent) ToastX.error(message: e);
    } finally {
      if (lease.isCurrent) isLoadingResendAgain.value = false;
    }
  }

  Future<String?> sendCode() async {
    final signUp = otp.isSignUp;
    final phone = otp.isPhone;
    final email = otp.email ?? '';
    if (email.isEmpty) throw ErrorX(message: 'Required');
    if (signUp) {
      if (phone) return null; // No phone verification contract is available.
      return DatabaseX.resendOtpSignUp(email: email);
    }
    return DatabaseX.forgetPassword(email: email);
  }

  void _updateTimerFromElapsedTime() {
    if (isClosed || _timerStartTime == null) return;
    final remaining =
        _initialDuration -
        DateTime.now().difference(_timerStartTime!).inSeconds;
    if (remaining > 0) {
      start.value = remaining;
    } else {
      start.value = 120;
      isResendAgain.value = true;
      timer?.cancel();
    }
  }

  void startTimer() {
    if (isClosed || isResendAgain.value) return;
    timer?.cancel();
    _timerStartTime = DateTime.now();
    _initialDuration = start.value;
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTimerFromElapsedTime(),
    );
  }

  @override
  void onInit() {
    super.onInit();
    otpKey = GlobalKey<OtpPinFieldState>();
    WidgetsBinding.instance.addObserver(this);
    startTimer();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    _resetTimer?.cancel();
    final pending = _provisional;
    if (pending?.isCurrent == true) {
      unawaited(app.clearLocalSession(pending!, navigate: false));
    }
    otpCode.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && !isResendAgain.value) {
      _updateTimerFromElapsedTime();
    }
  }
}
