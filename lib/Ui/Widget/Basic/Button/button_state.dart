part of '../../widget.dart';

// ignore: must_be_immutable
class ButtonStateX extends StatefulWidget {
  ButtonStateX({
    required this.onTap,
    this.text,
    this.onAnimationEnd,
    this.state = ButtonStateEX.normal,
    this.minWidth = 50.0,
    this.maxWidth = 400.0,
    this.radius = 100,
    this.height = StyleX.buttonHeight,
    this.padding = EdgeInsets.zero,
    this.minWidthStates = const <ButtonStateEX>[ButtonStateEX.loading],
    this.animationDuration = const Duration(milliseconds: 500),
    this.disabled = false,
    this.iconData,
    this.icon,
    this.width,
    this.colorButton,
    this.colorDisabledButton,
    this.colorDisabledText,
    this.colorDisabledBorder,
    this.marginVertical = 5,
    this.borderColor = Colors.transparent,
    this.marginHorizontal = 0,
    this.colorText = Colors.white,
    super.key,
  });
  ButtonStateX.second({
    required this.onTap,
    this.text,
    this.onAnimationEnd,
    this.state = ButtonStateEX.normal,
    this.minWidth = 50.0,
    this.maxWidth = 400.0,
    this.radius = 100,
    this.height = StyleX.buttonHeight,
    this.padding = EdgeInsets.zero,
    this.minWidthStates = const <ButtonStateEX>[ButtonStateEX.loading],
    this.animationDuration = const Duration(milliseconds: 500),
    this.disabled = false,
    this.iconData,
    this.icon,
    this.width,
    this.colorButton = Colors.transparent,
    this.colorDisabledButton,
    this.colorDisabledText,
    this.colorDisabledBorder,
    this.marginVertical = 5,
    this.marginHorizontal = 0,
    super.key,
  }) {
    colorText = Get.theme.primaryColor;
    borderColor = Get.theme.primaryColor;
  }

  ButtonStateX.gray({
    required this.onTap,
    this.text,
    this.onAnimationEnd,
    this.state = ButtonStateEX.normal,
    this.minWidth = 50.0,
    this.maxWidth = 400.0,
    this.radius = 100,
    this.height = StyleX.buttonHeight,
    this.padding = EdgeInsets.zero,
    this.minWidthStates = const <ButtonStateEX>[ButtonStateEX.loading],
    this.animationDuration = const Duration(milliseconds: 500),
    this.disabled = false,
    this.iconData,
    this.icon,
    this.width,
    this.colorButton = Colors.transparent,
    this.colorDisabledButton,
    this.colorDisabledText,
    this.colorDisabledBorder,
    this.marginVertical = 5,
    this.marginHorizontal = 0,
    Color? borderColor,
    Color? colorText,
    super.key,
  }) {
    this.colorText = colorText ?? Get.theme.colorScheme.secondary;
    this.borderColor = borderColor ?? ColorX.grey;
  }
  ButtonStateX.dangerous({
    required this.onTap,
    this.text,
    this.onAnimationEnd,
    this.state = ButtonStateEX.normal,
    this.minWidth = 50.0,
    this.maxWidth = 400.0,
    this.radius = 100,
    this.height = StyleX.buttonHeight,
    this.padding = EdgeInsets.zero,
    this.minWidthStates = const <ButtonStateEX>[ButtonStateEX.loading],
    this.animationDuration = const Duration(milliseconds: 500),
    this.disabled = false,
    this.iconData,
    this.icon,
    this.width,
    this.colorButton = Colors.transparent,
    this.colorDisabledButton,
    this.colorDisabledText,
    this.colorDisabledBorder,
    this.marginVertical = 5,
    this.marginHorizontal = 0,
    super.key,
  }) {
    colorText = ColorX.danger;
    borderColor = ColorX.danger;
  }
  final String? text;
  final Function onTap;
  final double marginHorizontal;
  final double marginVertical;
  final EdgeInsets padding;
  final bool disabled;
  late Color borderColor;
  final ButtonStateEX state;
  final double minWidth;
  final double maxWidth;
  final double radius;
  final double height;
  final List<ButtonStateEX> minWidthStates;
  final Duration animationDuration;
  final Widget? icon;
  final IconData? iconData;
  final double? width;
  final Color? colorButton;
  final Color? colorDisabledButton;
  final Color? colorDisabledText;
  final Color? colorDisabledBorder;
  late Color? colorText;
  final Function? onAnimationEnd;
  @override
  State<ButtonStateX> createState() => _ButtonStateXState();
}

