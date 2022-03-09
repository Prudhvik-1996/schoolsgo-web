import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  Future<ThemeMode> themeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int themeIndex = prefs.getInt('THEME_INDEX') ?? 0;
    return [ThemeMode.system, ThemeMode.light, ThemeMode.dark][themeIndex];
  }

  Future<void> updateThemeMode(ThemeMode newTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('THEME_INDEX', [ThemeMode.system, ThemeMode.light, ThemeMode.dark].indexOf(newTheme));
  }
}
