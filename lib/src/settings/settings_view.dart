import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/login/generate_new_four_digit_pin_screen.dart';
import 'package:schoolsgo_web/src/login/generate_new_login_pin_screen.dart';
import 'package:schoolsgo_web/src/login/model/login.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_udates_log/app_updates_log_screen.dart';
import 'package:schoolsgo_web/src/settings/model/app_version.dart';
import 'package:schoolsgo_web/src/settings/notification_preference_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_controller.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    Key? key,
    required this.controller,
    this.adminProfile,
  }) : super(key: key);

  final SettingsController controller;
  final AdminProfile? adminProfile;

  static const routeName = "/settings";

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isLoading = true;

  String? fcmToken;
  int? loggedInUserId;

  String? currentAppVersion;

  AppVersion? latestAppVersion;
  bool isAppDrawerEnabled = false;

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
    currentAppVersion = prefs.getString('CURRENT_APP_VERSION');
    isAppDrawerEnabled = prefs.getBool('IS_APP_DRAWER_ENABLED') ?? false;

    latestAppVersion = await getAppVersion(null);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildThemeDropdown(),
                const Divider(),
                _buildTextThemeDropdown(),
                if (loggedInUserId != null) const Divider(),
                if (loggedInUserId != null) _buildNotificationToggle(),
                if (loggedInUserId != null) const Divider(),
                if (loggedInUserId != null) _buildAppDrawerToggle(),
                if (widget.adminProfile != null) const Divider(),
                if (widget.adminProfile != null) showResetFourDigitPinOption(),
                if (loggedInUserId != null) const Divider(),
                if (loggedInUserId != null) _buildUpdatePasswordWidget(),
                const Divider(),
                _buildUpdateLogsWidget(),
                const Divider(),
              ],
            ),
      bottomSheet: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          currentVersion(),
          const SizedBox(height: 10),
          if (fcmToken != null) _buildFcmTokenSection(),
          if (fcmToken != null) const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildUpdateLogsWidget() {
    return ListTile(
      leading: const Icon(Icons.update),
      title: const Text("Update Log"),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return const AppUpdatesLogScreen();
        }),
      ),
    );
  }

  Widget _buildUpdatePasswordWidget() {
    return ListTile(
      leading: const Icon(Icons.password),
      title: const Text("Update Password"),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return GenerateNewLoginPinScreen(
            userId: loggedInUserId,
            studentId: null,
          );
        }),
      ),
    );
  }

  Widget currentVersion() {
    return Row(
      children: [
        const SizedBox(
          width: 15,
        ),
        const Expanded(child: Text("App version")),
        const SizedBox(
          width: 15,
        ),
        Text(currentAppVersion ?? "-"),
        const SizedBox(
          width: 15,
        ),
        TextButton(
          child: Text((currentAppVersion == null || latestAppVersion?.versionName != currentAppVersion) ? "Update" : "Restart"),
          onPressed: updateApp,
        ),
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }

  Future<void> updateApp() async {
    if (latestAppVersion?.versionName == null) return;
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('CURRENT_APP_VERSION', latestAppVersion!.versionName!);
    setState(() => _isLoading = false);
    Restart.restartApp(webOrigin: "/");
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
          setState(() => _isLoading = true);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          NotificationPreferenceSettings notificationPreferenceSettings = NotificationPreferenceSettings(prefs, context, true);
          if (!enableNotifications) {
            await notificationPreferenceSettings.turnOffNotifications();
          } else {
            await notificationPreferenceSettings.init();
          }
          await _loadData();
          setState(() => _isLoading = false);
        },
        value: fcmToken != null,
      ),
    );
  }

  // Builds the notification toggle
  Widget _buildAppDrawerToggle() {
    return ListTile(
      leading: isAppDrawerEnabled ? const Icon(Icons.menu) : const Icon(Icons.menu_open_outlined),
      title: const Text("App Drawer"),
      trailing: Switch(
        onChanged: (bool enableAppDrawer) async {
          setState(() => _isLoading = true);
          await AppDrawerHelper.instance.updateAppDrawerState(enableAppDrawer);
          isAppDrawerEnabled = enableAppDrawer;
          await _loadData();
          setState(() => _isLoading = false);
        },
        value: isAppDrawerEnabled,
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

  Widget showResetFourDigitPinOption() {
    return ListTile(
      leading: const Icon(Icons.password),
      title: const Text("Update Four Digit Pin"),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return GenerateNewFourDigitPinScreen(
            adminProfile: widget.adminProfile!,
          );
        }),
      ),
    );
  }
}
