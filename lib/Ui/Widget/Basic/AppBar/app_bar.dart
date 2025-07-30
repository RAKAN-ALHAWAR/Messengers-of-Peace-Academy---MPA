part of '../../widget.dart';

class AppBarX extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final double? leadingWidth;
  final bool isBack;
  final Color? color;
  final Color? backgroundColor;
  final dynamic backValue;
  final Function()? onBack;

  const AppBarX({
    super.key,
    this.title,
    this.height = StyleX.appBarHeight,
    this.actions,
    this.isBack = true,
    this.leading,
    this.leadingWidth,
    this.color,
    this.backgroundColor,
    this.backValue,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundColor == null ? ColorX.primaryGradient : null,
      ),
      child: AppBar(
        title:
            title != null
                ? TextX(
                  title!,
                  style: TextStyleX.titleLarge,
                  color: color ?? Colors.white,
                ).fadeAnimation100
                : null,
        surfaceTintColor: Colors.transparent,
        actions: actions,
        leadingWidth: leadingWidth ?? ((leading != null || isBack) ? 66 : 0),
        leading:
            leading ??
            (isBack
                ? BackButtonX(
                  color: color,
                  backValue: backValue,
                  onTap: onBack,
                ).fadeAnimation100
                : null),
        centerTitle: true,
        backgroundColor: backgroundColor ?? Colors.transparent,
        toolbarHeight: StyleX.appBarPaddingTop,
      ),
    );
  }
}
