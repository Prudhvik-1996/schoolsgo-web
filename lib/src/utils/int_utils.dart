import "package:intl/intl.dart";
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

String doubleToStringAsFixedForINR(double? val, {int decimalPlaces = 2}) {
  if (val == null) return "-";
  int? parsedInt = int.tryParse(val.toString());
  if (parsedInt == val) {
    return NumberFormat.currency(symbol: "", decimalDigits: 0, locale: 'HI').format(int.parse(val.toString()));
  }
  return NumberFormat.currency(symbol: "", locale: 'HI').format(double.parse(val.toStringAsFixed(decimalPlaces).trimTrailingRegex("0")));
}
