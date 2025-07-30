part of '../../widget.dart';

Future<dynamic> bottomSheetX({
  required Widget child,
  String? title,
  EdgeInsets? padding,
  bool isPaddingBottom = true,
  bool isScrollEnabled = true,
  ScrollController? scrollController,
}) async {
  return await Get.bottomSheet(
    backgroundColor: Get.theme.cardColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(StyleX.radiusLg),
      ),
    ),
    Container(
      constraints: BoxConstraints(
        maxHeight:
            Get.height -
            Get.mediaQuery.padding.top -
            Get.mediaQuery.padding.bottom -
            20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
              child: Container(
                height: 3,
                width: 60,
                decoration: BoxDecoration(
                  color: ColorX.grey.shade200,
                  borderRadius: BorderRadius.circular(StyleX.radiusLg),
                ),
              ),
            ),
          ),
          if (title != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 5.0,
                start: StyleX.bottomSheetPadding,
                end: StyleX.bottomSheetPadding - 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: TextX(title, style: TextStyleX.titleMedium)),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.close_rounded,
                      color:
                          Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ).fadeAnimation200,
          const SizedBox(height: 6.0),
          Flexible(
            child: ListView(
              controller: scrollController,
              physics:
                  isScrollEnabled
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
              padding:
                  padding ??
                  EdgeInsets.only(
                    bottom:
                        (isPaddingBottom ? StyleX.bottomSheetPadding : 0) +
                        MediaQuery.of(Get.context!).padding.bottom,
                    left: StyleX.bottomSheetPadding,
                    right: StyleX.bottomSheetPadding,
                    top: 10,
                  ),
              shrinkWrap: true,
              children: [child],
            ),
          ),
        ],
      ),
    ),
  );
}
