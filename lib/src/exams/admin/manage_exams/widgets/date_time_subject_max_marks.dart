import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';

class DateTimeSubjectMaxMarks implements Comparable<DateTimeSubjectMaxMarks> {
  DateTime? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Subject? subject;
  double? maxMarks;

  TextEditingController maxMarksController = TextEditingController();

  DateTimeSubjectMaxMarks({
    this.date,
    this.startTime,
    this.endTime,
    this.subject,
    this.maxMarks,
  });

  @override
  String toString() {
    return "DateTimeSubjectMaxMarks: {date: $date, startTime: $startTime, endTime: $endTime, subject: $subject, maxMarks: $maxMarks}";
  }

  @override
  int compareTo(DateTimeSubjectMaxMarks other) => date == null || other.date == null
      ? 0
      : (date!.millisecondsSinceEpoch ~/ 1000 +
              (startTime ?? const TimeOfDay(hour: 0, minute: 0)).hour * 3600 +
              (startTime ?? const TimeOfDay(hour: 0, minute: 0)).minute * 60) -
          (other.date!.millisecondsSinceEpoch ~/ 1000 +
              (other.startTime ?? const TimeOfDay(hour: 0, minute: 0)).hour * 3600 +
              (other.startTime ?? const TimeOfDay(hour: 0, minute: 0)).minute * 60);
}
