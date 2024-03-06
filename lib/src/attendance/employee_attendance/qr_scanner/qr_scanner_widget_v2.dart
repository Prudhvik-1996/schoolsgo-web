import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/admin/employee_attendance_utils.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/qr_scanner/qr_screen_overlay.dart';

class QRScannerWidgetV2 extends StatefulWidget {
  const QRScannerWidgetV2({
    Key? key,
  }) : super(key: key);

  @override
  State<QRScannerWidgetV2> createState() => _QRScannerWidgetV2State();
}

class _QRScannerWidgetV2State extends State<QRScannerWidgetV2> {
  String? scannedQrCodeData;
  MobileScannerController cameraController = MobileScannerController();

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
      body: Stack(
        children: [
          MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (barcode, args) async {
              if (barcode.rawValue == null) return;
              setState(() {
                scannedQrCodeData = getDecryptCode(barcode.rawValue!);
              });
              Navigator.pop(context, [scannedQrCodeData]);
            },
          ),
          QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
        ],
      ),
    );
  }
}
