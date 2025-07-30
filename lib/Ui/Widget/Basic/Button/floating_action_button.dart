part of '../../widget.dart';

class FloatingActionButtonX extends StatelessWidget {
  final IconData icon;
  final Widget? widget;
  final Color? backgroundColor;
  final Function() onTap;
  const FloatingActionButtonX({
    required this.onTap,
    required this.icon,
    super.key,
    this.widget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: CircleAvatar(
        backgroundColor: backgroundColor ?? ColorX.primary,
        radius: StyleX.floatingActionButton / 2,
        child: widget ??
            Icon(
              icon,
              color: Colors.white,
            ),
      ),
    );
  }
}
