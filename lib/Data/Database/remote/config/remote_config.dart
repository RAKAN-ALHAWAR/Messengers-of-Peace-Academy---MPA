import '../../../../Config/Translation/translation.dart';
import '../../../Enum/transmission_method_status.dart';

class RemoteConfigX {
  static String version = 'v1';
  // Http header
  static String contentType = 'application/x-www-form-urlencoded';
  static String accept = 'application/json';
  static String authType = 'Bearer';
  static String get languageCode => TranslationX.getLanguageCode;

  // Connection
  static int maxRetries = 1;
  static Duration timeout = const Duration(seconds: 30);

  static TransmissionMethodStatusX languageMethod =
      TransmissionMethodStatusX.headers;
  static TransmissionMethodStatusX apiVersionMethod =
      TransmissionMethodStatusX.headers;
}
