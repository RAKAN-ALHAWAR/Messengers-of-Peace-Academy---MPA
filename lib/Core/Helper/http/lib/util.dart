part of '../http.dart';

class HttpUtilX {
  /// Function to check URL validity
  static void validateUrl(String url) {
    if (url.isEmpty ||
        !(Uri.tryParse(url)?.isAbsolute ?? false) ||
        !(Uri.tryParse(url)?.hasAbsolutePath ?? false)) {
      throw ErrorX.createErrorByCode(
        ErrorCodesX.invalidURL,
        details: {"URL": url},
      );
    }
  }

  /// Function to check internet connection
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(HttpX._internetCheckUrl);
      var res = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      return res;
    } catch (_) {
      return false;
    }
  }
}
