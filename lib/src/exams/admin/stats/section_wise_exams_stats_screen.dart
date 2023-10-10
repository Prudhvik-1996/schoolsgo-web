import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class SectionWiseExamsStatsScreen extends StatefulWidget {
  const SectionWiseExamsStatsScreen({
    super.key,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.customExams,
    required this.faExams,
  });

  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<CustomExam> customExams;
  final List<FAExam> faExams;

  @override
  State<SectionWiseExamsStatsScreen> createState() => _SectionWiseExamsStatsScreenState();
}

class _SectionWiseExamsStatsScreenState extends State<SectionWiseExamsStatsScreen> {
  List<int> sortedExamIds = [];
  Set<String> sectionSubjectTeacherMap = {};

  List<ScrollController> verticalScrollControllers = [];
  List<ScrollController> horizontalScrollControllers = [];

  List<List<ExamSectionSubjectMap>> examWiseEssmList = [];

  @override
  void initState() {
    super.initState();
    sortedExamIds = widget.customExams.map((e) => e.customExamId).whereNotNull().toList() +
        widget.faExams.map((e) => e.faExamId).whereNotNull().toList().sorted((a, b) {
          String? aDate = widget.customExams.where((e) => e.customExamId == a).firstOrNull?.date ??
              widget.faExams.where((e) => e.faExamId == a).firstOrNull?.date;
          String? bDate = widget.customExams.where((e) => e.customExamId == b).firstOrNull?.date ??
              widget.faExams.where((e) => e.faExamId == b).firstOrNull?.date;
          return convertYYYYMMDDFormatToDateTime(aDate).compareTo(convertYYYYMMDDFormatToDateTime(bDate));
        });
    for (var _ in widget.sectionsList) {
      verticalScrollControllers.add(ScrollController());
      horizontalScrollControllers.add(ScrollController());
    }
    sectionSubjectTeacherMap = (widget.customExams
                .map((ece) {
                  return (ece.examSectionSubjectMapList ?? [])
                      .whereNotNull()
                      .map((essm) => "${essm.sectionId ?? "-"}|${essm.subjectId ?? "-"}|${essm.authorisedAgent ?? "-"}");
                })
                .expand((i) => i)
                .toList() +
            widget.faExams
                .map((efe) {
                  return (efe.overAllEssmList)
                      .whereNotNull()
                      .map((essm) => "${essm.sectionId ?? "-"}|${essm.subjectId ?? "-"}|${essm.authorisedAgent ?? "-"}");
                })
                .expand((i) => i)
                .toList())
        .sorted((a, b) {
      int? aSectionId = int.tryParse(a.split("|")[0]);
      int? aSubjectId = int.tryParse(a.split("|")[1]);
      int? bSectionId = int.tryParse(b.split("|")[0]);
      int? bSubjectId = int.tryParse(b.split("|")[1]);
      Section? aSection = widget.sectionsList.where((es) => es.sectionId == aSectionId).firstOrNull;
      Section? bSection = widget.sectionsList.where((es) => es.sectionId == bSectionId).firstOrNull;
      Subject? aSubject = widget.subjectsList.where((es) => es.subjectId == aSubjectId).firstOrNull;
      Subject? bSubject = widget.subjectsList.where((es) => es.subjectId == bSubjectId).firstOrNull;
      if ((aSection?.seqOrder ?? 0).compareTo(bSection?.seqOrder ?? 0) == 0) {
        return (aSubject?.seqOrder ?? 0).compareTo(bSubject?.seqOrder ?? 0);
      }
      return (aSection?.seqOrder ?? 0).compareTo(bSection?.seqOrder ?? 0);
    }).toSet();
    examWiseEssmList = [
      ...sortedExamIds.map((eachExamId) {
        CustomExam? customExam = widget.customExams.where((ece) => ece.customExamId == eachExamId).firstOrNull;
        FAExam? faExam = widget.faExams.where((efe) => efe.faExamId == eachExamId).firstOrNull;
        if (customExam != null) {
          return (customExam.examSectionSubjectMapList ?? []).whereNotNull().toList().sorted((a, b) {
            Section? aSection = widget.sectionsList.where((es) => es.sectionId == a.sectionId).firstOrNull;
            Section? bSection = widget.sectionsList.where((es) => es.sectionId == b.sectionId).firstOrNull;
            Subject? aSubject = widget.subjectsList.where((es) => es.subjectId == a.subjectId).firstOrNull;
            Subject? bSubject = widget.subjectsList.where((es) => es.subjectId == b.subjectId).firstOrNull;
            if ((aSection?.seqOrder ?? 0).compareTo(bSection?.seqOrder ?? 0) == 0) {
              return (aSubject?.seqOrder ?? 0).compareTo(bSubject?.seqOrder ?? 0);
            }
            return (aSection?.seqOrder ?? 0).compareTo(bSection?.seqOrder ?? 0);
          });
        }
        if (faExam != null) {
          return faExam.overAllEssmList.sorted((a, b) {
            Section? aSection = widget.sectionsList.where((es) => es.sectionId == a.sectionId).firstOrNull;
            Section? bSection = widget.sectionsList.where((es) => es.sectionId == b.sectionId).firstOrNull;
            Subject? aSubject = widget.subjectsList.where((es) => es.subjectId == a.subjectId).firstOrNull;
            Subject? bSubject = widget.subjectsList.where((es) => es.subjectId == b.subjectId).firstOrNull;
            if ((aSection?.seqOrder ?? 0).compareTo(bSection?.seqOrder ?? 0) == 0) {
              return (aSubject?.seqOrder ?? 0).compareTo(bSubject?.seqOrder ?? 0);
            }
            return (aSection?.seqOrder ?? 0).compareTo(bSection?.seqOrder ?? 0);
          });
        }
        return [];
      })
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Wise Stats"),
      ),
      body: ListView(
        children: [
          ...List.generate(widget.sectionsList.length, (sectionIndex) {
            return sectionWiseStatsTable(
              widget.sectionsList[sectionIndex],
              verticalScrollControllers[sectionIndex],
              horizontalScrollControllers[sectionIndex],
            );
          }),
        ],
      ),
    );
  }

  Widget sectionWiseStatsTable(Section eachSection, ScrollController verticalScrollController, ScrollController horizontalScrollController) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(eachSection.sectionName ?? "-"),
          const SizedBox(height: 10),
          const Divider(
            thickness: 1,
          ),
          const SizedBox(height: 10),
          AdaptiveScrollbar(
            controller: verticalScrollController,
            child: AdaptiveScrollbar(
              controller: horizontalScrollController,
              position: ScrollbarPosition.bottom,
              underColor: Colors.blueGrey.withOpacity(0.3),
              sliderDefaultColor: Colors.grey.withOpacity(0.7),
              sliderActiveColor: Colors.grey,
              child: SingleChildScrollView(
                controller: verticalScrollController,
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  controller: horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 16.0, top: 10.0),
                    child: DataTable(
                      columns: [
                        const DataColumn(label: Text("Subject")),
                        const DataColumn(label: Text("Teacher")),
                        ...sortedExamIds
                            .map((eachExamId) => DataColumn(
                                  label: Text(widget.customExams.where((ece) => ece.customExamId == eachExamId).firstOrNull?.customExamName ??
                                      widget.faExams.where((efe) => efe.faExamId == eachExamId).firstOrNull?.faExamName ??
                                      "-"),
                                  numeric: true,
                                ))
                            .toList(),
                        const DataColumn(label: Text("Average")),
                      ],
                      rows: [
                        ...sectionSubjectTeacherMap.where((e) {
                          int? sectionId = int.tryParse(e.split("|")[0]);
                          return sectionId == eachSection.sectionId;
                        }).map((genEssmId) {
                          int? subjectId = int.tryParse(genEssmId.split("|")[1]);
                          int? teacherId = int.tryParse(genEssmId.split("|")[2]);
                          List<double> averagesList = [];
                          List<DataCell> cells = [];
                          cells.add(DataCell(
                              Text(widget.subjectsList.where((eachSubject) => eachSubject.subjectId == subjectId).firstOrNull?.subjectName ?? "-")));
                          cells.add(DataCell(
                              Text(widget.teachersList.where((eachTeacher) => eachTeacher.teacherId == teacherId).firstOrNull?.teacherName ?? "-")));
                          for (List<ExamSectionSubjectMap> eachEssmList in examWiseEssmList) {
                            int index = eachEssmList
                                .map((e) => "${e.sectionId ?? "-"}|${e.subjectId ?? "-"}|${e.authorisedAgent ?? "-"}")
                                .toList()
                                .indexWhere((e) => e == genEssmId);
                            if (index == -1) {
                              cells.add(const DataCell(Text("-")));
                            } else {
                              double? classAveragePercentage = eachEssmList[index].classAveragePercentage;
                              if (classAveragePercentage != null) {
                                averagesList.add(classAveragePercentage);
                                cells.add(DataCell(Text(doubleToStringAsFixed(classAveragePercentage))));
                              } else {
                                cells.add(const DataCell(Text("-")));
                              }
                            }
                          }
                          cells.add(DataCell(Text(averagesList.isEmpty ? "-" : doubleToStringAsFixed(averagesList.average))));
                          return DataRow(cells: cells);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
