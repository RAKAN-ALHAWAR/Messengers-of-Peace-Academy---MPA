part of '../../widget.dart';

class WebOptionsX extends StatelessWidget {
  const WebOptionsX(
      {required this.isSelectionText, super.key, required this.materialApp});
  final bool isSelectionText;
  final Widget materialApp;
  @override
  Widget build(BuildContext context) {
    if (isSelectionText) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SelectionArea(
          child: materialApp,
        ),
      );
    } else {
      return materialApp;
    }
  }
}
