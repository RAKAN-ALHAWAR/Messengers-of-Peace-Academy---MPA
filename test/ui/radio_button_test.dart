import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

class CollisionChoice {
  const CollisionChoice(this.id);
  final int id;
  @override
  int get hashCode => 1;
  @override
  bool operator ==(Object other) => other is CollisionChoice && id == other.id;
}

Finder anyRadioIn(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byWidgetPredicate((widget) => widget is Radio),
);
bool checked(WidgetTester tester, Finder radio) =>
    tester.getSemantics(radio).flagsCollection.isChecked == CheckedState.isTrue;

void main() {
  setUp(() {
    Get.testMode = true;
    Get.locale = const Locale('en');
  });
  tearDown(Get.reset);

  testWidgets(
    'unequal choices with equal hashes remain mutually exclusive after a real selection',
    (tester) async {
      const first = CollisionChoice(1);
      const second = CollisionChoice(2);
      var selected = first;
      var callbacks = 0;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder:
                  (context, setState) => Column(
                    children: [
                      RadioButtonX<CollisionChoice>(
                        key: const ValueKey('first'),
                        value: first,
                        groupValue: selected,
                        label: 'First',
                        onChanged:
                            (value) => setState(() {
                              selected = value!;
                              callbacks++;
                            }),
                      ),
                      RadioButtonX<CollisionChoice>(
                        key: const ValueKey('second'),
                        value: second,
                        groupValue: selected,
                        label: 'Second',
                        onChanged:
                            (value) => setState(() {
                              selected = value!;
                              callbacks++;
                            }),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      );
      expect(checked(tester, anyRadioIn('first')), isTrue);
      expect(checked(tester, anyRadioIn('second')), isFalse);
      await tester.tap(anyRadioIn('second'));
      await tester.pumpAndSettle();
      expect(selected, second);
      expect(callbacks, 1);
      expect(checked(tester, anyRadioIn('first')), isFalse);
      expect(checked(tester, anyRadioIn('second')), isTrue);
    },
  );

  testWidgets(
    'label taps publish the real value once and a parent-disabled card ignores both targets',
    (tester) async {
      var selected = 1;
      var callbacks = 0;
      var disabled = false;
      late StateSetter update;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return AbsorbPointer(
                  absorbing: disabled,
                  child: RadioButtonX<int>(
                    key: const ValueKey('option'),
                    value: 2,
                    groupValue: selected,
                    child: const Text('Option', key: ValueKey('label')),
                    onChanged:
                        (value) => setState(() {
                          selected = value!;
                          callbacks++;
                        }),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('label')));
      await tester.pumpAndSettle();
      expect(selected, 2);
      expect(callbacks, 1);
      expect(checked(tester, anyRadioIn('option')), isTrue);
      update(() {
        selected = 1;
        disabled = true;
      });
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('label')),
        warnIfMissed: false,
      );
      await tester.tap(anyRadioIn('option'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(callbacks, 1);
      expect(checked(tester, anyRadioIn('option')), isFalse);
    },
  );

  testWidgets('read-only callback leaves selection controlled by the caller', (
    tester,
  ) async {
    var callbacks = 0;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: RadioButtonX<String>(
            key: const ValueKey('readonly'),
            value: 'second',
            groupValue: 'first',
            label: 'Choice',
            onChanged: (_) {
              callbacks++;
            },
          ),
        ),
      ),
    );
    await tester.tap(anyRadioIn('readonly'));
    await tester.pumpAndSettle();
    expect(callbacks, 1);
    expect(checked(tester, anyRadioIn('readonly')), isFalse);
  });

  testWidgets(
    'legacy valueCheck selects by hash while check controls color and callback keeps T',
    (tester) async {
      String? submitted;
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );
      await tester.pumpWidget(
        GetMaterialApp(
          theme: theme,
          home: Scaffold(
            body: RadioButtonX<String>(
              key: const ValueKey('legacy'),
              value: 'original',
              groupValue: 'selected',
              valueCheck: 'selected'.hashCode,
              check: () => false,
              child: const Text('Legacy', key: ValueKey('legacy-label')),
              onChanged: (value) => submitted = value,
            ),
          ),
        ),
      );
      expect(checked(tester, anyRadioIn('legacy')), isTrue);
      final radio = tester.widget<Radio>(anyRadioIn('legacy'));
      expect(
        radio.fillColor!.resolve({WidgetState.selected}),
        theme.colorScheme.onSurfaceVariant,
      );
      await tester.tap(find.byKey(const ValueKey('legacy-label')));
      await tester.pumpAndSettle();
      expect(submitted, 'original');
    },
  );

  testWidgets(
    'card-only mode retains full-card selection without a radio indicator',
    (tester) async {
      var selected = false;
      var checks = 0;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: RadioButtonX<bool>(
              key: const ValueKey('card'),
              value: true,
              groupValue: false,
              isCardOnly: true,
              check: () {
                checks++;
                return true;
              },
              child: const Text('Card'),
              onChanged: (value) => selected = value!,
            ),
          ),
        ),
      );
      expect(find.byWidgetPredicate((widget) => widget is Radio), findsNothing);
      await tester.tap(find.byKey(const ValueKey('card')));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
      expect(checks, 0);
    },
  );
}
