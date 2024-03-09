import 'dart:convert';
import 'dart:html' as html;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/schools.dart';

Future<String?> downloadAttendanceQRPdf(
  String qrUrl,
  SchoolInfoBean schoolInfo,
) async {
  final pdf = Document();

  final font = await PdfGoogleFonts.merriweatherRegular();
  final schoolNameFont = await PdfGoogleFonts.acmeRegular();
  List<ImageProvider?> studentImages = [];
  ImageProvider? qrImage;
  try {
    qrImage = await networkImage(allowCORSEndPoint + qrUrl);
  } on Exception catch (e) {
    return "Something went wrong.. $e";
  }
  pdf.addPage(MultiPage(
    pageTheme: PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const EdgeInsets.all(32),
      buildBackground: (_) {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: PdfColors.grey), // Set your preferred border color here
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
    build: (context) {
      return [
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text("Please use the QR code provided to register your attendance.", textAlign: TextAlign.center),
            ),
          ],
        ),
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Image(qrImage!, height: 250, width: 250, fit: BoxFit.scaleDown, alignment: Alignment.center),
            ),
          ],
        ),
      ];
    },
    footer: (_) => Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(""),
          Expanded(
            child: Center(child: Text("Powered by Epsilon Diary")),
          ),
        ],
      ),
    ),
  ));
  var x = await pdf.save();
  final blob = html.Blob([x], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement anchorElement = html.AnchorElement(href: url);
  anchorElement.target = '_blank';
  anchorElement.download = "Employee Attendance QR.pdf";
  anchorElement.click();
  return "Pdf Generated Successfully";
}
