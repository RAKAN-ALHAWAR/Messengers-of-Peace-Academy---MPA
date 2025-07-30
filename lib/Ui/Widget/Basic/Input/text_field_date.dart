part of '../../widget.dart';

class TextFieldDateX extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final String? titleBottomSheet;
  final bool disabled;
  final EdgeInsets margin;
  final IconData? icon;
  final Color? color;
  final DateTime? lastDate;
  final DateTime? firstDate;
  final DateTime? initialDate;
  final String? Function(String?)? validate;
  final Function(DateTime?)? onChange;
  late final Locale locale;
  final String? format;

  TextFieldDateX({
    super.key,
    required this.controller,
    required this.hint,
    this.validate,
    this.initialDate,
    this.color,
    this.firstDate,
    this.lastDate,
    this.label,
    this.disabled = false,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.icon,
    this.onChange,
    this.titleBottomSheet,
    this.format,
    Locale? locale,
  }) {
    this.locale = locale ?? Locale(TranslationX.getLanguageCode);
  }

  @override
  State<TextFieldDateX> createState() => _TextFieldDateXState();
}

class _TextFieldDateXState extends State<TextFieldDateX> {
  DateTime? date;
  @override
  void initState() {
    initializeDateFormatting(widget.locale.languageCode, null);
    date = widget.initialDate ?? DateTime.now();
    if (widget.initialDate != null) {
      widget.controller.text =
          (date != null
              ? (intl.DateFormat(
                widget.format ?? 'EEEE، d MMMM y',
                'ar',
              ).format(date!)).arabicToEnglishNumbers
              : '');
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
              DatePickerX(
                initialDate: widget.initialDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                selectedDate: date,
                firstDayOfWeek: DateTime.saturday,
                onDateSelected: (newDate) {
                  date = newDate;
                  widget.onChange?.call(date);
                },
              ).fadeAnimation200,
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: ButtonX(
                      text: "Ok",
                      onTap: () {
                        widget.controller.text =
                            (date != null
                                ? (intl.DateFormat(
                                  widget.format ?? 'EEEE، d MMMM y',
                                  'ar',
                                ).format(date!)).arabicToEnglishNumbers
                                : '');
                        widget.onChange?.call(date);
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
                        date = null;
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
