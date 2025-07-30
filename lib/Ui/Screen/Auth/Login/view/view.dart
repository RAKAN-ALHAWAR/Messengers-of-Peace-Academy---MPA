import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../Widget/widget.dart';
import '../controller/controller.dart';
import '../../../../Section/AuthLayout/auth_layout.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayoutX(
      title: "Login",
      subtitle: "Welcome back login to your account",
      formKey: controller.formKey,
      autoValidateMode: controller.autovalidate,
      isBackIcon: false,
      child: Obx(
        /// Lock the screen when loading
        () => AbsorbPointer(
          absorbing: controller.isLoading.value,
          child: Column(
            children: [
              /// Google login button
              ButtonStateX.gray(
                state: controller.buttonStateGoogle.value,
                borderColor: Theme.of(context).primaryColor,
                text: "Login with Google account",
                colorText: Theme.of(context).primaryColor,
                icon: Image.asset(ImageX.google, height: 19),
                onTap: controller.onLoginWithGoogle,
              ).fadeAnimation200,

              /// Divider with "Or" text
              Row(
                children: [
                  Expanded(child: Divider()),
                  TextX(
                    "Or",
                    style: TextStyleX.labelLarge,
                  ).marginSymmetric(horizontal: 12),
                  Expanded(child: Divider()),
                ],
              ).fadeAnimation200.marginSymmetric(vertical: 16),

              /// Email input field
              TextFieldX(
                controller: controller.email,
                hint: 'Email',
                validate: ValidatorX.email,
                textInputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                margin: EdgeInsets.only(bottom: 12),
              ).fadeAnimation250,

              /// Password input field
              TextFieldX(
                controller: controller.password,
                hint: 'Password',
                validate: ValidatorX.password,
                textInputType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                margin: EdgeInsets.only(bottom: 16),
              ).fadeAnimation250,

              /// Forgot password link
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: InkWell(
                  onTap: controller.onForgotPassword,
                  child: TextX(
                    "Forgot Password?",
                    color: Theme.of(context).primaryColor,
                    textDecoration: TextDecoration.underline,
                  ),
                ),
              ).marginOnly(bottom: 16).fadeAnimation300,

              /// Login button
              ButtonStateX(
                text: "login",
                state: controller.buttonStateLogin.value,
                onTap: controller.onLogin,
              ).marginOnly(bottom: 16).fadeAnimation300,

              /// Create account link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextX("Don't have an account?"),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: controller.onCreateAccount,
                    child: TextX(
                      "Create Account",
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ).fadeAnimation350,
            ],
          ),
        ),
      ),
    );
  }
}
