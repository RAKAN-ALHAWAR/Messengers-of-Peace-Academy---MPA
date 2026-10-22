import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../Config/config.dart';
import '../../../../Data/Model/course/mini_course.dart';
import '../Card/course_card.dart';

/// A bounded lazy viewport whose equal card height follows the full translated
/// text. Measuring the snapshot is O(N); mounting cards is viewport-bounded.
class CourseCarousel extends StatefulWidget {
  const CourseCarousel({super.key, required this.courses, required this.onTap});
  final List<MiniCourseX> courses;
  final Function(MiniCourseX) onTap;

  @override
  State<CourseCarousel> createState() => _CourseCarouselState();
}

class _CourseCarouselState extends State<CourseCarousel> {
  Object? _metricsKey;
  double _height = 0;
  List<(String, int, int, double, bool)>? _content;
  final _measurements = <(String, TextStyle, double), double>{};

  @override
  void initState() {
    super.initState();
    PaintingBinding.instance.systemFonts.addListener(_fontsChanged);
  }

  void _fontsChanged() {
    if (!mounted) return;
    setState(() => _metricsKey = null);
  }

  @override
  void dispose() {
    PaintingBinding.instance.systemFonts.removeListener(_fontsChanged);
    super.dispose();
  }

  double _textHeight(String text, TextStyle style, double width) {
    final translated = text.tr;
    final key = (translated, style, width);
    final cached = _measurements[key];
    if (cached != null) return cached;
    final defaults = DefaultTextStyle.of(context);
    var effective = style.inherit ? defaults.style.merge(style) : style;
    if (MediaQuery.boldTextOf(context)) {
      effective = effective.copyWith(fontWeight: FontWeight.bold);
    }
    // Mirror Text's accessibility spacing overrides in the pinned SDK.
    effective = effective.copyWith(
      height: MediaQuery.maybeLineHeightScaleFactorOverrideOf(context),
      letterSpacing: MediaQuery.maybeLetterSpacingOverrideOf(context),
      wordSpacing: MediaQuery.maybeWordSpacingOverrideOf(context),
    );
    final painter = TextPainter(
      text: TextSpan(text: translated, style: effective),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      textHeightBehavior: defaults.textHeightBehavior,
      textWidthBasis: defaults.textWidthBasis,
      maxLines: 1000,
      ellipsis: '\u2026',
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    _measurements[key] = height;
    return height;
  }

  double _cardHeight(MiniCourseX course, double width) {
    final contentWidth = width - CourseCard.cardPadding * 2;
    final progress =
        course.isOpen
            ? math.max(
                  _textHeight(
                    '${course.numSections}/${course.numCompletionSections}',
                    TextStyleX.labelSmall,
                    contentWidth,
                  ),
                  _textHeight(
                    '${course.completionPercent.toInt()}%',
                    TextStyleX.labelSmall,
                    contentWidth,
                  ),
                ) +
                4 +
                CourseCard.progressHeight(context) +
                16
            : 0;
    final lessons =
        course.numSections > 0
            ? math.max(
              16.0,
              _textHeight(
                '${course.numSections} ${'lesson'.tr}',
                TextStyleX.labelMedium,
                contentWidth - 20,
              ),
            )
            : 0;
    return (CourseCard.cardPadding * 2 +
            CourseCard.imageHeight +
            16 +
            progress +
            _textHeight(course.name, TextStyleX.titleMedium, contentWidth) +
            4 +
            lessons)
        .ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.courses.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final available =
            constraints.maxWidth - StyleX.hPaddingApp - CourseCard.cardGap;
        // On extremely narrow hosts keep the original card scrollable rather
        // than hiding its content or giving text a negative layout width.
        final width =
            available > CourseCard.cardPadding * 2 + 20
                ? math.min(CourseCard.preferredWidth, available)
                : CourseCard.preferredWidth;
        // Include value changes as MiniCourseX retains a mutable isOpen field.
        final content = widget.courses
            .map(
              (c) => (
                c.name.tr,
                c.numSections,
                c.numCompletionSections,
                c.completionPercent,
                c.isOpen,
              ),
            )
            .toList(growable: false);
        final key = (
          width,
          DefaultTextStyle.of(context),
          MediaQuery.of(context),
          Theme.of(context),
          Directionality.of(context),
          Localizations.maybeLocaleOf(context),
          Get.locale,
        );
        if (_metricsKey != key || !listEquals(_content, content)) {
          // Repeated progress/lesson labels share exact measurements within
          // this pass. Do not retain content across snapshots or font changes.
          _measurements.clear();
          _height = widget.courses.fold(
            0.0,
            (height, course) => math.max(height, _cardHeight(course, width)),
          );
          _measurements.clear();
          _metricsKey = key;
          _content = content;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SizedBox(
            height: _height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.only(
                start: StyleX.hPaddingApp,
              ),
              itemExtent: width + CourseCard.cardGap,
              itemCount: widget.courses.length,
              itemBuilder:
                  (_, index) => CourseCard(
                    width: width,
                    course: widget.courses[index],
                    onTap: widget.onTap,
                  ),
            ),
          ),
        );
      },
    );
  }
}
