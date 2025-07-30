part of '../../widget.dart';

class SwitchX extends StatefulWidget {
  const SwitchX({
    super.key,
    this.label,
    required this.value,
    required this.onChange,
    this.margin = const EdgeInsets.symmetric(vertical: 0),
    this.isSmallTitle = false,
    this.isFittedTitle = true,
  });
  final String? label;
  final bool value;
  final Function(bool val) onChange;
  final EdgeInsetsGeometry margin;
  final bool isSmallTitle;
  final bool isFittedTitle;
  @override
  State<SwitchX> createState() => _SwitchXState();
}

class _SwitchXState extends State<SwitchX> {
  late bool value;
  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SwitchX oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        value = widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 42,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch(
                thumbIcon: WidgetStateProperty.all(const Icon(null)),
                thumbColor: WidgetStatePropertyAll(
                  context.isDarkMode ? ColorX.grey.shade300 : Colors.white,
                ),
                value: value,
                onChanged: (bool val) async {
                  setState(() {
                    value = val;
                  });
                  await widget.onChange(val);
                },
              ),
            ),
          ),
          if (widget.label != null) const SizedBox(width: 10),
          if (widget.label != null && widget.isFittedTitle)
            Flexible(
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    value = !value;
                  });
                  await widget.onChange(value);
                },
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: TextX(
                    widget.label!,
                    style: widget.isSmallTitle ? TextStyleX.titleSmall : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (widget.label != null && !widget.isFittedTitle)
            Flexible(
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    value = !value;
                  });
                  await widget.onChange(value);
                },
                child: TextX(
                  widget.label!,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).iconTheme.color,
                  style: widget.isSmallTitle ? TextStyleX.labelMedium : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
