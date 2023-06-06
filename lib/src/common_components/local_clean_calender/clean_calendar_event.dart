import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class CleanCalendarEvent {
  String summary;
  String description;
  String location;
  DateTime startTime;
  DateTime endTime;
  Color color;
  bool isAllDay;
  bool isDone;
  TeacherDealingSection? tds;

  CleanCalendarEvent(
    this.summary, {
    this.description = '',
    this.location = '',
    required this.startTime,
    required this.endTime,
    this.color = Colors.blue,
    this.isAllDay = false,
    this.isDone = false,
    this.tds,
  });
}
