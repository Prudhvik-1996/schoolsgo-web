import 'package:shared_preferences/shared_preferences.dart';

class AppDrawerHelper {
  static final AppDrawerHelper _instance = AppDrawerHelper._internal();
  bool _isDrawerDisabled = true; // Default to true (disabled)
  bool _isInitialized = false;

  AppDrawerHelper._internal();

  static AppDrawerHelper get instance => _instance;

  Future<void> init() async {
    if (!_isInitialized) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isDrawerDisabled = !(prefs.getBool('IS_APP_DRAWER_ENABLED') ?? false);
      _isInitialized = true;
    }
  }

  bool isAppDrawerDisabled() => _isDrawerDisabled;

  Future<void> updateAppDrawerState(bool isEnabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('IS_APP_DRAWER_ENABLED', isEnabled);
    _isDrawerDisabled = !isEnabled; 
  }
}
