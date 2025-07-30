part of '../../widget.dart';

class LayoutWidgetX extends StatelessWidget {
  final Widget? largeScreen;
  final Widget? mediumScreen;
  final Widget smallScreen;

  const LayoutWidgetX({
    super.key,
    this.largeScreen,
    this.mediumScreen,
    required this.smallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (DeviseX.size(context)) {
          case SizeTypeEX.small:
            return smallScreen;
          case SizeTypeEX.medium:
            return mediumScreen ?? smallScreen;
          case SizeTypeEX.large:
            return largeScreen ?? smallScreen;
        }
      },
    );
  }
}

// case SizeType.medium:
// return mediumScreen ?? smallScreen;
// case SizeType.large:
// return largeScreen ?? xLargeScreen?? mediumScreen ?? smallScreen;
// case SizeType.xLarge:
// return xLargeScreen ?? largeScreen?? mediumScreen ??smallScreen;