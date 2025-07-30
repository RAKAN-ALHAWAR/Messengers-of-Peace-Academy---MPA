part of '../animation.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this class }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Animation on the element when its size changes
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class SizeAnimationX extends StatelessWidget {
  final int delay;
  final Widget child;

  const SizeAnimationX({required this.child, required this.delay, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: AnimatedSize(
        duration: Duration(milliseconds: delay),
        reverseDuration: Duration(milliseconds: delay),
        curve: Curves.easeIn,
        child: child,
      ),
    );
  }
}

/// This is an addition to using animation easily
/// like: SizedBox().sizeAnimation100
extension SizeAnimationExtension on Widget {
  SizeAnimationX get sizeAnimation100 {
    return SizeAnimationX(delay: 100, child: this);
  }

  SizeAnimationX get sizeAnimation200 {
    return SizeAnimationX(delay: 200, child: this);
  }

  SizeAnimationX get sizeAnimation300 {
    return SizeAnimationX(delay: 300, child: this);
  }

  SizeAnimationX get sizeAnimation400 {
    return SizeAnimationX(delay: 400, child: this);
  }

  SizeAnimationX get sizeAnimation500 {
    return SizeAnimationX(delay: 500, child: this);
  }

  SizeAnimationX get sizeAnimation600 {
    return SizeAnimationX(delay: 600, child: this);
  }

  SizeAnimationX get sizeAnimation700 {
    return SizeAnimationX(delay: 700, child: this);
  }

  SizeAnimationX get sizeAnimation800 {
    return SizeAnimationX(delay: 800, child: this);
  }

  SizeAnimationX get sizeAnimation900 {
    return SizeAnimationX(delay: 900, child: this);
  }

  SizeAnimationX get sizeAnimation1000 {
    return SizeAnimationX(delay: 1000, child: this);
  }

  /// To customize values
  SizeAnimationX sizeAnimationX(int delay, {bool isDisable = false}) {
    return SizeAnimationX(delay: delay, child: this);
  }
}
