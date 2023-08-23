import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class AttendanceQRWidget extends StatefulWidget {
  const AttendanceQRWidget({
    Key? key,
    required this.adminProfile,
    required this.isStatic,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final bool isStatic;

  @override
  State<AttendanceQRWidget> createState() => _AttendanceQRWidgetState();
}

class _AttendanceQRWidgetState extends State<AttendanceQRWidget> {
  Timer? _timer;
  final int _refreshInterval = 10;
  int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;

  bool isClockIn = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: _refreshInterval), (_) {
      if (!widget.isStatic) {
        setState(() => currentTimeMillis = DateTime.now().millisecondsSinceEpoch);
      }
    });
  }

  String getQRCodeData() {
    return "${widget.adminProfile.schoolId}|$currentTimeMillis|$isClockIn";
  }

  String getStaticQRCodeData() {
    return "${widget.adminProfile.schoolId}";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 250,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (!widget.isStatic) Center(child: Text(convertEpochToDDMMYYYYEEEEHHMMAA(currentTimeMillis))),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              width: 250,
              child: Image.network(
                widget.isStatic
                    ? "https://api.qrserver.com/v1/create-qr-code/?data=${getStaticQRCodeData()}&size=250x250"
                    : "https://api.qrserver.com/v1/create-qr-code/?data=${getQRCodeData()}&size=250x250",
                fit: BoxFit.scaleDown,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (!widget.isStatic)
              SizedBox(
                height: 60,
                width: 250,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 60, maxWidth: 250),
                  child: SwitchListTile(
                    value: isClockIn,
                    onChanged: (bool newValue) => setState(() => isClockIn = newValue),
                    title: Text(isClockIn ? "Clock In" : "Clock Out"),
                  ),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
