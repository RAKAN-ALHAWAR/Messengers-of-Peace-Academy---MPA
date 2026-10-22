import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Data/Model/info/phone_code.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.locale = const Locale('en');
  });
  tearDown(Get.reset);
  testWidgets(
    'selected dropdown row preserves theme channels and requested alpha then search selects a new code',
    (tester) async {
      var selected = '+101';
      final scheme = ColorScheme.fromSeed(seedColor: const Color(0xff23517b));
      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(colorScheme: scheme),
          home: Scaffold(
            body: StatefulBuilder(
              builder:
                  (context, setState) => SearchableCountryCodeDropdown(
                    key: const ValueKey('country'),
                    value: selected,
                    onlyEnglish: true,
                    phoneCodesList: [
                      PhoneCode(code: 'AA', name: 'Alpha', dialCode: '+101'),
                      PhoneCode(code: 'BB', name: 'Beta', dialCode: '+202'),
                    ],
                    onChanged: (value) => setState(() => selected = value),
                  ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('country')));
      await tester.pumpAndSettle();
      final row = tester.widget<Container>(
        find
            .ancestor(of: find.text('Alpha'), matching: find.byType(Container))
            .first,
      );
      final decoration = row.decoration! as BoxDecoration;
      final borderColor = (decoration.border! as Border).bottom.color;
      expect(decoration.color!.a, closeTo(0.1, 0.000001));
      expect(borderColor.a, closeTo(0.1, 0.000001));
      expect(
        decoration.color!.toARGB32(),
        scheme.primary.withAlpha(26).toARGB32(),
      );
      expect(borderColor.toARGB32(), scheme.outline.withAlpha(26).toARGB32());
      await tester.enterText(find.byType(TextField), 'beta');
      await tester.pumpAndSettle();
      expect(find.text('Alpha'), findsNothing);
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(selected, '+202');
      expect(find.byType(BottomSheet), findsNothing);
    },
  );
}
