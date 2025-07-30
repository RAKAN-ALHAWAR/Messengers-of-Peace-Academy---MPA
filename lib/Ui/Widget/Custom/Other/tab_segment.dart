import 'package:flutter/material.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';

import '../../../../Config/config.dart';

class TabSegmentX extends StatelessWidget {
  const TabSegmentX({
    required this.controller,
    required this.tabs,
    this.width = double.maxFinite,
    super.key,
  });
  final ValueNotifier<int> controller;
  final Map<int, String> tabs;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(StyleX.radiusLg),
      ),
      child: AdvancedSegment<int, String>(
        controller: controller,
        segments: tabs,
        activeStyle: TextStyleX.labelLarge.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
          fontFamily: "IBMPlexSansArabic",
        ),
        inactiveStyle: TextStyleX.labelLarge.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontFamily: "IBMPlexSansArabic",
        ),
        sliderDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(StyleX.radiusLg),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.all(Radius.circular(StyleX.radiusLg)),
        itemPadding: const EdgeInsets.symmetric(horizontal: 4),
        sliderOffset: 4,
        shadow: const [],
      ),
    );
  }
}
