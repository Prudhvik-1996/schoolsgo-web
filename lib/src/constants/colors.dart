import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color lightThemeColor = Color(0xFFF2F2F2);
const Color darkThemeColor = Color(0xFF3A3A3A);

bool isDarkTheme(BuildContext context) {
  return Theme.of(context).primaryColor != Colors.blue;
}

Color clayContainerColor(BuildContext context) {
  if (Theme.of(context).primaryColor == Colors.blue) {
    return lightThemeColor;
  }
  // return getInvertedColor(lightThemeColor);
  return darkThemeColor;
}

Color onGoingClassColor = Colors.green.shade400;

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

Map<String, TextTheme> textThemesMap = {
  'Roboto': GoogleFonts.robotoTextTheme(),
  'Open Sans': GoogleFonts.openSansTextTheme(),
  'PT Serif': GoogleFonts.ptSerifTextTheme(),
  'Chewy': GoogleFonts.chewyTextTheme(),
  'Satisy': GoogleFonts.satisfyTextTheme(),
  'Trade Winds': GoogleFonts.tradeWindsTextTheme(),
  'Dancing Scripts': GoogleFonts.dancingScriptTextTheme(),
};

const List<Color> COLORS = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
];

Color hexCodeToColor(String colorCode) {
  return Color(int.parse(colorCode.substring(1, 7), radix: 16) + 0xFF000000);
}

String colorToHexCode(Color color) {
  return '#${(color.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

bool isColorDark(Color color) {
  double luminance = color.computeLuminance();
  return luminance < 0.5;
}

Color getTextColorBasedOnBackground(Color backgroundColor) {
  return isColorDark(backgroundColor) ? Colors.white : Colors.black;
}
