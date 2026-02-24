import 'package:flutter/material.dart';
class SmartArabicTextStyle {
  /// Creates a responsive Arabic text style
  static TextStyle create({
    required BuildContext context,
    double baseSize = 16.0,
    bool autoScale = true,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
    String? fontFamily,
    double? height,
    FontStyle? fontStyle,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;
    // Get responsive font size
    double fontSize = _getResponsiveFontSize(context, baseSize);
    // Apply text scaling (user's preferred font size from device settings)
    if (autoScale) {
      fontSize = textScaler.scale(fontSize);
    }

    // Adjust for Arabic readability
    fontSize = _adjustForArabic(fontSize, mediaQuery);

    return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily ?? _getArabicFontFamily(),
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.7, // Optimal for Arabic script (default)
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  /// Creates multiple pre-defined Arabic text styles
  static TextStyle headingLarge(BuildContext context, {Color color = Colors.black}) {
    return create(
      context: context,
      baseSize: 32.0,
      color: color,
      fontWeight: FontWeight.bold,
      height: 1.5,
    );
  }

  static TextStyle headingMedium(BuildContext context, {Color color = Colors.black}) {
    return create(
      context: context,
      baseSize: 24.0,
      color: color,
      fontWeight: FontWeight.w600,
      height: 1.6,
    );
  }

  static TextStyle headingSmall(BuildContext context, {Color color = Colors.black}) {
    return create(
      context: context,
      baseSize: 20.0,
      color: color,
      fontWeight: FontWeight.w500,
      height: 1.7,
    );
  }

  static TextStyle bodyLarge(BuildContext context, {Color color = Colors.black}) {
    return create(
      context: context,
      baseSize: 18.0,
      color: color,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle bodyMedium(BuildContext context, {Color color = Colors.black}) {
    return create(
      context: context,
      baseSize: 16.0,
      color: color,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle bodySmall(BuildContext context, {Color color = Colors.black}) {
    return create(
      context: context,
      baseSize: 14.0,
      color: color,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle caption(BuildContext context, {Color color = Colors.grey}) {
    return create(
      context: context,
      baseSize: 12.0,
      color: color,
      fontWeight: FontWeight.normal,
      height: 1.6,
    );
  }

  /// Creates a responsive Arabic text style with custom parameters
  static TextStyle custom({
    required BuildContext context,
    double baseSize = 16.0,
    bool autoScale = true,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
    String? fontFamily,
    double? height,
    double? letterSpacing,
  }) {
    return create(
      context: context,
      baseSize: baseSize,
      autoScale: autoScale,
      color: color,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Private helper methods
  static double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;

    if (width < 320) return baseSize * 0.8;  // Very small devices
    if (width < 360) return baseSize * 0.9;  // Small phones
    if (width < 400) return baseSize;        // Normal phones
    if (width < 600) return baseSize * 1.1;  // Large phones
    if (width < 800) return baseSize * 1.2;  // Small tablets
    return baseSize * 1.3;                   // Large tablets/desktop
  }

  static double _adjustForArabic(double fontSize, MediaQueryData mediaQuery) {
    // Arabic text often benefits from slightly larger sizes for readability
    double adjustedSize = fontSize * 1.05;

    // But not too large on small screens
    if (mediaQuery.size.width < 360) {
      adjustedSize = fontSize * 0.95;
    }

    return adjustedSize;
  }

  static String _getArabicFontFamily() {
    // Try different Arabic fonts, fallback to system
    // You can customize this based on your app's fonts
    return 'NotoKufiArabic'; // Example Arabic font
  }

  /// Extension method to easily apply Arabic style to any TextStyle
  static TextStyle applyArabicStyle({
    required TextStyle baseStyle,
    required BuildContext context,
    bool autoScale = true,
    double arabicMultiplier = 1.05,
  }) {
    double fontSize = baseStyle.fontSize ?? 16.0;

    if (autoScale) {
      fontSize = MediaQuery.of(context).textScaler.scale(fontSize);
    }

    // Apply Arabic adjustment
    final mediaQuery = MediaQuery.of(context);
    double adjustedSize = fontSize * arabicMultiplier;

    if (mediaQuery.size.width < 360) {
      adjustedSize = fontSize * 0.95;
    }

    return baseStyle.copyWith(
      fontSize: adjustedSize,
      fontFamily: _getArabicFontFamily(),
      height: baseStyle.height ?? 1.7,
    );
  }
}