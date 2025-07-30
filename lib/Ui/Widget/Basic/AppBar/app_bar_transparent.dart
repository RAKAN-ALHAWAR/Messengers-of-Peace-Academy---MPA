part of '../../widget.dart';

class AppBarTransparent extends StatelessWidget {
  const AppBarTransparent({
    super.key,
    this.title,
    this.actions,
    this.color,
    this.iconColor,
  });
  final String? title;
  final List<Widget>? actions;
  final Color? color;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black54,
            Colors.black45,
            Colors.black45,
            Colors.black38,
            Colors.black26,
            Colors.black12,
            Colors.black12.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StyleX.hPaddingApp,
                  ),
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(StyleX.radius),
                    child: GlassX(
                      opacity: .3,
                      child: SizedBox(
                        height: 48,
                        width: 48,
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: color ?? Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: TextX(
              title ?? "",
              style: TextStyleX.titleMedium,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child:
                actions != null
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    )
                    : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
