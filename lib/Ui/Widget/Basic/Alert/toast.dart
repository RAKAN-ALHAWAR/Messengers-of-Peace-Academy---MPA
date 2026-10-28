part of '../../widget.dart';

class ToastX {
  static final _presenter = ToastPresenterX();

  static void success({String? title, String? message}) => _show(
    title: title,
    message: message,
    fallbackTitle: 'Success',
    color: ColorX.success,
    icon: Icons.check_circle_outline_rounded,
  );

  static void info({String? title, String? message}) => _show(
    title: title,
    message: message,
    fallbackTitle: 'Info',
    color: Colors.blue,
    icon: Icons.info_outline,
  );

  static void error({String? title, dynamic message}) => _show(
    title: title,
    message: message?.toString(),
    fallbackTitle: 'Something wrong',
    color: ColorX.danger,
    icon: Icons.info_outline,
  );

  static void dismiss() => _presenter.dismiss();

  static void _show({
    required String? title,
    required String? message,
    required String fallbackTitle,
    required Color color,
    required IconData icon,
  }) {
    // Get.overlayContext points above Flutter's entry marker on current Flutter.
    // Use the actual OverlayState, without entering Get's navigation queue.
    _presenter.show(
      overlay: Get.key.currentState?.overlay,
      duration: const Duration(seconds: StyleX.toastSecond),
      builder:
          (dismiss) => Align(
            // Top of the screen under the status bar, like the old snackbar.
            // Align only hit-tests its child, so the page below stays usable.
            alignment: Alignment.topCenter,
            child: _ToastSlideX(
              child: Dismissible(
                key: const Key('toast'),
                direction: DismissDirection.horizontal,
                onDismissed: (_) => dismiss(),
                child: Semantics(
                  liveRegion: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: StyleX.hPaddingApp,
                    ),
                    child: SafeArea(
                      bottom: false,
                      left: false,
                      right: false,
                      child: Material(
                        color: color,
                        borderRadius: BorderRadius.circular(StyleX.radiusMd),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: StyleX.hPaddingApp,
                            vertical: StyleX.vPaddingApp,
                          ),
                          child: Row(
                            children: [
                              Icon(icon, color: Colors.white),
                              const SizedBox(width: StyleX.toastContentGap),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (message == null || title != null)
                                      TextX(
                                        title ?? fallbackTitle,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    if (message != null || title != null)
                                      const SizedBox(height: 4),
                                    if (message != null)
                                      TextX(
                                        message,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: StyleX.toastContentGap),
                              // Closes only this toast (never Get.back, which
                              // would pop the page under it).
                              Semantics(
                                button: true,
                                label: 'Close'.tr,
                                child: GestureDetector(
                                  onTap: dismiss,
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

/// Entrance animation: slides down from above the screen edge, like the GetX
/// snackbar did (1s, easeOutCirc). Transform only, no layout work per frame,
/// and no motion at all when the system asks to disable animations.
class _ToastSlideX extends StatelessWidget {
  const _ToastSlideX({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 0.0),
      duration:
          MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(seconds: 1),
      curve: Curves.easeOutCirc,
      child: child,
      builder:
          (context, y, child) =>
              FractionalTranslation(translation: Offset(0, y), child: child),
    );
  }
}
