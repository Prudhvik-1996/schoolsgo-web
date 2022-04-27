import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyByAwOkUBofOmpKygDwCfEQtRT2I5ml5Lw",
      authDomain: "web-epsilon-diary.firebaseapp.com",
      projectId: "web-epsilon-diary",
      storageBucket: "web-epsilon-diary.appspot.com",
      messagingSenderId: "37324427087",
      appId: "1:37324427087:web:57870e64256b8c6a29ff3a",
      measurementId: "G-23LRNKNQ0B",
    ),
  );
  runApp(MyApp(settingsController: settingsController));
}
