import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/form_validation.dart';

void main() {
  testWidgets('optional dropdown still validates and selection updates', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    String? changed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: form,
            child: DropdownX<String>(
              value: '',
              hint: 'Optional',
              list: const ['One', 'Two'],
              onChanged: (value) => changed = value,
            ),
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), isTrue);
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Two').last);
    await tester.pumpAndSettle();
    expect(changed, 'Two');
    expect(
      tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .value,
      'Two',
    );
  });

  testWidgets('required dropdown synchronizes parent values and clears error', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    String? selected;
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return Form(
                key: form,
                autovalidateMode: AutovalidateMode.always,
                child: DropdownX<String>(
                  value: selected,
                  hint: 'Required selection',
                  list: const ['One', 'Two'],
                  validator: (value) => value == null ? 'Pick one' : null,
                  onChanged: (value) => rebuild(() => selected = value),
                ),
              );
            },
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Pick one'), findsOneWidget);
    rebuild(() => selected = 'Two');
    await tester.pump();
    expect(form.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Pick one'), findsNothing);
    expect(
      tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .value,
      'Two',
    );
    rebuild(() => selected = null);
    await tester.pump();
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Pick one'), findsOneWidget);
  });

  testWidgets('removed conditional dropdown stops blocking form', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    var show = true;
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return Form(
                key: form,
                child: Column(
                  children: [
                    if (show)
                      DropdownX<String>(
                        value: '',
                        list: const ['One'],
                        validator: (_) => 'University required',
                        onChanged: (_) {},
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), isFalse);
    rebuild(() => show = false);
    await tester.pump();
    expect(form.currentState!.validate(), isTrue);
    expect(find.text('University required'), findsNothing);
  });

  testWidgets('first error is focused and revealed after error layout', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    final focus = FocusNode();
    final scroll = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: scroll,
            child: Form(
              key: form,
              child: Column(
                children: [
                  const SizedBox(height: 1000),
                  TextFormField(
                    focusNode: focus,
                    validator: (_) => 'First field error',
                  ),
                  TextFormField(validator: (_) => 'Second field error'),
                  const SizedBox(height: 1000),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(validateAndRevealFirstError(form.currentState!), isFalse);
    expect(scroll.offset, 0);
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    final error = tester.getRect(find.text('First field error'));
    expect(error.top, greaterThanOrEqualTo(0));
    expect(error.bottom, lessThan(600));
    expect(scroll.offset, greaterThan(0));
    await tester.pumpWidget(const SizedBox());
    focus.dispose();
    scroll.dispose();
  });
}
