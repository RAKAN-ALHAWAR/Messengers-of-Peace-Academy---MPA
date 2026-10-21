import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

void main() {
  testWidgets('removing delayed content cancels its pending entrance', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FadeAnimationX(delay: 5000, child: Text('Delayed content')),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    // The binding also rejects any pending timer when this test completes.
  });
  testWidgets('visible content still starts after its delay and finishes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FadeAnimationX(delay: 200, child: Text('Visible content')),
      ),
    );
    final opacity = find.ancestor(
      of: find.text('Visible content'),
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(opacity).opacity, 0);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
