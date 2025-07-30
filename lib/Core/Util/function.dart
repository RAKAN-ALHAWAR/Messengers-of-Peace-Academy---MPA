part of '../core.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this Util }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Generic functions that can be used across the entire project
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class FunctionX {
  /// Separating connected words like: SakerDakak -> Saker Dakak
  static String addSpaceBeforeUpperCase(String val) {
    return val[0] +
        val.substring(1).replaceAllMapped(RegExp(r'([A-Z])'), (match) {
          return ' ${match.group(1)}';
        });
  }

  /// Time format like: 80 -> 1:20
  static String formatTime(int val) {
    return '${(val ~/ 60).toString().padLeft(2, '0')}:${(val % 60).toString().padLeft(2, '0')}';
  }

  /// Large number format like: 1000 -> 1,000
  static String formatLargeNumber(num val, {int decimal = 0}) {
    intl.NumberFormat formatter = intl.NumberFormat.decimalPatternDigits(
      locale: 'en_us',
      decimalDigits: decimal,
    );
    return formatter.format(val);
  }

  /// Format duration for timer
  static String formatDuration(Duration d) {
    int hours = d.inHours;
    int minutes = d.inMinutes.remainder(60);
    int seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return "$hours ${"h".tr} $minutes ${"m".tr} $seconds ${"s".tr}";
    } else {
      return "$minutes ${"m".tr} $seconds ${"s".tr}";
    }
  }

  /// Extract the country code and phone number
  /// like: +963994343927 -> [ 963 , 994343927 ]
  static (String, int?) extractCountryCodeAndPhoneNumber(String number) {
    // Remove all spaces
    number = number.replaceAll(" ", '');
    number = number.replaceAll("-", '');

    // Remove any leading '+' or '00'
    number = number.replaceAll(RegExp(r'^(\+|00)'), '');

    // Check if the number contains a country code
    if (number.length > 10) {
      int? countryCode;
      String x = number.substring(0, number.length - 9);
      if (x.length == 3 || x.length == 2) {
        countryCode = int.parse(x);
      }
      String phoneNumber = number.substring(number.length - 9);

      return (phoneNumber, countryCode);
    } else {
      return (number, null);
    }
  }

  static (String, String) formatFileSize(int bytes) {
    const int kb = 1024;
    const int mb = kb * 1024;

    if (bytes >= mb) {
      return ((bytes / mb).toStringAsFixed(2), 'MB');
    } else if (bytes >= kb) {
      return ((bytes / kb).toStringAsFixed(2), 'KB');
    } else {
      return (bytes.toString(), 'Bytes');
    }
  }

  static bool isImage(String type) {
    final imageExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'heic',
    ];
    return imageExtensions.contains(type);
  }
}
