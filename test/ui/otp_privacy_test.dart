import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.getData') return {'text': '۰۱۲۳'};
        return null;
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(SystemChannels.platform, null);
      });
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
      await tester.longPress(find.byType(OtpPinField));
      await tester.pump();
      expect(changes.last, '0123');
      expect(submitted.last, '0123');
      expect(output.join(), isNot(contains('6842')));
      expect(output.join(), isNot(contains('7391')));
      expect(output.join(), isNot(contains('0123')));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
      debugPrint = previous;
    },
  );
}
