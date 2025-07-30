part of '../../widget.dart';

class AlertDialogX {
  /// Alert with custom child
  static child({required Widget child, String title = ''}) {
    Get.defaultDialog(
      title: title.tr,
      titleStyle: TextStyleX.titleLarge,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      radius: StyleX.radius,
      content: child,
    );
  }

  /// Loading Alert
  static loading() {
    return Get.dialog(const Center(child: CircularProgressIndicator()));
  }

  /// Standard Alert
  static Future<dynamic> okAndCancel({
    required String title,
    required String message,
    String? textOK,
    String? textCancel,
    Color? colorTextOk,
    bool isShowCancel = true,
    required void Function() onOk,
    void Function()? onCancel,
  }) async {
    return await Get.defaultDialog(
      title: title.tr,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      radius: StyleX.radius,
      titleStyle: TextStyleX.titleLarge,
      titlePadding: const EdgeInsets.only(top: 10),
      content: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [TextX(message, style: TextStyleX.titleSmall)],
            ),
          ),
          Row(
            mainAxisAlignment:
                isShowCancel
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
            children: [
              if (isShowCancel)
                TextButton(
                  onPressed: onCancel ?? Get.back,
                  child: TextX(
                    textCancel ?? "Cancel".tr,
                    style: TextStyleX.titleSmall,
                    color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                  ),
                ),
              if (isShowCancel) const SizedBox(width: 16),
              TextButton(
                onPressed: onOk,
                child: TextX(
                  textOK ?? "Ok",
                  style: TextStyleX.titleSmall,
                  color: colorTextOk ?? ColorX.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
