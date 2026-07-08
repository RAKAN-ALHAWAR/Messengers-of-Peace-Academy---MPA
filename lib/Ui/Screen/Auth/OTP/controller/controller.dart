import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart';
import '../../../../../Data/Model/user/user.dart';
import '../../../../../Data/data.dart';
import '../../../../Widget/Package/otp_pin_field_widget/src/otp_pin_field_state.dart';
import '../../../../Widget/widget.dart';

class OTPController extends GetxController with WidgetsBindingObserver {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  // Loading state
  final isLoading = false.obs;
  final isLoadingResendAgain = false.obs;

  // Resend again state
  final isResendAgain = false.obs;

  // Done input state
  final isDoneInput = false.obs;

  // Button states
  final buttonState = ButtonStateEX.normal.obs;

  // OTP object
  final otp = Get.arguments;

  // OTP code
  final otpCode = TextEditingController();
  late GlobalKey<OtpPinFieldState> otpKey;

  // Timer
  Timer? timer;
  final start = 120.obs;

  // وقت بداية العداد (للاستمرار في الخلفية)
  DateTime? _timerStartTime;
  int _initialDuration = 120; // المدة الأولية بالثواني

  //============================================================================
  // Functions

  /// Get subtitle
  String getSubTitle() {
    if (otp.isPhone) {
      return "${"Please enter the verification code sent to your WhatsApp number".tr}\n ${otp.phone}";
    } else {
      return "${"Please enter the verification code sent to your email".tr}\n ${otp.email}";
    }
  }

  /// Handle verify OTP
  void onVerify() async {
    /// Check if loading is false
    if (isLoading.isFalse) {
      /// Set Loading to true
      isLoading.value = true;

      /// Set Button State to loading
      buttonState.value = ButtonStateEX.loading;

      /// Try to verify OTP
      try {
        late UserX user;

        /// Check if OTP is for sign up
        if (otp.isSignUp) {
          var token = await DatabaseX.verifyOtpSignUp(
            userId: otp.userid ?? '',
            otpCode: otpCode.text,
          );

          /// Save the user token before any authenticated request,
          /// because it is the `wstoken` used by [DBEndPointX.mainAPI]
          if (token.isNotEmpty) LocalDataX.put(LocalKeyX.token, token);

          /// Get user
          user = await DatabaseX.getUser(userId: otp.userid!);
        } else {
          /// Verify OTP for forget password
          await DatabaseX.verifyOtpForgetPassword(
            email: otp.email ?? '',
            otpCode: otpCode.text,
          );
        }

        /// Set Button State to success
        buttonState.value = ButtonStateEX.success;

        /// The time delay here is aesthetically beneficial
        await Future.delayed(
          const Duration(seconds: StyleX.successButtonSecond),
        );

        /// Check if OTP is for sign up
        if (otp.isSignUp) {
          /// Set User on App Controller
          app.user = user.obs;

          /// Save data on local
          LocalDataX.put(LocalKeyX.userid, user.id);
          LocalDataX.put(LocalKeyX.route, RouteNameX.root);

          /// Navigate to complete account info screen
          Get.offAllNamed(RouteNameX.completeAccountInfo);
        } else {
          /// Navigate to forgot password reset screen
          Get.offAndToNamed(
            RouteNameX.forgotPasswordReset,
            arguments: {NameX.email: otp.email, NameX.otp: otpCode.text},
          );
        }
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
    }
  }

  /// Resend the code and set a new timer
  void onResend() async {
    /// Set Loading to true
    isLoadingResendAgain.value = true;

    /// Try to resend code
    try {
      String message = await sendCode() ?? '';

      /// Set Resend again state to false
      isResendAgain.value = false;

      /// Start timer
      startTimer();

      /// Check if message is not empty
      if (message.isNotEmpty) {
        ToastX.success(message: message);
      }
    } catch (e) {
      /// Show error message
      ToastX.error(message: e);
    }

    /// Set Loading to false
    isLoadingResendAgain.value = false;
  }

  /// Send code
  Future<String?> sendCode() async {
    /// Try to send code
    try {
      if (otp.isSignUp) {
        if (otp.isPhone) {
          /// TODO: add api to resend otp sign up by phone
          // return await DatabaseX.resendOtpSignUp(email: otp.email!);
          return null;
        } else {
          /// Resend OTP for sign up by email
          return await DatabaseX.resendOtpSignUp(email: otp.email!);
        }
      } else {
        /// Resend OTP for forget password
        return await DatabaseX.forgetPassword(email: otp.email!);
      }
    } catch (e) {
      /// Show error message
      rethrow;
    }
  }

  /// حساب الوقت المتبقي بناءً على الوقت الفعلي
  void _updateTimerFromElapsedTime() {
    if (_timerStartTime == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(_timerStartTime!).inSeconds;
    final remaining = _initialDuration - elapsed;

    if (remaining > 0) {
      start.value = remaining;
    } else {
      start.value = _initialDuration;
      isResendAgain.value = true;
      timer?.cancel();
    }
  }

  /// A timer to calculate the time remaining until the code can be re-sent
  startTimer() {
    /// Check if resend again state is false
    if (!isResendAgain.value) {
      /// إلغاء العداد السابق إن وجد
      timer?.cancel();

      /// حفظ وقت البدء
      _timerStartTime = DateTime.now();
      _initialDuration = start.value;

      /// Start timer
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        /// Check if start is not 0
        if (start.value != 0) {
          /// Decrease start by 1
          start.value--;
        } else {
          /// Reset start to 120
          start.value = 120;
          _initialDuration = 120;

          /// Set resend again state to true
          isResendAgain.value = true;

          /// Cancel timer
          timer.cancel();
        }
      });
    }
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Initialize OTP key
    otpKey = GlobalKey<OtpPinFieldState>();

    /// إضافة مراقب دورة حياة التطبيق
    WidgetsBinding.instance.addObserver(this);

    /// Start the counter to resend the code
    startTimer();
  }

  @override
  void onClose() {
    /// إزالة مراقب دورة حياة التطبيق
    WidgetsBinding.instance.removeObserver(this);

    /// Dispose controllers
    otpCode.dispose();
    timer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    /// عند العودة للتطبيق من الخلفية
    if (state == AppLifecycleState.resumed) {
      /// تحديث العداد بناءً على الوقت الفعلي المنقضي
      if (_timerStartTime != null && !isResendAgain.value) {
        _updateTimerFromElapsedTime();

        /// إعادة تشغيل العداد إذا كان لا يزال هناك وقت متبقي
        if (start.value > 0 && (timer == null || !timer!.isActive)) {
          timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (start.value != 0) {
              start.value--;
            } else {
              start.value = 120;
              _initialDuration = 120;
              isResendAgain.value = true;
              timer.cancel();
            }
          });
        }
      }
    }
  }
}
