import 'package:flutter/material.dart';

class SettingsService {
  Future<ThemeMode> themeMode() async => ThemeMode.light;

  Future<void> updateThemeMode(ThemeMode newTheme) async {
    //  TODO preserve in shared_preferences or http
  }
}
