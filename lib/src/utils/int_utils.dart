import 'package:schoolsgo_web/src/utils/string_utils.dart';

String intToStringAsFixed(int? val, {int decimalPlaces = 2}) {
  return val == null ? "-" : val.toStringAsFixed(decimalPlaces);
}

String doubleToStringAsFixed(double? val, {int decimalPlaces = 2}) {
  if (val == null) return "-";
  int? parsedInt = int.tryParse(val.toString());
  if (parsedInt == val) {
    return int.parse(val.toString()).toString();
  }
  return val.toStringAsFixed(decimalPlaces).trimTrailingRegex("0");
}
