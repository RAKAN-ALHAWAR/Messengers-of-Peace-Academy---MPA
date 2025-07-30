part of '../core.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this Helper }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Capturing application errors in the development and production stages
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class CatchErrorX{
  /// Restructure the error message
  static console(error){
    FlutterError.reportError(FlutterErrorDetails(exception: error,library: 'Saker Dakak'));
  }

  /// Change the appearance of the default error screen
  // static systemCrash(){
  //   ErrorWidget.builder=(FlutterErrorDetails error){
  //     return SystemCrashView(error: error);
  //   };
  // }

}