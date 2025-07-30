part of '../config.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Manage all application colors and color tones
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ColorX {
  /// Light
  static Color primary = const Color(0xff006B5F);
  static Color onPrimary = const Color(0xff9EF2E3);
  static Color secondary = const Color(0xff4E635E);
  static Color onSecondary = const Color(0xffFFFFFF);
  static Color secondaryContainer = const Color(0xffCCE8E2);
  static Color onSecondaryContainer = const Color(0xff9EF2E3);
  static Color text = const Color(0xff171D1E);
  static Color onSurfaceVariant = const Color(0xff3F484A);
  static Color inverseOnSurface = const Color(0xffECF2F3);
  static Color surfaceVariant = const Color(0xffDBE4E6);
  static Color surfaceContainerLow = const Color(0xffEFF5F6);
  static Color surfaceContainerLowest = const Color(0xffFFFFFF);
  static Color success = const Color(0xff2D6A45);
  static Color onSuccess = const Color(0xffD8F3E9);
  static Color danger = const Color(0xffBA1A1A);
  static Color onDanger = const Color(0xffFFDAD6);
  static Color background = const Color(0xffF5FAFB);
  static Color successContainer = const Color(0xffB0F1C2);

  /// Dark
  static Color primaryDark = const Color(0xff82D5C7);
  static Color onPrimaryDark = const Color(0xff003731);
  static Color secondaryDark = const Color(0xffB1CCC6);
  static Color onSecondaryDark = const Color(0xff1C3530);
  static Color secondaryContainerDark = const Color(0xff334B47);
  static Color onSecondaryContainerDark = const Color(0xffCCE8E2);
  static Color textDark = const Color(0xffDEE3E5);
  static Color onSurfaceVariantDark = const Color(0xffBFC8CA);
  static Color inverseOnSurfaceDark = const Color(0xff2B3133);
  static Color surfaceVariantDark = const Color(0xff3F484A);
  static Color surfaceContainerLowDark = const Color(0xff171D1E);
  static Color surfaceContainerLowestDark = const Color(0xff090F10);
  static Color textGreyDark = const Color(0xffBFC8CA);
  static Color successDark = const Color(0xff95D5A7);
  static Color onSuccessDark = const Color(0xff10512F);
  static Color dangerDark = const Color(0xffFFB4AB);
  static Color onDangerDark = const Color(0xff93000A);
  static Color backgroundDark = const Color(0xff0E1415);
  static Color successContainerDark = const Color(0xff10512F);

  static Color check = const Color(0xff89C3AA);

  /// Grey
  static const MaterialColor grey = MaterialColor(0xff6F797A, {
    50: Color(0xffF9FAFB),
    100: Color(0xffF3F4F6),
    200: Color(0xffE5E7EB),
    300: Color(0xffECF2F3), //
    400: Color(0xffBFC8CA), //
    500: Color(0xff6F797A), //
    600: Color(0xffBFC8CA),
    700: Color(0xff374151),
    800: Color(0xff252631),
    900: Color(0xFF111928),
  });

  /// Yellow
  static const MaterialColor yellow = MaterialColor(0xffFDA712, {
    50: Color(0xffF9FAFB),
    100: Color(0xffFEF4E1), //
    200: Color(0xffE5E7EB),
    300: Color(0xffECF2F3),
    400: Color(0xffFFBF38), //
    500: Color(0xffFDA712), //
    600: Color(0xffF79009), //
    700: Color(0xffFFDDB6), // Extended Colors/Yellow Container
    800: Color(0xff252631),
    900: Color(0xFF442106), //
  });

  /// Gradients
  static LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xff00A392), Color(0xff0A655E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static LinearGradient primaryGradient2 = LinearGradient(
    colors: [Color(0xff47CD89), Color(0xff067647)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Gradients
  static LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xffFDDF86), Color(0xffFDC348)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient gold2Gradient = LinearGradient(
    colors: [Color(0xffFFFFFF), Color(0xffFFFAEB)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
}
