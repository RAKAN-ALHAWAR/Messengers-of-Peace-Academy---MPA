import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

/// Arabic-Indic digits (U+0660 to U+0669) and extended Arabic-Indic digits
final _arabicIndic = RegExp('[٠-٩۰-۹]');

Iterable<String> _texts(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '');

void main() {
  Future<void> openPicker(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: TextFieldDateX(
            controller: TextEditingController(),
            hint: 'date',
            locale: locale,
            prefillInitialDate: false,
            initialDate: DateTime(2008, 10, 28),
            firstDate: DateTime(1990),
            lastDate: DateTime(2030),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextFieldDateX));
    await tester.pumpAndSettle();
  }

  setUp(() => Get.testMode = true);

  testWidgets('the Arabic date picker shows Latin digits only', (tester) async {
    await openPicker(tester, const Locale('ar'));
    final texts = _texts(tester).toList();
    expect(
      texts.where(_arabicIndic.hasMatch),
      isEmpty,
      reason: 'Arabic-Indic digits found in: $texts',
    );
    // The header date and the month title still show the picked date
    expect(texts.any((t) => t.contains('28') && t.contains('أكتوبر')), isTrue);
    expect(texts.any((t) => t.contains('2008')), isTrue);
  });

  testWidgets('the year list of the Arabic picker shows Latin digits', (
    tester,
  ) async {
    await openPicker(tester, const Locale('ar'));
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    final texts = _texts(tester).toList();
    expect(texts.where(_arabicIndic.hasMatch), isEmpty, reason: '$texts');
    expect(texts, contains('2008'));
  });

  testWidgets('the English picker is unchanged', (tester) async {
    await openPicker(tester, const Locale('en'));
    final texts = _texts(tester).toList();
    expect(texts.any((t) => t.contains('Oct 28')), isTrue, reason: '$texts');
    expect(texts, contains('October 2008'));
  });
}
