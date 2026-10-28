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

  /// Whether [initialDate] is written into the field up front.
  ///
  /// Set it to false when the value has to be chosen by the user, so that
  /// [initialDate] only decides where the date picker opens.
  final bool prefillInitialDate;
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
    this.prefillInitialDate = true,
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
    if (widget.prefillInitialDate && widget.initialDate != null) {
      date = widget.initialDate;
      widget.controller.text =
          (intl.DateFormat(
            widget.format ?? 'EEEE، d MMMM y',
            widget.locale.languageCode,
          ).format(date!)).arabicToEnglishNumbers;
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
                  builder: (context, child) {
                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;

                    // The locale is set here and not with showDatePicker's
                    // locale, which sits inside the builder and would hide the
                    // Latin digits delegate
                    return Localizations.override(
                      context: context,
                      locale: widget.locale,
                      delegates: const [_LatinDigitsMaterialDelegate()],
                      child: Theme(
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
                      ),
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

/// The stock Material texts, but dates in Latin digits. intl formats dates
/// with the Arabic-Indic digits of the locale unless useNativeDigits is off,
/// and the app writes every number with Latin digits.
class _LatinDigitsMaterialDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _LatinDigitsMaterialDelegate();

  @override
  bool isSupported(Locale locale) =>
      GlobalMaterialLocalizations.delegate.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final name = locale.languageCode;
    intl.DateFormat latin(intl.DateFormat format) =>
        format..useNativeDigits = false;
    return Future.value(
      getMaterialTranslation(
        locale,
        latin(intl.DateFormat.y(name)),
        latin(intl.DateFormat.yMd(name)),
        latin(intl.DateFormat.yMMMd(name)),
        latin(intl.DateFormat.MMMEd(name)),
        latin(intl.DateFormat.yMMMMEEEEd(name)),
        latin(intl.DateFormat.yMMMM(name)),
        latin(intl.DateFormat.MMMd(name)),
        intl.NumberFormat.decimalPattern(name),
        intl.NumberFormat('00', name),
      )!,
    );
  }

  @override
  bool shouldReload(_LatinDigitsMaterialDelegate old) => false;
}
