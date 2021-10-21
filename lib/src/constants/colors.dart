import 'package:flutter/material.dart';

const Color lightThemeColor = Color(0xFFF2F2F2);
const Color darkThemeColor = Color(0xFF3A3A3A);
Color clayContainerColor(BuildContext context) {
  if (Theme.of(context).primaryColor == Colors.blue) {
    return lightThemeColor;
  }
  // return getInvertedColor(lightThemeColor);
  return darkThemeColor;
}

Color clayContainerTextColor(BuildContext context) {
  if (Theme.of(context).primaryColor == Colors.blue) {
    return Colors.black87;
  }
  // return getInvertedColor(lightThemeColor);
  return Colors.white70;
}

Color getInvertedColor(Color color) {
  final r = 255 - color.red;
  final g = 255 - color.green;
  final b = 255 - color.blue;

  return Color.fromARGB((color.opacity * 255).round(), r, g, b);
}
