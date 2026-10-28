import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

String typeInto(String typed) {
  var value = TextEditingValue.empty;
  final next = TextEditingValue(
    text: typed,
    selection: TextSelection.collapsed(offset: typed.length),
  );
  value = emailInputFormatters.fold(
    next,
    (current, formatter) => formatter.formatEditUpdate(value, current),
  );
  return value.text;
}

void main() {
  test('email field keeps a normal ASCII address unchanged', () {
    expect(typeInto('student.one+mopa@example.org'), 'student.one+mopa@example.org');
  });

  test('email field drops Arabic letters typed from an Arabic keyboard', () {
    expect(typeInto('سلامuser@mail.com'), 'user@mail.com');
  });

  test('email field converts Arabic-Indic digits to Latin digits', () {
    expect(typeInto('user١٢٣@mail.com'), 'user123@mail.com');
  });

  test('email field drops spaces', () {
    expect(typeInto('user @mail.com'), 'user@mail.com');
  });

  testWidgets('email TextFieldX rejects Arabic input as it is typed', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextFieldX(
            controller: controller,
            textInputType: TextInputType.emailAddress,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'عليuser@mail.com');
    expect(controller.text, 'user@mail.com');
  });

  testWidgets('a non-email TextFieldX still accepts Arabic text', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TextFieldX(controller: controller)),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'محمد');
    expect(controller.text, 'محمد');
  });
}
