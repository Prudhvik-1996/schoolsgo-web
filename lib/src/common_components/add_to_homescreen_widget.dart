import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InstallEpsilonDiaryScreen extends StatefulWidget {
  const InstallEpsilonDiaryScreen({super.key});

  @override
  State<InstallEpsilonDiaryScreen> createState() => _InstallEpsilonDiaryScreenState();
}

class _InstallEpsilonDiaryScreenState extends State<InstallEpsilonDiaryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Epsilon Diary"),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
          },
        ),
      ),
      body: ListView(
        controller: _scrollController,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildFeaturesSection(),
        ],
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  /// 🏡 Header Section with Animated Install Button
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0175C2),
            Color(0xFF004A77),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/EISlogo.png", height: 120, width: 120),
            const SizedBox(height: 20),
            const Text(
              "📚 Welcome to Epsilon Diary! 🚀",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "A smart school management system designed for Admins, Teachers & Parents!",
              style: TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addToHomeScreen(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.white.withOpacity(0.1),
                elevation: 5,
              ),
              child: const Text(
                "📲 Add to Home Screen",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🚀 Features Section
  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("✨ Key Features for Everyone:", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildFeatureCategory("🛠️ For Admins:", [
            ["📊", "Performance Reports – Generate insights on students & staff."],
            ["✅", "Automated Attendance – Save time with digital tracking."],
            ["💰", "Fee Management – Track transactions with ease."],
            ["📢", "Instant Announcements – Keep parents & teachers informed."],
          ]),
          _buildFeatureCategory("📖 For Teachers:", [
            ["📅", "Exam Scheduling & Results – Manage exams seamlessly."],
            ["📝", "Digital Mark Sheets – Generate and share grades instantly."],
            ["✅", "Homework & Assignments – Easily assign & track student work."],
            ["💬", "Parent Communication – Direct messaging with parents."],
          ]),
          _buildFeatureCategory("👨‍👩‍👧‍👦 For Parents:", [
            ["🔔", "Real-Time Notifications – Get updates on school activities."],
            ["✅", "Daily Attendance Updates – Get notified if your child is absent."],
            ["📚", "Homework & Study Plans – Stay updated with assignments."],
            ["💰", "Online Fee Payments – Pay securely from anywhere."],
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 📌 Feature Category Builder (Now with Icons!)
  Widget _buildFeatureCategory(String title, List<List<String>> features) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feature[0], style: const TextStyle(fontSize: 20)), // Emoji Icon
                    const SizedBox(width: 8), Expanded(child: Text(feature[1], style: const TextStyle(fontSize: 16))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// 🔝 Floating "Back to Top" Button
  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      backgroundColor: Colors.blueAccent,
      elevation: 5,
      child: const Icon(Icons.arrow_upward, color: Colors.white),
    );
  }

  /// 📲 Calls JavaScript "Add to Home Screen"
  void _addToHomeScreen(BuildContext context) {
    // Check if the device is running Android
    String userAgent = html.window.navigator.userAgent;
    bool isAndroid = userAgent.contains('Android');
    bool isIOS = userAgent.contains('iPhone') || userAgent.contains('iPad') || userAgent.contains('iPod');
    bool isDesktop = userAgent.contains('Win') || userAgent.contains('Mac') || userAgent.contains('Linux') || userAgent.contains('CrOS');

    if (isAndroid) {
      try {
        js.context.callMethod('showAddToHomeScreenPrompt');
      } catch (e) {
        debugPrint("Error calling showAddToHomeScreenPrompt: $e");
      }
    } else if (isIOS) {
      _showIOSInstallationDialog(context);
    } else if (isDesktop) {
      _showDesktopInstallationDialog(context);
    } else {
      debugPrint("Unsupported platform for PWA installation.");
    }
  }

  void _showDesktopInstallationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Install as PWA"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "To install Epsilon Diary as a desktop app:\n\n"
                "1. Open Chrome, Edge, or Brave.\n"
                "2. Click the Install App icon in the address bar.\n"
                "3. Confirm the installation.",
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showIOSInstallationDialog(BuildContext context) {
    String appUrl = "https://epsilondiary.web.app/";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("📲 Install Epsilon Diary"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "To install Epsilon Diary on your iPhone/iPad, follow these steps:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("1. Open Safari (this feature does not work on Chrome or other browsers)."),
              const Text("2. Go to:"),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: appUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("App URL copied to clipboard!")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          appUrl,
                          style: const TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.copy, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text("3. Tap the Share button at the bottom."),
              const Text("4. Scroll down and select Add to Home Screen."),
              const Text("5. Tap Add in the top-right corner."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
