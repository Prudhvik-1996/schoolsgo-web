import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetCalenderEventsRequest {
  String? endDate;
  int? eventId;
  int? schoolId;
  int? sectionId;
  String? startDate;
  Map<String, dynamic> __origJson = {};

  GetCalenderEventsRequest({
    this.endDate,
    this.eventId,
    this.schoolId,
    this.sectionId,
    this.startDate,
  });

  GetCalenderEventsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    endDate = json['endDate']?.toString();
    eventId = json['eventId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    startDate = json['startDate']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['endDate'] = endDate;
    data['eventId'] = eventId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['startDate'] = startDate;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class SectionWiseEventBean {
  int? agentId;
  String? description;
  int? eventId;
  int? sectionId;
  String? sectionName;
  int? sectionWiseEventId;
  String? status;
  Map<String, dynamic> __origJson = {};

  SectionWiseEventBean({
    this.agentId,
    this.description,
    this.eventId,
    this.sectionId,
    this.sectionName,
    this.sectionWiseEventId,
    this.status,
  });

  SectionWiseEventBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    description = json['description']?.toString();
    eventId = json['eventId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    sectionWiseEventId = json['sectionWiseEventId']?.toInt();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['description'] = description;
    data['eventId'] = eventId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['sectionWiseEventId'] = sectionWiseEventId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CalenderEvent {
  int? agentId;
  String? color;
  String? description;
  String? endDate;
  int? eventId;
  String? isHoliday;
  List<SectionWiseEventBean?>? sectionWiseEventBeanList;
  String? startDate;
  String? status;
  String? subject;
  Map<String, dynamic> __origJson = {};

  List<DateTime> expandedDates = [];

  String getColorCode() {
    color ??= Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0).toHexString();
    return color!;
  }

  Color getColor() => Color(int.parse(getColorCode().substring(1, 7), radix: 16) + 0xFF000000);

  CalenderEvent({
    this.agentId,
    this.color,
    this.description,
    this.endDate,
    this.eventId,
    this.isHoliday,
    this.sectionWiseEventBeanList,
    this.startDate,
    this.status,
    this.subject,
  }) {
    getColorCode();
  }

  CalenderEvent.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    color = json['color']?.toString();
    description = json['description']?.toString();
    endDate = json['endDate']?.toString();
    eventId = json['eventId']?.toInt();
    isHoliday = json['isHoliday']?.toString();
    if (json['sectionWiseEventBeanList'] != null) {
      final v = json['sectionWiseEventBeanList'];
      final arr0 = <SectionWiseEventBean>[];
      v.forEach((v) {
        arr0.add(SectionWiseEventBean.fromJson(v));
      });
      sectionWiseEventBeanList = arr0;
    }
    startDate = json['startDate']?.toString();
    status = json['status']?.toString();
    subject = json['subject']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['color'] = color;
    data['description'] = description;
    data['endDate'] = endDate;
    data['eventId'] = eventId;
    data['isHoliday'] = isHoliday;
    if (sectionWiseEventBeanList != null) {
      final v = sectionWiseEventBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['sectionWiseEventBeanList'] = arr0;
    }
    data['startDate'] = startDate;
    data['status'] = status;
    data['subject'] = subject;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetCalenderEventsResponse {
  List<CalenderEvent?>? calenderEventList;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetCalenderEventsResponse({
    this.calenderEventList,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  GetCalenderEventsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['calenderEventList'] != null) {
      final v = json['calenderEventList'];
      final arr0 = <CalenderEvent>[];
      v.forEach((v) {
        arr0.add(CalenderEvent.fromJson(v));
      });
      calenderEventList = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (calenderEventList != null) {
      final v = calenderEventList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['calenderEventList'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetCalenderEventsResponse> getCalenderEvents(GetCalenderEventsRequest getCalenderEventsRequest) async {
  debugPrint("Raising request to getCalenderEvents with request ${jsonEncode(getCalenderEventsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_CALENDER_EVENTS;

  GetCalenderEventsResponse getCalenderEventsResponse = await HttpUtils.post(
    _url,
    getCalenderEventsRequest.toJson(),
    GetCalenderEventsResponse.fromJson,
  );

  debugPrint("GetCalenderEventsResponse ${getCalenderEventsResponse.toJson()}");
  return getCalenderEventsResponse;
}

class CreateOrUpdateCalenderEventsRequest {
  int? agentId;
  List<CalenderEvent?>? calenderEventBeans;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateCalenderEventsRequest({
    this.agentId,
    this.calenderEventBeans,
    this.schoolId,
  });

  CreateOrUpdateCalenderEventsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    if (json['calenderEventBeans'] != null) {
      final v = json['calenderEventBeans'];
      final arr0 = <CalenderEvent>[];
      v.forEach((v) {
        arr0.add(CalenderEvent.fromJson(v));
      });
      calenderEventBeans = arr0;
    }
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    if (calenderEventBeans != null) {
      final v = calenderEventBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['calenderEventBeans'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateCalenderEventsResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateCalenderEventsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateCalenderEventsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateCalenderEventsResponse> createOrUpdateCalenderEvents(
    CreateOrUpdateCalenderEventsRequest createOrUpdateCalenderEventsRequest) async {
  debugPrint("Raising request to createOrUpdateCalenderEvents with request ${jsonEncode(createOrUpdateCalenderEventsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_CALENDER_EVENTS;

  CreateOrUpdateCalenderEventsResponse createOrUpdateCalenderEventsResponse = await HttpUtils.post(
    _url,
    createOrUpdateCalenderEventsRequest.toJson(),
    CreateOrUpdateCalenderEventsResponse.fromJson,
  );

  debugPrint("CreateOrUpdateCalenderEventsResponse ${createOrUpdateCalenderEventsResponse.toJson()}");
  return createOrUpdateCalenderEventsResponse;
}
