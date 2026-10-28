import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

const hint = 'Switch the keyboard to English to type the email';

void main() {
  Future<TextEditingController> mount(
    WidgetTester tester, {
    TextInputType type = TextInputType.emailAddress,
  }) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextFieldX(controller: controller, textInputType: type),
        ),
      ),
    );
    return controller;
  }

  testWidgets('a dropped Arabic letter shows the keyboard hint', (
    tester,
  ) async {
    final controller = await mount(tester);
    expect(find.text(hint), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'عليuser');
    await tester.pump();

    expect(controller.text, 'user');
    expect(find.text(hint), findsOneWidget);
  });

  testWidgets('the next accepted edit clears the hint', (tester) async {
    final controller = await mount(tester);

    await tester.enterText(find.byType(TextFormField), 'عليuser');
    await tester.pump();
    expect(find.text(hint), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'user2');
    await tester.pump();

    expect(controller.text, 'user2');
    expect(find.text(hint), findsNothing);
  });

  testWidgets('a dropped space or a converted digit shows no hint', (
    tester,
  ) async {
    final controller = await mount(tester);

    await tester.enterText(find.byType(TextFormField), 'user ١٢@mail.com');
    await tester.pump();

    expect(controller.text, 'user12@mail.com');
    expect(find.text(hint), findsNothing);
  });

  testWidgets('a non-email field never shows the hint', (tester) async {
    final controller = await mount(tester, type: TextInputType.text);

    await tester.enterText(find.byType(TextFormField), 'عليuser');
    await tester.pump();

    expect(controller.text, 'عليuser');
    expect(find.text(hint), findsNothing);
  });
}
