import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

import 'admin_exams.dart';

class GetExamsRequest {
/*
{
  "examId": 0,
  "examType": "SLIP_TEST",
  "schoolId": 0,
  "sectionId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  int? examId;
  String? examType;
  int? schoolId;
  int? sectionId;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetExamsRequest({
    this.examId,
    this.examType,
    this.schoolId,
    this.sectionId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });
  GetExamsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    examId = json['examId']?.toInt();
    examType = json['examType']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['examId'] = examId;
    data['examType'] = examType;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class Exam {
/*
{
  "agent": "string",
  "examId": 0,
  "examName": "string",
  "examStartDate": "string",
  "examStatus": "active",
  "examType": "SLIP_TEST",
  "markingAlgorithmId": 0,
  "markingAlgorithmName": "string",
  "markingSchemeCode": "A",
  "schoolId": 0,
  "schoolName": "string"
}
*/

  String? agent;
  int? examId;
  String? examName;
  String? examStartDate;
  String? examStatus;
  String? examType;
  int? markingAlgorithmId;
  String? markingAlgorithmName;
  String? markingSchemeCode;
  int? schoolId;
  String? schoolName;
  Map<String, dynamic> __origJson = {};

  Exam({
    this.agent,
    this.examId,
    this.examName,
    this.examStartDate,
    this.examStatus,
    this.examType,
    this.markingAlgorithmId,
    this.markingAlgorithmName,
    this.markingSchemeCode,
    this.schoolId,
    this.schoolName,
  });
  Exam.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examStartDate = json['examStartDate']?.toString();
    examStatus = json['examStatus']?.toString();
    examType = json['examType']?.toString();
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    markingAlgorithmName = json['markingAlgorithmName']?.toString();
    markingSchemeCode = json['markingSchemeCode']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['examId'] = examId;
    data['examName'] = examName;
    data['examStartDate'] = examStartDate;
    data['examStatus'] = examStatus;
    data['examType'] = examType;
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['markingAlgorithmName'] = markingAlgorithmName;
    data['markingSchemeCode'] = markingSchemeCode;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetExamsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "exams": [
    {
      "agent": "string",
      "examId": 0,
      "examName": "string",
      "examStartDate": "string",
      "examStatus": "active",
      "examType": "SLIP_TEST",
      "markingAlgorithmId": 0,
      "markingAlgorithmName": "string",
      "markingSchemeCode": "A",
      "schoolId": 0,
      "schoolName": "string"
    }
  ],
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  List<Exam?>? exams;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetExamsResponse({
    this.errorCode,
    this.errorMessage,
    this.exams,
    this.httpStatus,
    this.responseStatus,
  });
  GetExamsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    if (json['exams'] != null) {
      final v = json['exams'];
      final arr0 = <Exam>[];
      v.forEach((v) {
        arr0.add(Exam.fromJson(v));
      });
      exams = arr0;
    }
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    if (exams != null) {
      final v = exams;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['exams'] = arr0;
    }
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetExamsResponse> getExams(GetExamsRequest getExamsRequest) async {
  print("Raising request to getExams with request ${jsonEncode(getExamsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_EXAMS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getExamsRequest.toJson()),
  );

  GetExamsResponse getExamsResponse = GetExamsResponse.fromJson(json.decode(response.body));
  print("GetExamsResponse ${getExamsResponse.toJson()}");
  return getExamsResponse;
}

class GetStudentExamBytesRequestStudentProfile {
/*
{
  "balanceAmount": 0,
  "fatherName": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "gaurdianFirstName": "string",
  "gaurdianId": 0,
  "gaurdianLastName": "string",
  "gaurdianMailId": "string",
  "gaurdianMiddleName": "string",
  "gaurdianMobile": "string",
  "motherName": "string",
  "rollNumber": "string",
  "schoolId": 0,
  "schoolName": "string",
  "schoolPhotoUrl": "string",
  "sectionDescription": "string",
  "sectionId": 0,
  "sectionName": "string",
  "studentDob": "string",
  "studentFirstName": "string",
  "studentId": 0,
  "studentLastName": "string",
  "studentMailId": "string",
  "studentMiddleName": "string",
  "studentMobile": "string",
  "studentPhotoUrl": "string"
}
*/

