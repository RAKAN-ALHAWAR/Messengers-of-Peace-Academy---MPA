import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/Model/auth/otp.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Core/Error/error.dart';
import '../../../../../Data/data.dart';

class LoginController extends GetxController {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  // Loading state
  final isLoading = false.obs;

  // Button states
  final buttonStateGoogle = ButtonStateEX.normal.obs;
  final buttonStateLogin = ButtonStateEX.normal.obs;

  // Google Sign In
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId:
        Platform.isAndroid ? ConstantX.clientIdAndroid : ConstantX.clientIdIOS,
  );

  // Form controllers
  late GlobalKey<FormState> formKey;
  final email = TextEditingController();
  final password = TextEditingController();

  // Form validation
  AutovalidateMode autovalidate = AutovalidateMode.disabled;

  //============================================================================
  // Functions

  /// Handle Google login
  void onLoginWithGoogle() async {
    /// Check if loading is false
    if (isLoading.isFalse) {
      /// Set loading to true
      isLoading.value = true;
      buttonStateGoogle.value = ButtonStateEX.loading;

      /// Try to sign in with Google
      try {
        /// Sign in with Google
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        /// If the user cancels the login, set the button state to normal and return
        if (googleUser == null) {
          buttonStateGoogle.value = ButtonStateEX.normal;
          isLoading.value = false;
          return;
        }

        /// Get token from Google
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        /// Disconnect from Google
        await googleSignIn.disconnect();

        /// If the token is null, throw an error
        if (idToken == null) {
          throw ErrorX(message: 'Failed to get Google token.');
        }

        /// Login with token to database
        var userid = await DatabaseX.loginByGoogle(token: idToken);

        /// Set user on app controller
        app.user = (await DatabaseX.getUser(userId: userid)).obs;
        app.isLogin.value = true;

        /// Set Local Data
        LocalDataX.put(LocalKeyX.userid, userid);
        LocalDataX.put(LocalKeyX.route, RouteNameX.root);

        /// Success
        buttonStateGoogle.value = ButtonStateEX.success;
        await Future.delayed(
          const Duration(seconds: StyleX.successButtonSecond),
        );

        /// Navigate to Root
        Get.offAndToNamed(RouteNameX.root);
      } catch (e) {
        /// Set Error
        buttonStateGoogle.value = ButtonStateEX.failed;
        ToastX.error(message: e);

        /// Set Loading to false
        isLoading.value = false;

        /// Reset button state
        Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () {
            buttonStateGoogle.value = ButtonStateEX.normal;
          },
        );
      }
    }
  }

  /// Handle email/password login
  void onLogin() async {
    /// Check if loading is false
    if (isLoading.isFalse) {
      /// Check if form is valid
      if (formKey.currentState!.validate()) {
        /// Set Loading to true
        isLoading.value = true;

        /// Set Button State to loading
        buttonStateLogin.value = ButtonStateEX.loading;

        /// Try to login
        try {
          /// Login Database
          var data = await DatabaseX.login(
            email: email.text,
            password: password.text,
          );

          /// Set User on App Controller
          app.user = (await DatabaseX.getUser(userId: data.$1)).obs;
          app.isLogin.value = true;

          /// Set Local Data
          LocalDataX.put(LocalKeyX.userid, data.$1);
          LocalDataX.put(LocalKeyX.token, data.$2);
          LocalDataX.put(LocalKeyX.route, RouteNameX.root);

          /// Success
          buttonStateLogin.value = ButtonStateEX.success;
          await Future.delayed(
            const Duration(seconds: StyleX.successButtonSecond),
          );

          /// Navigate to Root
          Get.offAndToNamed(RouteNameX.root);
        } catch (e) {
          var error = e.toErrorX;

          /// Check Error Code
          if (error.details[NameX.errorcode] == 'invalidlogin') {
            error = ErrorX(message: 'Please check your email or password');
          } else if (error.details[NameX.errorcode] == 'usernotconfirmed') {
            /// Set Button State to success
            buttonStateLogin.value = ButtonStateEX.success;
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
              ),
            );
          }

          /// Set Button State to failed
          buttonStateLogin.value = ButtonStateEX.failed;
          ToastX.error(message: error.message);

          /// Set Loading to false
          isLoading.value = false;

          /// Reset button state
          Timer(
            const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
            () {
              buttonStateLogin.value = ButtonStateEX.normal;
            },
          );
        }
      } else {
        /// Set Autovalidate to always
        autovalidate = AutovalidateMode.always;
      }
    }
  }

  /// Navigate to forgot password screen
  void onForgotPassword() => Get.toNamed(RouteNameX.forgotPassword);

  /// Navigate to sign up screen
  void onCreateAccount() => Get.offAndToNamed(RouteNameX.signUp);

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
    password.dispose();
    super.onClose();
  }
}
