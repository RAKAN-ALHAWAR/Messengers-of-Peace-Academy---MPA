import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Config/config.dart';
import '../../widget.dart';

class LabelX extends StatelessWidget {
  const LabelX(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(bottom: marginBottom, top: marginTop),
            child: TextX(label, style: TextStyleX.titleMedium, maxLines: 10),
          ),
        ),
        const SizedBox(width: 5),
        if (isRequired != true && isOptional == true)
          TextX("(${"optional".tr})", style: TextStyleX.titleMedium),
        if (isRequired ?? false) TextX("*", style: TextStyleX.titleMedium),
      ],
    );
  }
}
