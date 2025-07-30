import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Config/config.dart';
import '../../../../Ui/Widget/widget.dart';

class SelectedCardX<T> extends StatelessWidget {
  const SelectedCardX({
    super.key,
    required this.groupValue,
    required this.value,
    required this.onChanged,
    this.label,
    this.check,
    this.child,
    this.height,
    this.color,
    this.margin = const EdgeInsets.symmetric(vertical: 5),
  });
  final String? label;
  final Widget? child;
  final double? height;
  final EdgeInsets margin;
  final Color? color;
  final T? groupValue;
  final T value;
  final bool Function()? check;
  final void Function(T? value) onChanged;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(value);
      },
      child: ContainerX(
        margin: margin,
        isBorder: true,
        color:
            (check != null ? check!() : value.hashCode == groupValue.hashCode)
                ? context.isDarkMode
                    ? ColorX.primary
                    : Theme.of(context).colorScheme.onPrimary
                : color ?? Theme.of(context).cardTheme.color,
        borderColor:
            (check != null ? check!() : value.hashCode == groupValue.hashCode)
                ? context.isDarkMode
                    ? Theme.of(context).primaryColor
                    : ColorX.primary
                : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14.0),
        height: height ?? StyleX.inputHeight,
        child:
            child ??
            Flexible(
              child: TextX(
                label ?? '',
                color:
                    (check != null
                            ? check!()
                            : value.hashCode == groupValue.hashCode)
                        ? Theme.of(context).primaryColor
                        : null,
              ),
            ),
      ),
    );
  }
}
