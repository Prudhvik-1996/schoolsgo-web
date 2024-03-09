import 'dart:convert';

import 'package:schoolsgo_web/src/utils/list_utils.dart';

String getQRCodeData(int schoolId, bool isStatic, int millis, int adminId) {
  return base64.encode("$schoolId|${isStatic ? "true" : "false"}|$millis|$adminId".codeUnits);
}

String getDecryptCode(String qr) {
  return String.fromCharCodes(base64.decode(qr));
}

bool? scannedFromDynamicQr(String? qr) => qr == null ? null : String.fromCharCodes(base64.decode(qr)).contains("false");

bool isQRValid(String qr) {
  return qr.split("|").isNotEmpty &&
      extractSchoolIdFromQr(qr) != null &&
      extractIsStaticFromQr(qr) != null &&
      extractMillisFromQr(qr) != null &&
      extractAdminIdFromQr(qr) != null;
}

int? extractSchoolIdFromQr(String qr) {
  return int.tryParse(qr.split("|").firstOrNull() ?? "");
}

bool? extractIsStaticFromQr(String qr) {
  return qr.split("|").tryGet(1) == "true";
}

int? extractMillisFromQr(String qr) {
  return int.tryParse(qr.split("|").tryGet(2) ?? "");
}

int? extractAdminIdFromQr(String qr) {
  return int.tryParse(qr.split("|").tryGet(3) ?? "");
}
