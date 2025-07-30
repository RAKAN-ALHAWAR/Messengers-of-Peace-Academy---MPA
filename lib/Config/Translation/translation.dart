import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Data/data.dart';
import 'Locale/Ar/ar.dart';
import 'Locale/En/en.dart';
import 'Locale/Es/es.dart';
import 'Locale/ph/ph.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Managing the day and night theme for the entire application
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Note: This section is not included with the config package because it is only
///       --> used in a few places within the application
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class TranslationX extends Translations {
  //============================================================================
  // Data

  /// Backup language
  static const fallbackLocale = Locale('en');

  ///Names of available languages with their code
  static final List<Map<String, String>> languages = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'ph', 'name': 'Filipino'},
  ];

  /// List Locale of all supported languages
  static const locales = [
    Locale('en'),
    Locale('ar'),
    Locale('es'),
    Locale('ph'),
  ];

  /// Link the language code with its translation file
  @override
  Map<String, Map<String, String>> get keys {
    return {'en': en, 'ar': ar, 'es': es, 'ph': ph};
  }

  //============================================================================
  // Functions

  /// Fetch the name of the current language
  static String getCurrentNameLanguage() {
    String x = Get.locale!.languageCode;
    return languages.firstWhere((lang) => x == lang['code'])['name'] ??
        "not found";
  }

  /// Fetch the locale of the current language
  static Locale get getLocale =>
      Locale(Get.locale?.languageCode ?? LocalDataX.language);

  /// Fetch the code of the current language
  static String get getLanguageCode =>
      Get.locale?.languageCode ?? LocalDataX.language;

  /// Change the application language
  static changeLocale(String lang) async {
    await Get.updateLocale(Locale(lang));
  }
}
