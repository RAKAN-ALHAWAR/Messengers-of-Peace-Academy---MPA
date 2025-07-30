part of '../core.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this Helper }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Configure application state and properties
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ConfigAppHelperX{
   /// Control the color of the phone's status bar
  static statusBarColor(Color color) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: color,
    ));
  }

  /// Select application directions available
  static deviceOrientation({bool up = true, bool down = true}) {
    SystemChrome.setPreferredOrientations([
      up ? DeviceOrientation.portraitUp : DeviceOrientation.portraitDown,
      down ? DeviceOrientation.portraitDown : DeviceOrientation.portraitUp,
    ]);
  }
}