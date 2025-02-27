import 'dart:html' as html;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';
import 'package:schoolsgo_web/src/utils/custom_routing_strategy.dart';

import 'firebase_options_primary.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

import 'firebase_options_primary.dart' as primary;
import 'firebase_options_secondary.dart' as secondary;

const firebaseEnvKey = String.fromEnvironment('FIREBASE_ENV');

void main() async {
  setHybridUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await initialiseFirebase();
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  await AppDrawerHelper.instance.init();
  runApp(MyApp(settingsController: settingsController));
  html.window.onBeforeUnload.listen((event) {
    event.preventDefault(); // Disable browser back
  });
}

Future<void> initialiseFirebase() async {
  print('FIREBASE_ENV: $firebaseEnvKey');
  const bool isPrimary = firebaseEnvKey == "primary";
  await Firebase.initializeApp(
    options: isPrimary ? primary.DefaultFirebaseOptions.currentPlatform : secondary.DefaultFirebaseOptions.currentPlatform,
  );
}

//el8YjQ79TysyU8yadf3I0s:APA91bH6_cWbLvJSf8L-IxGcJsIwhx1y5PtTzlutz475pHJs-hggdYJ9933fJVhOWclFBeBt7JSr9WB1QEYAy8TPScVvhfzm7u90z0KYioWf26UrhXdd9axpJQZeeWY4onv124g7RlCs
