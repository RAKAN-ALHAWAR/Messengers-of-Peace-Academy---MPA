import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/activity_points_card.dart';

import 'catalog_activity_lists_test.dart' show host, viewport;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('IBMPlexSansArabic');
    for (final weight in ['Regular', 'SemiBold', 'Bold']) {
      loader.addFont(
        rootBundle.load('assets/fonts/IBMPlexSansArabic-$weight.ttf'),
      );
    }
    await loader.load();
  });
  for (final locale in ['ar', 'en', 'es', 'fil']) {
    for (final scale in [2.0, 3.0]) {
      for (final points in [7, 1000000, 9223372036854775807]) {
        testWidgets('full activity points $points at320/${scale}x $locale', (
          tester,
        ) async {
          viewport(tester, width: 320);
          const name = 'Full activity name without truncation عنوان النشاط';
          final label = '${FunctionX.formatLargeNumber(points)}+';
          await tester.pumpWidget(
            host(
              Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ActivityPointsCard(
                      name: name,
                      points: points,
                      secondaryText: 'Full secondary text remains readable',
                    ),
                  ),
                ),
              ),
              locale: locale,
              scale: scale,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (final text in [name, label]) {
            final finder = find.text(text);
            expect(finder, findsOneWidget);
            final paragraph = tester.renderObject<RenderParagraph>(finder);
            expect(paragraph.didExceedMaxLines, isFalse);
            final bounds = tester.getRect(finder);
            final card = tester.getRect(find.byType(ActivityPointsCard));
            expect(bounds.left, greaterThanOrEqualTo(card.left));
            expect(bounds.right, lessThanOrEqualTo(card.right));
          }
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }
}
