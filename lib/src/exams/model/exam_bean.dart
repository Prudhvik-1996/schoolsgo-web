import 'package:schoolsgo_web/src/exams/model/exams.dart';

class ExamTdsMapBean {
/*
{
  "endTime": "",
  "examId": 0,
  "examName": "string",
  "examTdsDate": "string",
  "examTdsMapId": 0,
  "internalExamTdsMapBeanList": [
    {
      "endTime": "",
      "examId": 0,
      "examName": "string",
      "examTdsDate": "string",
      "examTdsMapId": 0,
      "internalExamId": 0,
      "internalExamMapTdsId": 0,
      "internalExamName": "string",
      "internalNumber": 0,
      "maxMarks": 0,
      "sectionId": 0,
      "sectionName": "string",
      "startTime": "",
      "status": "active",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "internalsComputationCode": "A",
  "maxMarks": 0,
  "sectionId": 0,
  "sectionName": "string",
  "startTime": "",
  "status": "active",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  String? endTime;
  int? examId;
  String? examName;
  String? examTdsDate;
  int? examTdsMapId;
  List<Exam?>? internalExamTdsMapBeanList;
  String? internalsComputationCode;
  int? maxMarks;
  int? sectionId;
  String? sectionName;
  String? startTime;
  String? status;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  Map<String, dynamic> __origJson = {};

  ExamTdsMapBean({
    this.endTime,
    this.examId,
    this.examName,
    this.examTdsDate,
    this.examTdsMapId,
    this.internalExamTdsMapBeanList,
    this.internalsComputationCode,
    this.maxMarks,
    this.sectionId,
    this.sectionName,
    this.startTime,
    this.status,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
  });
  ExamTdsMapBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    endTime = json['endTime']?.toString();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examTdsDate = json['examTdsDate']?.toString();
    examTdsMapId = json['examTdsMapId']?.toInt();
    if (json['internalExamTdsMapBeanList'] != null) {
      final v = json['internalExamTdsMapBeanList'];
      final arr0 = <Exam>[];
      v.forEach((v) {
        arr0.add(Exam.fromJson(v));
      });
      internalExamTdsMapBeanList = arr0;
    }
    internalsComputationCode = json['internalsComputationCode']?.toString();
    maxMarks = json['maxMarks']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    startTime = json['startTime']?.toString();
    status = json['status']?.toString();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
    teacherName = json['teacherName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['endTime'] = endTime;
    data['examId'] = examId;
    data['examName'] = examName;
    data['examTdsDate'] = examTdsDate;
    data['examTdsMapId'] = examTdsMapId;
    if (internalExamTdsMapBeanList != null) {
      final v = internalExamTdsMapBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['internalExamTdsMapBeanList'] = arr0;
    }
    data['internalsComputationCode'] = internalsComputationCode;
    data['maxMarks'] = maxMarks;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['startTime'] = startTime;
    data['status'] = status;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class ExamSectionMapBean {
/*
{
  "examId": 0,
  "examSectionMapId": 0,
  "examTdsMapBeanList": [
    {
      "endTime": "",
      "examId": 0,
      "examName": "string",
      "examTdsDate": "string",
      "examTdsMapId": 0,
      "internalExamTdsMapBeanList": [
        {
          "endTime": "",
          "examId": 0,
          "examName": "string",
          "examTdsDate": "string",
          "examTdsMapId": 0,
          "internalExamId": 0,
          "internalExamMapTdsId": 0,
          "internalExamName": "string",
          "internalNumber": 0,
          "maxMarks": 0,
          "sectionId": 0,
          "sectionName": "string",
          "startTime": "",
          "status": "active",
          "subjectId": 0,
          "subjectName": "string",
          "tdsId": 0,
          "teacherId": 0,
          "teacherName": "string"
        }
      ],
      "internalsComputationCode": "A",
      "maxMarks": 0,
      "sectionId": 0,
      "sectionName": "string",
      "startTime": "",
      "status": "active",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "markingAlgorithmId": 0,
  "markingAlgorithmName": "string",
  "markingAlgorithmRangeBeanList": [
    {
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
  "markingSchemeCode": "A",
  "sectionId": 0,
  "sectionName": "string",
  "status": "active"
}
*/

