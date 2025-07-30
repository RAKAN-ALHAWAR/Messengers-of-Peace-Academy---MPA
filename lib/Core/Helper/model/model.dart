import '../../Error/error.dart';

class ModelUtilX {
  static T checkFromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, Object?>) fromJson, {
    List<String> requiredDataKeys = const [],
    List<List<String>> requiredAnyDataOfKeys = const [],
  }) {
    try {
      _checkRequiredDataKeys(json, requiredDataKeys);
      _checkRequiredAnyOfKeys(json, requiredAnyDataOfKeys);
      return fromJson(Map<String, Object?>.from(json));
    } on ErrorX catch (e, stackTrace) {
      e.stackTrace = stackTrace;
      rethrow;
    } catch (e, stackTrace) {
      return throw ErrorX.createErrorByCode(
        ErrorCodesX.modelToJsonConversionFailed,
        stackTrace: stackTrace,
        details: json,
        originalError: e.toString(),
      );
    }
  }

  static List<T> generateItems<T>(
      List<dynamic>? jsonData, T Function(Map<String, dynamic>) fromJson) {
    List<T> items = [];

    for (Map json in jsonData ?? []) {
      try {
        T item = fromJson(Map<String, dynamic>.from(json));
        items.add(item);
      } catch (e,stackTrace) {
        var x =e.toErrorX;
        x.stackTrace=stackTrace;
        x.log();
      }
    }

    return items;
  }

  /// Check if data for mandatory fields is available
  static void _checkRequiredDataKeys(Map<String, dynamic> json, List<String> keys) {
    for (String key in keys) {
      if (!containsKey(json, key)) {
        throw ErrorX.createErrorByCode(
          ErrorCodesX.missingRequiredKeysInJson,
          details: {"Missing key": key},
        );
      }
    }
  }

  /// Check if at least one key in each group is non-empty
  static void _checkRequiredAnyOfKeys(
      Map<String, dynamic> json, List<List<String>> requiredAnyOfKeysGroups) {
    for (List<String> group in requiredAnyOfKeysGroups) {
      bool hasAtLeastOne = false;

      for (String key in group) {
        if (containsKey(json, key)) {
          hasAtLeastOne = true;
          break; // We found at least one non-empty key, no need to check further in this group
        }
      }

      // If none of the keys in the group are non-empty, throw an error
      if (!hasAtLeastOne) {
        throw ErrorX.createErrorByCode(
          ErrorCodesX.missingRequiredKeysInJson,
          details: {"Missing one of keys in group": group.join(", ")},
        );
      }
    }
  }

  /// Checks if a given key exists in a nested map structure.
  ///
  /// This function traverses a nested map structure and checks if the specified key exists at any level.
  ///
  /// [map] The map to search within.
  /// [key] The key to search for.
  ///
  /// Returns `true` if the key is found, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// Map<String, dynamic> json = {
  ///   "level1": {
  ///     "level2": {
  ///       "targetKey": "value"
  ///     }
  ///   }
  /// };
  ///
  /// bool exists = containsKey(json, "targetKey"); // returns true
  /// ```
  /// -----------------------------------------------------------------------
  /// يتحقق مما إذا كان مفتاح معين موجود في بنية خريطة متداخلة.
  ///
  /// تقوم هذه الدالة بعبور بنية خريطة متداخلة وتتحقق مما إذا كان المفتاح المحدد موجودًا في أي مستوى.
  ///
  /// [map] الخريطة التي سيتم البحث داخلها.
  /// [key] المفتاح الذي سيتم البحث عنه.
  ///
  /// تُرجع `true` إذا تم العثور على المفتاح، و `false` خلاف ذلك.
  ///
  /// مثال:
  /// ```dart
  /// Map<String, dynamic> json = {
  ///   "level1": {
  ///     "level2": {
  ///       "targetKey": "value"
  ///     }
  ///   }
  /// };
  ///
  /// bool exists = containsKey(json, "targetKey"); // returns true
  /// ```
  static bool containsKey(Map<String, dynamic> map, String key) {
    for (var entry in map.entries) {
      if (entry.key == key) {
        return true;
      }
      if (entry.value is Map) {
        bool found = containsKey(Map<String,dynamic>.from(entry.value), key);
        if (found) {
          return true;
        }
      }
    }
    return false;
  }

  static T getNestedValue<T>(
      Map<String, dynamic> json, String key, T defaultValue) {
    for (var entry in json.entries) {
      if (entry.key == key) {
        return entry.value;
      }
      if (entry.value is Map<String, dynamic>) {
        T? found = getNestedValue(entry.value, key, defaultValue);
        if (found != null) {
          return found;
        }
      }
    }
    return defaultValue;
  }
}
