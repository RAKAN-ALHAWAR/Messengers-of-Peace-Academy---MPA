import 'package:flutter/material.dart';

extension ConvertExtensionX on dynamic {
  /// Converts a given value to an int if possible.
  /// If the conversion fails or the value is null, it returns the provided default value.
  ///
  /// [value] The value to be converted.
  /// [defaultValue] The default value to return if the conversion fails or the value is null.
  ///
  /// Returns the converted int value if successful, otherwise the default value.
  int get toIntX {
    try {
      if (this is int) {
        return this;
      }
      if (this is double || this is num) {
        return this.toInt();
      }
      if (this is bool ) {
        return this?1:0;
      }
      if (this is String) {
        String value = (this as String).trim();
        try {
          int? num = int.tryParse(value);
          if (num != null) {
            return num;
          } else if (double.tryParse(value) != null) {
            return double.tryParse(value)!.toInt();
          } else {
            throw Exception('Cannot parse to int');
          }
        } catch (e) {
          throw Exception('Invalid input for conversion to int');
        }
      }
      throw Exception('Unsupported type for conversion to int');
    } catch (e) {
      rethrow;
    }
  }


  String get arabicToEnglishNumbers{
    const arabicNumbers = '٠١٢٣٤٥٦٧٨٩';
    const englishNumbers = '0123456789';
    String result=this;
    for (int i = 0; i < arabicNumbers.length; i++) {
      result = result.replaceAll(arabicNumbers[i], englishNumbers[i]);
    }
    return result;
  }


