library;

import 'package:flutter/material.dart';

part 'lib/fade_animation_extension.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this class }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Animation Show the item as disappearing
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// A widget that applies a fade-in animation with an optional offset.
// عنصر يقوم بتطبيق تأثير تلاشي مع إمكانية تحريك اختيارية.
class FadeAnimationX extends StatefulWidget {
  final int delay; // Delay before the animation starts.
  // التأخير قبل بدء الرسوم المتحركة.
  final Widget child; // The child widget to animate.
  // عنصر الطفل الذي سيتم تطبيق الرسوم المتحركة عليه.
  final bool isDisable; // Whether the animation is disabled.
  // ما إذا كانت الرسوم المتحركة معطلة.
  final double? startX; // The X offset to apply, can be null.
  // الإزاحة على محور X، يمكن أن تكون null.
  final double? startY; // The Y offset to apply, can be null.
  // الإزاحة على محور Y، يمكن أن تكون null.
  final Alignment alignment; // The alignment to use if offsets are null.
  // المحاذاة التي سيتم استخدامها إذا كانت الإزاحات null.

  const FadeAnimationX({
    required this.child,
    required this.delay,
    this.isDisable = false,
    this.startX, // startX can be null.
    this.startY, // startY can be null.
    this.alignment = Alignment.topCenter, // Default alignment is at the top.
    super.key,
  });

  @override
  State<FadeAnimationX> createState() => _FadeAnimationXState();
}

// State class for FadeAnimationX.
// الفئة الحالة لـ FadeAnimationX.
class _FadeAnimationXState extends State<FadeAnimationX>
    with SingleTickerProviderStateMixin {
  late AnimationController
  _controller; // Animation controller for managing the animation.
  // وحدة التحكم في الرسوم المتحركة لإدارة الرسوم المتحركة.
  late Animation<double>
  _opacityAnimation; // Animation for opacity (fade effect).
  // الرسوم المتحركة للشفافية (تأثير التلاشي).
  late Animation<Offset>
  _translateAnimation; // Animation for translation (movement effect).
  // الرسوم المتحركة للإزاحة (تأثير الحركة).

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Animation duration.
      // مدة الرسوم المتحركة.
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Curve for the animation effect.
      // المنحنى لتأثير الرسوم المتحركة.
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curve); // Opacity animation from 0 to 1.
    // الرسوم المتحركة للشفافية من 0 إلى 1.

    // Determine the movement based on the use of offsets or alignment.
    // تحديد الحركة بناءً على استخدام الإزاحات أو المحاذاة.
    double offsetX = widget.startX ?? 0.0; // Use startX or default to 0.
    // استخدام startX أو افتراضياً 0.
    double offsetY = widget.startY ?? 30.0; // Use startY or default to 30.
    // استخدام startY أو افتراضياً 30.

    if (widget.startX != null || widget.startY != null) {
      // Use precise control if any offset is provided.
      // استخدم التحكم الدقيق إذا كانت أي من الإزاحات مقدمة.
      _translateAnimation = Tween<Offset>(
        begin: Offset(offsetX, offsetY),
        end: Offset.zero,
      ).animate(curve);
    } else {
      // Use alignment if offsets are both null.
      // استخدم المحاذاة إذا كانت الإزاحات كلاهما null.
      switch (widget.alignment) {
        case Alignment.topLeft:
          offsetX = -30.0;
          offsetY = -30.0;
          break;
        case Alignment.topCenter:
          offsetX = 0.0;
          offsetY = -30.0;
          break;
        case Alignment.topRight:
          offsetX = 30.0;
          offsetY = -30.0;
          break;
        case Alignment.centerLeft:
          offsetX = -30.0;
          offsetY = 0.0;
          break;
        case Alignment.center:
          offsetX = 0.0;
          offsetY = 0.0; // No movement for center alignment.
          // لا يوجد حركة للمحاذاة الوسطى.
          break;
        case Alignment.centerRight:
          offsetX = 30.0;
          offsetY = 0.0;
          break;
        case Alignment.bottomLeft:
          offsetX = -30.0;
          offsetY = 30.0;
          break;
        case Alignment.bottomCenter:
          offsetX = 0.0;
          offsetY = 30.0;
          break;
        case Alignment.bottomRight:
          offsetX = 30.0;
          offsetY = 30.0;
          break;
        default:
          offsetX = 0.0;
          offsetY = 30.0; // Default to moving downwards.
        // الافتراضي هو التحرك نحو الأسفل.
      }

      _translateAnimation = Tween<Offset>(
        begin: Offset(offsetX, offsetY),
        end: Offset.zero,
      ).animate(curve);
    }

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward(); // Start the animation after the delay.
        // بدء الرسوم المتحركة بعد التأخير.
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller.
    // التخلص من وحدة التحكم في الرسوم المتحركة.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDisable) {
      return widget
          .child; // Return the child directly if animation is disabled.
      // إرجاع عنصر الطفل مباشرة إذا كانت الرسوم المتحركة معطلة.
    } else {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value, // Apply opacity animation.
            // تطبيق الرسوم المتحركة للشفافية.
            child: Transform.translate(
              offset: _translateAnimation.value, // Apply translation animation.
              // تطبيق الرسوم المتحركة للإزاحة.
              child: child,
            ),
          );
        },
        child: widget.child, // Pass the child to the AnimatedBuilder.
        // تمرير عنصر الطفل إلى AnimatedBuilder.
      );
    }
  }
}
