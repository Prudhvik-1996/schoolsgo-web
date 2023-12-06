import 'dart:convert';
import 'dart:html' as html;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class StudentAbsenteesPdfDownload {
  final List<StudentProfile> filteredStudentsList;
  final List<StudentAttendanceBean> studentAttendanceBeans;
  final bool showOnlyAbsentees;
  final bool showContactInfo;
  final SchoolInfoBean schoolInfo;
  final DateTime selectedDate;

  StudentAbsenteesPdfDownload({
    required this.filteredStudentsList,
    required this.studentAttendanceBeans,
    required this.showOnlyAbsentees,
    required this.showContactInfo,
    required this.schoolInfo,
    required this.selectedDate,
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
        header: (_) => schoolInfo.receiptHeader != null
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
                      cellText("Attendance", isCenter: false),
                    ].toList(),
                  ),
                  ...filteredStudentsList.map(
                    (StudentProfile eachStudent) {
                      Map<String, PdfColor> slotsStrings = Map.fromEntries(
                        (studentAttendanceBeans.where((esab) => esab.studentId == eachStudent.studentId).toList()
                              ..sort((a, b) => getSecondsEquivalentOfTimeFromWHHMMSS(a.startTime, null)
                                  .compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(b.startTime, null))))
                            .where((e) => showOnlyAbsentees ? e.isPresent == -1 : true)
                            .map(
                              (esab) => MapEntry(
                                "${esab.startTime == null ? "-" : formatHHMMSStoHHMMA(esab.startTime!)} - ${esab.endTime == null ? "-" : formatHHMMSStoHHMMA(esab.endTime!)}",
                                esab.isPresent == 1
                                    ? PdfColors.green
                                    : esab.isPresent == -1
                                        ? PdfColors.red
                                        : PdfColors.blue,
                              ),
                            ),
                      );
                      return TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          cellText(eachStudent.sectionName ?? "", isCenter: false),
                          cellText(eachStudent.rollNumber ?? "", isCenter: false),
                          cellText(eachStudent.studentFirstName ?? "", isCenter: false),
                          if (showContactInfo) cellText(eachStudent.gaurdianFirstName ?? "", isCenter: false),
                          if (showContactInfo) cellText(eachStudent.gaurdianMobile ?? "", isCenter: false),
                          cellRichText(slotsStrings),
                        ],
                      );
                    },
                  ),
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
    anchorElement.download = "Student Absentees List (${convertDateTimeToDDMMYYYYFormat(selectedDate)}).pdf";
    anchorElement.click();
  }

  Widget cellText(
    String e, {
    bool isCenter = true,
    double fontSize = 7,
  }) {
    final textWidget = Text(
      e,
      style: TextStyle(fontSize: fontSize),
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
