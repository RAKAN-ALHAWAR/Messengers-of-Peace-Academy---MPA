part of '../data.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Managing data stored internally on the client device
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class LocalDataX<T> {
  // In-memory login generation. Even a same-value credential write invalidates
  // older work; it cannot be recognized by comparing the token alone.
  static int _sessionRevision = 0;
  static int get sessionRevision => _sessionRevision;
  static final _sessionChanges = StreamController<int>.broadcast();
  static Stream<int> get sessionChanges => _sessionChanges.stream;
  static bool _notificationPending = false;
  static void identityChanged([String? key]) {
    if (key == null || key == LocalKeyX.userid || key == LocalKeyX.token) {
      _sessionRevision++;
      // Coalesce synchronous credential writes. Listeners observe Hive's updated
      // in-memory identity, never the credentials preceding this revision.
      if (!_notificationPending) {
        _notificationPending = true;
        scheduleMicrotask(() {
          _notificationPending = false;
          _sessionChanges.add(_sessionRevision);
        });
      }
    }
  }
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

  static Future<void> put<T>(String kay, T data, {Duration? maxAge}) =>
      HiveX.put(data: data, key: kay, maxAge: maxAge);

  static Future<void> remove(String kay) => HiveX.remove(kay);
}
