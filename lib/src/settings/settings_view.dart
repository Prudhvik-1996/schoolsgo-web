import 'package:flutter/material.dart';

import '../constants/colors.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  static const routeName = "/settings";
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: DropdownButton<ThemeMode>(
              underline: Container(),
              value: controller.themeMode,
              onChanged: controller.updateThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text("System Theme"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text("Dark Theme"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text("Light Theme"),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.text_format),
            title: DropdownButton<String>(
              underline: Container(),
              value: controller.textTheme,
              onChanged: controller.updateTextTheme,
              items: textThemesMap.keys
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: textThemesMap[e]!.headline3),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
