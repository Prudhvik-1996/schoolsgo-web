import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';

class EachMarksCellWidget extends StatelessWidget {
  const EachMarksCellWidget({
    super.key,
    required this.studentId,
    required this.essmIdIndex,
    required this.eachStudentExamMarks,
    required this.examSectionSubjectMap,
    required this.handleArrowKeyNavigation,
    required this.setState,
  });

  final int studentId;
  final int essmIdIndex;
  final StudentExamMarks eachStudentExamMarks;
  final ExamSectionSubjectMap examSectionSubjectMap;
  final void Function(RawKeyDownEvent event, StudentExamMarks examSectionMarks) handleArrowKeyNavigation;
  final void Function(VoidCallback fn) setState;

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          handleArrowKeyNavigation(event, eachStudentExamMarks);
        }
      },
      child: Stack(
        children: [
          TextFormField(
            autofocus: true,
            enabled: eachStudentExamMarks.isAbsent != 'N',
            focusNode: FocusNode(),
            initialValue: "${eachStudentExamMarks.marksObtained ?? ""}",
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                try {
                  final text = newValue.text;
                  if (text.isEmpty || (double.tryParse(text) != null && double.parse(text) <= (examSectionSubjectMap.maxMarks ?? 0))) {
                    return newValue;
                  }
                  return oldValue;
                } catch (e) {
                  debugPrintStack();
                }
                return oldValue;
              }),
            ],
            onChanged: (String? newText) => setState(() {
              if ((newText ?? "").trim().isEmpty) {
                eachStudentExamMarks.marksObtained = null;
              }
              double? newMarks = double.tryParse(newText ?? "");
              if (newMarks != null) {
                eachStudentExamMarks.marksObtained = newMarks;
              }
            }),
            maxLines: null,
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.start,
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                setState(() {
                  eachStudentExamMarks.isAbsent = eachStudentExamMarks.isAbsent == null || eachStudentExamMarks.isAbsent == 'P' ? 'N' : 'P';
                });
              },
              child: Tooltip(
                message: eachStudentExamMarks.isAbsent == 'N' ? "Mark Present" : "Mark Absent",
                child: ClayButton(
                  depth: 40,
                  surfaceColor: eachStudentExamMarks.isAbsent == 'N' ? Colors.blue : Colors.grey,
                  parentColor: clayContainerColor(context),
                  spread: 1,
                  borderRadius: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    width: 15,
                    height: 15,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(eachStudentExamMarks.isAbsent == 'N' ? "P" : "A"),
                      ),
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
