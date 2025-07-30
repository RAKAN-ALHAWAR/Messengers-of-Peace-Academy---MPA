part of '../core.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this Helper }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Color conversion processes
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ColorHelperX {
  /// Convert a color to a list of gradient colors from light to dark
  static MaterialColor toMaterial(Color color) {
    List strengths = <double>[.05];
    List dss = <double>[1];
    Map<int, Color> swatch = {};
    final int r = color.r.toInt(), g = color.g.toInt(), b = color.b.toInt();

    for (int i = 1, j = 10; i < 10; i++, j--) {
      strengths.add(0.1 * i);
      dss.add(0.1 * j);
    }
    for (int i = 0; i < strengths.length; i++) {
      final double ds = dss[i] - strengths[i];
      swatch[(strengths[i] * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }
}
