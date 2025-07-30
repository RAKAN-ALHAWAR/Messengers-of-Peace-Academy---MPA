part of '../../widget.dart';

class CheckBoxX extends StatefulWidget {
  const CheckBoxX({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.isCardOnly = false,
    this.isJustBox = true,
    this.check,
    this.child,
    this.height,
    this.textStyle,
    this.valueCheck,
    this.color,
    this.strikethroughOnChecked = false,
    this.margin = const EdgeInsets.symmetric(vertical: 5),
  });

  final String? label;
  final Widget? child;
  final bool isCardOnly;
  final bool isJustBox;
  final double? height;
  final EdgeInsets margin;
  final TextStyle? textStyle;
  final Color? color;
  final bool value;
  final dynamic valueCheck;
  final bool Function()? check;
  final void Function(bool value) onChanged;
  final bool strikethroughOnChecked;

  @override
  State<CheckBoxX> createState() => _CheckBoxXState();
}

class _CheckBoxXState extends State<CheckBoxX> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant CheckBoxX oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  void _toggleValue() {
    setState(() {
      _value = !_value;
    });
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleValue,
      child: AddParentX(
        isAdd: !widget.isJustBox,
        child: Row(
          mainAxisAlignment:
              widget.isCardOnly
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
          children: [
            if (!widget.isCardOnly)
              Checkbox(
                value: _value,
                onChanged: (_) => _toggleValue(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                side: WidgetStateBorderSide.resolveWith(
                  (states) => BorderSide(
                    width: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            Flexible(
              child:
                  widget.child ??
                  TextX(
                    widget.label ?? '',
                    style: (widget.textStyle ?? TextStyleX.titleMedium)
                        .copyWith(
                          color:
                              _value && widget.strikethroughOnChecked
                                  ? ColorX.grey.shade400
                                  : null,
                          decorationColor:
                              _value && widget.strikethroughOnChecked
                                  ? ColorX.grey.shade400
                                  : null,
                          decoration:
                              widget.strikethroughOnChecked && _value
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                        ),
                  ),
            ),
          ],
        ),
        parent:
            (child) => ContainerX(
              margin: widget.margin,
              isBorder: true,
              color:
                  (widget.check != null ? widget.check!() : _value) &&
                          !widget.strikethroughOnChecked
                      ? context.isDarkMode
                          ? ColorX.primary
                          : Theme.of(context).colorScheme.onPrimary
                      : widget.color ?? Theme.of(context).cardTheme.color,
              borderColor:
                  widget.strikethroughOnChecked
                      ? null
                      : (widget.check != null ? widget.check!() : _value)
                      ? context.isDarkMode
                          ? Theme.of(context).primaryColor
                          : ColorX.primary
                      : null,
              padding:
                  widget.isCardOnly
                      ? const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14.0,
                      )
                      : EdgeInsets.zero,
              height: widget.height ?? StyleX.inputHeight,
              child: child,
            ),
      ),
    );
  }
}
