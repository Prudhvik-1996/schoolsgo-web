import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/employee_attendance/model/employee_attendance.dart';
import 'package:schoolsgo_web/src/employee_attendance/qr_scanner/qr_screen_overlay.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class QrScannerWidget extends StatefulWidget {
  const QrScannerWidget({
    Key? key,
    required this.employeeAttendanceBean,
  }) : super(key: key);

  final EmployeeAttendanceBean employeeAttendanceBean;

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  String? scannedQrCodeData;
  MobileScannerController cameraController = MobileScannerController();

  bool isLoading = true;
  bool updatingAttendance = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    setState(() => isLoading = false);
  }

  Future<void> clockAttendance() async {
    int? schoolId = scannedSchoolId;
    if (schoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Scanned an incorrect QR!"),
        ),
      );
      return;
    }
    setState(() => updatingAttendance = true);
    CreateOrUpdateEmployeeAttendanceClockResponse createOrUpdateEmployeeAttendanceClockResponse =
        await createOrUpdateEmployeeAttendanceClock(CreateOrUpdateEmployeeAttendanceClockRequest(
      schoolId: schoolId,
      agent: widget.employeeAttendanceBean.employeeId,
      status: "active",
      attendanceId: null,
      clockedIn: scannedClockInMode,
      clockedTime: scannedMillis ?? DateTime.now().millisecondsSinceEpoch,
      comment: null,
      employeeId: widget.employeeAttendanceBean.employeeId,
      latitude: null,
      longitude: null,
    ));
    if (createOrUpdateEmployeeAttendanceClockResponse.httpStatus != "OK" ||
        createOrUpdateEmployeeAttendanceClockResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }
    await Future.delayed(const Duration(seconds: 2));
    setState(() => updatingAttendance = false);
    await Future.delayed(const Duration(seconds: 5));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Attendance"),
        actions: scannedQrCodeData == null
            ? [
                IconButton(
                  color: Colors.white,
                  icon: ValueListenableBuilder(
                    valueListenable: cameraController.torchState,
                    builder: (context, state, child) {
                      switch (state as TorchState) {
                        case TorchState.off:
                          return const Icon(Icons.flash_off, color: Colors.grey);
                        case TorchState.on:
                          return const Icon(Icons.flash_on, color: Colors.yellow);
                      }
                    },
                  ),
                  iconSize: 32.0,
                  onPressed: () => cameraController.toggleTorch(),
                ),
                IconButton(
                  color: Colors.white,
                  icon: ValueListenableBuilder(
                    valueListenable: cameraController.cameraFacingState,
                    builder: (context, state, child) {
                      switch (state as CameraFacing) {
                        case CameraFacing.front:
                          return const Icon(Icons.camera_front);
                        case CameraFacing.back:
                          return const Icon(Icons.camera_rear);
                      }
                    },
                  ),
                  iconSize: 32.0,
                  onPressed: () => cameraController.switchCamera(),
                ),
                const SizedBox(width: 20)
              ]
            : [],
      ),
      body: isLoading
          ? const EpsilonDiaryLoadingWidget()
          : scannedQrCodeData == null
              ? qrScannerWidget()
              : updatingAttendance
                  ? Column(
                      children: [
                        const SizedBox(height: 20),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              'assets/images/eis_loader.gif',
                              height: 500,
                              width: 500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("Updating attendance"),
                        const SizedBox(height: 20),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Details',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text('Name: ${widget.employeeAttendanceBean.employeeName}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.school),
                          title: Text('Franchise: ${widget.employeeAttendanceBean.franchiseName}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.account_box),
                          title: Text('Roles: ${widget.employeeAttendanceBean.roles?.join(", ")}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: Text('Email: ${widget.employeeAttendanceBean.emailId}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: Text('Mobile: ${widget.employeeAttendanceBean.mobile}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.date_range),
                          title: Text('Date: ${scannedMillis == null ? "-" : convertEpochToDDMMYYYYEEEEHHMMAA(scannedMillis!)}'),
                        ),
                      ],
                    ),
    );
  }

  Stack qrScannerWidget() {
    return Stack(
      children: [
        MobileScanner(
          allowDuplicates: false,
          controller: cameraController,
          onDetect: (barcode, args) async {
            setState(() {
              scannedQrCodeData = barcode.rawValue;
            });
            if (scannedQrCodeData != null) {
              await clockAttendance();
            }
          },
        ),
        QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
      ],
    );
  }

  int? get scannedSchoolId {
    try {
      int? scannedId = int.parse((scannedQrCodeData?.split("|") ?? [])[0]);
      if (scannedId == widget.employeeAttendanceBean.schoolId) {
        return scannedId;
      }
      return null;
    } on Exception catch (e, st) {
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  int? get scannedMillis {
    try {
      return int.parse((scannedQrCodeData?.split("|") ?? [])[1]);
    } on Exception catch (e, st) {
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  bool? get scannedClockInMode {
    try {
      return (scannedQrCodeData?.split("|") ?? [])[2] == "true";
    } on Exception catch (e, st) {
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  DateTime? get scannedDateTime {
    try {
      return DateTime.fromMillisecondsSinceEpoch(int.parse((scannedQrCodeData?.split("|") ?? [])[1]));
    } on Exception catch (e, st) {
      debugPrintStack(stackTrace: st);
      return null;
    }
  }
}
