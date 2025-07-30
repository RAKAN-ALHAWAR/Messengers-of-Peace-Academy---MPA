part of "../animation.dart";

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this class }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Ready-made shapes for frequently used elements in the project
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ShimmerAnimationShapeX {
  /// Label Input
  static Widget label({
    double width = 100,
    EdgeInsets? margin,
    double height = 22,
  }) {
    return ShimmerAnimationX(
      height: height,
      width: width,
      margin: margin ?? const EdgeInsetsDirectional.only(bottom: 12),
    );
  }

  /// Filed Input
  static Widget filedInput({
    double width = double.maxFinite,
    EdgeInsets? margin,
  }) {
    return ShimmerAnimationX(
      height: StyleX.inputHeight,
      width: width,
      margin: margin ?? const EdgeInsetsDirectional.only(bottom: 12),
    );
  }

  /// Button
  static Widget button({double width = double.maxFinite, EdgeInsets? margin}) {
    return ShimmerAnimationX(
      height: StyleX.buttonHeight,
      width: width,
      margin: margin ?? const EdgeInsetsDirectional.symmetric(vertical: 5),
    );
  }
}
