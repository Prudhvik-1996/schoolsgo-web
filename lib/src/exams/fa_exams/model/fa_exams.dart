import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
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
  int? markingAlgorithmId;
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
    this.markingAlgorithmId,
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
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
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
    data['markingAlgorithmId'] = markingAlgorithmId;
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

  List<ExamSectionSubjectMap> get overAllEssmList {
    // Initialize a set to store unique subject-section IDs.
    Set<String> subjectSectionIds = {};

    // Iterate through the internal exams and their associated sections and subjects.
    (faInternalExams ?? []).forEach((FaInternalExam? internalExam) {
      (internalExam?.examSectionSubjectMapList ?? []).forEach((essm) {
        // Create a unique identifier for subject and section.
        String subjectSectionId = "${essm?.subjectId ?? "-"}|${essm?.sectionId ?? "-"}";
        subjectSectionIds.add(subjectSectionId);
      });
    });

    // Create a list of ExamSectionSubjectMap based on unique subject-section IDs.
    return subjectSectionIds.map((subjectSectionId) {
      int? subjectId = int.tryParse(subjectSectionId.split("|")[0]);
      int? sectionId = int.tryParse(subjectSectionId.split("|")[1]);

      // Calculate maxMaxMarks.
      double maxMaxMarks = (faInternalExams ?? []).fold<double>(0.0, (max, internalExam) {
        double maxMarks = (internalExam?.examSectionSubjectMapList ?? [])
            .where((essm) => essm?.subjectId == subjectId && essm?.sectionId == sectionId)
            .map((essm) => essm?.maxMarks ?? 0)
            .fold<double>(0.0, (max, value) => max > value ? max : value);
        return max > maxMarks ? max : maxMarks;
      });

      // Find authorizedAgent.
      int? authorizedAgent = (faInternalExams ?? []).expand((internalExam) {
        return (internalExam?.examSectionSubjectMapList ?? [])
            .where((essm) => essm?.subjectId == subjectId && essm?.sectionId == sectionId && essm?.maxMarks == maxMaxMarks)
            .map((essm) => essm?.authorisedAgent);
      }).firstOrNull;

      List<StudentExamMarks?> studentExamMarksList = (faInternalExams ?? [])
          .map((FaInternalExam? e) => e?.examSectionSubjectMapList ?? [])
          .expand((i) => i)
          .where((ExamSectionSubjectMap? essm) => essm?.subjectId == subjectId && essm?.sectionId == sectionId)
          .map((ExamSectionSubjectMap? essm) => essm?.studentExamMarksList ?? [])
          .expand((i) => i)
          .toList();

      // Filter and remove absent or unmarked students.
      Set<int> studentIdAbsentOrUnMarkedSet = studentExamMarksList
          .where((examMarks) => examMarks?.isAbsent == "N" || examMarks?.marksObtained != null)
          .map((examMarks) => examMarks?.studentId)
      .whereNotNull()
          .toSet();

      studentExamMarksList.removeWhere((examMarks) => !studentIdAbsentOrUnMarkedSet.contains(examMarks?.studentId));

      // Calculate studentExamMarksForEssm.
      List<StudentExamMarks> studentExamMarksForEssm = studentIdAbsentOrUnMarkedSet
          .map((studentId) => StudentExamMarks()
            ..studentId = studentId
            ..marksObtained =
                studentExamMarksList.where((examMarks) => examMarks?.studentId == studentId).map((examMarks) => examMarks?.marksObtained ?? 0).sum)
          .toList();

      double actualMaxMarks = 0.0;
      for (FaInternalExam? internalExam in faInternalExams ??[]) {
        if (internalExam == null) continue;
        for (ExamSectionSubjectMap? essm in (internalExam.examSectionSubjectMapList ?? []).where((essm) => essm?.sectionId == sectionId && essm?.subjectId == subjectId)) {
          actualMaxMarks += essm?.maxMarks ?? 0;
        }
      }

      // Create and return ExamSectionSubjectMap.
      return ExamSectionSubjectMap()
        ..subjectId = subjectId
        ..sectionId = sectionId
        ..authorisedAgent = authorizedAgent
        ..maxMarks = actualMaxMarks
        ..masterExamId = faExamId
        ..studentExamMarksList = studentExamMarksForEssm;
    }).toList();
  }
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
  int? markingAlgorithmId;
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
    this.markingAlgorithmId,
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
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
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
    data['markingAlgorithmId'] = markingAlgorithmId;
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

Future<List<int>> downloadHallTicketsFromWeb(int schoolId, int academicYearId, List<int> studentIds, int faExamId, int internalExamId) async {
  debugPrint(
      """Raising request to downloadHallTicketsFromWeb with request {"schoolId": $schoolId, "academicYearId": $academicYearId, "studentIds": $studentIds, "faExamId": $faExamId, "internalExamId": $internalExamId}""");
  String _url = SCHOOLS_GO_BASE_URL +
      GET_HALL_TICKETS +
      '?' +
      Uri(queryParameters: {
        "schoolId": schoolId.toString(),
        "academicYearId": academicYearId.toString(),
        "studentIds": studentIds.join(','),
        "faExamId": faExamId.toString(),
        "internalExamId": internalExamId.toString(),
      }).query;
  debugPrint("URL: $_url");
  return await HttpUtils.postToDownloadFile(_url, {});
}