  /// Converts a given value to an int if possible.
  /// If the conversion fails or the value is null, it returns the provided default value.
  ///
  /// [value] The value to be converted.
  /// [defaultValue] The default value to return if the conversion fails or the value is null.
  ///
  /// Returns the converted int value if successful, otherwise the default value.
  int toIntDefaultX(defaultValue) {
    if (this is int) {
      return this;
    }
    if (this is double || this is num) {
      return this.toInt();
    }
    if (this is bool) {
      return this?1:0;
    }
    if (this == null || this is Object) {
      return defaultValue;
    }
    if (this is String) {
      String value = this.trim();
      if (value.isEmpty) {
        return defaultValue;
      }
      try {
        return int.tryParse(this) ??
            double.tryParse(this)?.toInt() ??
            defaultValue;
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  /// Converts a given value to an int if possible.
  /// If the conversion fails or the value is null, it returns the provided default value.
  ///
  /// [value] The value to be converted.
  /// [defaultValue] The default value to return if the conversion fails or the value is null.
  ///
  /// Returns the converted int value if successful, otherwise the default value.
  int? get toIntNullableX {
    try {
      if (this == null) {
        return null;
      }
      if (this is int) {
        return this;
      }
      if (this is double || this is num) {
        return this.toInt();
      }
      if (this is bool) {
        return this?1:0;
      }
      if (this is String) {
        String value = this.trim();
        try {
          if (int.tryParse(value) != null) {
            return int.parse(value);
          } else if (double.tryParse(value) != null) {
            return double.tryParse(value)!.toInt();
          } else {
            return null;
          }
        } catch (e) {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<K, V> toMapX<K, V>() {
    try {
      // التحقق من أن الكائن الحالي هو Map
      if (this is Map) {
        final inputMap = this as Map;
        return inputMap.map((key, value) {
          // محاولة تحويل المفتاح إلى النوع K
          final newKey = key is K
              ? key
              : (K == String ? key.toString() : int.parse(key.toString())) as K;

          // محاولة تحويل القيمة إلى النوع V
          final newValue = value is V
              ? value
              : (V == String
              ? value.toString()
              : int.parse(value.toString())) as V;

          return MapEntry(newKey, newValue);
        });
      } else {
        throw Exception('Object is not a Map');
      }
    } catch (e) {
      throw Exception('Failed to convert to Map<$K, $V>: $e');
    }
  }

  /// يحاول إنشاء كائن من JSON باستخدام دالة `fromJson`
  /// يعيد الكائن إذا نجحت العملية، أو يعيد null إذا حدث خطأ.
  T? toFromJsonNullableX<T>(T Function(Map<String, dynamic>) fromJson) {
    if (this is Map<String, dynamic>) {
      try {
        return fromJson(this as Map<String, dynamic>);
      } catch (e) {
        // تجاهل الخطأ وأعد null
        return null;
      }
    }
    // إذا لم تكن البيانات من نوع Map، أعد null
    return null;
  }

  double get toDoubleX {
    try {
      if (this is double) {
        return this;
      }
      if (this is int || this is num) {
        return this+.0;
      }
      if (this is String) {
        String value = this.trim();
        try {
          if (double.tryParse(value) != null) {
            return double.parse(value);
          } else {
            throw Exception();
          }
        } catch (e) {
          throw Exception();
        }
      }
      throw Exception();
    } catch (e) {
      rethrow;
    }
  }

  double? get toDoubleNullableX{
    try {
      if (this == null) {
        return null;
      }
      if (this is double) {
        return this;
      }
      if (this is int || this is num) {
        return this+.0;
      }
      if (this is String) {
        String value = this.trim();
        try {
          if (double.tryParse(value) != null) {
            return double.parse(value);
          } else {
            return null;
          }
        } catch (e) {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  double toDoubleDefaultX(double defaultValue) {
    try {
      if (this is double) {
        return this;
      }
      if (this is int || this is num) {
        return this+.0;
      }
      if (this == null || this is Object) {
        return defaultValue;
      }
      if (this is String) {
        String value = this.trim();
        try {
          if (double.tryParse(value) != null) {
            return double.parse(value);
          } else {
            throw defaultValue;
          }
        } catch (e) {
          throw defaultValue;
        }
      }
      throw defaultValue;
    } catch (e) {
      rethrow;
    }
  }

  /// Converts a given value to a bool if possible.
  /// If the conversion fails or the value is null, it returns the provided default value.
  ///
  /// [value] The value to be converted.
  /// [defaultValue] The default value to return if the conversion fails or the value is null.
  ///
  /// Returns the converted bool value if successful, otherwise the default value.
  bool get toBoolX {
    try {
      if (this is bool) {
        return this;
      }
      if (this == null) {
        throw Exception();
      }

      String strValue = "$this".toLowerCase().trim();
      if (strValue == 'true' || strValue == "1" || strValue == "١") {
        return true;
      } else if (strValue == 'false' || strValue == "0" || strValue == "٠") {
        return false;
      }
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  /// Converts a given value to a bool if possible.
  /// If the conversion fails or the value is null, it returns the provided default value.
  ///
  /// [value] The value to be converted.
  /// [defaultValue] The default value to return if the conversion fails or the value is null.
  ///
  /// Returns the converted bool value if successful, otherwise the default value.
  bool toBoolDefaultX(defaultValue) {
    try {
      if (this is bool) {
        return this;
      }
      if (this == null) {
        return defaultValue;
      }

      String strValue = "$this".toLowerCase().trim();
      if (strValue == 'true' || strValue == "1" || strValue == "١") {
        return true;
      } else if (strValue == 'false' || strValue == "0" || strValue == "٠") {
        return false;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Converts a given value to a bool if possible.
  /// If the conversion fails or the value is null, it returns the provided default value.
  ///
  /// [value] The value to be converted.
  /// [defaultValue] The default value to return if the conversion fails or the value is null.
  ///
  /// Returns the converted bool value if successful, otherwise the default value.
  bool? get toBoolNullableX {
    try {
      if (this is bool) {
        return this;
      }
      if (this == null) {
        return null;
      }

      String strValue = "$this".toLowerCase().trim();
      if (strValue == 'true' || strValue == "1" || strValue == "١") {
        return true;
      } else if (strValue == 'false' || strValue == "0" || strValue == "٠") {
        return false;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Converts a given value to a String.
  /// If the value is null, it returns the provided default value.
  ///
  /// [value] The value to be converted.
  /// [defaultValue] The default value to return if the value is null.
  ///
  /// Returns the converted String value.
  String get toStrX {
    if (this is String) {
      return this.trim();
    } else if (this == null) {
      throw Exception();
    } else {
      return "$this".trim();
    }
  }

  /// Converts a given value to a String.
  /// If the value is null, it returns the provided default value.
  ///
  /// [value] The value to be converted.
  /// [defaultValue] The default value to return if the value is null.
  ///
  /// Returns the converted String value.
  String toStrDefaultX(String defaultValue) {
    if (this is String) {
      return this.trim();
    } else if (this == null) {
      return defaultValue;
    } else {
      return "$this".trim();
    }
  }

  /// Converts a given value to a String.
  /// If the value is null, it returns the provided default value.
  ///
  /// [value] The value to be converted.
  /// [defaultValue] The default value to return if the value is null.
  ///
  /// Returns the converted String value.
  String? get toStrNullableX {
    if (this == null) {
      return null;
    } else if (this is String) {
      return this.trim();
    } else {
      return "$this".trim();
    }
  }


  DateTime get toDateTimeX{
    try {
      if (this == null) {
        throw Exception();
      }
      if (this is DateTime) {
        return this as DateTime;
      }
      if (this is String) {
        String value = (this as String).trim();
        try {
          var x = DateTime.tryParse(value);
          if(x!=null){
            return x;
          }
          throw Exception();
        } catch (e) {
          rethrow;
        }
      }
      if (this is int) {
        try {
          return DateTime.fromMillisecondsSinceEpoch(this as int);
        } catch (e) {
          rethrow;
        }
      }
      if (this is double) {
        try {
          return DateTime.fromMillisecondsSinceEpoch((this as double).toInt());
        } catch (e) {
          throw Exception();
        }
      }
      if (this is TimeOfDay) {
        final now = DateTime.now();
        final timeOfDay = this as TimeOfDay;
        return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
      }
      throw Exception();
    } catch (e) {
      rethrow;
    }
  }
  DateTime? get toDateTimeNullableX {
    try {
      if (this == null) {
        return null;
      }
      if (this is DateTime) {
        return this as DateTime;
      }
      if (this is String) {
        String value = (this as String).trim();
        try {
          return DateTime.tryParse(value);
        } catch (e) {
          return null;
        }
      }
      if (this is int) {
        try {
          return DateTime.fromMillisecondsSinceEpoch(this as int);
        } catch (e) {
          return null;
        }
      }
      if (this is double) {
        try {
          return DateTime.fromMillisecondsSinceEpoch((this as double).toInt());
        } catch (e) {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  TimeOfDay get toTimeOfDayX {
    try {
      if (this == null) {
        throw Exception('Value is null');
      }
      if (this is TimeOfDay) {
        return this as TimeOfDay;
      }
      if (this is String) {
        String value = (this as String).trim();
        try {
          final parts = value.split(':');
          if (parts.length != 2) {
            throw Exception('Invalid time format');
          }
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return TimeOfDay(hour: hour, minute: minute);
        } catch (e) {
          rethrow;
        }
      }
      throw Exception('Unsupported type for TimeOfDay conversion');
    } catch (e) {
      rethrow;
    }
  }

  TimeOfDay? get toTimeOfDayNullableX {
    try {
      if (this == null) {
        return null;
      }
      if (this is TimeOfDay) {
        return this as TimeOfDay;
      }
      if (this is String) {
        String value = (this as String).trim();
        try {
          final parts = value.split(':');
          if (parts.length != 2) {
            return null;
          }
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return TimeOfDay(hour: hour, minute: minute);
        } catch (e) {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
