import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);
  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  late String _textTheme;

  ThemeMode get themeMode => _themeMode;
  String get textTheme => _textTheme;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _textTheme = await _settingsService.textTheme();
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    notifyListeners();

    await _settingsService.updateThemeMode(_themeMode);
  }

  Future<void> updateTextTheme(String? newTextTheme) async {
    if (newTextTheme == null) return;

    if (newTextTheme == _textTheme) return;

    _textTheme = newTextTheme;

    notifyListeners();

    await _settingsService.updateTextTheme(_textTheme);
  }
}
