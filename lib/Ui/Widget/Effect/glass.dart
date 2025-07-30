part of '../widget.dart';

class GlassX extends StatelessWidget {
  const GlassX({
    super.key,
    this.blur = StyleX.blur,
    this.opacity = 0.15,
    this.radius,
    required this.child,
    this.isLight = false,
  });

  final double blur;
  final bool isLight;
  final double opacity;
  final Widget child;
  final BorderRadiusGeometry? radius;
  @override
  Widget build(BuildContext context) {
    var color =
        isLight
            ? (context.isDarkMode ? Colors.white : ColorX.grey.shade100)
            : Colors.white;
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(StyleX.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius ?? BorderRadius.circular(StyleX.radius),
            border: Border.all(width: 2, color: color.withValues(alpha: 0.7)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: opacity / 3),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
