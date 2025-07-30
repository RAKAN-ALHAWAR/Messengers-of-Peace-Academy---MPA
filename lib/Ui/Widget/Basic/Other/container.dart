part of '../../widget.dart';

class ContainerX extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double maxWidth;
  final double minWidth;
  final double minHeight;
  final double maxHeight;
  final double radius;
  final BorderRadiusGeometry? borderRadius;
  final double borderWidth;
  final Color? color;
  final EdgeInsetsGeometry margin;
  final EdgeInsets padding;
  final bool isBorder;
  final bool isShadow;
  final Color? borderColor;
  const ContainerX({
    this.width,
    this.maxWidth = double.infinity,
    this.minWidth = 0.0,
    this.minHeight = 0.0,
    this.maxHeight = double.infinity,
    this.isBorder = false,
    this.isShadow = false,
    this.height,
    this.borderWidth = StyleX.borderWidth,
    this.color,
    this.borderRadius,
    this.borderColor,
    this.padding = const EdgeInsets.all(14.0),
    this.radius = StyleX.radius,
    this.margin = const EdgeInsets.all(0),
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minWidth: minWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius:
            borderRadius?.resolve(Directionality.of(context)) ??
            BorderRadius.circular(radius),
        boxShadow:
            isShadow
                ? [
                  const BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ]
                : [],
        border:
            isBorder
                ? Border.all(
                  width: borderWidth,
                  color: borderColor ?? Theme.of(context).dividerColor,
                )
                : null,
        color: color ?? Theme.of(context).cardColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(StyleX.radius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
