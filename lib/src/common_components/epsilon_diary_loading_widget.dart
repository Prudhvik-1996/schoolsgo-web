import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class EpsilonDiaryLoadingWidget extends StatefulWidget {
  const EpsilonDiaryLoadingWidget({super.key});

  @override
  State<EpsilonDiaryLoadingWidget> createState() => _EpsilonDiaryLoadingWidgetState();
}

class _EpsilonDiaryLoadingWidgetState extends State<EpsilonDiaryLoadingWidget> {
  String? _networkSpeed;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchNetworkSpeed());
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  Future<void> _fetchNetworkSpeed() async {
    String testUrl = allowCORSEndPoint + 'https://google.com';
    final startTime = DateTime.now();
    final response = await http.get(Uri.parse(testUrl));
    final endTime = DateTime.now();
    final elapsedTime = endTime.difference(startTime).inMilliseconds;
    final fileSizeInBytes = response.bodyBytes.length;
    // print("39: $fileSizeInBytes, $elapsedTime");
    final downloadSpeedKbps = (fileSizeInBytes / elapsedTime) / 1024;
    final downloadSpeedMbps = (downloadSpeedKbps / elapsedTime) / 1024;
    // print("42: $downloadSpeedKbps, $downloadSpeedMbps");
    setState(() {
      _networkSpeed = downloadSpeedMbps > 1 ? "${doubleToStringAsFixed(downloadSpeedMbps)} Mbps" : "${doubleToStringAsFixed(downloadSpeedKbps)} Kbps";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 500,
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/eis_loader.gif',
              height: 400,
              width: 400,
              fit: BoxFit.scaleDown,
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_networkSpeed == null ? "Loading..." : "Epsilon Diary is loading\nat a speed of $_networkSpeed"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
