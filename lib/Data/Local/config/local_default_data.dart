part of '../../data.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Default data if no stored data is available
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class LocalDefaultDataX {
  static String route = RouteNameX.login;
  static String userid = '';
  static String token = '';
  static bool themeIsDark = false;
  static String language =
      Get.deviceLocale?.languageCode ??
      TranslationX.fallbackLocale.languageCode;
}
