import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/exam_topics.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/topic_wise_exams.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/views/topic_wise_exams_all_students_marks_excel_template.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class AllTopicsStudentsMarksDownload {
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final TeacherDealingSection tds;
  final int selectedAcademicYearId;
  final List<StudentProfile> studentsList;
  final List<ExamTopic> examTopics;
  final List<TopicWiseExam> topicWiseExams;

  AllTopicsStudentsMarksDownload({
    required this.adminProfile,
    required this.teacherProfile,
    required this.tds,
    required this.selectedAcademicYearId,
    required this.studentsList,
    required this.examTopics,
    required this.topicWiseExams,
  });

  Future<void> downloadReport() async {
    Excel excel = Excel.createExcel();

    for (ExamTopic examTopic in examTopics) {
      Sheet sheet = excel['${examTopic.topicName}'];
      // Extract topic wise exams for each topic
      List<TopicWiseExam> topicWiseExamsForEachTopic = topicWiseExams.where((etw) => etw.topicId == examTopic.topicId).toList();
      // Extract exam wise students list
      List<StudentProfile> examWiseStudentsList = <StudentProfile>{
        ...studentsList.where((e) => e.sectionId == tds.sectionId),
        ...studentsList.where(
            (e) => (topicWiseExams.map((e) => e.studentExamMarksList ?? []).expand((i) => i) ?? []).map((e) => e?.studentId).contains(e.studentId))
      }.toSet().toList();
      studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      // Extract exam marks
      List<StudentExamMarks> examMarks = [];
      for (StudentProfile eachStudent in studentsList) {
        for (TopicWiseExam topicWiseExam in topicWiseExamsForEachTopic) {
          StudentExamMarks? actualMarksBean =
              (topicWiseExam.studentExamMarksList ?? []).where((e) => e?.studentId == eachStudent.studentId).firstOrNull;
          if (actualMarksBean != null) {
            examMarks.add(StudentExamMarks.fromJson(actualMarksBean.toJson()));
          } else {
            examMarks.add(StudentExamMarks(
              examSectionSubjectMapId: topicWiseExam.examSectionSubjectMapId,
              examId: topicWiseExam.examId,
              agent: adminProfile?.userId ?? teacherProfile?.teacherId,
              comment: actualMarksBean?.comment,
              studentId: eachStudent.studentId,
              marksObtained: actualMarksBean?.marksObtained,
              marksId: actualMarksBean?.marksId,
              studentExamMediaBeans: actualMarksBean?.studentExamMediaBeans ?? [],
            ));
          }
        }
      }
      TopicWiseExamsAllStudentMarksUpdateTemplate(
        adminProfile: adminProfile,
        teacherProfile: teacherProfile,
        tds: tds,
        selectedAcademicYearId: selectedAcademicYearId,
        studentsList: examWiseStudentsList,
        examTopic: examTopic,
        topicWiseExams: topicWiseExamsForEachTopic,
        examMarks: examMarks,
      ).generateSheetForExam(sheet, excel, showRules: false);
    }
    // Generate the Excel file as bytes
    List<int>? excelBytes = excel.encode();
    if (excelBytes == null) return;
    Uint8List excelUint8List = Uint8List.fromList(excelBytes);

    // Save the Excel file
    FileSaver.instance
        .saveFile(bytes: excelUint8List, name: 'Topic Wise Exam Report for ${tds.sectionName} ${tds.subjectName} ${tds.teacherName}.xlsx');
  }
}
