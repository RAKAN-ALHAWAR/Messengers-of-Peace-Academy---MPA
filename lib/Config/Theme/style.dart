part of '../config.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Manage all application styles from one place
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class StyleX {
  /// Radius
  static const double radiusSm = 4.0;
  static const double radius = 10.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXLg = 32.0;

  /// Blur
  static const double blur = 20.0;

  /// Height
  static const double buttonHeightSm = 35.0;
  static const double buttonHeight = 40.0;
  static const double cardHeight = 50.0;
  static const double inputHeight = 56.0;
  static const double accordionHeight = 60.0;

  /// Nav bar
  static const double navBarHeight = 74.0;
  static const double navBarIconSize = 30.0;

  /// App bar
  static const double appBarHeight = 80.0;
  static const double radiusAppBar = 30.0;
  static const double appBarPaddingTop = 90.0;

  /// Padding
  static const EdgeInsets paddingApp = EdgeInsets.symmetric(
    horizontal: hPaddingApp,
    vertical: vPaddingApp,
  );
  static const double hPaddingApp = 16.0;
  static const double vPaddingApp = 20.0;
  static const double bottomSheetPadding = 20.0;
  static const double paddingHeaderWeb = 80.0;

  /// Size
  static const double floatingActionButton = 60.0;

  /// Border
  static const double borderWidth = 1;

  /// Times
  static const int successButtonSecond = 1;
  static const int returnButtonToNormalStateSecond = 2;
  static const int toastSecond = 4;
}
