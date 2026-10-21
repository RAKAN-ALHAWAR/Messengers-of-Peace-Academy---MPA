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
    {'code': 'fil', 'name': 'Filipino'},
  ];

  /// List Locale of all supported languages
  static const locales = [
    Locale('en'),
    Locale('ar'),
    Locale('es'),
    Locale('fil'),
  ];

  /// Link the language code with its translation file
  @override
  Map<String, Map<String, String>> get keys {
    return {'en': en, 'ar': ar, 'es': es, 'fil': ph};
  }

  //============================================================================
  // Functions

  /// Fetch the name of the current language
  static String getCurrentNameLanguage() {
    final code = getLanguageCode;
    return languages.firstWhere(
      (language) => code == language['code'],
      orElse:
          () => languages.firstWhere((language) => language['code'] == 'en'),
    )['name']!;
  }

  // Legacy preferences used the country-like "ph" code. The UI uses intl's
  // Filipino locale, while the existing backend contract continues to use ph.
  static String _uiCode(String code) => code == 'ph' ? 'fil' : code;

  /// Fetch the locale of the current language, including legacy preferences.
  static Locale get getLocale => Locale(getLanguageCode);

  /// Locale for UI translations, dates, and request ownership.
  static String get getLanguageCode =>
      _uiCode(Get.locale?.languageCode ?? LocalDataX.language);

  /// Language code for existing backend headers and explicit language fields.
  static String get backendLanguageCode =>
      getLanguageCode == 'fil' ? 'ph' : getLanguageCode;

  /// Change the application language
  static changeLocale(String lang) async {
    await Get.updateLocale(Locale(_uiCode(lang)));
  }
}
