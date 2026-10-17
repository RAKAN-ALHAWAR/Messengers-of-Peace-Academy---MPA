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
          (dismiss) => Positioned(
        // Keep page navigation reachable while feedback is visible.
        top: StyleX.appBarHeight,
            left: StyleX.hPaddingApp,
            right: StyleX.hPaddingApp,
            child: SafeArea(
              bottom: false,
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.horizontal,
                onDismissed: (_) => dismiss(),
                child: Semantics(
                  liveRegion: true,
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
                                    style: TextStyleX.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (title != null && message != null)
                                  const SizedBox(height: StyleX.radiusSm),
                                if (message != null)
                                  TextX(
                                    message,
                                    style: TextStyleX.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: StyleX.toastContentGap),
                          IconButton(
                            tooltip: 'Close'.tr,
                            onPressed: dismiss,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white54,
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
    );
  }
}
