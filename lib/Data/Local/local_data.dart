part of '../data.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Managing data stored internally on the client device
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class LocalDataX<T> {
  //============================================================================
  // Variables

  static String get route =>
      get(LocalKeyX.route, defaultData: LocalDefaultDataX.route);
  static String get userid =>
      get(LocalKeyX.userid, defaultData: LocalDefaultDataX.userid);
  static String get token =>
      get(LocalKeyX.token, defaultData: LocalDefaultDataX.token);
  static bool get themeIsDark =>
      get(LocalKeyX.themeIsDark, defaultData: LocalDefaultDataX.themeIsDark);
  static String get language =>
      get(LocalKeyX.language, defaultData: LocalDefaultDataX.language);

  //============================================================================
  // Functions

  static Future<void> init() async {
    /// Recover data saved in phone case
    await HiveX.init();
  }

  static T get<T>(String kay, {T? defaultData}) {
    return HiveX.get<T>(kay, defaultData)!;
  }

  static void put<T>(String kay, T data, {Duration? maxAge}) {
    HiveX.put(data: data, key: kay, maxAge: maxAge);
  }

  static void remove(String kay) {
    HiveX.remove(kay);
  }
}
