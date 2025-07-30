part of '../config.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Managing the day and night theme for the entire application
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ThemeX {
  //============================================================================
  // Functions
  static ThemeMode get getTheme =>
      isDarkMode ? ThemeMode.dark : ThemeMode.light;

  static bool get isDarkMode => LocalDataX.themeIsDark;

  static change(bool val) =>
      Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);

  //============================================================================
  // Data

  /// Light Theme
  static ThemeData light = ThemeData.light(useMaterial3: true).copyWith(
    /// Fonts
    textTheme: ThemeData.light().textTheme.apply(
      fontFamily: 'IBMPlexSansArabic',
      bodyColor: ColorX.text,
      decorationColor: ColorX.text,
      displayColor: ColorX.text,
    ),

    /// Text
    hintColor: ColorX.onSurfaceVariant,

    /// Primary Color
    primaryColor: ColorX.primary,
    // Darker variant of the primary color
    primaryColorDark: ColorX.primaryDark,
    // Lighter variant of the primary color
    primaryColorLight: ColorX.onPrimary,

    /// Background Color
    canvasColor: ColorX.background,
    // Background color for larger parts of the app
    scaffoldBackgroundColor: ColorX.background,

    /// Widgets
    cardColor: ColorX.surfaceContainerLowest,
    dividerColor: ColorX.grey.shade300,
    unselectedWidgetColor: ColorX.grey.shade300,
    disabledColor: ColorX.grey.shade300,

    /// Effect Color
    highlightColor: ColorX.onPrimary,
    // The color of the circle that selects the clicked item
    splashColor: ColorX.onPrimary,

    // The color of the flashing effect when you click on an item
    colorScheme: ColorScheme.fromSeed(
      // Determines if the theme is light or dark
      brightness: Brightness.light,
      primary: ColorX.primary,
      onPrimary: ColorX.onPrimary,
      seedColor: ColorX.primary,
      secondary: ColorX.secondary,
      onSecondary: ColorX.onSecondary,
      secondaryContainer: ColorX.secondaryContainer,
      onSecondaryContainer: ColorX.onSecondaryContainer,
      error: ColorX.danger,
      surfaceContainerHighest: ColorX.surfaceVariant,
      onSurfaceVariant: ColorX.onSurfaceVariant,
      onError: ColorX.onDanger,
      outline: ColorX.grey.shade300,
      surfaceContainerLow: ColorX.surfaceContainerLow,
      surfaceContainerLowest: ColorX.surfaceContainerLowest,
      onInverseSurface: ColorX.inverseOnSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    cardTheme: CardTheme(color: ColorX.surfaceContainerLowest),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ColorX.surfaceContainerLowest,
      indicatorColor: ColorX.secondaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
        return IconThemeData(color: ColorX.onSurfaceVariant, size: 26);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        return TextStyle(
          fontSize: 12.1,
          color: ColorX.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        );
      }),
    ),
  );

  //=============================================================

  static ThemeData dark = ThemeData.dark(useMaterial3: true).copyWith(
    /// Fonts
    textTheme: ThemeData.dark().textTheme.apply(
      fontFamily: 'IBMPlexSansArabic',
      bodyColor: ColorX.textDark,
      decorationColor: ColorX.textDark,
      displayColor: ColorX.textDark,
    ),

    /// Text
    hintColor: ColorX.grey.shade500,

    /// Primary Color
    // Primary color for major parts of the app (toolbars, tab bars, etc.)
    primaryColor: ColorX.primaryDark,
    // Darker variant of the primary color
    primaryColorDark: ColorX.primaryDark,
    // Lighter variant of the primary color
    primaryColorLight: ColorX.onPrimary,

    /// Background Color
    canvasColor: ColorX.backgroundDark,
    // Background color for larger parts of the app
    scaffoldBackgroundColor: ColorX.backgroundDark,

    /// Widgets
    cardColor: ColorX.surfaceContainerLowestDark,
    dividerColor: ColorX.grey.shade700,
    unselectedWidgetColor: ColorX.grey.shade500,
    disabledColor: ColorX.grey.shade600,

    /// Effect Color
    highlightColor: ColorX.onPrimaryDark,
    // The color of the circle that selects the clicked item
    splashColor: ColorX.onPrimaryDark,

    // The color of the flashing effect when you click on an item
    colorScheme: ColorScheme.fromSeed(
      // Determines if the theme is light or dark
      brightness: Brightness.dark,
      primary: ColorX.primaryDark,
      onPrimary: ColorX.onPrimaryDark,
      seedColor: ColorX.primaryDark,
      secondary: ColorX.secondaryDark,
      onSecondary: ColorX.onSecondaryDark,
      secondaryContainer: ColorX.secondaryContainerDark,
      onSecondaryContainer: ColorX.onSecondaryContainerDark,
      surfaceContainerHighest: ColorX.surfaceVariantDark,
      onSurfaceVariant: ColorX.onSurfaceVariantDark,
      error: ColorX.dangerDark,
      onError: ColorX.onDangerDark,
      surfaceContainerLow: ColorX.surfaceContainerLowDark,
      surfaceContainerLowest: ColorX.surfaceContainerLowestDark,
      onInverseSurface: ColorX.inverseOnSurfaceDark,
    ),
    cardTheme: CardTheme(color: ColorX.surfaceContainerLowestDark),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ColorX.grey.shade900,
      surfaceTintColor: ColorX.grey.shade900,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ColorX.surfaceContainerLowestDark,
      indicatorColor: ColorX.secondaryContainerDark,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
        return IconThemeData(color: ColorX.onSurfaceVariantDark, size: 26);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        return TextStyle(
          fontSize: 12.1,
          color: ColorX.onSurfaceVariantDark,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        );
      }),
    ),
  );
}
