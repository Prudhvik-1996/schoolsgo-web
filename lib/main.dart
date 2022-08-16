import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission();
  String? key = await FirebaseMessaging.instance.getToken();
  // print("114: $key");
  final settingsController = SettingsController(SettingsService());
  settingsController.fcmToken = key;
  await settingsController.loadSettings();
  runApp(MyApp(settingsController: settingsController));
}

//el8YjQ79TysyU8yadf3I0s:APA91bH6_cWbLvJSf8L-IxGcJsIwhx1y5PtTzlutz475pHJs-hggdYJ9933fJVhOWclFBeBt7JSr9WB1QEYAy8TPScVvhfzm7u90z0KYioWf26UrhXdd9axpJQZeeWY4onv124g7RlCs
