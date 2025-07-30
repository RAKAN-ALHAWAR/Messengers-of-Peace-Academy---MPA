part of '../fade_animation.dart';

/// This is an addition to using animation easily
/// like: SizedBox().fadeAnimation100
extension FadeAnimationExtensionX on Widget {
  FadeAnimationX get fadeAnimation50 {
    return FadeAnimationX(delay: 50, child: this);
  }

  FadeAnimationX get fadeAnimation100 {
    return FadeAnimationX(delay: 100, child: this);
  }

  FadeAnimationX get fadeAnimation150 {
    return FadeAnimationX(delay: 150, child: this);
  }

  FadeAnimationX get fadeAnimation200 {
    return FadeAnimationX(delay: 200, child: this);
  }

  FadeAnimationX get fadeAnimation250 {
    return FadeAnimationX(delay: 250, child: this);
  }

  FadeAnimationX get fadeAnimation300 {
    return FadeAnimationX(delay: 300, child: this);
  }

  FadeAnimationX get fadeAnimation350 {
    return FadeAnimationX(delay: 350, child: this);
  }

  FadeAnimationX get fadeAnimation400 {
    return FadeAnimationX(delay: 400, child: this);
  }

  FadeAnimationX get fadeAnimation450 {
    return FadeAnimationX(delay: 450, child: this);
  }

  FadeAnimationX get fadeAnimation500 {
    return FadeAnimationX(delay: 500, child: this);
  }

  FadeAnimationX get fadeAnimation550 {
    return FadeAnimationX(delay: 550, child: this);
  }

  FadeAnimationX get fadeAnimation600 {
    return FadeAnimationX(delay: 600, child: this);
  }

  FadeAnimationX get fadeAnimation650 {
    return FadeAnimationX(delay: 650, child: this);
  }

  FadeAnimationX get fadeAnimation700 {
    return FadeAnimationX(delay: 700, child: this);
  }

  FadeAnimationX get fadeAnimation750 {
    return FadeAnimationX(delay: 750, child: this);
  }

  FadeAnimationX get fadeAnimation800 {
    return FadeAnimationX(delay: 800, child: this);
  }

  FadeAnimationX get fadeAnimation850 {
    return FadeAnimationX(delay: 850, child: this);
  }

  FadeAnimationX get fadeAnimation900 {
    return FadeAnimationX(delay: 900, child: this);
  }

  FadeAnimationX get fadeAnimation950 {
    return FadeAnimationX(delay: 950, child: this);
  }

  FadeAnimationX get fadeAnimation1000 {
    return FadeAnimationX(delay: 1000, child: this);
  }

  /// To customize values for the FadeAnimationX widget.
  /// لتخصيص القيم لعنصر FadeAnimationX.
  FadeAnimationX fadeAnimationX(
    int delay, {
    bool isDisable = false,
    double? startX,
    double? startY,
    Alignment alignment = Alignment.topCenter,
  }) {
    return FadeAnimationX(
      delay: delay,
      isDisable: isDisable,
      startX: startX,
      startY: startY,
      alignment: alignment,
      child: this,
    );
  }
}
