import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/time_slot.dart';

class GetStudentAttendanceTimeSlotsRequest {
  int? attendanceTimeSlotId;
  String? date;
  int? schoolId;
  int? sectionId;
  String? status;
  int? managerId;

  GetStudentAttendanceTimeSlotsRequest({
    attendanceTimeSlotId,
    date,
    schoolId,
    sectionId,
    status,
    managerId,
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

  GetStudentAttendanceTimeSlotsResponse(
      {attendanceTimeSlotBeans,
      errorCode,
      errorMessage,
      httpStatus,
      responseStatus});

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
      data['attendanceTimeSlotBeans'] =
          attendanceTimeSlotBeans!.map((v) => v.toJson()).toList();
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
  bool? isEdited;

  AttendanceTimeSlotBean(
      {agent,
      attendanceTimeSlotId,
      createTime,
      date,
      endTime,
      lastUpdated,
      managerId,
      managerName,
      sectionId,
      sectionName,
      startTime,
      status,
      validFrom,
      validThrough,
      week,
      weekId,
      isEdited});

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
    GetStudentAttendanceTimeSlotsRequest
        getStudentAttendanceTimeSlotsRequest) async {
  print(
      "Raising request to getStudentAttendanceTimeSlots with request ${jsonEncode(getStudentAttendanceTimeSlotsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_ATTENDANCE_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getStudentAttendanceTimeSlotsRequest.toJson()),
  );

  GetStudentAttendanceTimeSlotsResponse getStudentAttendanceTimeSlotsResponse =
      GetStudentAttendanceTimeSlotsResponse.fromJson(
          json.decode(response.body));
  print(
      "GetStudentAttendanceTimeSlotsResponse ${getStudentAttendanceTimeSlotsResponse.toJson()}");
  return getStudentAttendanceTimeSlotsResponse;
}

class CreateOrUpdateAttendanceTimeSlotBeansRequest {
  int? agent;
  List<AttendanceTimeSlotBean>? attendanceTimeSlotBeans;
  int? schoolId;

  CreateOrUpdateAttendanceTimeSlotBeansRequest(
      {agent, attendanceTimeSlotBeans, schoolId});

  CreateOrUpdateAttendanceTimeSlotBeansRequest.fromJson(
      Map<String, dynamic> json) {
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
      data['attendanceTimeSlotBeans'] =
          attendanceTimeSlotBeans!.map((v) => v.toJson()).toList();
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

  CreateOrUpdateAttendanceTimeSlotBeansResponse(
      {errorCode, errorMessage, httpStatus, responseStatus});

  CreateOrUpdateAttendanceTimeSlotBeansResponse.fromJson(
      Map<String, dynamic> json) {
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

Future<CreateOrUpdateAttendanceTimeSlotBeansResponse>
    createOrUpdateAttendanceTimeSlotBeans(
        CreateOrUpdateAttendanceTimeSlotBeansRequest
            createOrUpdateAttendanceTimeSlotBeansRequest) async {
  print(
      "Raising request to createOrUpdateAttendanceTimeSlotBeans with request ${jsonEncode(createOrUpdateAttendanceTimeSlotBeansRequest.toJson())}");
  String _url =
      SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDENT_ATTENDANCE_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateAttendanceTimeSlotBeansRequest.toJson()),
  );

  CreateOrUpdateAttendanceTimeSlotBeansResponse
      createOrUpdateAttendanceTimeSlotBeansResponse =
      CreateOrUpdateAttendanceTimeSlotBeansResponse.fromJson(
          json.decode(response.body));
  print(
      "createOrUpdateAttendanceTimeSlotBeansResponse ${createOrUpdateAttendanceTimeSlotBeansResponse.toJson()}");
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

  GetStudentAttendanceBeansRequest(
      {this.attendanceTimeSlotId,
      this.date,
      this.endDate,
      this.onlineClassRoomId,
      this.schoolId,
      this.sectionId,
      this.startDate,
      this.studentId,
      this.teacherId});

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

  GetStudentAttendanceBeansResponse(
      {attendanceTimeSlotBeans,
      errorCode,
      errorMessage,
      httpStatus,
      responseStatus,
      studentAttendanceBeans});

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
      data['attendanceTimeSlotBeans'] =
          attendanceTimeSlotBeans!.map((v) => v.toJson()).toList();
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentAttendanceBeans != null) {
      data['studentAttendanceBeans'] =
          studentAttendanceBeans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StudentAttendanceBean {
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

  bool? isEdited;

  StudentAttendanceBean(
      {agent,
      atsAgent,
      atsStatus,
      attendanceId,
      attendanceTimeSlotId,
      date,
      endTime,
      isPresent,
      managerId,
      managerName,
      markedBy,
      markedById,
      sectionId,
      sectionName,
      startTime,
      status,
      studentId,
      studentName,
      studentRollNumber,
      validFrom,
      validThrough,
      week,
      weekId});

  StudentAttendanceBean.fromJson(Map<String, dynamic> json) {
    agent = json['agent'];
    atsAgent = json['atsAgent'];
    atsStatus = json['atsStatus'];
    attendanceId = json['attendanceId'];
    attendanceTimeSlotId = json['attendanceTimeSlotId'];
    date = json['date'];
    endTime = json['endTime'];
    isPresent = json['isPresent'];
    managerId = json['managerId'];
    managerName = json['managerName'];
    markedBy = json['markedBy'];
    markedById = json['markedById'];
    sectionId = json['sectionId'];
    sectionName = json['sectionName'];
    startTime = json['startTime'];
    status = json['status'];
    studentId = json['studentId'];
    studentName = json['studentName'];
    studentRollNumber = json['studentRollNumber'];
    validFrom = json['validFrom'];
    validThrough = json['validThrough'];
    week = json['week'];
    weekId = json['weekId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
}

Future<GetStudentAttendanceBeansResponse> getStudentAttendanceBeans(
    GetStudentAttendanceBeansRequest getStudentAttendanceBeansRequest) async {
  print(
      "Raising request to getStudentAttendanceBeans with request ${jsonEncode(getStudentAttendanceBeansRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_ATTENDANCE_BEANS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getStudentAttendanceBeansRequest.toJson()),
  );

  GetStudentAttendanceBeansResponse getStudentAttendanceBeansResponse =
      GetStudentAttendanceBeansResponse.fromJson(json.decode(response.body));
  print(
      "GetStudentAttendanceBeansResponse ${getStudentAttendanceBeansResponse.toJson()}");
  return getStudentAttendanceBeansResponse;
}

class CreateOrUpdateStudentAttendanceRequest {
  int? agent;
  int? schoolId;
  List<StudentAttendanceBean>? studentAttendanceBeans;

  CreateOrUpdateStudentAttendanceRequest(
      {agent, schoolId, studentAttendanceBeans});

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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['agent'] = agent;
    data['schoolId'] = schoolId;
    if (studentAttendanceBeans != null) {
      data['studentAttendanceBeans'] =
          studentAttendanceBeans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CreateOrUpdateStudentAttendanceResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  CreateOrUpdateStudentAttendanceResponse(
      {errorCode, errorMessage, httpStatus, responseStatus});

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
    CreateOrUpdateStudentAttendanceRequest
        createOrUpdateStudentAttendanceRequest) async {
  print(
      "Raising request to createOrUpdateStudentAttendance with request ${jsonEncode(createOrUpdateStudentAttendanceRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDENT_ATTENDANCE_BEANS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateStudentAttendanceRequest.toJson()),
  );

  CreateOrUpdateStudentAttendanceResponse
      createOrUpdateStudentAttendanceResponse =
      CreateOrUpdateStudentAttendanceResponse.fromJson(
          json.decode(response.body));
  print(
      "createOrUpdateStudentAttendanceResponse ${createOrUpdateStudentAttendanceResponse.toJson()}");
  return createOrUpdateStudentAttendanceResponse;
}

class BulkEditAttendanceTimeSlotsRequest {
  int? agent;
  int? schoolId;
  List<int>? sectionIds;
  List<TimeSlot>? timeSlots;
  List<int>? weekIds;

  BulkEditAttendanceTimeSlotsRequest(
      {agent, schoolId, sectionIds, timeSlots, weekIds});

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

  BulkEditAttendanceTimeSlotsResponse(
      {errorCode, errorMessage, httpStatus, responseStatus});

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

Future<BulkEditAttendanceTimeSlotsResponse> bulkEditAttendanceTimeSlots(
    BulkEditAttendanceTimeSlotsRequest
        bulkEditAttendanceTimeSlotsRequest) async {
  print(
      "Raising request to bulkEditAttendanceTimeSlots with request ${jsonEncode(bulkEditAttendanceTimeSlotsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + BULK_EDIT_ATTENDANCE_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(bulkEditAttendanceTimeSlotsRequest.toJson()),
  );

  BulkEditAttendanceTimeSlotsResponse bulkEditAttendanceTimeSlotsResponse =
      BulkEditAttendanceTimeSlotsResponse.fromJson(json.decode(response.body));
  print(
      "bulkEditAttendanceTimeSlotsResponse ${bulkEditAttendanceTimeSlotsResponse.toJson()}");
  return bulkEditAttendanceTimeSlotsResponse;
}
