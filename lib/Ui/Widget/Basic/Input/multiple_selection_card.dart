part of '../../widget.dart';

class MultipleSelectionCardX extends StatelessWidget {
  final String title;
  final String? selected;
  final bool asInputField;
  final void Function()? onTap;

  const MultipleSelectionCardX({
    required this.title,
    this.selected,
    this.onTap,
    this.asInputField = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ContainerX(
        isBorder: true,
        height: StyleX.inputHeight,
        color: Theme.of(context).cardTheme.color,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
        child: Row(
          children: [
            if (!asInputField)
              Expanded(child: TextX(title, style: TextStyleX.titleSmall)),
            if (selected == null && asInputField)
              Expanded(
                child: TextX(
                  title,
                  style: TextStyleX.titleSmall,
                  color: Get.theme.colorScheme.secondary,
                ),
              ),
            if (selected != null && asInputField)
              Expanded(child: TextX(selected!, style: TextStyleX.titleSmall)),
            const SizedBox(width: 14),
            if (selected != null && !asInputField)
              FittedBox(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: TextX(
                    selected!,
                    style: TextStyleX.labelLarge,
                    maxLines: 1,
                    color:
                        context.isDarkMode
                            ? ColorX.grey.shade200
                            : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color:
                  context.isDarkMode
                      ? ColorX.grey.shade200
                      : Theme.of(context).colorScheme.secondary,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
