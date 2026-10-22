import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../performance/counterpart_lists_test.dart' show host, viewport;

void main() {
  tearDown(() => Get.reset());
  testWidgets(
    'bounded state buttons retain their nominal height in every state',
    (tester) async {
      Get.testMode = true;
      viewport(tester, 320);
      for (final state in ButtonStateEX.values) {
        await tester.pumpWidget(
          host(
            Scaffold(
              body: Center(
                child: ButtonStateX(
                  key: ValueKey(state),
                  state: state,
                  text: 'Save',
                  marginVertical: 0,
                  onTap: () async {},
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        final ink = find.descendant(
          of: find.byType(ButtonStateX),
          matching: find.byType(InkWell),
        );
        expect(tester.getSize(ink).height, StyleX.buttonHeight);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('a compact plain button fits an unbounded row', (tester) async {
    Get.testMode = true;
    await tester.pumpWidget(
      host(
        Scaffold(
          body: Row(
            children: [ButtonX(text: 'Save', isMaxFinite: false, onTap: () {})],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ButtonX)).width, lessThan(300));
  });
  testWidgets('state transitions preserve tap and animation callbacks', (
    tester,
  ) async {
    Get.testMode = true;
    var taps = 0;
    final completed = <ButtonStateEX>[];
    for (final state in [
      ButtonStateEX.normal,
      ButtonStateEX.loading,
      ButtonStateEX.success,
      ButtonStateEX.failed,
      ButtonStateEX.normal,
    ]) {
      await tester.pumpWidget(
        host(
          Scaffold(
            body: Center(
              child: ButtonStateX(
                key: const ValueKey('button'),
                state: state,
                text: 'Save',
                onTap: () async => taps++,
                onAnimationEnd: (AnimationStatus status, ButtonStateEX state) {
                  if (status == AnimationStatus.completed) completed.add(state);
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
    expect(taps, 5);
    expect(
      completed,
      containsAll([
        ButtonStateEX.loading,
        ButtonStateEX.success,
        ButtonStateEX.failed,
        ButtonStateEX.normal,
      ]),
    );
    await tester.pumpWidget(const SizedBox());
  });
  for (final stateful in [false, true]) {
    for (final locale in ['ar', 'en', 'es', 'fil']) {
      for (final scale in [1.0, 2.0, 3.0]) {
        testWidgets(
          '${stateful ? 'state' : 'plain'} button fits $locale scale$scale and still responds',
          (tester) async {
            Get.testMode = true;
            viewport(tester, 320);
            var taps = 0;
            Widget button(bool disabled) =>
                stateful
                    ? ButtonStateX(
                      text: 'All notifications have been marked as read',
                      iconData: IconX.check,
                      disabled: disabled,
                      onTap: () async => taps++,
                    )
                    : ButtonX(
                      text: 'All notifications have been marked as read',
                      iconData: IconX.check,
                      disabled: disabled,
                      onTap: () => taps++,
                    );
            await tester.pumpWidget(
              host(
                Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [button(false), button(true)]),
                    ),
                  ),
                ),
                locale: locale,
                scale: scale,
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final labels = find.text(
              'All notifications have been marked as read'.tr,
            );
            expect(labels, findsNWidgets(2));
            for (final paragraph in tester.renderObjectList<RenderParagraph>(
              labels,
            )) {
              expect(paragraph.didExceedMaxLines, isFalse);
              expect(paragraph.paintBounds.height, greaterThan(0));
            }
            await tester.ensureVisible(labels.first);
            await tester.tap(labels.first);
            await tester.ensureVisible(labels.last);
            // AbsorbPointer intentionally excludes the disabled state button.
            await tester.tap(labels.last, warnIfMissed: false);
            await tester.pumpAndSettle();
            expect(taps, 1);
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
}
