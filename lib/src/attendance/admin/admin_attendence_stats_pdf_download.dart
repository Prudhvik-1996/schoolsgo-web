import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_information_center/modal/date_range_attendance.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class StudentAttendanceStatsPdfDownload {
  final Map<StudentProfile, StudentDateRangeAttendanceBean?> studentAttendanceMap;
  final bool showContactInfo;
  final String startDateForAttendance;
  final String endDateForAttendance;
  final SchoolInfoBean schoolInfo;

  StudentAttendanceStatsPdfDownload({
    required this.studentAttendanceMap,
    required this.showContactInfo,
    required this.startDateForAttendance,
    required this.endDateForAttendance,
    required this.schoolInfo,
  });

  Future<void> downloadAsPdf() async {
    final pdf = Document();

    final font = await PdfGoogleFonts.merriweatherRegular();
    final schoolNameFont = await PdfGoogleFonts.acmeRegular();

    pdf.addPage(
      MultiPage(
        pageTheme: PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.all(32),
          buildBackground: (_) {
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.grey),
              ),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
            );
          },
        ),
        header: (_) => Column(
          children: [
            schoolInfo.receiptHeader != null
                ? Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image(
                      MemoryImage(
                        const Base64Decoder().convert(schoolInfo.receiptHeader!),
                      ),
                      fit: BoxFit.scaleDown,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              schoolInfo.schoolDisplayName ?? "-",
                              style: TextStyle(font: schoolNameFont, fontSize: 30, color: PdfColors.blue),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              schoolInfo.detailedAddress ?? "-",
                              style: TextStyle(font: font, fontSize: 14, color: PdfColors.grey900),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: cellText("From: ${convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(startDateForAttendance))}"),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: cellText("To: ${convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(endDateForAttendance))}"),
                  ),
                ),
              ],
            ),
          ],
        ),
        build: (Context context) {
          return [
            SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.all(10),
              child: Table(
                border: TableBorder.all(
                  color: PdfColors.grey,
                ),
                children: [
                  TableRow(
                    repeat: true,
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      cellText("Section", isCenter: false),
                      cellText("Roll No.", isCenter: false),
                      cellText("Student Name", isCenter: false),
                      if (showContactInfo) cellText("Parent Name", isCenter: false),
                      if (showContactInfo) cellText("Phone", isCenter: false),
                      cellText("Total", isCenter: false),
                      cellText("Present", isCenter: false),
                      cellText("Absent", isCenter: false),
                      cellText("Attendance (%)", isCenter: false),
                    ].toList(),
                  ),
                  ...studentAttendanceMap.entries.mapIndexed((int index, MapEntry<StudentProfile, StudentDateRangeAttendanceBean?> entry) {
                    StudentProfile es = entry.key;
                    StudentDateRangeAttendanceBean? attendanceBean = entry.value;
                    return TableRow(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        cellText(es.sectionName ?? "-", isCenter: false),
                        cellText(es.rollNumber ?? "-", isCenter: false),
                        cellText(es.studentFirstName ?? "-", isCenter: false),
                        if (showContactInfo) cellText(es.gaurdianFirstName ?? "-", isCenter: false),
                        if (showContactInfo) cellText(es.gaurdianMobile ?? "-", isCenter: false),
                        cellText(doubleToStringAsFixed(attendanceBean?.totalWorkingDays ?? 0), isCenter: false, color: PdfColors.blue),
                        cellText(doubleToStringAsFixed(attendanceBean?.presentDays ?? 0), isCenter: false, color: PdfColors.green),
                        cellText(doubleToStringAsFixed(attendanceBean?.absentDays ?? 0), isCenter: false, color: PdfColors.red),
                        cellText(doubleToStringAsFixed(attendanceBean?.attendancePercentage ?? 0), isCenter: false, color: PdfColors.black),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ];
        },
      ),
    );

    var x = await pdf.save();
    final blob = html.Blob([x], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.target = '_blank';
    anchorElement.download =
        "Student Attendance Stats (${convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(startDateForAttendance))} - ${convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(endDateForAttendance))}).pdf";
    anchorElement.click();
  }

  Widget cellText(
    String e, {
    bool isCenter = true,
    double fontSize = 7,
    PdfColor? color,
  }) {
    final textWidget = Text(
      e,
      style: TextStyle(fontSize: fontSize, color: color ?? PdfColors.black),
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
    );

    return Padding(
      padding: const EdgeInsets.all(4),
      child: isCenter ? Center(child: textWidget) : textWidget,
    );
  }

  Widget cellRichText(
    Map<String, PdfColor> stringsMap, {
    bool isCenter = false,
    double fontSize = 6,
  }) {
    final textWidget = RichText(
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
      text: TextSpan(children: [
        ...stringsMap.entries.map((MapEntry<String, PdfColor> entry) {
          String text = entry.key;
          PdfColor color = entry.value;
          return TextSpan(
            text: " $text ",
            style: TextStyle(color: color, fontSize: fontSize),
          );
        })
      ]),
    );

    return Padding(
      padding: const EdgeInsets.all(4),
      child: isCenter ? Center(child: textWidget) : textWidget,
    );
  }
}
