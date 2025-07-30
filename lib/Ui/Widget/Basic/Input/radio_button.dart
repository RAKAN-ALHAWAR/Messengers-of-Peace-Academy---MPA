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
              Radio(
                value: valueCheck ?? value.hashCode,
                groupValue: groupValue.hashCode,
                fillColor: WidgetStateProperty.all(
                  (check != null
                          ? check!()
                          : value.hashCode == groupValue.hashCode)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ), // Change the fill color when selected
                splashRadius: 25, // Change the splash radius when clicked
                onChanged: (_) => onChanged(value),
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
