import 'dart:html' as html;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  // setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  runApp(MyApp(settingsController: settingsController));
}

//el8YjQ79TysyU8yadf3I0s:APA91bH6_cWbLvJSf8L-IxGcJsIwhx1y5PtTzlutz475pHJs-hggdYJ9933fJVhOWclFBeBt7JSr9WB1QEYAy8TPScVvhfzm7u90z0KYioWf26UrhXdd9axpJQZeeWY4onv124g7RlCs
