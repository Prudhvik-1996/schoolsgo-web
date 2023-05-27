import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/login/model/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SettingsController controller;

  static const routeName = "/settings";

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isLoading = true;

  String? fcmToken;
  int? loggedInUserId;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedInUserId = prefs.getInt('LOGGED_IN_USER_ID');
    fcmToken = prefs.getString('USER_FCM_TOKEN');

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildThemeDropdown(),
                const Divider(),
                _buildTextThemeDropdown(),
                const Divider(),
                _buildNotificationToggle(),
                const Divider(),
              ],
            ),
      bottomSheet: fcmToken == null ? null : _buildFcmTokenSection(),
    );
  }

  // Builds the dropdown for selecting the theme mode
  Widget _buildThemeDropdown() {
    return ListTile(
      leading: const Icon(Icons.color_lens_outlined),
      title: DropdownButton<ThemeMode>(
        isExpanded: true,
        underline: Container(),
        value: widget.controller.themeMode,
        onChanged: widget.controller.updateThemeMode,
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
    );
  }

  // Builds the dropdown for selecting the text theme
  Widget _buildTextThemeDropdown() {
    return ListTile(
      leading: const Icon(Icons.text_format),
      title: DropdownButton<String>(
        isExpanded: true,
        underline: Container(),
        value: widget.controller.textTheme,
        onChanged: widget.controller.updateTextTheme,
        items: textThemesMap.keys
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: textThemesMap[e]!.headline3?.copyWith(
                        color: clayContainerTextColor(context),
                      ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // Builds the notification toggle
  Widget _buildNotificationToggle() {
    return ListTile(
      leading: fcmToken == null ? const Icon(Icons.notifications) : const Icon(Icons.notifications_active),
      title: const Text("Notifications"),
      trailing: Switch(
        onChanged: (bool enableNotifications) async {
          if (enableNotifications) {
            if (fcmToken == null) {
              await FirebaseMessaging.instance.requestPermission();
              fcmToken = await FirebaseMessaging.instance.getToken();
            }
            if (fcmToken != null) {
              CreateOrUpdateFcmTokenResponse createOrUpdateFcmTokenResponse = await createOrUpdateFcmToken(
                CreateOrUpdateFcmTokenRequest(
                  fcmBean: FcmBean(
                    status: "active",
                    userId: loggedInUserId,
                    fcmToken: fcmToken,
                  ),
                ),
              );

              if (createOrUpdateFcmTokenResponse.httpStatus == "OK" && createOrUpdateFcmTokenResponse.responseStatus == "success") {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('USER_FCM_TOKEN', fcmToken!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Something went wrong..\nPlease try again later"),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Something went wrong..\nPlease try again later"),
                ),
              );
            }
            await _loadData();
          } else {
            CreateOrUpdateFcmTokenResponse createOrUpdateFcmTokenResponse = await createOrUpdateFcmToken(
              CreateOrUpdateFcmTokenRequest(
                fcmBean: FcmBean(
                  status: "inactive",
                  userId: loggedInUserId,
                  fcmToken: fcmToken,
                ),
              ),
            );

            if (createOrUpdateFcmTokenResponse.httpStatus == "OK" && createOrUpdateFcmTokenResponse.responseStatus == "success") {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('USER_FCM_TOKEN');
              await FirebaseMessaging.instance.requestPermission();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Something went wrong..\nPlease try again later"),
                ),
              );
            }
            await _loadData();
          }
        },
        value: fcmToken != null,
      ),
    );
  }

  // Builds the bottom sheet section displaying the FCM token
  Widget _buildFcmTokenSection() {
    return Row(
      children: [
        const SizedBox(
          width: 15,
        ),
        Expanded(child: SelectableText(fcmToken ?? "Enable notifications to check your token")),
        const SizedBox(
          width: 15,
        ),
        InkWell(
          child: const Icon(
            Icons.copy,
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: fcmToken ?? ""));
          },
        ),
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }
}
