part of '../../data.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Data storage and management via Hive technology
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class HiveX {
  //============================================================================
  // Variables

  static late Box box;
  static const String _boxName = 'app';

  //============================================================================
  // Functions

  static init() async {
    try {
      /// The web does not require configuration, only in the case of the phone
      Directory path = await getApplicationDocumentsDirectory();
      Hive.init(path.path);
      box = await Hive.openBox(_boxName);
    } catch (e) {
      rethrow;
    }
  }

  static T? get<T>(String key, [T? defaultValue]) {
    try {
      var data = box.get(key);
      if (data != null) {
        if (data is Map && data['value'] != null) {
          var expiry = data['expiry'];
          if (expiry != null &&
              DateTime.now().isAfter(DateTime.parse(expiry))) {
            remove(key);
            return defaultValue;
          }
          return data['value'] as T;
        } else {
          return data;
        }
      }
      return defaultValue;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> put<T>({
    required T data,
    required String key,
    Duration? maxAge,
  }) async {
    LocalDataX.identityChanged(key);
    try {
      var expiry =
          maxAge != null ? DateTime.now().add(maxAge).toIso8601String() : null;
      await box.put(key, {'value': data, 'expiry': expiry});
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> remove(String key) async {
    LocalDataX.identityChanged(key);
    try {
      await box.delete(key);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeAll() async {
    LocalDataX.identityChanged();
    try {
      await box.clear();
    } catch (e) {
      rethrow;
    }
  }
}
