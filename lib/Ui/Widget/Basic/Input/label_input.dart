part of '../../widget.dart';

class LabelInputX extends StatelessWidget {
  const LabelInputX(
    this.label, {
    super.key,
    this.marginTop = 0,
    this.marginBottom = 0,
    this.isRequired = false,
    this.isOptional = false,
  });
  final String label;
  final double marginTop;
  final double marginBottom;
  final bool? isOptional;
  final bool? isRequired;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom, top: marginTop),
      child: Row(
        children: [
          Expanded(
            child: TextX(
              label +
                  (isRequired == false && isOptional == true
                      ? " (${"optional".tr})"
                      : "") +
                  (isRequired == true ? " *" : ""),
              style: TextStyleX.labelLarge,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
