part of '../../widget.dart';

// ignore: must_be_immutable
class DropdownX<T> extends StatefulWidget {
  DropdownX({
    super.key,
    this.title,
    required this.value,
    this.color,
    required this.list,
    required this.onChanged,
    this.icon,
    this.hint,
    this.disable = false,
    this.valueShow,
    this.valueWidget,
    this.onlyEnglish = false,
  }) {
    if (value == "") {
      value = null;
    }
  }
  final String? title;
  final String? hint;
  T? value;
  final List list;
  final Color? color;
  final bool disable;
  final IconData? icon;
  final void Function(T) onChanged;
  final String Function(T)? valueShow;
  final Widget Function(T)? valueWidget;
  final bool onlyEnglish;

  @override
  State<DropdownX<T>> createState() => _DropdownXState<T>();
}

class _DropdownXState<T> extends State<DropdownX<T>> {
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.disable,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ContainerX(
            height: StyleX.inputHeight,
            padding:
                widget.icon != null
                    ? const EdgeInsets.symmetric(vertical: 0, horizontal: 4)
                    : const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            isBorder: true,
            color:
                widget.disable
                    ? Theme.of(context).disabledColor
                    : widget.color ?? Theme.of(context).cardTheme.color,
            child: Row(
              children: [
                if (widget.icon != null)
                  Icon(widget.icon, color: ColorX.grey.shade700, size: 22),
                SizedBox(width: widget.icon != null ? 20.0 : 10),
                Expanded(
                  child: DropdownButton<T>(
                    hint: TextX(
                      widget.hint ?? '',
                      style: TextStyleX.bodyMedium,
                      color:
                          widget.disable
                              ? Theme.of(context).iconTheme.color
                              : null,
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 15),
                    value: widget.value,
                    underline: const SizedBox(),
                    items:
                        widget.list.map((value) {
                          return DropdownMenuItem<T>(
                            value: value,
                            child:
                                widget.valueWidget != null
                                    ? widget.valueWidget!(value)
                                    : TextX(
                                      widget.valueShow != null
                                          ? widget.valueShow!(value)
                                          : value.toString(),
                                      style: TextStyleX.titleSmall,
                                      textDirection:
                                          widget.onlyEnglish
                                              ? TextDirection.ltr
                                              : null,
                                    ),
                          );
                        }).toList(),
                    onChanged: (T? val) {
                      if (val != null) {
                        setState(() {
                          widget.value = val;
                        });
                        widget.onChanged(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (widget.hint != null &&
              (widget.value != null && widget.value != ""))
            Positioned.directional(
              textDirection: Directionality.of(context),
              top: -8,
              start: 17,
              end: 0,
              child: TextX(
                widget.hint ?? '',
                style: TextStyleX.labelSmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
