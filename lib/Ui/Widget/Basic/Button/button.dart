part of '../../widget.dart';

// ignore: must_be_immutable
class ButtonX extends StatelessWidget {
  final String? text;
  final IconData? iconData;
  final Widget? icon;
  final double marginHorizontal;
  final double marginVertical;
  final double? width;
  final Function onTap;
  final bool halfWidth;
  final double radius;
  final bool disabled;
  final bool isMaxFinite;
  final bool isTextFirst;
  final double? height;
  final EdgeInsets padding;
  Color? borderColor;
  Color? colorButton;
  Color? colorText;
  ButtonX({
    required this.onTap,
    this.text,
    Color? colorButton,
    this.disabled = false,
    this.iconData,
    this.icon,
    this.width,
    this.marginVertical = 4,
    this.halfWidth = false,
    this.isMaxFinite = true,
    this.isTextFirst = false,
    this.borderColor = Colors.transparent,
    this.marginHorizontal = 0,
    this.colorText = Colors.white,
    this.radius = 100,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    super.key,
    this.height,
  }) {
    this.colorButton = colorButton ?? ColorX.primary;
  }
  ButtonX.second({
    required this.onTap,
    this.text,
    this.colorButton,
    this.disabled = false,
    this.isMaxFinite = true,
    this.isTextFirst = false,
    this.iconData,
    this.icon,
    this.width,
    this.marginVertical = 5,
    this.halfWidth = false,
    this.marginHorizontal = 0,
    this.radius = 100,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    super.key,
    this.height,
  }) {
    colorText = ColorX.primary;
    borderColor = ColorX.primary;
  }
  ButtonX.gray({
    required this.onTap,
    this.text,
    this.disabled = false,
    this.isMaxFinite = true,
    this.isTextFirst = false,
    this.iconData,
    this.icon,
    this.width,
    Color? colorText,
    this.marginVertical = 5,
    this.halfWidth = false,
    this.marginHorizontal = 0,
    this.radius = 100,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    super.key,
    this.height,
  }) {
    this.colorText = colorText ?? Get.theme.colorScheme.secondary;
    borderColor = ColorX.grey;
  }

  var isDanger = false;
  ButtonX.dangerous({
    required this.onTap,
    this.disabled = false,
    this.isMaxFinite = true,
    this.text,
    this.iconData,
    this.icon,
    this.width,
    this.halfWidth = false,
    this.isTextFirst = false,
    this.marginVertical = 5,
    this.marginHorizontal = 0,
    this.radius = 100,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    super.key,
    this.height,
  }) {
    isDanger = true;
  }
  @override
  Widget build(BuildContext context) {
    if (borderColor == ColorX.primary && colorText == ColorX.primary) {
      colorText = Theme.of(context).primaryColor;
      borderColor = Theme.of(context).primaryColor;
    }
    if (isDanger) {
      colorText = Theme.of(context).colorScheme.error;
      borderColor = Theme.of(context).colorScheme.error;
    }
    return GestureDetector(
      onTap: () {
        if (!disabled) {
          onTap();
        }
      },
      child: Container(
        height: height ?? StyleX.buttonHeight,
        width: width ?? (isMaxFinite ? double.maxFinite : null),
        padding: padding,
        margin: EdgeInsets.symmetric(
          vertical: marginVertical,
          horizontal: marginHorizontal,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor!),
          borderRadius: BorderRadius.circular(radius),
          color: disabled ? ColorX.grey : colorButton,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon!,
            if (text != null && isTextFirst)
              TextX(text!, color: colorText, style: TextStyleX.labelLarge),
            if ((iconData != null || icon != null) &&
                text != null &&
                isTextFirst)
              const SizedBox(width: 8),
            if (iconData != null && icon == null)
              Icon(iconData, color: colorText, size: text != null ? 20 : 22),
            if ((iconData != null || icon != null) &&
                text != null &&
                !isTextFirst)
              const SizedBox(width: 8),
            if (text != null && !isTextFirst)
              TextX(text!, color: colorText, style: TextStyleX.labelLarge),
          ],
        ),
      ),
    );
  }
}