  int? balanceAmount;
  String? fatherName;
  int? franchiseId;
  String? franchiseName;
  String? gaurdianFirstName;
  int? gaurdianId;
  String? gaurdianLastName;
  String? gaurdianMailId;
  String? gaurdianMiddleName;
  String? gaurdianMobile;
  String? motherName;
  String? rollNumber;
  int? schoolId;
  String? schoolName;
  String? schoolPhotoUrl;
  String? sectionDescription;
  int? sectionId;
  String? sectionName;
  String? studentDob;
  String? studentFirstName;
  int? studentId;
  String? studentLastName;
  String? studentMailId;
  String? studentMiddleName;
  String? studentMobile;
  String? studentPhotoUrl;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequestStudentProfile({
    this.balanceAmount,
    this.fatherName,
    this.franchiseId,
    this.franchiseName,
    this.gaurdianFirstName,
    this.gaurdianId,
    this.gaurdianLastName,
    this.gaurdianMailId,
    this.gaurdianMiddleName,
    this.gaurdianMobile,
    this.motherName,
    this.rollNumber,
    this.schoolId,
    this.schoolName,
    this.schoolPhotoUrl,
    this.sectionDescription,
    this.sectionId,
    this.sectionName,
    this.studentDob,
    this.studentFirstName,
    this.studentId,
    this.studentLastName,
    this.studentMailId,
    this.studentMiddleName,
    this.studentMobile,
    this.studentPhotoUrl,
  });
  GetStudentExamBytesRequestStudentProfile.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    balanceAmount = json['balanceAmount']?.toInt();
    fatherName = json['fatherName']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    gaurdianFirstName = json['gaurdianFirstName']?.toString();
    gaurdianId = json['gaurdianId']?.toInt();
    gaurdianLastName = json['gaurdianLastName']?.toString();
    gaurdianMailId = json['gaurdianMailId']?.toString();
    gaurdianMiddleName = json['gaurdianMiddleName']?.toString();
    gaurdianMobile = json['gaurdianMobile']?.toString();
    motherName = json['motherName']?.toString();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    sectionDescription = json['sectionDescription']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    studentDob = json['studentDob']?.toString();
    studentFirstName = json['studentFirstName']?.toString();
    studentId = json['studentId']?.toInt();
    studentLastName = json['studentLastName']?.toString();
    studentMailId = json['studentMailId']?.toString();
    studentMiddleName = json['studentMiddleName']?.toString();
    studentMobile = json['studentMobile']?.toString();
    studentPhotoUrl = json['studentPhotoUrl']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['balanceAmount'] = balanceAmount;
    data['fatherName'] = fatherName;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['gaurdianFirstName'] = gaurdianFirstName;
    data['gaurdianId'] = gaurdianId;
    data['gaurdianLastName'] = gaurdianLastName;
    data['gaurdianMailId'] = gaurdianMailId;
    data['gaurdianMiddleName'] = gaurdianMiddleName;
    data['gaurdianMobile'] = gaurdianMobile;
    data['motherName'] = motherName;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['sectionDescription'] = sectionDescription;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['studentDob'] = studentDob;
    data['studentFirstName'] = studentFirstName;
    data['studentId'] = studentId;
    data['studentLastName'] = studentLastName;
    data['studentMailId'] = studentMailId;
    data['studentMiddleName'] = studentMiddleName;
    data['studentMobile'] = studentMobile;
    data['studentPhotoUrl'] = studentPhotoUrl;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanListInternalsStartTime {
/*
{
  "date": 0,
  "day": 0,
  "hours": 0,
  "minutes": 0,
  "month": 0,
  "seconds": 0,
  "time": 0,
  "timezoneOffset": 0,
  "year": 0
}
*/

  int? date;
  int? day;
  int? hours;
  int? minutes;
  int? month;
  int? seconds;
  int? time;
  int? timezoneOffset;
  int? year;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanListInternalsStartTime({
    this.date,
    this.day,
    this.hours,
    this.minutes,
    this.month,
    this.seconds,
    this.time,
    this.timezoneOffset,
    this.year,
  });
  GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanListInternalsStartTime.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toInt();
    day = json['day']?.toInt();
    hours = json['hours']?.toInt();
    minutes = json['minutes']?.toInt();
    month = json['month']?.toInt();
    seconds = json['seconds']?.toInt();
    time = json['time']?.toInt();
    timezoneOffset = json['timezoneOffset']?.toInt();
    year = json['year']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['day'] = day;
    data['hours'] = hours;
    data['minutes'] = minutes;
    data['month'] = month;
    data['seconds'] = seconds;
    data['time'] = time;
    data['timezoneOffset'] = timezoneOffset;
    data['year'] = year;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanListInternalsEndTime {
/*
{
  "date": 0,
  "day": 0,
  "hours": 0,
  "minutes": 0,
  "month": 0,
  "seconds": 0,
  "time": 0,
  "timezoneOffset": 0,
  "year": 0
}
*/

  int? date;
  int? day;
  int? hours;
  int? minutes;
  int? month;
  int? seconds;
  int? time;
  int? timezoneOffset;
  int? year;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanListInternalsEndTime({
    this.date,
    this.day,
    this.hours,
    this.minutes,
    this.month,
    this.seconds,
    this.time,
    this.timezoneOffset,
    this.year,
  });
  GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanListInternalsEndTime.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toInt();
    day = json['day']?.toInt();
    hours = json['hours']?.toInt();
    minutes = json['minutes']?.toInt();
    month = json['month']?.toInt();
    seconds = json['seconds']?.toInt();
    time = json['time']?.toInt();
    timezoneOffset = json['timezoneOffset']?.toInt();
    year = json['year']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['day'] = day;
    data['hours'] = hours;
    data['minutes'] = minutes;
    data['month'] = month;
    data['seconds'] = seconds;
    data['time'] = time;
    data['timezoneOffset'] = timezoneOffset;
    data['year'] = year;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanList {
/*
{
  "examId": 0,
  "examName": "string",
  "examTdsMapId": 0,
  "examType": "SLIP_TEST",
  "internalExamId": 0,
  "internalExamName": "string",
  "internalExamType": "SLIP_TEST",
  "internalNumber": 0,
  "internalTdsId": 0,
  "internalTdsMapId": 0,
  "internalsComputationCode": "A",
  "internalsDate": "string",
  "internalsEndTime": {
    "date": 0,
    "day": 0,
    "hours": 0,
    "minutes": 0,
    "month": 0,
    "seconds": 0,
    "time": 0,
    "timezoneOffset": 0,
    "year": 0
  },
  "internalsMarksObtained": 0,
  "internalsMaxMarks": 0,
  "internalsSectionId": 0,
  "internalsSectionName": "string",
  "internalsStartTime": {
    "date": 0,
    "day": 0,
    "hours": 0,
    "minutes": 0,
    "month": 0,
    "seconds": 0,
    "time": 0,
    "timezoneOffset": 0,
    "year": 0
  },
  "internalsSubjectId": 0,
  "internalsSubjectName": "string",
  "internalsTeacherId": 0,
  "internalsTeacherName": "string",
  "rollNumber": "string",
  "schoolId": 0,
  "studentId": 0,
  "studentName": "string"
}
*/

  int? examId;
  String? examName;
  int? examTdsMapId;
  String? examType;
  int? internalExamId;
  String? internalExamName;
  String? internalExamType;
  int? internalNumber;
  int? internalTdsId;
  int? internalTdsMapId;
  String? internalsComputationCode;
  String? internalsDate;
  GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanListInternalsEndTime? internalsEndTime;
  int? internalsMarksObtained;
  int? internalsMaxMarks;
  int? internalsSectionId;
  String? internalsSectionName;
  GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanListInternalsStartTime? internalsStartTime;
  int? internalsSubjectId;
  String? internalsSubjectName;
  int? internalsTeacherId;
  String? internalsTeacherName;
  String? rollNumber;
  int? schoolId;
  int? studentId;
  String? studentName;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanList({
    this.examId,
    this.examName,
    this.examTdsMapId,
    this.examType,
    this.internalExamId,
    this.internalExamName,
    this.internalExamType,
    this.internalNumber,
    this.internalTdsId,
    this.internalTdsMapId,
    this.internalsComputationCode,
    this.internalsDate,
    this.internalsEndTime,
    this.internalsMarksObtained,
    this.internalsMaxMarks,
    this.internalsSectionId,
    this.internalsSectionName,
    this.internalsStartTime,
    this.internalsSubjectId,
    this.internalsSubjectName,
    this.internalsTeacherId,
    this.internalsTeacherName,
    this.rollNumber,
    this.schoolId,
    this.studentId,
    this.studentName,
  });
  GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanList.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examTdsMapId = json['examTdsMapId']?.toInt();
    examType = json['examType']?.toString();
    internalExamId = json['internalExamId']?.toInt();
    internalExamName = json['internalExamName']?.toString();
    internalExamType = json['internalExamType']?.toString();
    internalNumber = json['internalNumber']?.toInt();
    internalTdsId = json['internalTdsId']?.toInt();
    internalTdsMapId = json['internalTdsMapId']?.toInt();
    internalsComputationCode = json['internalsComputationCode']?.toString();
    internalsDate = json['internalsDate']?.toString();
    internalsEndTime = (json['internalsEndTime'] != null)
        ? GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanListInternalsEndTime.fromJson(
            json['internalsEndTime'])
        : null;
    internalsMarksObtained = json['internalsMarksObtained']?.toInt();
    internalsMaxMarks = json['internalsMaxMarks']?.toInt();
    internalsSectionId = json['internalsSectionId']?.toInt();
    internalsSectionName = json['internalsSectionName']?.toString();
    internalsStartTime = (json['internalsStartTime'] != null)
        ? GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanListInternalsStartTime.fromJson(
            json['internalsStartTime'])
        : null;
    internalsSubjectId = json['internalsSubjectId']?.toInt();
    internalsSubjectName = json['internalsSubjectName']?.toString();
    internalsTeacherId = json['internalsTeacherId']?.toInt();
    internalsTeacherName = json['internalsTeacherName']?.toString();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['examId'] = examId;
    data['examName'] = examName;
    data['examTdsMapId'] = examTdsMapId;
    data['examType'] = examType;
    data['internalExamId'] = internalExamId;
    data['internalExamName'] = internalExamName;
    data['internalExamType'] = internalExamType;
    data['internalNumber'] = internalNumber;
    data['internalTdsId'] = internalTdsId;
    data['internalTdsMapId'] = internalTdsMapId;
    data['internalsComputationCode'] = internalsComputationCode;
    data['internalsDate'] = internalsDate;
    if (internalsEndTime != null) {
      data['internalsEndTime'] = internalsEndTime!.toJson();
    }
    data['internalsMarksObtained'] = internalsMarksObtained;
    data['internalsMaxMarks'] = internalsMaxMarks;
    data['internalsSectionId'] = internalsSectionId;
    data['internalsSectionName'] = internalsSectionName;
    if (internalsStartTime != null) {
      data['internalsStartTime'] = internalsStartTime!.toJson();
    }
    data['internalsSubjectId'] = internalsSubjectId;
    data['internalsSubjectName'] = internalsSubjectName;
    data['internalsTeacherId'] = internalsTeacherId;
    data['internalsTeacherName'] = internalsTeacherName;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentExamBytesRequestStudentExamMarksDetailsListStartTime {
/*
{
  "date": 0,
  "day": 0,
  "hours": 0,
  "minutes": 0,
  "month": 0,
  "seconds": 0,
  "time": 0,
  "timezoneOffset": 0,
  "year": 0
}
*/

  int? date;
  int? day;
  int? hours;
  int? minutes;
  int? month;
  int? seconds;
  int? time;
  int? timezoneOffset;
  int? year;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequestStudentExamMarksDetailsListStartTime({
    this.date,
    this.day,
    this.hours,
    this.minutes,
    this.month,
    this.seconds,
    this.time,
    this.timezoneOffset,
    this.year,
  });
  GetStudentExamBytesRequestStudentExamMarksDetailsListStartTime.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toInt();
    day = json['day']?.toInt();
    hours = json['hours']?.toInt();
    minutes = json['minutes']?.toInt();
    month = json['month']?.toInt();
    seconds = json['seconds']?.toInt();
    time = json['time']?.toInt();
    timezoneOffset = json['timezoneOffset']?.toInt();
    year = json['year']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['day'] = day;
    data['hours'] = hours;
    data['minutes'] = minutes;
    data['month'] = month;
    data['seconds'] = seconds;
    data['time'] = time;
    data['timezoneOffset'] = timezoneOffset;
    data['year'] = year;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentExamBytesRequestStudentExamMarksDetailsListEndTime {
/*
{
  "date": 0,
  "day": 0,
  "hours": 0,
  "minutes": 0,
  "month": 0,
  "seconds": 0,
  "time": 0,
  "timezoneOffset": 0,
  "year": 0
}
*/

  int? date;
  int? day;
  int? hours;
  int? minutes;
  int? month;
  int? seconds;
  int? time;
  int? timezoneOffset;
  int? year;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequestStudentExamMarksDetailsListEndTime({
    this.date,
    this.day,
    this.hours,
    this.minutes,
    this.month,
    this.seconds,
    this.time,
    this.timezoneOffset,
    this.year,
  });
  GetStudentExamBytesRequestStudentExamMarksDetailsListEndTime.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toInt();
    day = json['day']?.toInt();
    hours = json['hours']?.toInt();
    minutes = json['minutes']?.toInt();
    month = json['month']?.toInt();
    seconds = json['seconds']?.toInt();
    time = json['time']?.toInt();
    timezoneOffset = json['timezoneOffset']?.toInt();
    year = json['year']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['day'] = day;
    data['hours'] = hours;
    data['minutes'] = minutes;
    data['month'] = month;
    data['seconds'] = seconds;
    data['time'] = time;
    data['timezoneOffset'] = timezoneOffset;
    data['year'] = year;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentExamBytesRequestStudentExamMarksDetailsList {
/*
{
  "date": "string",
  "endTime": {
    "date": 0,
    "day": 0,
    "hours": 0,
    "minutes": 0,
    "month": 0,
    "seconds": 0,
    "time": 0,
    "timezoneOffset": 0,
    "year": 0
  },
  "examId": 0,
  "examName": "string",
  "examTdsMapId": 0,
  "examType": "SLIP_TEST",
  "internalsComputationCode": "A",
  "internalsWeightage": 0,
  "marksObtained": 0,
  "maxMarks": 0,
  "rollNumber": "string",
  "schoolId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "startTime": {
    "date": 0,
    "day": 0,
    "hours": 0,
    "minutes": 0,
    "month": 0,
    "seconds": 0,
    "time": 0,
    "timezoneOffset": 0,
    "year": 0
  },
  "studentId": 0,
  "studentInternalExamMarksDetailsBeanList": [
    {
      "examId": 0,
      "examName": "string",
      "examTdsMapId": 0,
      "examType": "SLIP_TEST",
      "internalExamId": 0,
      "internalExamName": "string",
      "internalExamType": "SLIP_TEST",
      "internalNumber": 0,
      "internalTdsId": 0,
      "internalTdsMapId": 0,
      "internalsComputationCode": "A",
      "internalsDate": "string",
      "internalsEndTime": {
        "date": 0,
        "day": 0,
        "hours": 0,
        "minutes": 0,
        "month": 0,
        "seconds": 0,
        "time": 0,
        "timezoneOffset": 0,
        "year": 0
      },
      "internalsMarksObtained": 0,
      "internalsMaxMarks": 0,
      "internalsSectionId": 0,
      "internalsSectionName": "string",
      "internalsStartTime": {
        "date": 0,
        "day": 0,
        "hours": 0,
        "minutes": 0,
        "month": 0,
        "seconds": 0,
        "time": 0,
        "timezoneOffset": 0,
        "year": 0
      },
      "internalsSubjectId": 0,
      "internalsSubjectName": "string",
      "internalsTeacherId": 0,
      "internalsTeacherName": "string",
      "rollNumber": "string",
      "schoolId": 0,
      "studentId": 0,
      "studentName": "string"
    }
  ],
  "studentName": "string",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  String? date;
  GetStudentExamBytesRequestStudentExamMarksDetailsListEndTime? endTime;
  int? examId;
  String? examName;
  int? examTdsMapId;
  String? examType;
  String? internalsComputationCode;
  int? internalsWeightage;
  int? marksObtained;
  int? maxMarks;
  String? rollNumber;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  GetStudentExamBytesRequestStudentExamMarksDetailsListStartTime? startTime;
  int? studentId;
  List<GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanList?>? studentInternalExamMarksDetailsBeanList;
  String? studentName;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequestStudentExamMarksDetailsList({
    this.date,
    this.endTime,
    this.examId,
    this.examName,
    this.examTdsMapId,
    this.examType,
    this.internalsComputationCode,
    this.internalsWeightage,
    this.marksObtained,
    this.maxMarks,
    this.rollNumber,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.startTime,
    this.studentId,
    this.studentInternalExamMarksDetailsBeanList,
    this.studentName,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
  });
  GetStudentExamBytesRequestStudentExamMarksDetailsList.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toString();
    endTime = (json['endTime'] != null) ? GetStudentExamBytesRequestStudentExamMarksDetailsListEndTime.fromJson(json['endTime']) : null;
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examTdsMapId = json['examTdsMapId']?.toInt();
    examType = json['examType']?.toString();
    internalsComputationCode = json['internalsComputationCode']?.toString();
    internalsWeightage = json['internalsWeightage']?.toInt();
    marksObtained = json['marksObtained']?.toInt();
    maxMarks = json['maxMarks']?.toInt();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    startTime = (json['startTime'] != null) ? GetStudentExamBytesRequestStudentExamMarksDetailsListStartTime.fromJson(json['startTime']) : null;
    studentId = json['studentId']?.toInt();
    if (json['studentInternalExamMarksDetailsBeanList'] != null) {
      final v = json['studentInternalExamMarksDetailsBeanList'];
      final arr0 = <GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanList>[];
      v.forEach((v) {
        arr0.add(GetStudentExamBytesRequestStudentExamMarksDetailsListStudentInternalExamMarksDetailsBeanList.fromJson(v));
      });
      studentInternalExamMarksDetailsBeanList = arr0;
    }
    studentName = json['studentName']?.toString();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
    teacherName = json['teacherName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    if (endTime != null) {
      data['endTime'] = endTime!.toJson();
    }
    data['examId'] = examId;
    data['examName'] = examName;
    data['examTdsMapId'] = examTdsMapId;
    data['examType'] = examType;
    data['internalsComputationCode'] = internalsComputationCode;
    data['internalsWeightage'] = internalsWeightage;
    data['marksObtained'] = marksObtained;
    data['maxMarks'] = maxMarks;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    if (startTime != null) {
      data['startTime'] = startTime!.toJson();
    }
    data['studentId'] = studentId;
    if (studentInternalExamMarksDetailsBeanList != null) {
      final v = studentInternalExamMarksDetailsBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentInternalExamMarksDetailsBeanList'] = arr0;
    }
    data['studentName'] = studentName;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentExamBytesRequestMarkingAlgorithmBeanMarkingAlgorithmRangeBeanList {
/*
{
  "agent": 0,
  "algorithmName": "string",
  "endRange": 0,
  "gpa": 0,
  "grade": "string",
  "markingAlgorithmId": 0,
  "markingAlgorithmRangeId": 0,
  "schoolId": 0,
  "schoolName": "string",
  "startRange": 0,
  "status": "active"
}
*/

  int? agent;
  String? algorithmName;
  int? endRange;
  int? gpa;
  String? grade;
  int? markingAlgorithmId;
  int? markingAlgorithmRangeId;
  int? schoolId;
  String? schoolName;
  int? startRange;
  String? status;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequestMarkingAlgorithmBeanMarkingAlgorithmRangeBeanList({
    this.agent,
    this.algorithmName,
    this.endRange,
    this.gpa,
    this.grade,
    this.markingAlgorithmId,
    this.markingAlgorithmRangeId,
    this.schoolId,
    this.schoolName,
    this.startRange,
    this.status,
  });
  GetStudentExamBytesRequestMarkingAlgorithmBeanMarkingAlgorithmRangeBeanList.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    algorithmName = json['algorithmName']?.toString();
    endRange = json['endRange']?.toInt();
    gpa = json['gpa']?.toInt();
    grade = json['grade']?.toString();
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    markingAlgorithmRangeId = json['markingAlgorithmRangeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    startRange = json['startRange']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['algorithmName'] = algorithmName;
    data['endRange'] = endRange;
    data['gpa'] = gpa;
    data['grade'] = grade;
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['markingAlgorithmRangeId'] = markingAlgorithmRangeId;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['startRange'] = startRange;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentExamBytesRequestMarkingAlgorithmBean {
/*
{
  "agent": 0,
  "algorithmName": "string",
  "markingAlgorithmId": 0,
  "markingAlgorithmRangeBeanList": [
    {
      "agent": 0,
      "algorithmName": "string",
      "endRange": 0,
      "gpa": 0,
      "grade": "string",
      "markingAlgorithmId": 0,
      "markingAlgorithmRangeId": 0,
      "schoolId": 0,
      "schoolName": "string",
      "startRange": 0,
      "status": "active"
    }
  ],
  "schoolId": 0,
  "schoolName": "string",
  "status": "active"
}
*/

  int? agent;
  String? algorithmName;
  int? markingAlgorithmId;
  List<GetStudentExamBytesRequestMarkingAlgorithmBeanMarkingAlgorithmRangeBeanList?>? markingAlgorithmRangeBeanList;
  int? schoolId;
  String? schoolName;
  String? status;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequestMarkingAlgorithmBean({
    this.agent,
    this.algorithmName,
    this.markingAlgorithmId,
    this.markingAlgorithmRangeBeanList,
    this.schoolId,
    this.schoolName,
    this.status,
  });
  GetStudentExamBytesRequestMarkingAlgorithmBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    algorithmName = json['algorithmName']?.toString();
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    if (json['markingAlgorithmRangeBeanList'] != null) {
      final v = json['markingAlgorithmRangeBeanList'];
      final arr0 = <GetStudentExamBytesRequestMarkingAlgorithmBeanMarkingAlgorithmRangeBeanList>[];
      v.forEach((v) {
        arr0.add(GetStudentExamBytesRequestMarkingAlgorithmBeanMarkingAlgorithmRangeBeanList.fromJson(v));
      });
      markingAlgorithmRangeBeanList = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['algorithmName'] = algorithmName;
    data['markingAlgorithmId'] = markingAlgorithmId;
    if (markingAlgorithmRangeBeanList != null) {
      final v = markingAlgorithmRangeBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['markingAlgorithmRangeBeanList'] = arr0;
    }
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentExamBytesRequestExam {
/*
{
  "agent": "string",
  "examId": 0,
  "examName": "string",
  "examStartDate": "string",
  "examStatus": "active",
  "examType": "SLIP_TEST",
  "markingAlgorithmId": 0,
  "markingAlgorithmName": "string",
  "markingSchemeCode": "A",
  "schoolId": 0,
  "schoolName": "string"
}
*/

  String? agent;
  int? examId;
  String? examName;
  String? examStartDate;
  String? examStatus;
  String? examType;
  int? markingAlgorithmId;
  String? markingAlgorithmName;
  String? markingSchemeCode;
  int? schoolId;
  String? schoolName;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequestExam({
    this.agent,
    this.examId,
    this.examName,
    this.examStartDate,
    this.examStatus,
    this.examType,
    this.markingAlgorithmId,
    this.markingAlgorithmName,
    this.markingSchemeCode,
    this.schoolId,
    this.schoolName,
  });
  GetStudentExamBytesRequestExam.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examStartDate = json['examStartDate']?.toString();
    examStatus = json['examStatus']?.toString();
    examType = json['examType']?.toString();
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    markingAlgorithmName = json['markingAlgorithmName']?.toString();
    markingSchemeCode = json['markingSchemeCode']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['examId'] = examId;
    data['examName'] = examName;
    data['examStartDate'] = examStartDate;
    data['examStatus'] = examStatus;
    data['examType'] = examType;
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['markingAlgorithmName'] = markingAlgorithmName;
    data['markingSchemeCode'] = markingSchemeCode;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentExamBytesRequest {
/*
{
  "exam": {
    "agent": "string",
    "examId": 0,
    "examName": "string",
    "examStartDate": "string",
    "examStatus": "active",
    "examType": "SLIP_TEST",
    "markingAlgorithmId": 0,
    "markingAlgorithmName": "string",
    "markingSchemeCode": "A",
    "schoolId": 0,
    "schoolName": "string"
  },
  "markingAlgorithmBean": {
    "agent": 0,
    "algorithmName": "string",
    "markingAlgorithmId": 0,
    "markingAlgorithmRangeBeanList": [
      {
        "agent": 0,
        "algorithmName": "string",
        "endRange": 0,
        "gpa": 0,
        "grade": "string",
        "markingAlgorithmId": 0,
        "markingAlgorithmRangeId": 0,
        "schoolId": 0,
        "schoolName": "string",
        "startRange": 0,
        "status": "active"
      }
    ],
    "schoolId": 0,
    "schoolName": "string",
    "status": "active"
  },
  "studentExamMarksDetailsList": [
    {
      "date": "string",
      "endTime": {
        "date": 0,
        "day": 0,
        "hours": 0,
        "minutes": 0,
        "month": 0,
        "seconds": 0,
        "time": 0,
        "timezoneOffset": 0,
        "year": 0
      },
      "examId": 0,
      "examName": "string",
      "examTdsMapId": 0,
      "examType": "SLIP_TEST",
      "internalsComputationCode": "A",
      "internalsWeightage": 0,
      "marksObtained": 0,
      "maxMarks": 0,
      "rollNumber": "string",
      "schoolId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "startTime": {
        "date": 0,
        "day": 0,
        "hours": 0,
        "minutes": 0,
        "month": 0,
        "seconds": 0,
        "time": 0,
        "timezoneOffset": 0,
        "year": 0
      },
      "studentId": 0,
      "studentInternalExamMarksDetailsBeanList": [
        {
          "examId": 0,
          "examName": "string",
          "examTdsMapId": 0,
          "examType": "SLIP_TEST",
          "internalExamId": 0,
          "internalExamName": "string",
          "internalExamType": "SLIP_TEST",
          "internalNumber": 0,
          "internalTdsId": 0,
          "internalTdsMapId": 0,
          "internalsComputationCode": "A",
          "internalsDate": "string",
          "internalsEndTime": {
            "date": 0,
            "day": 0,
            "hours": 0,
            "minutes": 0,
            "month": 0,
            "seconds": 0,
            "time": 0,
            "timezoneOffset": 0,
            "year": 0
          },
          "internalsMarksObtained": 0,
          "internalsMaxMarks": 0,
          "internalsSectionId": 0,
          "internalsSectionName": "string",
          "internalsStartTime": {
            "date": 0,
            "day": 0,
            "hours": 0,
            "minutes": 0,
            "month": 0,
            "seconds": 0,
            "time": 0,
            "timezoneOffset": 0,
            "year": 0
          },
          "internalsSubjectId": 0,
          "internalsSubjectName": "string",
          "internalsTeacherId": 0,
          "internalsTeacherName": "string",
          "rollNumber": "string",
          "schoolId": 0,
          "studentId": 0,
          "studentName": "string"
        }
      ],
      "studentName": "string",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "studentProfile": {
    "balanceAmount": 0,
    "fatherName": "string",
    "franchiseId": 0,
    "franchiseName": "string",
    "gaurdianFirstName": "string",
    "gaurdianId": 0,
    "gaurdianLastName": "string",
    "gaurdianMailId": "string",
    "gaurdianMiddleName": "string",
    "gaurdianMobile": "string",
    "motherName": "string",
    "rollNumber": "string",
    "schoolId": 0,
    "schoolName": "string",
    "schoolPhotoUrl": "string",
    "sectionDescription": "string",
    "sectionId": 0,
    "sectionName": "string",
    "studentDob": "string",
    "studentFirstName": "string",
    "studentId": 0,
    "studentLastName": "string",
    "studentMailId": "string",
    "studentMiddleName": "string",
    "studentMobile": "string",
    "studentPhotoUrl": "string"
  }
}
*/

  Exam? exam;
  MarkingAlgorithmBean? markingAlgorithmBean;
  List<StudentExamMarksDetailsBean?>? studentExamMarksDetailsList;
  StudentProfile? studentProfile;
  Map<String, dynamic> __origJson = {};

  GetStudentExamBytesRequest({
    this.exam,
    this.markingAlgorithmBean,
    this.studentExamMarksDetailsList,
    this.studentProfile,
  });
  GetStudentExamBytesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    exam = (json['exam'] != null) ? Exam.fromJson(json['exam']) : null;
    markingAlgorithmBean = (json['markingAlgorithmBean'] != null) ? MarkingAlgorithmBean.fromJson(json['markingAlgorithmBean']) : null;
    if (json['studentExamMarksDetailsList'] != null) {
      final v = json['studentExamMarksDetailsList'];
      final arr0 = <StudentExamMarksDetailsBean>[];
      v.forEach((v) {
        arr0.add(StudentExamMarksDetailsBean.fromJson(v));
      });
      studentExamMarksDetailsList = arr0;
    }
    studentProfile = (json['studentProfile'] != null) ? StudentProfile.fromJson(json['studentProfile']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (exam != null) {
      data['exam'] = exam!.toJson();
    }
    if (markingAlgorithmBean != null) {
      data['markingAlgorithmBean'] = markingAlgorithmBean!.toJson();
    }
    if (studentExamMarksDetailsList != null) {
      final v = studentExamMarksDetailsList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentExamMarksDetailsList'] = arr0;
    }
    if (studentProfile != null) {
      data['studentProfile'] = studentProfile!.toJson();
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<List<int>> getStudentExamBytes(GetStudentExamBytesRequest getStudentExamBytesRequest) async {
  print("Raising request to getStudentExamBytes with request ${jsonEncode(getStudentExamBytesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_EXAM_BYTES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getStudentExamBytesRequest.toJson()),
  );

  List<int> getStudentExamBytesResponse = response.bodyBytes;
  // print("GetStudentExamMarksDetailsResponse ${getStudentExamBytesResponse.toJson()}");
  return getStudentExamBytesResponse;
}
