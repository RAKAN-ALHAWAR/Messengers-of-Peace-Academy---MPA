import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../Config/Translation/translation.dart';
import '../../widget.dart';

class TextFieldTimeX extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final String? titleBottomSheet;
  final bool disabled;
  final EdgeInsets margin;
  final IconData? icon;
  final Color? color;
  final String? Function(String?)? validate;
  final Function(TimeOfDay?)? onChange;
  final TimeOfDay? initialTime;
  late final Locale locale;

  TextFieldTimeX({
    super.key,
    required this.controller,
    required this.hint,
    this.validate,
    this.color,
    this.label,
    this.disabled = false,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.icon,
    this.onChange,
    this.titleBottomSheet,
    this.initialTime,
    Locale? locale,
  }) {
    this.locale = locale ?? Locale(TranslationX.getLanguageCode);
  }

  @override
  State<TextFieldTimeX> createState() => _TextFieldTimeXState();
}

class _TextFieldTimeXState extends State<TextFieldTimeX> {
  TimeOfDay? time;
  @override
  void initState() {
    initializeDateFormatting(widget.locale.languageCode, null);
    time = widget.initialTime ?? TimeOfDay.now();
    if (widget.initialTime != null) {
      widget.controller.text = '${(time!.hour > 12
          ? time!.hour - 12
          : time!.hour == 0
          ? 12
          : time!.hour).toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')} ${time!.period.name.toUpperCase().tr}';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldX(
      label: widget.label,
      margin: widget.margin,
      controller: widget.controller,
      validate: widget.validate,
      textInputType: TextInputType.datetime,
      textInputAction: TextInputAction.done,
      focusNode: AlwaysDisabledFocusNode(),
      onlyRead: true,
      onlyReadNotChangeColor: true,
      hint: widget.hint,
      suffixWidget:
          widget.icon != null
              ? Icon(
                widget.icon,
                size: 22.0,
                color: Theme.of(context).colorScheme.secondary,
              )
              : null,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        await bottomSheetX(
          title: widget.titleBottomSheet,
          child: Column(
            children: [
              SizedBox(height: 12),
              TimeInputX(
                initialTime: time,
                onChange: (time) {
                  setState(() {
                    this.time = time;
                  });
                },
              ).fadeAnimation200,
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: ButtonX(
                      text: "Ok",
                      onTap: () {
                        if (time != null) {
                          widget.controller.text = '${(time!.hour > 12
                              ? time!.hour - 12
                              : time!.hour == 0
                              ? 12
                              : time!.hour).toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')} ${time!.period.name.toUpperCase().tr}';
                          widget.onChange?.call(time);
                        }
                        Get.back();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: ButtonX.gray(
                      text: "Reset",
                      onTap: () {
                        widget.controller.text = '';
                        time = null;
                        widget.onChange?.call(null);
                        Get.back();
                      },
                    ),
                  ),
                ],
              ).fadeAnimation300,
            ],
          ),
        );
      },
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
