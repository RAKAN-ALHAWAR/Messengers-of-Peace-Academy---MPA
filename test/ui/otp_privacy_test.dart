import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Ui/Widget/Package/otp_pin_field_widget/otp_pin_field.dart';

void main() {
  testWidgets(
    'manual and autofilled OTPs reach callbacks without debug output',
    (tester) async {
      final output = <String?>[];
      final changes = <String>[];
      final submitted = <String>[];
      final autofilled = <String>[];
      final previous = debugPrint;
      debugPrint = (message, {wrapWidth}) => output.add(message);
      addTearDown(() => debugPrint = previous);
      final key = GlobalKey<OtpPinFieldState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OtpPinField(
              key: key,
              autoFocus: false,
              onChange: changes.add,
              onSubmit: submitted.add,
              onCodeChanged: autofilled.add,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '6842');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(changes, contains('6842'));
      expect(submitted, contains('6842'));
      key.currentState!.codeUpdate('7391');
      await tester.pump();
      expect(autofilled, ['7391']);
      expect(output.join(), isNot(contains('6842')));
      expect(output.join(), isNot(contains('7391')));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
      debugPrint = previous;
    },
  );
}
