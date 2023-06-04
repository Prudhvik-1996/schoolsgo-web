import 'dart:convert';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetPlannerTimeSlotsRequest {
/*
{
  "endDate": "string",
  "schoolId": 0,
  "sectionId": 0,
  "startDate": "string",
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  String? endDate;
  int? schoolId;
  int? sectionId;
  String? startDate;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetPlannerTimeSlotsRequest({
    this.endDate,
    this.schoolId,
    this.sectionId,
    this.startDate,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });

  GetPlannerTimeSlotsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    endDate = json['endDate']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    startDate = json['startDate']?.toString();
    subjectId = json['subjectId']?.toInt();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['endDate'] = endDate;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['startDate'] = startDate;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class PlannerTimeSlot {
/*
{
  "date": "string",
  "weekId": 0,
  "startTime": "",
  "endTime": "",
  "tdsId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "subjectId": 0,
  "teacherId": 0
}
*/

  String? date;
  int? weekId;
  String? startTime;
  String? endTime;
  int? tdsId;
  int? schoolId;
  int? sectionId;
  int? subjectId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  PlannerTimeSlot({
    this.date,
    this.weekId,
    this.startTime,
    this.endTime,
    this.tdsId,
    this.schoolId,
    this.sectionId,
    this.subjectId,
    this.teacherId,
  });

  PlannerTimeSlot.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toString();
    weekId = json['weekId']?.toInt();
    startTime = json['startTime']?.toString();
    endTime = json['endTime']?.toString();
    tdsId = json['tdsId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['weekId'] = weekId;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['tdsId'] = tdsId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  DateTime? getDate() => date == null ? null : convertYYYYMMDDFormatToDateTime(date!);

  TimeOfDay? getStartTime() => startTime == null ? null : formatHHMMSSToTimeOfDay(startTime!);

  TimeOfDay? getEndTime() => endTime == null ? null : formatHHMMSSToTimeOfDay(endTime!);

  DateTime getStartTimeInDate() {
    DateTime date = getDate()!;
    TimeOfDay timeOfDay = getStartTime()!;
    return DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute, 0);
  }

  DateTime getEndTimeInDate() {
    DateTime date = getDate()!;
    TimeOfDay timeOfDay = getEndTime()!;
    return DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute, 0);
  }

  String dateTimeStringEq() {
    return '${getDate() == null ? "-" : convertDateTimeToDDMMYYYYFormat(getDate()!)}\n${getStartTime() == null ? "-" : timeOfDayToString(getStartTime()!)} - ${getEndTime() == null ? "-" : timeOfDayToString(getEndTime()!)}';
  }

  String timeStringEq() {
    return '${getStartTime() == null ? "-" : timeOfDayToString(getStartTime()!)} - ${getEndTime() == null ? "-" : timeOfDayToString(getEndTime()!)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PlannerTimeSlot && runtimeType == other.runtimeType && dateTimeStringEq() == other.dateTimeStringEq();

  @override
  int get hashCode => dateTimeStringEq().hashCode;

  CalendarEventData<PlannerTimeSlot> toCalenderEventData({String? title, String? description}) => CalendarEventData(
        date: getDate() ?? DateTime.now(),
        event: this,
        title: title ?? "-",
        description: description ?? "-",
        startTime: getStartTimeInDate(),
        endTime: getEndTimeInDate(),
      );
}

class GetPlannerTimeSlotsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "plannerTimeSlots": [
    {
      "date": "string",
      "weekId": 0,
      "startTime": "",
      "endTime": "",
      "tdsId": 0,
      "schoolId": 0,
      "sectionId": 0,
      "subjectId": 0,
      "teacherId": 0
    }
  ],
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<PlannerTimeSlot?>? plannerTimeSlots;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetPlannerTimeSlotsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.plannerTimeSlots,
    this.responseStatus,
  });

  GetPlannerTimeSlotsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['plannerTimeSlots'] != null) {
      final v = json['plannerTimeSlots'];
      final arr0 = <PlannerTimeSlot>[];
      v.forEach((v) {
        arr0.add(PlannerTimeSlot.fromJson(v));
      });
      plannerTimeSlots = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (plannerTimeSlots != null) {
      final v = plannerTimeSlots;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['plannerTimeSlots'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetPlannerTimeSlotsResponse> getPlannerTimeSlots(GetPlannerTimeSlotsRequest getPlannerTimeSlotsRequest) async {
  debugPrint("Raising request to getPlannerTimeSlots with request ${jsonEncode(getPlannerTimeSlotsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_ACADEMIC_PLANNER_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  GetPlannerTimeSlotsResponse getPlannerTimeSlotsResponse = await HttpUtils.post(
    _url,
    getPlannerTimeSlotsRequest.toJson(),
    GetPlannerTimeSlotsResponse.fromJson,
  );

  debugPrint("GetPlannerTimeSlotsResponse ${getPlannerTimeSlotsResponse.toJson()}");
  return getPlannerTimeSlotsResponse;
}

// class PlannerTimeSlotDataSource extends CalendarDataSource {
//   PlannerTimeSlotDataSource(List<PlannerTimeSlot> source) {
//     appointments = source;
//   }
//
//   @override
//   DateTime getStartTime(int index) {
//     DateTime date = _getPlannerTimeSlotData(index).getDate()!;
//     TimeOfDay timeOfDay = _getPlannerTimeSlotData(index).getStartTime()!;
//     return DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute, 0);
//   }
//
//   @override
//   DateTime getEndTime(int index) {
//     DateTime date = _getPlannerTimeSlotData(index).getDate()!;
//     TimeOfDay timeOfDay = _getPlannerTimeSlotData(index).getEndTime()!;
//     return DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute, 0);
//   }
//
//   @override
//   String getSubject(int index) {
//     return "${_getPlannerTimeSlotData(index).subjectId}";
//   }
//
//   @override
//   Color getColor(int index) {
//     return Colors.blue;
//   }
//
//   @override
//   bool isAllDay(int index) {
//     return false;
//   }
//
//   PlannerTimeSlot _getPlannerTimeSlotData(int index) {
//     final dynamic meeting = appointments![index];
//     late final PlannerTimeSlot meetingData;
//     if (meeting is PlannerTimeSlot) {
//       meetingData = meeting;
//     }
//
//     return meetingData;
//   }
// }
