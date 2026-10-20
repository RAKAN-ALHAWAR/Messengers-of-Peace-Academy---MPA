import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import 'profile_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final harness = ProfileHarness();
  setUpAll(harness.initialize);
  setUp(harness.reset);
  tearDown(harness.cleanUp);
  tearDownAll(harness.close);

  for (final mode in ['failure', 'missing', 'empty']) {
    testWidgets(
      'reference $mode retains country language prefix and full phone',
      (tester) async {
        harness.failReferences = mode == 'failure';
        harness.emptyReferences = mode == 'empty';
        await http.runWithClient(() async {
          await harness.controller.getData();
          expect(harness.controller.country.value, 'Syria');
          expect(harness.controller.language.value, 'Arabic');
          expect(harness.controller.countryCode.value, '+963');
          expect(harness.controller.formData.whatsappNumber, '+963944123456');
          await harness.mount(tester);
          expect(tester.takeException(), isNull);
        }, harness.client);
      },
    );
  }

  testWidgets('unknown legacy selections are retained and render safely', (
    tester,
  ) async {
    harness.cleanUp();
    await tester.runAsync(
      () => harness.reset(user: syntheticProfile(unknown: true)),
    );
    await http.runWithClient(() async {
      await harness.mount(tester);
      expect(harness.controller.country.value, 'Legacy Country');
      expect(harness.controller.language.value, 'Legacy Language');
      expect(harness.controller.age.value, 'Legacy Age');
      expect(harness.controller.howToFindUs.value, 'Legacy Referral');
      expect(harness.controller.university.value, 'Legacy University');
      expect(tester.takeException(), isNull);
    }, harness.client);
  });

  testWidgets(
    'mismatched stored prefix does not rewrite phone on unrelated edit',
    (tester) async {
      harness.cleanUp();
      await tester.runAsync(
        () => harness.reset(user: syntheticProfile(phone: '+441234567890')),
      );
      await http.runWithClient(() async {
        await harness.mount(tester);
        harness.controller.city.text = 'Aleppo';
        expect(harness.controller.whatsapp.text, '+441234567890');
        expect(harness.controller.formData.whatsappNumber, '+441234567890');
        expect(harness.controller.formData.countryPhoneCode, '+963');
      }, harness.client);
    },
  );

  testWidgets(
    'malformed full phone stays visible and blocks an unintended rewrite',
    (tester) async {
      harness.cleanUp();
      await tester.runAsync(
        () => harness.reset(user: syntheticProfile(phone: '+441234567890')),
      );
      await http.runWithClient(() async {
        await harness.mount(tester);
        await harness.controller.onEdit();
        await tester.pumpAndSettle();
        expect(harness.updateCalls, 0);
        expect(harness.controller.whatsapp.text, '+441234567890');
        expect(find.text('Enter a valid phone number'), findsOneWidget);
        // Explicitly changing the local-number input is a distinct user action.
        harness.controller.whatsapp.text = '944123456';
        harness.onUpdate =
            () async => http.Response(
              '{"status":"error","message":"Synthetic validation retry"}',
              200,
            );
        await harness.controller.onEdit();
        await tester.pump();
        expect(harness.updateCalls, 1);
        expect(harness.lastUpdate?['customfields[2][value]'], '+963944123456');
        expect(Get.currentRoute, '/profile-test');
        ToastX.dismiss();
        await tester.pump(const Duration(seconds: 5));
      }, harness.client);
    },
  );
}
