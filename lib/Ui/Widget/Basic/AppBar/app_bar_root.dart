part of '../../widget.dart';

class AppBarRootX extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final double? leadingWidth;
  final String title;
  final Widget? leading;
  final int indexSelected;
  final List<Widget>? actions;
  final List<RootPageX> pages;
  const AppBarRootX({
    super.key,
    required this.title,
    this.height = StyleX.appBarHeight,
    this.leadingWidth,
    this.actions,
    this.leading,
    required this.pages,
    required this.indexSelected,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextX(
        title,
        style: TextStyleX.titleLarge,
      ).fadeAnimation100,
      surfaceTintColor: Colors.transparent,
      actions: actions,
      centerTitle: true,
      leading: leading,
      leadingWidth: leadingWidth,
      toolbarHeight: StyleX.appBarPaddingTop,
    );
  }
}
