import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

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
  double? averageMarksObtained;
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
    this.averageMarksObtained,
    this.subjectId,
  }) {
    maxMarksController.text = status == 'active' ? "${maxMarks ?? ''}" : '';
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
    averageMarksObtained = json['averageMarksObtained']?.toDouble();
    subjectId = json['subjectId']?.toInt();
    maxMarksController.text = status == 'active' ? "${maxMarks ?? ''}" : '';
  }

  ExamSectionSubjectMap.cloneFrom(ExamSectionSubjectMap essm, {int? agent}) {
    agent = agent;
    authorisedAgent = essm.authorisedAgent;
    comment = essm.comment;
    date = null;
    endTime = null;
    examId = null;
    examSectionSubjectMapId = null;
    masterExamId = null;
    maxMarks = essm.maxMarks;
    sectionId = essm.sectionId;
    startTime = null;
    status = essm.status;
    studentExamMarksList = [];
    averageMarksObtained = null;
    subjectId = essm.subjectId;
    maxMarksController.text = status == 'active' ? "${maxMarks ?? ''}" : '';
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

  double? get classAveragePercentage {
    if ((studentExamMarksList ?? []).isEmpty || maxMarks == null) {
      return null;
    }

    // Calculate the total marks obtained by students who are not absent.
    double totalMarksObtained =
        studentExamMarksList!.where((e) => e?.marksObtained != null && e?.isAbsent != 'N').map((e) => e!.marksObtained!).fold(0.0, (a, b) => a + b);
    double totalMaxMarks = studentExamMarksList!.where((e) => e?.marksObtained != null && e?.isAbsent != 'N').length * maxMarks!;

    // Calculate the average percentage and round it to two decimal places.
    return (totalMarksObtained / totalMaxMarks) * 100;
  }

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
    data['averageMarksObtained'] = averageMarksObtained;
    data['subjectId'] = subjectId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  String get examDate => date == null ? "-" : convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(date));

  String get startTimeSlot => startTime == null ? "-" : convert24To12HourFormat(startTime!);

  String get endTimeSlot => endTime == null ? "-" : convert24To12HourFormat(endTime!);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamSectionSubjectMap && runtimeType == other.runtimeType && examSectionSubjectMapId == other.examSectionSubjectMapId;

  @override
  int get hashCode => examSectionSubjectMapId.hashCode;
}
