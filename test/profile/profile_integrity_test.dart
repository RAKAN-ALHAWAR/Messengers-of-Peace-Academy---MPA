import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'package:messengersofpeace/Data/data.dart';

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

  testWidgets('late profile references cannot overwrite the current locale', (
    tester,
  ) async {
    Get.locale = const Locale('en');
    final old = Completer<http.Response>();
    harness.onReference = () => old.future;
    await http.runWithClient(() async {
      final first = harness.controller.getData();
      await tester.pump();
      Get.locale = const Locale('ar');
      harness.onReference = null;
      await harness.controller.getData();
      old.complete(
        http.Response(
          '[{"code":"ZZ","name":"Stale locale","dial_code":"+000"}]',
          200,
        ),
      );
      await first;
      expect(
        harness.controller.countriesList.map((value) => value.name),
        isNot(contains('Stale locale')),
      );
      expect(
        harness.controller.languagesList.map((value) => value.name),
        isNot(contains('Stale locale')),
      );
      expect(harness.controller.countryCode.value, '+963');
    }, harness.client);
  });

  testWidgets(
    'profile view reloads locale references and retires old-session form',
    (tester) async {
      await http.runWithClient(() async {
        await harness.mount(tester);
        harness.controller.city.text = 'Synthetic entered city';
        final loaded = harness.referenceCalls;
        Get.updateLocale(const Locale('ar'));
        await tester.pumpAndSettle();
        expect(harness.referenceCalls, loaded + 3);
        expect(harness.controller.city.text, 'Synthetic entered city');
        expect(find.byType(Form), findsOneWidget);
        await tester.runAsync(
          () => LocalDataX.put(LocalKeyX.token, 'synthetic-token'),
        );
        await tester.pumpAndSettle();
        expect(find.byType(Form), findsNothing);
        expect(harness.referenceCalls, loaded + 3);
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }, harness.client);
    },
  );
}
