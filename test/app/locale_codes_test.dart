import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/remote/config/remote_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-locale-tests-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic-locale');
    await initializeDateFormatting();
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('stored legacy ph selects intl-supported Filipino UI locale', () async {
    Get.locale = null;
    await LocalDataX.put(LocalKeyX.language, 'ph');
    expect(TranslationX.getLocale, const Locale('fil'));
    expect(TranslationX.getLanguageCode, 'fil');
    expect(RemoteConfigX.languageCode, 'ph');
    expect(
      DateFormat.yMMMMd(
        TranslationX.getLanguageCode,
      ).format(DateTime(2026, 7, 12)),
      isNotEmpty,
    );
  });
  test(
    'legacy active locale alias resolves a language name and translated keys',
    () {
      Get.locale = const Locale('ph');
      expect(TranslationX.getLanguageCode, 'fil');
      expect(TranslationX.getCurrentNameLanguage(), 'Filipino');
      expect(TranslationX.locales, contains(const Locale('fil')));
      expect(TranslationX().keys.containsKey('fil'), isTrue);
    },
  );
  for (final code in ['ar', 'en', 'es', 'fil']) {
    test(
      '$code UI and backend codes stay separate without changing other languages',
      () {
        Get.locale = Locale(code);
        expect(TranslationX.getLanguageCode, code);
        expect(RemoteConfigX.languageCode, code == 'fil' ? 'ph' : code);
        expect(TranslationX.getCurrentNameLanguage(), isNotEmpty);
      },
    );
  }
  testWidgets(
    'changing legacy ph selects fil and dates open in all supported locales',
    (tester) async {
      Get.testMode = true;
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('en'),
          translations: TranslationX(),
          supportedLocales: TranslationX.locales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const Scaffold(body: Text('Synthetic locale host')),
        ),
      );
      final change = TranslationX.changeLocale('ph');
      await tester.pumpAndSettle();
      await change;
      expect(Get.locale, const Locale('fil'));
      expect(TranslationX.getCurrentNameLanguage(), 'Filipino');
      for (final code in ['ar', 'en', 'es', 'fil']) {
        final change = TranslationX.changeLocale(code);
        await tester.pumpAndSettle();
        await change;
        expect(
          DateFormat.yMMMMd(
            TranslationX.getLanguageCode,
          ).format(DateTime(2026, 7, 12)),
          isNotEmpty,
        );
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
}
