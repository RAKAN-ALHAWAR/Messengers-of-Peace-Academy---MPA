part of "../../widget.dart";

class DashLineX extends StatelessWidget {
  final double dashHeight;
  final double dashWith;
  late final Color dashColor;
  final Axis direction;
  final EdgeInsets? margin;

  /// [0, 1] totalDashSpace/totalSpace
  final double fillRate;

  DashLineX({
    super.key,
    this.dashHeight = 1,
    this.dashWith = 5,
    Color? dashColor,
    this.fillRate = 0.6,
    this.direction = Axis.horizontal, this.margin,
  }) {
    this.dashColor = dashColor ?? Get.theme.dividerColor;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxSize = direction == Axis.horizontal
            ? constraints.constrainWidth()
            : constraints.constrainHeight();
        final dCount = (boxSize * fillRate / dashWith).floor();
        return Padding(
          padding: margin??EdgeInsets.zero,
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: direction,
            children: List.generate(dCount, (_) {
              return SizedBox(
                width: direction == Axis.horizontal ? dashWith : dashHeight,
                height: direction == Axis.horizontal ? dashHeight : dashWith,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: dashColor),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
