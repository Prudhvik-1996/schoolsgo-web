import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getCurrentDateString() {
  return DateFormat("dd/MM/yyyy").format(DateTime.now());
}

double timeToDouble(TimeOfDay myTime) =>
    myTime.hour * 60 * 60 + myTime.minute * 60.0;

TimeOfDay stringToTimeOfDay(String tod) {
  final format = DateFormat.jm(); //"6:00 AM"
  try {
    return TimeOfDay.fromDateTime(format.parse(tod));
  } catch (e) {
    return TimeOfDay.fromDateTime(DateFormat("hh:mm:ss").parse(tod));
  }
}

int getSecondsEquivalentOfTimeFromWHHMMSS(String time, int weekId) {
  try {
    return weekId * 24 * 60 * 60 +
        int.parse(time.split(":")[0]) * 60 * 60 +
        int.parse(time.split(":")[1]) * 60 +
        int.parse(time.split(":")[2]);
  } catch (e) {
    return 0;
  }
}

String convertHHMMSSSecondsEquivalentToHHMMA(int eq) {
  int hours = eq ~/ (3600);
  eq = eq ~/ 3600;
  int minutes = eq ~/ 60;
  eq = eq ~/ 60;
  int sec = eq ~/ 60;
  String tod = "";
  return DateFormat("hh:mm a")
      .format(DateTime(
        0,
        0,
        0,
        hours,
        minutes,
        sec,
        0,
        0,
      ))
      .toLowerCase();
}

String timeOfDayToString(TimeOfDay tod) {
  final format = DateFormat.jm(); //"6:00 AM"
  final now = new DateTime.now();
  return format
      .format(DateTime(now.year, now.month, now.day, tod.hour, tod.minute));
}

String timeOfDayToHHMMSS(TimeOfDay tod) {
  final format = DateFormat("HH:mm:ss");
  final now = new DateTime.now();
  return format
      .format(DateTime(now.year, now.month, now.day, tod.hour, tod.minute));
}

TimeOfDay formatHHMMSSToTimeOfDay(String tod) {
  final format = DateFormat("HH:mm:ss");
  final now = new DateTime.now();
  return TimeOfDay.fromDateTime(format.parse(tod));
}

String formatHHMMSStoHHMMA(String tod) {
  final format = DateFormat("HH:mm:ss");
  DateTime x = format.parse(tod);
  final returnFormat = DateFormat.jm();
  return returnFormat.format(x);
}

String getCurrentTimeStringInDDMMYYYYHHMMSS() {
  DateFormat dateFormat = DateFormat("yyyyMMddHHmmss");
  return dateFormat.format(DateTime.now());
}

String convert24To12HourFormat(String time) {
  try {
    DateTime dateTime = DateTime(
      0,
      0,
      0,
      int.parse(time.split(":")[0]),
      int.parse(time.split(":")[1]),
      int.parse(time.split(":")[2]),
      0,
      0,
    );
    return DateFormat("hh:mm a").format(dateTime).toLowerCase();
  } on Exception catch (_) {
    return "-";
  }
}

String convertDateTimeToDDMMYYYYFormat(DateTime date) {
  return DateFormat("dd-MM-yyyy").format(date == null ? DateTime.now() : date);
}

String convertDatTimeToYYYYMMDDFormat(DateTime date) {
  return DateFormat("yyyy-MM-dd").format(date == null ? DateTime.now() : date);
}

String weekOfGivenDateInYYYYMMDDFormat(String date) {
  return [
    "MON",
    "TUE",
    "WED",
    "THU",
    "FRI",
    "SAT",
    "SUN"
  ][DateTime.parse(date).weekday - 1];
}

String convertDateToDDMMMYYY(String date) {
  return date == null
      ? "-"
      : DateFormat('dd MMM, yyyy EEEE')
          .format(DateFormat("yyyy-MM-dd").parse(date));
}

String convertEpochToDDMMYYYYEEEEHHMMAA(int millis) {
  return DateFormat("dd MMM, yyyy EEEE, h:mm a")
      .format(DateTime.fromMillisecondsSinceEpoch(millis));
}

String convertEpochToDDMMYYYYHHMMAA(int millis) {
  return DateFormat("dd MMM, yyyy, h:mm a")
      .format(DateTime.fromMillisecondsSinceEpoch(millis));
}

String convertEpochToYYYYMMDD(int millis) {
  return DateFormat("yyyy-MM-dd")
      .format(DateTime.fromMillisecondsSinceEpoch(millis));
}
