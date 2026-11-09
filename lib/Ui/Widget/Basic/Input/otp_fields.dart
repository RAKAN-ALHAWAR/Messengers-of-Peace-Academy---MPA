import 'package:flutter/material.dart';

import '../../../../Config/config.dart';
import '../../Package/otp_pin_field_widget/otp_pin_field.dart';

class OtpFieldsX extends StatelessWidget {
  const OtpFieldsX({
    super.key,
    this.pinKey,
    required this.onChanged,
    this.enabled = true,
    this.autoFocus = true,
    this.keyboardAutofill = false,
  });

  static const _length = 6;
  static const _fieldWidth = 58.0;
  static const _spacing = 8.0;

  final Key? pinKey;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool autoFocus;
  final bool keyboardAutofill;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).cardTheme.color ?? Colors.transparent;
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: _length * _fieldWidth + (_length - 1) * _spacing,
          height: 54,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AbsorbPointer(
              absorbing: !enabled,
              child: OtpPinField(
                key: pinKey,
                fieldHeight: 54,
                fieldWidth: _fieldWidth,
                maxLength: _length,
                autoFocus: enabled && autoFocus,
                showDefaultKeyboard: enabled,
                keyboardAutofill: keyboardAutofill,
                cursorColor: ColorX.primary,
                mainAxisAlignment: MainAxisAlignment.center,
                otpPinFieldDecoration: OtpPinFieldDecoration.custom,
                onChange: onChanged,
                otpPinFieldStyle: OtpPinFieldStyle(
                  showHintText: false,
                  defaultFieldBackgroundColor: background,
                  activeFieldBackgroundColor: background,
                  activeFieldBorderColor: ColorX.primary,
                  defaultFieldBorderColor: ColorX.grey.shade200,
                  filledFieldBorderColor: ColorX.grey.shade200,
                  fieldBorderWidth: StyleX.borderWidth,
                  fieldPadding: _spacing,
                  fieldBorderRadius: 8,
                  textStyle: TextStyleX.titleMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