class _ButtonStateXState extends State<ButtonStateX>
    with TickerProviderStateMixin {
  AnimationController? colorAnimationController;
  Animation<Color?>? colorAnimation;
  double? width;

  late Map<ButtonStateEX, Color> stateColors;
  late Map<ButtonStateEX, Color> stateBorderColors;

  String get getText => switch (widget.state) {
    ButtonStateEX.loading => 'Loading',
    ButtonStateEX.failed => 'Failed',
    ButtonStateEX.success => 'Success',
    ButtonStateEX.normal => widget.text ?? "",
  };

  void startAnimations(ButtonStateEX? oldState, ButtonStateEX? newState) {
    Color? begin = stateColors[oldState!];
    Color? end = stateColors[newState!];
    width = widget.maxWidth;
    colorAnimation = ColorTween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: colorAnimationController!,
        curve: const Interval(0, 1, curve: Curves.easeIn),
      ),
    );
    colorAnimationController!.forward();
  }

  Color? get backgroundColor =>
      widget.disabled
          ? widget.colorDisabledButton ?? Theme.of(context).disabledColor
          : colorAnimation == null
          ? stateColors[widget.state]
          : colorAnimation!.value ?? stateColors[widget.state];

  Color get borderColor =>
      widget.disabled
          ? widget.colorDisabledBorder ?? Theme.of(context).disabledColor
          : stateBorderColors[widget.state] ?? widget.borderColor;

  @override
  void initState() {
    super.initState();
    width = widget.maxWidth;
    colorAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    colorAnimationController!.addStatusListener((status) {
      if (widget.onAnimationEnd != null) {
        widget.onAnimationEnd!(status, widget.state);
      }
    });
    stateColors = {
      ButtonStateEX.normal: widget.colorButton ?? ColorX.primary,
      ButtonStateEX.loading: Get.theme.disabledColor,
      ButtonStateEX.failed: ColorX.danger,
      ButtonStateEX.success: ColorX.success,
    };
    stateBorderColors = {
      ButtonStateEX.normal: widget.borderColor,
      ButtonStateEX.loading: Get.theme.disabledColor,
      ButtonStateEX.failed: ColorX.danger,
      ButtonStateEX.success: ColorX.success,
    };
  }

  @override
  void dispose() {
    colorAnimationController!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ButtonStateX oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state != widget.state) {
      colorAnimationController?.reset();
      startAnimations(oldWidget.state, widget.state);
    }
  }

  Widget getButtonChild(bool visibility) {
    if (widget.state == ButtonStateEX.normal) {
      return AnimatedOpacity(
        opacity: visibility ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) widget.icon!,
            if (widget.iconData != null && widget.icon == null)
              Icon(
                widget.iconData,
                color:
                    widget.disabled
                        ? widget.colorDisabledText ?? ColorX.grey.shade400
                        : widget.colorText,
              ),

            if (widget.text != null &&
                (widget.iconData != null || widget.icon != null))
              const SizedBox(width: 8.0),

            if (widget.text != null)
              TextX(
                widget.text!,
                color:
                    widget.disabled
                        ? widget.colorDisabledText ?? ColorX.grey.shade400
                        : widget.colorText,
              ),
          ],
        ),
      );
    } else if (widget.state == ButtonStateEX.loading) {
      return SizedBox(
        width: 100,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: CircularProgressIndicator(
                backgroundColor: stateColors[widget.state],

                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      return AnimatedOpacity(
        opacity: visibility ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: TextX(
          getText,
          color:
              widget.disabled
                  ? widget.colorDisabledText ?? ColorX.grey.shade400
                  : Colors.white,
          maxLines: 1,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.marginVertical,
        horizontal: widget.marginHorizontal,
      ),
      child: AnimatedBuilder(
        animation: colorAnimationController!,
        builder: (context, child) {
          return AnimatedContainer(
            width: width,
            height: widget.height,
            duration: widget.animationDuration,
            child: AbsorbPointer(
              absorbing: widget.disabled,
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.radius),
                onTap: () async {
                  if (!widget.disabled) {
                    await widget.onTap();
                  }
                },
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(widget.radius),
                    color: backgroundColor,
                  ),
                  child: Center(
                    child: getButtonChild(
                      colorAnimation == null
                          ? true
                          : colorAnimation!.isCompleted,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
