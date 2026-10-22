part of '../../widget.dart';

class RadioButtonX<T> extends StatelessWidget {
  const RadioButtonX({
    super.key,
    required this.groupValue,
    required this.value,
    required this.onChanged,
    this.label,
    this.isCardOnly = false,
    this.check,
    this.child,
    this.height,
    this.valueCheck,
    this.color,
    this.margin = const EdgeInsets.symmetric(vertical: 5),
    this.padding,
    this.isJustBox = false,
    this.borderColor,
  });
  final String? label;
  final Widget? child;
  final bool isCardOnly;
  final bool isJustBox;
  final double? height;
  final EdgeInsets margin;
  final EdgeInsets? padding;
  final Color? color;
  final Color? borderColor;
  final T? groupValue;
  final T value;
  final dynamic valueCheck;
  final bool Function()? check;
  final void Function(T? value) onChanged;
  @override
  Widget build(BuildContext context) {
    // Default options use value equality. Hash collisions are not selections.
    // valueCheck is a legacy explicit override whose hash-based mapping remains
    // supported; check overrides indicator color only, not group selection.
    final hasLegacyValue = valueCheck != null;
    final selectedValue =
        !isCardOnly && hasLegacyValue ? groupValue.hashCode : groupValue;
    final optionValue = hasLegacyValue ? valueCheck : value;
    final selectedColor =
        !isCardOnly &&
        (check != null
            ? check!()
            : hasLegacyValue
            ? value.hashCode == groupValue.hashCode
            : value == groupValue);
    return GestureDetector(
      onTap: () {
        onChanged(value);
      },
      child: AddParentX(
        isAdd: !isJustBox,
        child: Row(
          mainAxisAlignment:
              isCardOnly ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (!isCardOnly)
              RadioGroup<Object?>(
                groupValue: selectedValue,
                onChanged: (_) => onChanged(value),
                child: Radio<Object?>(
                  value: optionValue,
                  fillColor: WidgetStateProperty.all(
                    selectedColor
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  splashRadius: 25,
                ),
              ),
            if (label != null || child != null)
              Flexible(
                child:
                    child ??
                    TextX(
                      label ?? '',
                      // color:
                      //     (check != null
                      //             ? check!()
                      //             : value.hashCode == groupValue.hashCode)
                      //         ? Theme.of(context).colorScheme.primary
                      //         : null,
                    ),
              ),
          ],
        ),
        parent:
            (child) => ContainerX(
              margin: margin,
              isBorder: true,
              borderColor: borderColor,
              color: color ?? Theme.of(context).cardTheme.color,
              padding:
                  padding ??
                  (isCardOnly
                      ? const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16.0,
                      )
                      : EdgeInsets.zero),
              height: height,
              minHeight: StyleX.inputHeight,
              child: child,
            ),
      ),
    );
  }
}
