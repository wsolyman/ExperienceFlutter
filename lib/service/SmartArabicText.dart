import 'package:flutter/material.dart';
class SmartArabicText extends StatelessWidget {
  final String text;
  final double baseSize;
  final bool autoScale;
  final int? maxLines;
  final TextAlign textAlign;
  final Color color;
  final FontWeight fontWeight;

  const SmartArabicText({
    Key? key,
    required this.text,
    this.baseSize = 16.0,
    this.autoScale = true,
    this.maxLines,
    this.textAlign = TextAlign.right,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: _getArabicFontFamily(),
        fontWeight: fontWeight,
        color: color,
        height: 1.7, // Optimal for Arabic script
      ),
      textDirection: TextDirection.rtl,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      locale: const Locale('ar'), // Set Arabic locale
    );
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;

    if (width < 320) return baseSize * 0.8;  // Very small devices
    if (width < 360) return baseSize * 0.9;  // Small phones
    if (width < 400) return baseSize;        // Normal phones
    if (width < 600) return baseSize * 1.1;  // Large phones
    if (width < 800) return baseSize * 1.2;  // Small tablets
    return baseSize * 1.3;                   // Large tablets/desktop
  }

  double _adjustForArabic(double fontSize, MediaQueryData mediaQuery) {
    // Arabic text often benefits from slightly larger sizes for readability
    double adjustedSize = fontSize * 1.05;

    // But not too large on small screens
    if (mediaQuery.size.width < 360) {
      adjustedSize = fontSize * 0.95;
    }

    return adjustedSize;
  }

  String _getArabicFontFamily() {
    // Try different Arabic fonts, fallback to system
    return 'NotoKufiArabic';
  }
}