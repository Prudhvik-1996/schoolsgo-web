import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/time_slot.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetStudentAttendanceTimeSlotsRequest {
  int? attendanceTimeSlotId;
  String? date;
  int? schoolId;
  int? sectionId;
  String? status;
  int? managerId;

  GetStudentAttendanceTimeSlotsRequest({
    this.attendanceTimeSlotId,
    this.date,
    this.schoolId,
    this.sectionId,
    this.status,
    this.managerId,
  });

  GetStudentAttendanceTimeSlotsRequest.fromJson(Map<String, dynamic> json) {
    attendanceTimeSlotId = json['attendanceTimeSlotId'];
    date = json['date'];
    schoolId = json['schoolId'];
    sectionId = json['sectionId'];
    status = json['status'];
    managerId = json['managerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attendanceTimeSlotId'] = attendanceTimeSlotId;
    data['date'] = date;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['status'] = status;
    data['managerId'] = managerId;
    return data;
  }
}

class GetStudentAttendanceTimeSlotsResponse {
  List<AttendanceTimeSlotBean>? attendanceTimeSlotBeans;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  GetStudentAttendanceTimeSlotsResponse({
    this.attendanceTimeSlotBeans,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  GetStudentAttendanceTimeSlotsResponse.fromJson(Map<String, dynamic> json) {
    if (json['attendanceTimeSlotBeans'] != null) {
      attendanceTimeSlotBeans = <AttendanceTimeSlotBean>[];
      json['attendanceTimeSlotBeans'].forEach((v) {
        attendanceTimeSlotBeans!.add(AttendanceTimeSlotBean.fromJson(v));
      });
    }
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attendanceTimeSlotBeans != null) {
      data['attendanceTimeSlotBeans'] = attendanceTimeSlotBeans!.map((v) => v.toJson()).toList();
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

class AttendanceTimeSlotBean {
  int? agent;
  int? attendanceTimeSlotId;
  String? createTime;
  String? date;
  String? endTime;
  String? lastUpdated;
  int? managerId;
  String? managerName;
  int? sectionId;
  String? sectionName;
  String? startTime;
  String? status;
  String? validFrom;
  String? validThrough;
  String? week;
  int? weekId;
  bool isEdited = false;

  AttendanceTimeSlotBean({
    this.agent,
    this.attendanceTimeSlotId,
    this.createTime,
    this.date,
    this.endTime,
    this.lastUpdated,
    this.managerId,
    this.managerName,
    this.sectionId,
    this.sectionName,
    this.startTime,
    this.status,
    this.validFrom,
    this.validThrough,
    this.week,
    this.weekId,
  });

  AttendanceTimeSlotBean.fromJson(Map<String, dynamic> json) {
    agent = json['agent'];
    attendanceTimeSlotId = json['attendanceTimeSlotId'];
    createTime = json['createTime'];
    date = json['date'];
    endTime = json['endTime'];
    lastUpdated = json['lastUpdated'];
    managerId = json['managerId'];
    managerName = json['managerName'];
    sectionId = json['sectionId'];
    sectionName = json['sectionName'];
    startTime = json['startTime'];
    status = json['status'];
    validFrom = json['validFrom'];
    validThrough = json['validThrough'];
    week = json['week'];
    weekId = json['weekId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agent'] = agent;
    data['attendanceTimeSlotId'] = attendanceTimeSlotId;
    data['createTime'] = createTime;
    data['date'] = date;
    data['endTime'] = endTime;
    data['lastUpdated'] = lastUpdated;
    data['managerId'] = managerId;
    data['managerName'] = managerName;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['startTime'] = startTime;
    data['status'] = status;
    data['validFrom'] = validFrom;
    data['validThrough'] = validThrough;
    data['week'] = week;
    data['weekId'] = weekId;
    return data;
  }
}

Future<GetStudentAttendanceTimeSlotsResponse> getStudentAttendanceTimeSlots(
    GetStudentAttendanceTimeSlotsRequest getStudentAttendanceTimeSlotsRequest) async {
  debugPrint("Raising request to getStudentAttendanceTimeSlots with request ${jsonEncode(getStudentAttendanceTimeSlotsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_ATTENDANCE_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getStudentAttendanceTimeSlotsRequest.toJson()),
  );

  GetStudentAttendanceTimeSlotsResponse getStudentAttendanceTimeSlotsResponse =
      GetStudentAttendanceTimeSlotsResponse.fromJson(json.decode(response.body));
  debugPrint("GetStudentAttendanceTimeSlotsResponse ${getStudentAttendanceTimeSlotsResponse.toJson()}");
  return getStudentAttendanceTimeSlotsResponse;
}

class CreateOrUpdateAttendanceTimeSlotBeansRequest {
  int? agent;
  List<AttendanceTimeSlotBean>? attendanceTimeSlotBeans;
  int? schoolId;

  CreateOrUpdateAttendanceTimeSlotBeansRequest({
    this.agent,
    this.attendanceTimeSlotBeans,
    this.schoolId,
  });

  CreateOrUpdateAttendanceTimeSlotBeansRequest.fromJson(Map<String, dynamic> json) {
    agent = json['agent'];
    if (json['attendanceTimeSlotBeans'] != null) {
      attendanceTimeSlotBeans = <AttendanceTimeSlotBean>[];
      json['attendanceTimeSlotBeans'].forEach((v) {
        attendanceTimeSlotBeans!.add(AttendanceTimeSlotBean.fromJson(v));
      });
    }
    schoolId = json['schoolId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agent'] = agent;
    if (attendanceTimeSlotBeans != null) {
      data['attendanceTimeSlotBeans'] = attendanceTimeSlotBeans!.map((v) => v.toJson()).toList();
    }
    data['schoolId'] = schoolId;
    return data;
  }
}

class CreateOrUpdateAttendanceTimeSlotBeansResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  CreateOrUpdateAttendanceTimeSlotBeansResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateAttendanceTimeSlotBeansResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<CreateOrUpdateAttendanceTimeSlotBeansResponse> createOrUpdateAttendanceTimeSlotBeans(
    CreateOrUpdateAttendanceTimeSlotBeansRequest createOrUpdateAttendanceTimeSlotBeansRequest) async {
  debugPrint(
      "Raising request to createOrUpdateAttendanceTimeSlotBeans with request ${jsonEncode(createOrUpdateAttendanceTimeSlotBeansRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDENT_ATTENDANCE_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateAttendanceTimeSlotBeansRequest.toJson()),
  );

  CreateOrUpdateAttendanceTimeSlotBeansResponse createOrUpdateAttendanceTimeSlotBeansResponse =
      CreateOrUpdateAttendanceTimeSlotBeansResponse.fromJson(json.decode(response.body));
  debugPrint("createOrUpdateAttendanceTimeSlotBeansResponse ${createOrUpdateAttendanceTimeSlotBeansResponse.toJson()}");
  return createOrUpdateAttendanceTimeSlotBeansResponse;
}

class GetStudentAttendanceBeansRequest {
  int? attendanceTimeSlotId;
  String? date;
  String? endDate;
  int? onlineClassRoomId;
  int? schoolId;
  int? sectionId;
  String? startDate;
  int? studentId;
  int? teacherId;

  List<int?>? sectionIds;

  GetStudentAttendanceBeansRequest({
    this.attendanceTimeSlotId,
    this.date,
    this.endDate,
    this.onlineClassRoomId,
    this.schoolId,
    this.sectionId,
    this.startDate,
    this.studentId,
    this.teacherId,
    this.sectionIds,
  });

  GetStudentAttendanceBeansRequest.fromJson(Map<String, dynamic> json) {
    attendanceTimeSlotId = json['attendanceTimeSlotId'];
    date = json['date'];
    endDate = json['endDate'];
    onlineClassRoomId = json['onlineClassRoomId'];
    schoolId = json['schoolId'];
    sectionId = json['sectionId'];
    startDate = json['startDate'];
    studentId = json['studentId'];
    teacherId = json['teacherId'];
    if (json['sectionIds'] != null) {
      final v = json['sectionIds'];
      final arr0 = <int?>[];
      v.forEach((v) {
        arr0.add(int.tryParse(v));
      });
      sectionIds = arr0.toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attendanceTimeSlotId'] = attendanceTimeSlotId;
    data['date'] = date;
    data['endDate'] = endDate;
    data['onlineClassRoomId'] = onlineClassRoomId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['startDate'] = startDate;
    data['studentId'] = studentId;
    data['teacherId'] = teacherId;
    data['sectionIds'] = sectionIds;
    return data;
  }
}

class GetStudentAttendanceBeansResponse {
  List<AttendanceTimeSlotBean>? attendanceTimeSlotBeans;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentAttendanceBean>? studentAttendanceBeans;

  GetStudentAttendanceBeansResponse({
    this.attendanceTimeSlotBeans,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentAttendanceBeans,
  });

  GetStudentAttendanceBeansResponse.fromJson(Map<String, dynamic> json) {
    if (json['attendanceTimeSlotBeans'] != null) {
      attendanceTimeSlotBeans = <AttendanceTimeSlotBean>[];
      json['attendanceTimeSlotBeans'].forEach((v) {
        attendanceTimeSlotBeans!.add(AttendanceTimeSlotBean.fromJson(v));
      });
    }
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
    if (json['studentAttendanceBeans'] != null) {
      studentAttendanceBeans = <StudentAttendanceBean>[];
      json['studentAttendanceBeans'].forEach((v) {
        studentAttendanceBeans!.add(StudentAttendanceBean.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attendanceTimeSlotBeans != null) {
      data['attendanceTimeSlotBeans'] = attendanceTimeSlotBeans!.map((v) => v.toJson()).toList();
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentAttendanceBeans != null) {
      data['studentAttendanceBeans'] = studentAttendanceBeans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StudentAttendanceBean {
/*
{
  "agent": 0,
  "atsAgent": 0,
  "atsStatus": "active",
  "attendanceId": 0,
  "attendanceTimeSlotId": 0,
  "date": "string",
  "endTime": "",
  "isPresent": 0,
  "managerId": 0,
  "managerName": "string",
  "markedBy": "string",
  "markedById": 0,
  "sectionId": 0,
  "sectionName": "string",
  "startTime": "",
  "status": "active",
  "studentId": 0,
  "studentName": "string",
  "studentRollNumber": 0,
  "validFrom": "string",
  "validThrough": "string",
  "week": "string",
  "weekId": 0
}
*/

  int? agent;
  int? atsAgent;
  String? atsStatus;
  int? attendanceId;
  int? attendanceTimeSlotId;
  String? date;
  String? endTime;
  int? isPresent;
  int? managerId;
  String? managerName;
  String? markedBy;
  int? markedById;
  int? sectionId;
  String? sectionName;
  String? startTime;
  String? status;
  int? studentId;
  String? studentName;
  int? studentRollNumber;
  String? validFrom;
  String? validThrough;
  String? week;
  int? weekId;
  Map<String, dynamic> __origJson = {};

  bool isEdited = false;

  StudentAttendanceBean({
    this.agent,
    this.atsAgent,
    this.atsStatus,
    this.attendanceId,
    this.attendanceTimeSlotId,
    this.date,
    this.endTime,
    this.isPresent,
    this.managerId,
    this.managerName,
    this.markedBy,
    this.markedById,
    this.sectionId,
    this.sectionName,
    this.startTime,
    this.status,
    this.studentId,
    this.studentName,
    this.studentRollNumber,
    this.validFrom,
    this.validThrough,
    this.week,
    this.weekId,
  });
  StudentAttendanceBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    atsAgent = json['atsAgent']?.toInt();
    atsStatus = json['atsStatus']?.toString();
    attendanceId = json['attendanceId']?.toInt();
    attendanceTimeSlotId = json['attendanceTimeSlotId']?.toInt();
    date = json['date']?.toString();
    endTime = json['endTime']?.toString();
    isPresent = json['isPresent']?.toInt();
    managerId = json['managerId']?.toInt();
    managerName = json['managerName']?.toString();
    markedBy = json['markedBy']?.toString();
    markedById = json['markedById']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    startTime = json['startTime']?.toString();
    status = json['status']?.toString();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    studentRollNumber = json['studentRollNumber']?.toInt();
    validFrom = json['validFrom']?.toString();
    validThrough = json['validThrough']?.toString();
    week = json['week']?.toString();
    weekId = json['weekId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['atsAgent'] = atsAgent;
    data['atsStatus'] = atsStatus;
    data['attendanceId'] = attendanceId;
    data['attendanceTimeSlotId'] = attendanceTimeSlotId;
    data['date'] = date;
    data['endTime'] = endTime;
    data['isPresent'] = isPresent;
    data['managerId'] = managerId;
    data['managerName'] = managerName;
    data['markedBy'] = markedBy;
    data['markedById'] = markedById;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['startTime'] = startTime;
    data['status'] = status;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['studentRollNumber'] = studentRollNumber;
    data['validFrom'] = validFrom;
    data['validThrough'] = validThrough;
    data['week'] = week;
    data['weekId'] = weekId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentAttendanceBeansResponse> getStudentAttendanceBeans(GetStudentAttendanceBeansRequest getStudentAttendanceBeansRequest) async {
  debugPrint("Raising request to getStudentAttendanceBeans with request ${jsonEncode(getStudentAttendanceBeansRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_ATTENDANCE_BEANS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getStudentAttendanceBeansRequest.toJson()),
  );

  GetStudentAttendanceBeansResponse getStudentAttendanceBeansResponse = GetStudentAttendanceBeansResponse.fromJson(json.decode(response.body));
  debugPrint("GetStudentAttendanceBeansResponse ${getStudentAttendanceBeansResponse.toJson()}");
  return getStudentAttendanceBeansResponse;
}

class CreateOrUpdateStudentAttendanceRequest {
  int? agent;
  int? schoolId;
  List<StudentAttendanceBean>? studentAttendanceBeans;

  CreateOrUpdateStudentAttendanceRequest({
    this.agent,
    this.schoolId,
    this.studentAttendanceBeans,
  });

  CreateOrUpdateStudentAttendanceRequest.fromJson(Map<String, dynamic> json) {
    agent = json['agent'];
    schoolId = json['schoolId'];
    if (json['studentAttendanceBeans'] != null) {
      studentAttendanceBeans = <StudentAttendanceBean>[];
      json['studentAttendanceBeans'].forEach((v) {
        studentAttendanceBeans!.add(StudentAttendanceBean.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agent'] = agent;
    data['schoolId'] = schoolId;
    if (studentAttendanceBeans != null) {
      data['studentAttendanceBeans'] = studentAttendanceBeans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CreateOrUpdateStudentAttendanceResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  CreateOrUpdateStudentAttendanceResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateStudentAttendanceResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<CreateOrUpdateStudentAttendanceResponse> createOrUpdateStudentAttendance(
    CreateOrUpdateStudentAttendanceRequest createOrUpdateStudentAttendanceRequest) async {
  debugPrint("Raising request to createOrUpdateStudentAttendance with request ${jsonEncode(createOrUpdateStudentAttendanceRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDENT_ATTENDANCE_BEANS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateStudentAttendanceRequest.toJson()),
  );

  CreateOrUpdateStudentAttendanceResponse createOrUpdateStudentAttendanceResponse =
      CreateOrUpdateStudentAttendanceResponse.fromJson(json.decode(response.body));
  debugPrint("createOrUpdateStudentAttendanceResponse ${createOrUpdateStudentAttendanceResponse.toJson()}");
  return createOrUpdateStudentAttendanceResponse;
}

class BulkEditAttendanceTimeSlotsRequest {
  int? agent;
  int? schoolId;
  List<int>? sectionIds;
  List<TimeSlot>? timeSlots;
  List<int>? weekIds;

  BulkEditAttendanceTimeSlotsRequest({
    this.agent,
    this.schoolId,
    this.sectionIds,
    this.timeSlots,
    this.weekIds,
  });

  BulkEditAttendanceTimeSlotsRequest.fromJson(Map<String, dynamic> json) {
    agent = json['agent'];
    schoolId = json['schoolId'];
    sectionIds = json['sectionIds'].cast<int>();
    if (json['timeSlots'] != null) {
      timeSlots = <TimeSlot>[];
      json['timeSlots'].forEach((v) {
        timeSlots!.add(TimeSlot.fromJson(v));
      });
    }
    weekIds = json['weekIds'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agent'] = agent;
    data['schoolId'] = schoolId;
    data['sectionIds'] = sectionIds;
    if (timeSlots != null) {
      data['timeSlots'] = timeSlots!.map((v) => v.toJson()).toList();
    }
    data['weekIds'] = weekIds;
    return data;
  }
}

class BulkEditAttendanceTimeSlotsResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  BulkEditAttendanceTimeSlotsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  BulkEditAttendanceTimeSlotsResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<BulkEditAttendanceTimeSlotsResponse> bulkEditAttendanceTimeSlots(BulkEditAttendanceTimeSlotsRequest bulkEditAttendanceTimeSlotsRequest) async {
  debugPrint("Raising request to bulkEditAttendanceTimeSlots with request ${jsonEncode(bulkEditAttendanceTimeSlotsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + BULK_EDIT_ATTENDANCE_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(bulkEditAttendanceTimeSlotsRequest.toJson()),
  );

  BulkEditAttendanceTimeSlotsResponse bulkEditAttendanceTimeSlotsResponse = BulkEditAttendanceTimeSlotsResponse.fromJson(json.decode(response.body));
  debugPrint("bulkEditAttendanceTimeSlotsResponse ${bulkEditAttendanceTimeSlotsResponse.toJson()}");
  return bulkEditAttendanceTimeSlotsResponse;
}

Future<List<int>> getStudentAttendanceReport(GetStudentAttendanceBeansRequest getStudentAttendanceBeansRequest) async {
  debugPrint("Raising request to getStudentAttendanceReport with request ${jsonEncode(getStudentAttendanceBeansRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_ATTENDANCE_REPORT;
  return await HttpUtils.postToDownloadFile(_url, getStudentAttendanceBeansRequest.toJson());
}
