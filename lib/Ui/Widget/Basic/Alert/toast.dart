part of '../../widget.dart';

class ToastX {
  /// Success
  static success({String? title, String? message}) {
    Get.rawSnackbar(
      duration: const Duration(seconds: StyleX.toastSecond),
      dismissDirection: DismissDirection.horizontal,
      messageText: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message == null || title != null)
                  TextX(
                    title ?? "Success",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (message != null || title != null) const SizedBox(height: 4),
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
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.close_rounded, color: Colors.white54),
          ),
        ],
      ),
      backgroundColor: ColorX.success,
      padding: const EdgeInsets.symmetric(
        horizontal: StyleX.hPaddingApp,
        vertical: 20,
      ),
      margin: const EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
      borderRadius: StyleX.radiusMd,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// info
  static info({String? title, String? message}) {
    Get.rawSnackbar(
      duration: const Duration(seconds: StyleX.toastSecond),
      dismissDirection: DismissDirection.horizontal,
      messageText: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message == null || title != null)
                  TextX(
                    title ?? "Info",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (message != null || title != null) const SizedBox(height: 4),
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
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.close_rounded, color: Colors.white54),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(
        horizontal: StyleX.hPaddingApp,
        vertical: 20,
      ),
      margin: const EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
      borderRadius: StyleX.radiusMd,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Error
  static error({String? title, dynamic message}) {
    Get.rawSnackbar(
      duration: const Duration(seconds: StyleX.toastSecond),
      dismissDirection: DismissDirection.horizontal,
      messageText: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message == null || title != null)
                  TextX(
                    title ?? "Something wrong",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (message != null || title != null) const SizedBox(height: 4),
                if (message != null)
                  TextX(
                    message.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.close_rounded, color: Colors.white54),
          ),
        ],
      ),
      backgroundColor: ColorX.danger,
      padding: const EdgeInsets.symmetric(
        horizontal: StyleX.hPaddingApp,
        vertical: 20,
      ),
      margin: const EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
      borderRadius: StyleX.radiusMd,
      snackPosition: SnackPosition.TOP,
    );
  }
}
