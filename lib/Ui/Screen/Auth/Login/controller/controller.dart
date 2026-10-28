import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Service/controller_lease.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Data/Model/auth/otp.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Data/data.dart';

class LoginController extends GetxController {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  final isLoading = false.obs;
  final buttonStateGoogle = ButtonStateEX.normal.obs;
  final buttonStateLogin = ButtonStateEX.normal.obs;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: Platform.isAndroid
        ? ConstantX.clientIdAndroid
        : ConstantX.clientIdIOS,
  );
  late GlobalKey<FormState> formKey;
  final email = TextEditingController();
  final password = TextEditingController();
  AutovalidateMode autovalidate = AutovalidateMode.disabled;
  Timer? _resetTimer;
  int _submission = 0;
  SessionLeaseX? _provisional;

  // True when the account signed in but its profile is not fully set up yet.
  bool _profileMissing = false;

  //============================================================================
  // Functions

  /// Work started on [route]: open, on that route, and under this app controller.
  SessionLeaseX _capture(String route) => ControllerLeaseX.capture(
    this,
    app: app,
    also: () => Get.currentRoute == route,
  );

  /// Credentials stay provisional until the profile is verified.
  Future<SessionLeaseX?> _authenticate(
    (String, String) data,
    SessionLeaseX owner,
    String route,
    void Function(SessionLeaseX) onLease, {
    String? username,
  }) async {
    if (!owner.isCurrent) return null;
    _profileMissing = false;
    if (data.$1.trim().isEmpty || data.$2.trim().isEmpty) {
      throw ErrorX(
        message: 'Unable to start a secure session. Please sign in again.',
      );
    }
    app.isLogin.value = false;
    final writes = [
      LocalDataX.put(LocalKeyX.userid, data.$1),
      LocalDataX.put(LocalKeyX.token, data.$2),
      LocalDataX.put(LocalKeyX.route, RouteNameX.login),
    ];
    _provisional = SessionLeaseX.capture();
    final committed = _capture(route);
    onLease(committed);
    try {
      await Future.wait(writes);
      if (!committed.isCurrent) return null;
      UserX user;
      try {
        user = await DatabaseX.getUser(userId: data.$1);
      } catch (e) {
        // The server refuses the profile of an account whose data is not
        // complete yet. Keep the session and let the user complete the data,
        // starting from what is known (the login name is the email).
        final incomplete =
            e.toErrorX.details[NameX.errorcode] == 'usernotfullysetup';
        if (!incomplete || username == null) rethrow;
        if (!committed.isCurrent) return null;
        _profileMissing = true;
        user = UserX(
          id: data.$1,
          username: username,
          firstname: '',
          lastname: '',
          email: username,
          lang: 'en',
          customfields: [],
          city: '',
          image: '',
          points: 0,
        );
      }
      if (!committed.isCurrent) return null;
      if (user.id != data.$1) {
        throw ErrorX(
          message: 'Unable to start a secure session. Please sign in again.',
        );
      }
      await LocalDataX.put(
        LocalKeyX.route,
        _profileMissing ? RouteNameX.completeAccountInfo : RouteNameX.root,
      );
      if (!committed.isCurrent) return null;
      app.user = user.obs;
      app.isLogin.value = true;
      _provisional = null;
      return committed;
    } catch (_) {
      final pending = _provisional;
      if (pending?.isCurrent == true) {
        final clearing = app.clearLocalSession(pending!, navigate: false);
        onLease(_capture(route));
        await clearing;
      }
      _provisional = null;
      rethrow;
    } finally {
      final pending = _provisional;
      if (!committed.isCurrent && pending?.isCurrent == true) {
        await app.clearLocalSession(pending!, navigate: false);
        _provisional = null;
      }
    }
  }

  Future<void> onLoginWithGoogle() async {
    if (isLoading.value || isClosed) return;
    final route = Get.currentRoute;
    final submission = ++_submission;
    var lease = _capture(route);
    isLoading.value = true;
    buttonStateGoogle.value = ButtonStateEX.loading;
    try {
      final googleUser = await googleSignIn.signIn();
      if (!lease.isCurrent) return;
      if (googleUser == null) {
        buttonStateGoogle.value = ButtonStateEX.normal;
        return;
      }
      final googleAuth = await googleUser.authentication;
      if (!lease.isCurrent) return;
      final idToken = googleAuth.idToken;
      await googleSignIn.disconnect();
      if (!lease.isCurrent) return;
      if (idToken == null || idToken.isEmpty) {
        throw ErrorX(message: 'Failed to get Google token.');
      }
      final data = await DatabaseX.loginByGoogle(token: idToken);
      if (!lease.isCurrent) return;
      final authenticated = await _authenticate(
        data,
        lease,
        route,
        (next) => lease = next,
      );
      if (authenticated == null) return;
      lease = authenticated;
      if (!lease.isCurrent) return;
      buttonStateGoogle.value = ButtonStateEX.success;
      await Future<void>.delayed(
        const Duration(seconds: StyleX.successButtonSecond),
      );
      if (!lease.isCurrent) return;
      Get.offAndToNamed(RouteNameX.root);
    } catch (e) {
      if (!lease.isCurrent) return;
      buttonStateGoogle.value = ButtonStateEX.failed;
      ToastX.error(
        message: e.toString().contains('PlatformException(')
            ? 'Something wrong'
            : e,
      );
      _reset(buttonStateGoogle);
    } finally {
      _releaseSubmission(submission, route);
    }
  }

  Future<void> onLogin() async {
    if (isLoading.value || isClosed) return;
    if (formKey.currentState?.validate() != true) {
      autovalidate = AutovalidateMode.always;
      return;
    }
    final submittedEmail = email.text;
    final submittedPassword = password.text;
    final route = Get.currentRoute;
    final submission = ++_submission;
    var lease = _capture(route);
    isLoading.value = true;
    buttonStateLogin.value = ButtonStateEX.loading;
    try {
      final data = await DatabaseX.login(
        email: submittedEmail,
        password: submittedPassword,
      );
      if (!lease.isCurrent) return;
      final authenticated = await _authenticate(
        data,
        lease,
        route,
        (next) => lease = next,
        username: submittedEmail,
      );
      if (authenticated == null) return;
      lease = authenticated;
      if (!lease.isCurrent) return;
      buttonStateLogin.value = ButtonStateEX.success;
      await Future<void>.delayed(
        const Duration(seconds: StyleX.successButtonSecond),
      );
      if (!lease.isCurrent) return;
      if (_profileMissing) {
        Get.offAndToNamed(
          RouteNameX.completeAccountInfo,
          arguments: {'profileMissing': true},
        );
      } else {
        Get.offAndToNamed(RouteNameX.root);
      }
    } catch (e) {
      if (!lease.isCurrent) return;
      var error = e.toErrorX;
      if (error.details[NameX.errorcode] == 'invalidlogin') {
        error = ErrorX(message: 'Please check your email or password');
      } else if (error.details[NameX.errorcode] == 'usernotconfirmed') {
        // Only the known userid response field can establish verification identity.
        // Backend recovery without that field remains a contract blocker.
        final value = error.details[NameX.userId];
        final id = value is String || value is num
            ? value.toString().trim()
            : '';
        if (id.isNotEmpty) {
          isLoading.value = false;
          buttonStateLogin.value = ButtonStateEX.normal;
          Get.toNamed(
            RouteNameX.otp,
            arguments: OtpX(
              isSignUp: true,
              isPhone: false,
              email: submittedEmail,
              userid: id,
            ),
          );
          return;
        }
        error = ErrorX(
          message:
              'Your account still needs verification. Please contact support to recover verification access.',
        );
      }
      buttonStateLogin.value = ButtonStateEX.failed;
      ToastX.error(message: error.message);
      _reset(buttonStateLogin);
    } finally {
      _releaseSubmission(submission, route);
    }
  }

  /// Unlocks the screen if this is still its live controller, even after the session expired.
  void _releaseSubmission(int submission, String route) {
    if (submission != _submission ||
        Get.currentRoute != route ||
        !ControllerLeaseX.owns(this)) {
      return;
    }
    isLoading.value = false;
    if (buttonStateLogin.value == ButtonStateEX.loading) {
      buttonStateLogin.value = ButtonStateEX.normal;
    }
    if (buttonStateGoogle.value == ButtonStateEX.loading) {
      buttonStateGoogle.value = ButtonStateEX.normal;
    }
  }

  void _reset(Rx<ButtonStateEX> state) {
    _resetTimer?.cancel();
    final lease = _capture(Get.currentRoute);
    _resetTimer = Timer(
      const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
      () {
        if (lease.isCurrent) state.value = ButtonStateEX.normal;
      },
    );
  }

  void onForgotPassword() => Get.toNamed(RouteNameX.forgotPassword);
  void onCreateAccount() => Get.offAndToNamed(RouteNameX.signUp);

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
  }

  @override
  void onClose() {
    _resetTimer?.cancel();
    final pending = _provisional;
    if (pending?.isCurrent == true) {
      unawaited(app.clearLocalSession(pending!, navigate: false));
    }
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
