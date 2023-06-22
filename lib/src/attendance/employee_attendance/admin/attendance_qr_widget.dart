import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AttendanceQRWidget extends StatefulWidget {
  const AttendanceQRWidget({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<AttendanceQRWidget> createState() => _AttendanceQRWidgetState();
}

class _AttendanceQRWidgetState extends State<AttendanceQRWidget> {
  Timer? _timer;
  final int _refreshInterval = 10;

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
      setState(() {});
    });
  }

  String getQRCodeData() {
    int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
    return "${widget.adminProfile.schoolId}|$currentTimeMillis";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: Image.network(
        "https://api.qrserver.com/v1/create-qr-code/?data=${getQRCodeData()}&size=250x250",
        fit: BoxFit.scaleDown,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
            ),
          );
        },
      ),
    );
  }
}
