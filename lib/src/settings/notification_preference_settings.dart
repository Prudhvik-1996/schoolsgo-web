// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/login/model/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferenceSettings {
  SharedPreferences prefs;
  BuildContext context;
  bool forceNotifications;

  String? fcmToken;
  int? loggedInUserId;
  String? loggedInEmail;
  String? loggedInMobile;

  NotificationPreferenceSettings(
    this.prefs,
    this.context,
    this.forceNotifications,
  );

  Future<void> init() async {
    await loadExistingFcmToken();
    await askPermissionAndProceedIfNeeded();
  }

  Future<void> turnOffNotifications() async {
    await loadExistingFcmToken();
    CreateOrUpdateFcmTokenResponse createOrUpdateFcmTokenResponse = await createOrUpdateFcmToken(
      CreateOrUpdateFcmTokenRequest(
        fcmBean: FcmBean(
          status: "inactive",
          userId: loggedInUserId,
          mobileNumber: loggedInMobile,
          fcmToken: fcmToken,
        ),
      ),
    );
    if (createOrUpdateFcmTokenResponse.httpStatus == "OK" && createOrUpdateFcmTokenResponse.responseStatus == "success") {
      await prefs.remove('USER_FCM_TOKEN');
    } else {
      showSnackbar("Something went wrong..\nPlease try again later");
    }
  }

  Future<void> loadExistingFcmToken() async {
    loggedInUserId = prefs.getInt('LOGGED_IN_USER_ID');
    print("loggedInUserId: $loggedInUserId");
    loggedInEmail = prefs.getString('LOGGED_IN_USER_EMAIL');
    print("loggedInEmail: $loggedInEmail");
    loggedInMobile = prefs.getString('LOGGED_IN_MOBILE');
    print("loggedInMobile: $loggedInMobile");
    fcmToken = prefs.getString('USER_FCM_TOKEN');
    print("fcmToken: $fcmToken");
  }

  Future<void> askPermissionAndProceedIfNeeded() async {
    if (loggedInUserId == null && loggedInEmail == null && loggedInMobile == null) {
      return;
    }
    print("Requesting notification permission...");
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    print("Permission status: ${settings.authorizationStatus}");
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      showSnackbar("Notifications are disabled. Please enable them in your browser settings.");
      if (forceNotifications) {
        await showBlockedNotificationDialog(context);
      }
      return;
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      showSnackbar("Notifications are allowed temporarily. You might need to allow them permanently.");
    } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      showSnackbar("Notification permission is not determined.");
    }
    fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      CreateOrUpdateFcmTokenResponse createOrUpdateFcmTokenResponse = await createOrUpdateFcmToken(
        CreateOrUpdateFcmTokenRequest(
          fcmBean: FcmBean(
            status: "active",
            userId: loggedInUserId,
            mobileNumber: loggedInMobile,
            fcmToken: fcmToken,
          ),
        ),
      );

      if (createOrUpdateFcmTokenResponse.httpStatus == "OK" && createOrUpdateFcmTokenResponse.responseStatus == "success") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('USER_FCM_TOKEN', fcmToken!);
      } else {
        showSnackbar("Something went wrong..\nPlease try again later");
      }
    } else {
      showSnackbar("Something went wrong..\nPlease try again later");
    }
  }

  void showSnackbar(String message) {
    print(message);
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> showBlockedNotificationDialog(BuildContext context) async {
    String url = getBrowserNotificationSettingsUrl();
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Builder(
          builder: (BuildContext validContext) {
            return AlertDialog(
              title: const Text("Enable Notifications"),
              content: Text(
                "To enable notifications:\n\n"
                "1. Open new tab.\n"
                "2. Copy this URL and paste it in a new tab:\n"
                "$url",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(validContext);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Copied to clipboard!")),
                    );
                    Navigator.pop(validContext);
                  },
                  child: const Text("Copy URL"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void openBrowserNotificationSettings() {
    String url = getBrowserNotificationSettingsUrl();
    print("Redirecting to $url");
    html.window.open(url, "_blank");
  }

  String getBrowserNotificationSettingsUrl() {
    String userAgent = html.window.navigator.userAgent.toLowerCase();

    if (userAgent.contains("chrome")) {
      return "chrome://settings/content/notifications";
    } else if (userAgent.contains("firefox")) {
      return "about:preferences#privacy";
    } else if (userAgent.contains("safari")) {
      return "https://support.apple.com/guide/safari/customize-website-notifications-sfri40734/mac";
    } else if (userAgent.contains("edge")) {
      return "edge://settings/content/notifications";
    } else {
      return "https://www.whatismybrowser.com/guides/how-to-enable-notifications/";
    }
  }
}
