import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart' show FunctionX;
import '../../../../../Data/data.dart' show ButtonStateEX;
import '../../../../Animation/fade/fade_animation.dart';
import '../../../../Section/AuthLayout/auth_layout.dart';
import '../../../../Section/AuthLayout/otp_resend.dart';
import '../../../../Section/AuthLayout/otp_verification_form.dart';
import '../../../../Widget/Basic/Input/otp_fields.dart';
import '../../../../Widget/widget.dart';
import '../controller/controller.dart';

class AccountDeletionView extends GetView<AccountDeletionController> {
  const AccountDeletionView({super.key});

  @override
  Widget build(BuildContext context) {
    final systemScale = MediaQueryData.fromView(View.of(context)).textScaler;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: systemScale),
      child: GetBuilder<AccountDeletionController>(
        builder: (controller) => PopScope(
          canPop: controller.canGoBack,
          child: controller.hasChallenge
              ? _Verification(controller: controller)
              : _Consent(controller: controller),
        ),
      ),
    );
  }
}

class _Consent extends StatelessWidget {
  const _Consent({required this.controller});

  final AccountDeletionController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(
        title: 'Delete account',
        isBack: controller.canGoBack,
        leading: controller.canGoBack ? null : const SizedBox.shrink(),
        leadingWidth: controller.canGoBack ? null : 0,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: StyleX.paddingApp,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextX(
                'delete.explanation',
                style: TextStyleX.titleMedium,
              ),
              if (controller.showConsent) ...[
                const SizedBox(height: 16),
                AbsorbPointer(
                  absorbing: controller.busy,
                  child: CheckBoxX(
                    value: controller.consent,
                    onChanged: controller.onConsentChanged,
                    label: 'delete.consent',
                    textStyle: TextStyleX.bodyMedium,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (controller.showSend || controller.showResend)
                ButtonStateX(
                  text: controller.showSend ? 'delete.send' : 'delete.resend',
                  onTap: controller.onRequestCode,
                  state: controller.requestingCode
                      ? ButtonStateEX.loading
                      : ButtonStateEX.normal,
                  disabled:
                      !controller.canRequestCode && !controller.requestingCode,
                ),
              if (controller.uncertain)
                ButtonStateX(
                  text: 'delete.returnToSignIn',
                  onTap: controller.onReturnToSignIn,
                ),
              _DeletionFooter(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _Verification extends StatelessWidget {
  const _Verification({required this.controller});

  final AccountDeletionController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = controller.codeError;
    return AuthLayoutX(
      title: 'Delete account',
      subtitle: 'delete.sent',
      isBackIcon: controller.canGoBack,
      topSpacing: 56,
      child: OtpVerificationFormX(
        fields: Column(
          children: [
            Semantics(
              label: 'delete.code'.tr,
              child: OtpFieldsX(
                pinKey: ValueKey(controller.otpInputVersion),
                enabled: !controller.busy,
                keyboardAutofill: true,
                onChanged: controller.onCodeChanged,
              ),
            ).fadeAnimation250,
            if (error != null)
              Semantics(
                liveRegion: true,
                child: TextX(
                  error,
                  style: TextStyleX.bodySmall,
                  color: theme.colorScheme.error,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        action: 'delete.confirm',
        onVerify: controller.onConfirmDeletion,
        state: controller.confirming
            ? ButtonStateEX.loading
            : ButtonStateEX.normal,
        canVerify: controller.codeComplete && !controller.busy,
        resend: Column(
          children: [
            OtpResendX(
              seconds: controller.resendSeconds,
              onResend: controller.canRequestCode
                  ? controller.onRequestCode
                  : null,
              loading: controller.requestingCode,
            ),
            const SizedBox(height: 8),
            TextX(
              'delete.expires'.trParams({
                'time': FunctionX.formatTime(controller.expirySeconds),
              }),
              style: TextStyleX.bodySmall,
            ),
            const SizedBox(height: 16),
            _DeletionFooter(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _DeletionFooter extends StatelessWidget {
  const _DeletionFooter({required this.controller});

  final AccountDeletionController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = controller.message;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Semantics(
              liveRegion: true,
              child: TextX(
                message,
                style: TextStyleX.bodyMedium,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ButtonStateX.gray(
          text: 'delete.support',
          onTap: controller.onOpenSupport,
          disabled: controller.busy,
        ),
      ],
    );
  }
}
