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
    date = widget.initialDate;
    if (widget.initialDate != null) {
      widget.controller.text =
          (date != null
              ? (intl.DateFormat(
                widget.format ?? 'EEEE، d MMMM y',
                widget.locale.languageCode,
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
      onTap:
          widget.disabled
              ? null
              : () async {
                FocusScope.of(context).requestFocus(FocusNode());

                // Use Flutter's built-in showDatePicker for better date selection
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: date ?? widget.initialDate ?? DateTime.now(),
                  firstDate: widget.firstDate ?? DateTime(1900),
                  lastDate: widget.lastDate ?? DateTime(2100),
                  locale: widget.locale,
                  builder: (context, child) {
                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;

                    return Theme(
                      data: theme.copyWith(
                        dialogTheme: DialogThemeData(
                          backgroundColor:
                              isDark
                                  ? ColorX.surfaceContainerLowestDark
                                  : Colors.white,
                          surfaceTintColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null && picked != date) {
                  setState(() {
                    date = picked;
                    widget.controller.text =
                        (intl.DateFormat(
                          widget.format ?? 'EEEE، d MMMM y',
                          widget.locale.languageCode,
                        ).format(date!)).arabicToEnglishNumbers;
                    widget.onChange?.call(date);
                  });
                }
              },
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
