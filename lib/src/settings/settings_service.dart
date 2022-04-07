import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colors.dart';

class SettingsService {
  Future<ThemeMode> themeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int themeIndex = prefs.getInt('THEME_INDEX') ?? 0;
    return [ThemeMode.system, ThemeMode.light, ThemeMode.dark][themeIndex];
  }

  Future<String> textTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int themeIndex = prefs.getInt('TEXT_THEME_INDEX') ?? 0;
    return textThemesMap.keys.toList()[themeIndex];
  }

  Future<void> updateThemeMode(ThemeMode newTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('THEME_INDEX', [ThemeMode.system, ThemeMode.light, ThemeMode.dark].indexOf(newTheme));
  }

  Future<void> updateTextTheme(String newTextTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('TEXT_THEME_INDEX', textThemesMap.keys.toList().indexOf(newTextTheme));
  }
}
