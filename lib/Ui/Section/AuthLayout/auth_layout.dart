import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../Config/config.dart';
import '../../../Ui/Widget/widget.dart';

/// تخطيط مشترك لشاشات المصادقة
/// Shared layout for authentication screens
class AuthLayoutX extends StatelessWidget {
  const AuthLayoutX({
    super.key,
    required this.child,
    this.isBackIcon = true,
    this.isShowLogo = true,
    required this.title,
    required this.subtitle,
    this.formKey,
    this.autoValidateMode,
    this.showAppLogo = true,
    this.topSpacing = 110.0,
  });

  final Widget child;
  final bool isBackIcon;
  final bool isShowLogo;
  final String title;
  final String subtitle;
  final GlobalKey<FormState>? formKey;
  final AutovalidateMode? autoValidateMode;
  final bool showAppLogo;
  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: StyleX.paddingApp,
              child: Column(
                children: [
                  SizedBox(height: topSpacing),

                  // شعار التطبيق
                  // App logo
                  if (showAppLogo)
                    Image.asset(
                      ImageX.logo,
                      height: 50,
                    ).marginOnly(bottom: 32).fadeAnimation150,

                  // العنوان
                  // Title
                  TextX(
                    title,
                    style: TextStyleX.titleLarge,
                    textAlign: TextAlign.center,
                  ).marginOnly(bottom: 8).fadeAnimation150,

                  // الرسالة/الوصف
                  // Message/Description
                  TextX(
                    subtitle,
                    style: TextStyleX.bodyMedium,
                    textAlign: TextAlign.center,
                  ).marginOnly(bottom: 32).fadeAnimation150,

                  // المحتوى الرئيسي (النموذج أو المحتوى المخصص)
                  // Main content (form or custom content)
                  if (formKey != null)
                    Form(
                      key: formKey!,
                      autovalidateMode:
                          autoValidateMode ?? AutovalidateMode.disabled,
                      child: child,
                    )
                  else
                    child,
                ],
              ),
            ),

            // زر الرجوع
            // Back button
            if (isBackIcon)
              Positioned.directional(
                textDirection: Directionality.of(context),
                start: 0,
                top: 10,
                child:
                    BackButtonX(
                      color: Theme.of(context).colorScheme.onSurface,
                    ).fadeAnimation100,
              ),
          ],
        ),
      ),
    );
  }
}
