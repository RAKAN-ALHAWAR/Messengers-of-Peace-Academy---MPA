part of '../core.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this Helper }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Fixed permissions to retrieve images from the Internet in some cases
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class HttpOverridesHelperX extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