  int? examId;
  int? examSectionMapId;
  List<ExamTdsMapBean?>? examTdsMapBeanList;
  int? markingAlgorithmId;
  String? markingAlgorithmName;
  String? markingSchemeCode;
  int? sectionId;
  String? sectionName;
  String? status;
  Map<String, dynamic> __origJson = {};

  ExamSectionMapBean({
    this.examId,
    this.examSectionMapId,
    this.examTdsMapBeanList,
    this.markingAlgorithmId,
    this.markingAlgorithmName,
    this.markingSchemeCode,
    this.sectionId,
    this.sectionName,
    this.status,
  });
  ExamSectionMapBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    examId = json['examId']?.toInt();
    examSectionMapId = json['examSectionMapId']?.toInt();
    if (json['examTdsMapBeanList'] != null) {
      final v = json['examTdsMapBeanList'];
      final arr0 = <ExamTdsMapBean>[];
      v.forEach((v) {
        arr0.add(ExamTdsMapBean.fromJson(v));
      });
      examTdsMapBeanList = arr0;
    }
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    markingAlgorithmName = json['markingAlgorithmName']?.toString();
    markingSchemeCode = json['markingSchemeCode']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['examId'] = examId;
    data['examSectionMapId'] = examSectionMapId;
    if (examTdsMapBeanList != null) {
      final v = examTdsMapBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['examTdsMapBeanList'] = arr0;
    }
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['markingAlgorithmName'] = markingAlgorithmName;
    data['markingSchemeCode'] = markingSchemeCode;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class ExamBean {
/*
{
  "agent": 0,
  "examId": 0,
  "examName": "string",
  "examSectionMapBeanList": [
    {
      "examId": 0,
      "examSectionMapId": 0,
      "examTdsMapBeanList": [
        {
          "endTime": "",
          "examId": 0,
          "examName": "string",
          "examTdsDate": "string",
          "examTdsMapId": 0,
          "internalExamTdsMapBeanList": [
            {
              "endTime": "",
              "examId": 0,
              "examName": "string",
              "examTdsDate": "string",
              "examTdsMapId": 0,
              "internalExamId": 0,
              "internalExamMapTdsId": 0,
              "internalExamName": "string",
              "internalNumber": 0,
              "maxMarks": 0,
              "sectionId": 0,
              "sectionName": "string",
              "startTime": "",
              "status": "active",
              "subjectId": 0,
              "subjectName": "string",
              "tdsId": 0,
              "teacherId": 0,
              "teacherName": "string"
            }
          ],
          "internalsComputationCode": "A",
          "maxMarks": 0,
          "sectionId": 0,
          "sectionName": "string",
          "startTime": "",
          "status": "active",
          "subjectId": 0,
          "subjectName": "string",
          "tdsId": 0,
          "teacherId": 0,
          "teacherName": "string"
        }
      ],
      "markingAlgorithmId": 0,
      "markingAlgorithmName": "string",
      "markingAlgorithmRangeBeanList": [
        {
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
      "markingSchemeCode": "A",
      "sectionId": 0,
      "sectionName": "string",
      "status": "active"
    }
  ],
  "examStartDate": "string",
  "examType": "SLIP_TEST",
  "schoolId": 0,
  "status": "active"
}
*/

  int? agent;
  int? examId;
  String? examName;
  List<ExamSectionMapBean?>? examSectionMapBeanList;
  String? examStartDate;
  String? examType;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  ExamBean({
    this.agent,
    this.examId,
    this.examName,
    this.examSectionMapBeanList,
    this.examStartDate,
    this.examType,
    this.schoolId,
    this.status,
  });
  ExamBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    if (json['examSectionMapBeanList'] != null) {
      final v = json['examSectionMapBeanList'];
      final arr0 = <ExamSectionMapBean>[];
      v.forEach((v) {
        arr0.add(ExamSectionMapBean.fromJson(v));
      });
      examSectionMapBeanList = arr0;
    }
    examStartDate = json['examStartDate']?.toString();
    examType = json['examType']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['examId'] = examId;
    data['examName'] = examName;
    if (examSectionMapBeanList != null) {
      final v = examSectionMapBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['examSectionMapBeanList'] = arr0;
    }
    data['examStartDate'] = examStartDate;
    data['examType'] = examType;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}
