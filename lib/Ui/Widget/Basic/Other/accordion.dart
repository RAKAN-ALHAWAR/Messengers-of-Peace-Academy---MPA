part of '../../widget.dart';

class AccordionX extends StatefulWidget {
  const AccordionX({
    super.key,
    this.title = "",
    this.titleWidget,
    this.onTap,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: 10),
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.headColor,
    this.headOpenColor,
    this.bodyColor,
    this.isOpen = false,
    this.height,
  });
  final String title;
  final Widget? titleWidget;
  final Function(bool val)? onTap;
  final Widget child;
  final Color? headColor;
  final Color? headOpenColor;
  final Color? bodyColor;
  final bool isOpen;
  final double? height;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  @override
  State<AccordionX> createState() => _AccordionXState();
}

class _AccordionXState extends State<AccordionX> {
  bool isOpen = false;
  @override
  void initState() {
    isOpen = widget.isOpen;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContainerX(
      color: widget.bodyColor ?? Theme.of(context).cardColor,
      padding: EdgeInsets.zero,
      margin: widget.margin,
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              setState(() {
                isOpen = !isOpen;
              });
              if (widget.onTap != null) {
                await widget.onTap!(isOpen);
              }
            },
            child: Container(
              color:
                  isOpen
                      ? widget.headOpenColor ??
                          (Theme.of(context).colorScheme.surfaceContainerLow)
                      : widget.headColor ??
                          Theme.of(context).colorScheme.surfaceContainerLowest,
              padding: widget.padding,
              height: widget.height ?? StyleX.accordionHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child:
                        widget.titleWidget ??
                        TextX(
                          widget.title,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          color: ColorX.primary,
                        ),
                  ),
                  const SizedBox(width: 20),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down,
                    color:
                        (isOpen && context.isDarkMode)
                            ? Colors.white
                            : Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(child: isOpen ? widget.child : null).sizeAnimation300,
        ],
      ),
    );
  }
}
