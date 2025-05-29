import 'package:flutter/material.dart';

FontWeight checkWeight(String weight) {
  switch (weight) {
    case '500':
      return FontWeight.w500;
    case '600':
      return FontWeight.w600;
    case '700':
      return FontWeight.w700;
    default:
      return FontWeight.w400;
  }
}

double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 600) {
    return baseFontSize;
  } else {
    return baseFontSize * 0.80;
  }
}

TextStyle grotesk(double fontSize, double height,
    {BuildContext? context,
    String fontWeight = '400',
    Color? color,
    String? fontFamily,
    double? letterSpacing,
    bool hasUnderLine = false}) {
  return TextStyle(
      fontSize: context != null
          ? _getResponsiveFontSize(context, fontSize)
          : fontSize,
      letterSpacing: letterSpacing,
      height: height / fontSize,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.bodyLarge?.color
              : null),
      fontWeight: checkWeight(fontWeight),
      decoration: hasUnderLine ? TextDecoration.underline : TextDecoration.none,
      fontFamily: fontFamily ?? 'Montserrat');
}

TextStyle header(
    {BuildContext? context,
    String fontWeight = '700',
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(context != null ? _getResponsiveFontSize(context, 38) : 38, 44,
      context: context,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.displayLarge?.color
              : null));
}

TextStyle title1(
    {BuildContext? context,
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(context != null ? _getResponsiveFontSize(context, 32) : 32, 40,
      context: context,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.headlineLarge?.color
              : null));
}

TextStyle title2(
    {BuildContext? context,
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(context != null ? _getResponsiveFontSize(context, 29) : 29, 40,
      context: context,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.headlineMedium?.color
              : null));
}

TextStyle title3(
    {BuildContext? context,
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(25, 30,
      context: context,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.headlineSmall?.color
              : null));
}

TextStyle title4(
    {BuildContext? context,
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(19, 24,
      context: context,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.titleLarge?.color
              : null));
}

TextStyle headline(
    {BuildContext? context,
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(17, 22,
      context: context,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.titleMedium?.color
              : null));
}

TextStyle body(
    {BuildContext? context,
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(17, 24,
      context: context,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.bodyMedium?.color
              : null));
}

TextStyle callout(
    {BuildContext? context,
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(17, 24,
      context: context,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.bodyMedium?.color
              : null));
}

TextStyle subhead(
    {BuildContext? context,
    String fontWeight = '500',
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(15, 20,
      context: context,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.bodySmall?.color
              : null));
}

TextStyle footnote(
    {BuildContext? context,
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(14, 18,
      context: context,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.bodySmall?.color
              : null));
}

TextStyle caption1(
    {BuildContext? context,
    String fontWeight = '400',
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(15, 16,
      context: context,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.bodySmall?.color
              : null));
}

TextStyle caption2(
    {BuildContext? context,
    String fontWeight = '400',
    bool hasUnderLine = false,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    Color? color}) {
  return grotesk(11, 13,
      context: context,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color ??
          (context != null
              ? Theme.of(context).textTheme.bodySmall?.color
              : null));
}
