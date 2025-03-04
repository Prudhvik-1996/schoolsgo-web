import 'package:flutter/material.dart';

enum InternalsComputationCode { A, B, S }

extension InternalsComputationCodeExt on InternalsComputationCode {
  String toShortString() {
    return toString().split('.').last;
  }

  String get description {
    switch (this) {
      case InternalsComputationCode.A:
        return "Average";
      case InternalsComputationCode.B:
        return "Best Of";
      case InternalsComputationCode.S:
        return "Sum";
      default:
        return "-";
    }
  }
}

enum MarkingSchemeCode { A, B, C, D, E, F, G }

enum AttendanceType { BLANK, NO, WITH }

Future<AttendanceType> getAttendanceTypeFromAlertDialogue(BuildContext context) async {
  AttendanceType attendanceType = AttendanceType.WITH;
  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext dialogueContext) {
      return AlertDialog(
        title: const Text('Choose Attendance Report Format'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...AttendanceType.values.map((e) => RadioListTile(
                      title: e == AttendanceType.WITH
                          ? const Text("With Actual Attendance Report")
                          : e == AttendanceType.BLANK
                              ? const Text("With Empty Attendance Report")
                              : const Text("With No Attendance Report"),
                      selected: attendanceType == e,
                      value: e,
                      onChanged: (AttendanceType? value) {
                        if (value == null) return;
                        setState(() => attendanceType = value);
                      },
                      groupValue: attendanceType,
                    )),
              ],
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Proceed to download"),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
  return attendanceType;
}

extension MarkingSchemeExt on MarkingSchemeCode {
  String toShortString() {
    return toString().split('.').last;
  }

  String get description {
    switch (this) {
      case MarkingSchemeCode.A:
        return "All schemes";
      case MarkingSchemeCode.B:
        return "Only Marks";
      case MarkingSchemeCode.C:
        return "Only GPA";
      case MarkingSchemeCode.D:
        return "Only Grades";
      case MarkingSchemeCode.E:
        return "Only Marks & GPA";
      case MarkingSchemeCode.F:
        return "Only GPA & Grades";
      case MarkingSchemeCode.G:
        return "Only Grades & Marks";
      default:
        return "Invalid scheme";
    }
  }

  String get value {
    // In the order of Marks, Gpa, Grades
    switch (this) {
      case MarkingSchemeCode.A:
        return "TTT";
      case MarkingSchemeCode.B:
        return "TFF";
      case MarkingSchemeCode.C:
        return "FTF";
      case MarkingSchemeCode.D:
        return "FFT";
      case MarkingSchemeCode.E:
        return "TTF";
      case MarkingSchemeCode.F:
        return "FTT";
      case MarkingSchemeCode.G:
        return "TFT";
      default:
        return "FFF";
    }
  }
}

MarkingSchemeCode fromMarkingSchemeCodeBooleans(bool isMarks, bool isGrade, bool isGpa) {
  if (isMarks && isGrade && isGpa) {
    return MarkingSchemeCode.A;
  } else if (isMarks && !isGrade && !isGpa) {
    return MarkingSchemeCode.B;
  } else if (!isMarks && !isGrade && isGpa) {
    return MarkingSchemeCode.C;
  } else if (!isMarks && isGrade && !isGpa) {
    return MarkingSchemeCode.D;
  } else if (isMarks && isGrade && !isGpa) {
    return MarkingSchemeCode.E;
  } else if (!isMarks && isGrade && isGpa) {
    return MarkingSchemeCode.F;
  } else if (isMarks && isGrade && !isGpa) {
    return MarkingSchemeCode.G;
  }
  return MarkingSchemeCode.A;
}

MarkingSchemeCode? fromMarkingSchemeCodeString(String value) {
  switch (value) {
    case "A":
      return MarkingSchemeCode.A;
    case "B":
      return MarkingSchemeCode.B;
    case "C":
      return MarkingSchemeCode.C;
    case "D":
      return MarkingSchemeCode.D;
    case "E":
      return MarkingSchemeCode.E;
    case "F":
      return MarkingSchemeCode.F;
    case "G":
      return MarkingSchemeCode.G;
    default:
      return null;
  }
}

InternalsComputationCode? fromInternalsComputationCodeString(String value) {
  switch (value) {
    case "A":
      return InternalsComputationCode.A;
    case "B":
      return InternalsComputationCode.B;
    case "S":
      return InternalsComputationCode.S;
    default:
      return null;
  }
}
