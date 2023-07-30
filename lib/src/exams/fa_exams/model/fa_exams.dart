import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetFAExamsRequest {
  int? academicYearId;
  int? faExamId;
  int? schoolId;
  int? sectionId;
  int? subjectId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetFAExamsRequest({
    this.academicYearId,
    this.faExamId,
    this.schoolId,
    this.sectionId,
    this.subjectId,
    this.teacherId,
  });

  GetFAExamsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    faExamId = json['faExamId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['faExamId'] = faExamId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class ExamSectionSubjectMap {
  int? agent;
  int? authorisedAgent;
  String? comment;
  String? date;
  String? endTime;
  int? examId;
  int? examSectionSubjectMapId;
  int? masterExamId;
  double? maxMarks;
  int? sectionId;
  String? startTime;
  String? status;
  List<StudentExamMarks?>? studentExamMarksList;
  int? subjectId;
  Map<String, dynamic> __origJson = {};

  TextEditingController maxMarksController = TextEditingController();

  ExamSectionSubjectMap({
    this.agent,
    this.authorisedAgent,
    this.comment,
    this.date,
    this.endTime,
    this.examId,
    this.examSectionSubjectMapId,
    this.masterExamId,
    this.maxMarks,
    this.sectionId,
    this.startTime,
    this.status,
    this.studentExamMarksList,
    this.subjectId,
  }) {
    maxMarksController.text = "${maxMarks ?? ''}";
  }

  ExamSectionSubjectMap.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    authorisedAgent = json['authorisedAgent']?.toInt();
    comment = json['comment']?.toString();
    date = json['date']?.toString();
    endTime = json['endTime']?.toString();
    examId = json['examId']?.toInt();
    examSectionSubjectMapId = json['examSectionSubjectMapId']?.toInt();
    masterExamId = json['masterExamId']?.toInt();
    maxMarks = json['maxMarks']?.toDouble();
    maxMarksController.text = "${maxMarks ?? ''}";
    sectionId = json['sectionId']?.toInt();
    startTime = json['startTime']?.toString();
    status = json['status']?.toString();
    if (json['studentExamMarksList'] != null) {
      final v = json['studentExamMarksList'];
      final arr0 = <StudentExamMarks>[];
      v.forEach((v) {
        arr0.add(StudentExamMarks.fromJson(v));
      });
      studentExamMarksList = arr0;
    }
    subjectId = json['subjectId']?.toInt();
  }

  double? get classAverage => (studentExamMarksList ?? []).where((e) => e?.marksObtained != null && e?.isAbsent != 'N').isEmpty
      ? null
      : (((studentExamMarksList ?? [])
      .where((e) => e?.marksObtained != null && e?.isAbsent != 'N')
      .map((e) => e?.marksObtained ?? 0.0)
      .fold<double>(0.0, (double a, double b) => a + b) /
      (studentExamMarksList ?? []).where((e) => e?.marksObtained != null).length) *
      100)
      .toInt() /
      100.0;

  String get examDate => date == null ? "-" : convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(date));

  String get startTimeSlot => startTime == null ? "-" : convert24To12HourFormat(startTime!);

  String get endTimeSlot => endTime == null ? "-" : convert24To12HourFormat(endTime!);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['authorisedAgent'] = authorisedAgent;
    data['comment'] = comment;
    data['date'] = date;
    data['endTime'] = endTime;
    data['examId'] = examId;
    data['examSectionSubjectMapId'] = examSectionSubjectMapId;
    data['masterExamId'] = masterExamId;
    data['maxMarks'] = maxMarks;
    data['sectionId'] = sectionId;
    data['startTime'] = startTime;
    data['status'] = status;
    if (studentExamMarksList != null) {
      final v = studentExamMarksList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentExamMarksList'] = arr0;
    }
    data['subjectId'] = subjectId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class FaInternalExam {
  int? agent;
  List<ExamSectionSubjectMap?>? examSectionSubjectMapList;
  String? examType;
  int? faInternalExamId;
  String? faInternalExamName;
  int? masterExamId;
  String? status;
  Map<String, dynamic> __origJson = {};

  TextEditingController internalExamNameController = TextEditingController();

  FaInternalExam({
    this.agent,
    this.examSectionSubjectMapList,
    this.examType,
    this.faInternalExamId,
    this.faInternalExamName,
    this.masterExamId,
    this.status,
  }) {
    internalExamNameController.text = faInternalExamName ?? '';
  }

  FaInternalExam.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    if (json['examSectionSubjectMapList'] != null) {
      final v = json['examSectionSubjectMapList'];
      final arr0 = <ExamSectionSubjectMap>[];
      v.forEach((v) {
        arr0.add(ExamSectionSubjectMap.fromJson(v));
      });
      examSectionSubjectMapList = arr0;
    }
    examType = json['examType']?.toString();
    faInternalExamId = json['faInternalExamId']?.toInt();
    faInternalExamName = json['faInternalExamName']?.toString();
    internalExamNameController.text = faInternalExamName ?? '';
    masterExamId = json['masterExamId']?.toInt();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    if (examSectionSubjectMapList != null) {
      final v = examSectionSubjectMapList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['examSectionSubjectMapList'] = arr0;
    }
    data['examType'] = examType;
    data['faInternalExamId'] = faInternalExamId;
    data['faInternalExamName'] = faInternalExamName;
    data['masterExamId'] = masterExamId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class FAExam {
  int? academicYearId;
  int? agent;
  String? comment;
  String? date;
  String? examType;
  int? faExamId;
  String? faExamName;
  List<FaInternalExam?>? faInternalExams;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  FAExam({
    this.academicYearId,
    this.agent,
    this.comment,
    this.date,
    this.examType,
    this.faExamId,
    this.faExamName,
    this.faInternalExams,
    this.schoolId,
    this.status,
  });

  FAExam.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    agent = json['agent']?.toInt();
    comment = json['comment']?.toString();
    date = json['date']?.toString();
    examType = json['examType']?.toString();
    faExamId = json['faExamId']?.toInt();
    faExamName = json['faExamName']?.toString();
    if (json['faInternalExams'] != null) {
      final v = json['faInternalExams'];
      final arr0 = <FaInternalExam>[];
      v.forEach((v) {
        arr0.add(FaInternalExam.fromJson(v));
      });
      faInternalExams = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['agent'] = agent;
    data['comment'] = comment;
    data['date'] = date;
    data['examType'] = examType;
    data['faExamId'] = faExamId;
    data['faExamName'] = faExamName;
    if (faInternalExams != null) {
      final v = faInternalExams;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['faInternalExams'] = arr0;
    }
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetFAExamsResponse {
  String? errorCode;
  String? errorMessage;
  List<FAExam?>? exams;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetFAExamsResponse({
    this.errorCode,
    this.errorMessage,
    this.exams,
    this.httpStatus,
    this.responseStatus,
  });

  GetFAExamsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    if (json['exams'] != null) {
      final v = json['exams'];
      final arr0 = <FAExam>[];
      v.forEach((v) {
        arr0.add(FAExam.fromJson(v));
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

Future<GetFAExamsResponse> getFAExams(GetFAExamsRequest getFAExamsRequest) async {
  debugPrint("Raising request to getFAExams with request ${jsonEncode(getFAExamsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_FA_EXAMS;

  GetFAExamsResponse getFAExamsResponse = await HttpUtils.post(
    _url,
    getFAExamsRequest.toJson(),
    GetFAExamsResponse.fromJson,
  );

  debugPrint("GetFAExamsResponse ${getFAExamsResponse.toJson()}");
  return getFAExamsResponse;
}

class CreateOrUpdateFAExamRequest {

  int? academicYearId;
  int? agent;
  String? comment;
  String? date;
  String? examType;
  int? faExamId;
  String? faExamName;
  List<FaInternalExam?>? faInternalExams;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateFAExamRequest({
    this.academicYearId,
    this.agent,
    this.comment,
    this.date,
    this.examType,
    this.faExamId,
    this.faExamName,
    this.faInternalExams,
    this.schoolId,
    this.status,
  });
  CreateOrUpdateFAExamRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    agent = json['agent']?.toInt();
    comment = json['comment']?.toString();
    date = json['date']?.toString();
    examType = json['examType']?.toString();
    faExamId = json['faExamId']?.toInt();
    faExamName = json['faExamName']?.toString();
    if (json['faInternalExams'] != null) {
      final v = json['faInternalExams'];
      final arr0 = <FaInternalExam>[];
      v.forEach((v) {
        arr0.add(FaInternalExam.fromJson(v));
      });
      faInternalExams = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['agent'] = agent;
    data['comment'] = comment;
    data['date'] = date;
    data['examType'] = examType;
    data['faExamId'] = faExamId;
    data['faExamName'] = faExamName;
    if (faInternalExams != null) {
      final v = faInternalExams;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['faInternalExams'] = arr0;
    }
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateFAExamResponse {

  String? errorCode;
  String? errorMessage;
  int? faExamId;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateFAExamResponse({
    this.errorCode,
    this.errorMessage,
    this.faExamId,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateFAExamResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    faExamId = json['faExamId']?.toInt();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['faExamId'] = faExamId;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateFAExamResponse> createOrUpdateFAExam(CreateOrUpdateFAExamRequest createOrUpdateFAExamRequest) async {
  debugPrint("Raising request to createOrUpdateFAExam with request ${jsonEncode(createOrUpdateFAExamRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_FA_EXAMS;

  CreateOrUpdateFAExamResponse createOrUpdateFAExamResponse = await HttpUtils.post(
    _url,
    createOrUpdateFAExamRequest.toJson(),
    CreateOrUpdateFAExamResponse.fromJson,
  );

  debugPrint("createOrUpdateFAExamResponse ${createOrUpdateFAExamResponse.toJson()}");
  return createOrUpdateFAExamResponse;
}
