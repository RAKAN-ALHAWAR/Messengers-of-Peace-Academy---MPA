import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../Config/config.dart';
import '../../../../Widget/Basic/Other/label.dart';
import '../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class LevelsProgressSection extends StatefulWidget {
  const LevelsProgressSection({super.key});

  @override
  State<LevelsProgressSection> createState() => _LevelsProgressSectionState();
}

class _LevelsProgressSectionState extends State<LevelsProgressSection> {
  // Preserve the artwork, padding, stagger and minimum height. The old
  // FittedBox compressed full font metrics into 86px; allow natural growth.
  static const _badgeSize = 46.0;
  static const _stagger = 5.0;
  static const _horizontalPadding = 11.0;
  static const _verticalPadding = 10.0;
  static const _borderWidth = 1.0;
  static const _minimumHeight = 86.0;
  static const _lineInset = 20.0;
  static const _lineThickness = 6.0;
  static const _symbolSize = 15.0;
  final _scroll = ScrollController();
  Object? _metricsKey;
  Size _labelSize = Size.zero;

  HomeController get controller => Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    PaintingBinding.instance.systemFonts.addListener(_fontsChanged);
  }

  void _fontsChanged() {
    if (mounted) setState(() => _metricsKey = null);
  }

  @override
  void dispose() {
    PaintingBinding.instance.systemFonts.removeListener(_fontsChanged);
    _scroll.dispose();
    super.dispose();
  }

  Size _measureLabels(BuildContext context, int count) {
    final defaults = DefaultTextStyle.of(context);
    final media = MediaQuery.of(context);
    final key = (
      count,
      defaults,
      media,
      Theme.of(context),
      Get.locale,
      Localizations.maybeLocaleOf(context),
      DefaultTextHeightBehavior.maybeOf(context),
    );
    if (_metricsKey == key) return _labelSize;
    var style = defaults.style.merge(TextStyleX.labelSmall);
    if (media.boldText) style = style.copyWith(fontWeight: FontWeight.bold);
    style = style.copyWith(
      height: media.lineHeightScaleFactorOverride,
      letterSpacing: media.letterSpacingOverride,
      wordSpacing: media.wordSpacingOverride,
    );
    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      textScaler: media.textScaler,
      locale: Localizations.maybeLocaleOf(context),
      textHeightBehavior:
          defaults.textHeightBehavior ??
          DefaultTextHeightBehavior.maybeOf(context),
      textWidthBasis: defaults.textWidthBasis,
      strutStyle: StrutStyle(height: media.lineHeightScaleFactorOverride),
    );
    var width = 0.0;
    var height = 0.0;
    // Exact full-number measurements are O(N), cached for font/scaler/count.
    // Badge and number widgets remain bounded by the lazy viewport and cache.
    for (var number = 1; number <= count; number++) {
      painter.text = TextSpan(text: '$number', style: style);
      painter.layout();
      width = math.max(width, painter.width);
      height = math.max(height, painter.height);
    }
    painter.dispose();
    _metricsKey = key;
    return _labelSize = Size(width.ceilToDouble(), height.ceilToDouble());
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      LabelX('Levels Progress', marginBottom: 12).fadeAnimation150,
      LayoutBuilder(
        builder:
            (context, constraints) => Obx(() {
              final levels = controller.levels;
              final count = levels.length;
              final labelSize = _measureLabels(context, count);
              final cellWidth = math.max(_badgeSize, labelSize.width);
              final height = math.max(
                _minimumHeight,
                _badgeSize +
                    _stagger +
                    labelSize.height +
                    (_verticalPadding + _borderWidth) * 2,
              );
              final viewportWidth = math.max(
                0.0,
                constraints.maxWidth - (_horizontalPadding + _borderWidth) * 2,
              );
              // Retain spaceBetween geometry for a few levels; overflow scrolls
              // with each complete badge and label at its measured width.
              final step =
                  count > 1
                      ? math.max(
                        cellWidth,
                        (viewportWidth - cellWidth) / (count - 1),
                      )
                      : math.max(viewportWidth, cellWidth);
              final trackWidth =
                  count > 1
                      ? step * (count - 1) + cellWidth
                      : math.max(viewportWidth, cellWidth);
              final ratio =
                  count == 0
                      ? 0.0
                      : levels.where((level) => level.isCompleted).length /
                          count;
              return Container(
                height: height,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                  vertical: _verticalPadding,
                ),
                decoration: BoxDecoration(
                  gradient: ColorX.gold2Gradient,
                  borderRadius: BorderRadius.circular(StyleX.radiusMd),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    width: _borderWidth,
                  ),
                ),
                child: Stack(
                  key: const ValueKey('level-progress-viewport'),
                  children: [
                    Positioned.fill(
                      child: Semantics(
                        label: 'Levels Progress'.tr,
                        value: '${(ratio * 100).round()}%',
                        child: CustomPaint(
                          key: const ValueKey('level-progress-line'),
                          painter: _LevelProgressPainter(
                            scroll: _scroll,
                            trackWidth: trackWidth,
                            ratio: ratio,
                            inset: _lineInset + (cellWidth - _badgeSize) / 2,
                            centerY: _badgeSize / 2,
                            thickness: _lineThickness,
                            direction: Directionality.of(context),
                            background: ColorX.yellow.shade100,
                            foreground: ColorX.yellow.shade400,
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      key: const ValueKey('level-progress-list'),
                      controller: _scroll,
                      scrollDirection: Axis.horizontal,
                      primary: false,
                      padding: EdgeInsets.zero,
                      itemCount: count,
                      itemExtentBuilder:
                          (index, _) =>
                              index >= count
                                  ? null
                                  : count > 1 && index == count - 1
                                  ? cellWidth
                                  : step,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        return Align(
                          key: ValueKey('level-progress-item-$index'),
                          alignment: AlignmentDirectional.topStart,
                          child: SizedBox(
                            width: cellWidth,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: _badgeSize + _stagger,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: level.isCompleted ? _stagger : 0,
                                      bottom: level.isCompleted ? 0 : _stagger,
                                    ),
                                    child:
                                        level.isCompleted
                                            ? Image.asset(
                                              ImageX.badge2,
                                              width: _badgeSize,
                                              height: _badgeSize,
                                            )
                                            : Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Image.asset(
                                                  ImageX.shape,
                                                  width: _badgeSize,
                                                  height: _badgeSize,
                                                ),
                                                if (level.isOpen)
                                                  Container(
                                                    width: _symbolSize,
                                                    height: _symbolSize,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            100,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: CircleAvatar(
                                                        radius: 3.5,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  const Icon(
                                                    IconX.lock,
                                                    color: Colors.black,
                                                    size: _symbolSize,
                                                  ),
                                              ],
                                            ),
                                  ),
                                ),
                                SizedBox(
                                  height: labelSize.height,
                                  child: TextX(
                                    '${index + 1}',
                                    style: TextStyleX.labelSmall,
                                    textDirection: TextDirection.ltr,
                                    overflow: TextOverflow.visible,
                                    color:
                                        level.isCompleted
                                            ? ColorX.yellow.shade600
                                            : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
      ).fadeAnimation200,
    ],
  ).marginSymmetric(horizontal: StyleX.hPaddingApp);
}

/// One continuous logical track, independent of the mounted item window.
/// Scroll and RTL transform the whole line, never restart progress per cell.
class _LevelProgressPainter extends CustomPainter {
  _LevelProgressPainter({
    required this.scroll,
    required this.trackWidth,
    required this.ratio,
    required this.inset,
    required this.centerY,
    required this.thickness,
    required this.direction,
    required this.background,
    required this.foreground,
  }) : super(repaint: scroll);

  final ScrollController scroll;
  final double trackWidth, ratio, inset, centerY, thickness;
  final TextDirection direction;
  final Color background, foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final offset = scroll.hasClients ? scroll.offset : 0.0;
    final span = math.max(0.0, trackWidth - inset * 2);
    if (span == 0) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (direction == TextDirection.rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final start = Offset(inset - offset, centerY);
    final paint =
        Paint()
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      start,
      Offset(inset + span - offset, centerY),
      paint..color = background,
    );
    if (ratio > 0) {
      canvas.drawLine(
        start,
        Offset(inset + span * ratio - offset, centerY),
        paint..color = foreground,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LevelProgressPainter oldDelegate) =>
      oldDelegate.scroll != scroll ||
      oldDelegate.trackWidth != trackWidth ||
      oldDelegate.ratio != ratio ||
      oldDelegate.inset != inset ||
      oldDelegate.centerY != centerY ||
      oldDelegate.thickness != thickness ||
      oldDelegate.direction != direction ||
      oldDelegate.background != background ||
      oldDelegate.foreground != foreground;
}
