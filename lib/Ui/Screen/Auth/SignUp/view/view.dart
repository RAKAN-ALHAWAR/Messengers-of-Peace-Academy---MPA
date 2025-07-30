import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../../Config/config.dart';
import '../../../../Widget/widget.dart';
import '../../../../Section/AuthLayout/auth_layout.dart';
import '../controller/controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthLayoutX(
      title: "Create a new account",
      subtitle: "Create your account and start your educational journey",
      formKey: controller.formKey,
      autoValidateMode: controller.autovalidate,
      isBackIcon: false,
      child: Obx(
        /// Lock the screen when loading
        () => AbsorbPointer(
          absorbing: controller.isLoading.value,
          child: Column(
            children: [
              /// First Name and Last Name
              Row(
                children: [
                  /// First Name
                  Flexible(
                    child: TextFieldX(
                      controller: controller.firstName,
                      hint: "First Name",
                      validate: ValidatorX.name,
                      textInputType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                  ),

                  /// Space
                  const SizedBox(width: 12),

                  /// Last Name
                  Flexible(
                    child: TextFieldX(
                      controller: controller.lastName,
                      hint: "Last Name",
                      validate: ValidatorX.name,
                      textInputType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ).fadeAnimation200.marginOnly(bottom: 8),

              /// Note that you cannot change the name later unless you contact us
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "${"Please note that you cannot change the name later unless you".tr} ",
                        style: TextStyleX.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = controller.onContactUs,
                        text: "contact us.".tr,
                        style: TextStyleX.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ).fadeAnimation200.marginOnly(bottom: 12),
              ),

              /// Email
              TextFieldX(
                controller: controller.email,
                hint: 'Email',
                validate: ValidatorX.email,
                textInputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                margin: EdgeInsets.only(bottom: 12),
              ).fadeAnimation250,

              /// Password
              TextFieldX(
                controller: controller.password,
                hint: 'Password',
                validate: ValidatorX.password,
                textInputType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                margin: EdgeInsets.only(bottom: 12),
              ).fadeAnimation250,

              /// Account verification method
              DropdownX(
                value: controller.verificationMethod,
                list: controller.verificationMethods,
                hint: "Account verification method",
                onChanged: controller.onVerificationMethod,
              ).marginOnly(bottom: 12).fadeAnimation250,

              /// Terms and conditions
              CheckBoxX(
                value: controller.isTermsAccepted.value,
                onChanged: controller.onChangeTermsAccepted,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "${"I agree to".tr} ",
                        style: TextStyleX.labelLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = controller.onTermsAccepted,
                        text: "terms and conditions".tr,
                        style: TextStyleX.labelLarge.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TextSpan(
                        text: " ${"and".tr} ",
                        style: TextStyleX.labelLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = controller.onPrivacyPolicy,
                        text: "privacy policy".tr,
                        style: TextStyleX.labelLarge.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ).fadeAnimation300,

              /// Sign up button
              ButtonStateX(
                text: "sign up",
                state: controller.buttonState.value,
                disabled: !controller.isTermsAccepted.value,
                onTap: controller.onSignUp,
              ).marginOnly(bottom: 16).fadeAnimation300,

              /// Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Already have an account?
                  TextX("Already have an account?"),

                  /// Space
                  const SizedBox(width: 4),

                  /// Login
                  InkWell(
                    onTap: controller.onLogin,
                    child: TextX(
                      "Login",
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
