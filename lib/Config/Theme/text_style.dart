part of '../config.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// إدارة أنماط النصوص وأحجامها وفقًا لتصميم Material 3
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class TextStyleX {
  /// Display - للعناوين الكبيرة والمميزة
  static TextStyle displayLarge = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 57.0,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: -0.25,
  );

  static TextStyle displayMedium = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 45.0,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0.15,
  );

  static TextStyle displaySmall = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 36.0,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.15,
  );

  /// Headline - للعناوين الرئيسية
  static TextStyle headlineLarge = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 32.0,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0.15,
  );

  static TextStyle headlineMedium = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 28.0,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0.15,
  );

  static TextStyle headlineSmall = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 24.0,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.15,
  );

  static TextStyle titleSLarge = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
  );

  /// Title - للعناوين الفرعية
  static TextStyle titleLarge = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 22.0,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0.15,
  );

  static TextStyle titleMedium = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 16.0,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0.15,
  );

  static TextStyle titleSmall = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14.0,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0.1,
  );

  /// Label - للتسميات والأزرار
  static TextStyle labelLargeProminent = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14.0,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0.15,
  );

  static TextStyle labelLarge = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14.0,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.15,
  );

  static TextStyle labelMediumProminent = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 12.0,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0.15,
  );

  static TextStyle labelMedium = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 12.0,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.15,
  );

  static TextStyle labelSmall = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 11.0,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.15,
  );

  /// Body - للنصوص الأساسية
  static TextStyle bodyLarge = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 16.0,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.15,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14.0,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.15,
  );

  static TextStyle bodySmall = const TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 12.0,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.15,
  );
}
