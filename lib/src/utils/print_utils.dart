// ignore_for_file: implementation_imports, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/number_to_words.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

Future<Uint8List> printReceipts(
  BuildContext context,
  SchoolInfoBean schoolInfoBean,
  List<StudentFeeReceipt> receiptsToPrint,
  List<StudentProfile> studentProfiles,
  bool isTermWise, {
  bool isAdminCopySelected = false,
  bool isStudentCopySelected = true,
  bool download = false,
  bool isNewTab = true,
}) async {
  final pdf = pw.Document();
  final font = await PdfGoogleFonts.merriweatherRegular();
  final schoolNameFont = await PdfGoogleFonts.acmeRegular();
  for (int i = 0; i < receiptsToPrint.length; i++) {
    [isAdminCopySelected ? "Admin Copy" : null, isStudentCopySelected ? "Student Copy" : null].whereNotNull().forEach((copyType) async {
      StudentFeeReceipt eachTransaction = receiptsToPrint[i];
      List<pw.Widget> widgets = [];
      widgets.add(receiptHeaderWidget(schoolInfoBean, schoolNameFont, font));
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8.0),
        child: pw.Divider(color: PdfColors.black, thickness: 1),
      ));
      pw.Container eachTxnContainer = pw.Container(
        padding: const pw.EdgeInsets.fromLTRB(50, 10, 50, 10),
        child: pw.Column(
          children: [
            pw.SizedBox(
              height: 10,
            ),
            receiptTitleWidget(font),
            pw.SizedBox(
              height: 10,
            ),
            copyTypeWidget(copyType, font),
            pw.SizedBox(
              height: 20,
            ),
            receiptNumberAndDateWidget(font, eachTransaction),
            pw.SizedBox(
              height: 10,
            ),
            studentNameWidget(studentProfiles.where((e) => e.studentId == eachTransaction.studentId).first, font),
            // if (studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.fatherName != null)
            //   pw.SizedBox(
            //     height: 10,
            //   ),
            if (studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.gaurdianFirstName != null)
              pw.SizedBox(
                height: 10,
              ),
            if (eachTransaction.gaurdianName != null) parentNameWidget(eachTransaction.gaurdianName ?? "-", font),
            pw.SizedBox(
              height: 10,
            ),
            sectionAndRollNumberWidget(studentProfiles, eachTransaction, font),
            pw.SizedBox(
              height: 10,
            ),
          ],
        ),
      );
      widgets.add(eachTxnContainer);
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(50, 10, 50, 10),
          child: transactionsTableWidget(font, eachTransaction, isTermWise),
        ),
      );
      widgets.addAll([
        amountPayingInWordsWidget((eachTransaction.getTotalAmountForReceipt()) ~/ 100, font),
        pw.SizedBox(height: 5),
        if ((eachTransaction.comments ?? "").trim() == "") modeOfPaymentWidget(eachTransaction, font),
        if ((eachTransaction.comments ?? "").trim() == "") pw.SizedBox(height: 5),
        if ((eachTransaction.comments ?? "").trim() != "") commentsAndModeOfPaymentWidget(eachTransaction, font),
        if ((eachTransaction.comments ?? "").trim() != "") pw.SizedBox(height: 5),
        noteWidget(font),
      ]);
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(50, 10, 50, 10),
          child: pw.Row(
            children: [
              signatureWidget(font),
            ],
          ),
        ),
      );
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: widgets,
              ),
            ),
          ];
        },
        // footer: (_) => pw.Row(
        //   children: [
        //     signatureWidget(font),
        //   ],
        // ),
      ));
    });
  }
  var x = await pdf.save();
  final blob = html.Blob([x], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement anchorElement = html.AnchorElement(href: url);
  if (isNewTab) {
    anchorElement.target = '_blank';
  }
  if (download) {
    anchorElement.download = "Receipts.pdf";
  }
  anchorElement.click();
  return x;
}

pw.Widget commentsAndModeOfPaymentWidget(StudentFeeReceipt eachTransaction, pw.Font font) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: paddedText(
          "Comments: ${eachTransaction.comments ?? " - "}",
          font,
          fontSize: 10,
          align: pw.TextAlign.left,
          textColor: PdfColors.black,
          padding: const pw.EdgeInsets.fromLTRB(50, 6, 6, 6),
        ),
      ),
      pw.SizedBox(width: 10),
      pw.Expanded(
        child: modeOfPaymentWidget(eachTransaction, font),
      ),
      pw.SizedBox(width: 20),
    ],
  );
}

pw.Widget amountPayingInWordsWidget(int amount, pw.Font font) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: paddedText(
          "Amount In Words: ${convertIntoWords(amount).capitalize()} only",
          font,
          fontSize: 12,
          align: pw.TextAlign.left,
          textColor: PdfColors.black,
          padding: const pw.EdgeInsets.fromLTRB(50, 6, 6, 6),
        ),
      ),
    ],
  );
}

pw.Widget noteWidget(pw.Font font) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: paddedText(
          "Note: Fee once paid, will not be returned or transferred",
          font,
          fontSize: 10,
          align: pw.TextAlign.left,
          textColor: PdfColors.grey700,
          padding: const pw.EdgeInsets.fromLTRB(50, 6, 6, 6),
        ),
      ),
    ],
  );
}

pw.Widget copyTypeWidget(String copyType, pw.Font font) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: pw.Text(
          copyType,
          style: pw.TextStyle(
            font: font,
            fontSize: 14,
            color: PdfColors.grey700,
          ),
          textAlign: pw.TextAlign.right,
        ),
      ),
    ],
  );
}

pw.Row receiptTitleWidget(pw.Font font) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: pw.Text(
          "Fee Receipt",
          style: pw.TextStyle(
            font: font,
            fontSize: 18,
            decoration: pw.TextDecoration.underline,
            color: PdfColors.black,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    ],
  );
}

pw.Expanded signatureWidget(pw.Font font) {
  return pw.Expanded(
    child: paddedText(
      "Signature",
      font,
      fontSize: 16,
      align: pw.TextAlign.right,
      padding: const pw.EdgeInsets.fromLTRB(6, 6, 6, 6),
    ),
  );
}

pw.Widget modeOfPaymentWidget(StudentFeeReceipt eachTransaction, pw.Font font) {
  return paddedText(
    "Mode Of Payment: ${eachTransaction.modeOfPayment ?? "CASH"}",
    font,
    fontSize: 10,
    align: pw.TextAlign.left,
    padding: const pw.EdgeInsets.fromLTRB(50, 6, 6, 6),
  );
}

pw.Table transactionsTableWidget(pw.Font font, StudentFeeReceipt eachTransaction, bool isTermWise) {
  List<pw.TableRow> childTransactionsWidgets = childTransactionsPdfWidgets(eachTransaction, font, isTermWise);
  int txnsLength = (eachTransaction.feeTypes ?? []).length + (eachTransaction.feeTypes ?? []).map((e) => e?.customFeeTypes ?? []).length;
  if (txnsLength < 4) {
    for (int i = 0; i <= 4 - childTransactionsWidgets.length; i++) {
      childTransactionsWidgets.add(pw.TableRow(
        children: [
          pw.Expanded(
            child: paddedText(
              "|",
              font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              align: pw.TextAlign.center,
              textColor: PdfColors.white,
            ),
          ),
          paddedText(
            "|",
            font,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            align: pw.TextAlign.center,
            textColor: PdfColors.white,
          ),
        ],
      ));
    }
  }
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.black),
    children: [
      pw.TableRow(
        children: [
          pw.Expanded(
            child: paddedText(
              "Particulars",
              font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              align: pw.TextAlign.center,
            ),
          ),
          paddedText(
            "Amount",
            font,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            align: pw.TextAlign.center,
          ),
        ],
      ),
      ...childTransactionsWidgets,
      pw.TableRow(
        children: [
          pw.Expanded(
            child: paddedText(
              "Total",
              font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              align: pw.TextAlign.center,
            ),
          ),
          paddedText(
            "$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTransaction.getTotalAmountForReceipt()) / 100)} /-",
            font,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            align: pw.TextAlign.right,
          ),
        ],
      ),
    ],
  );
}

pw.Row sectionAndRollNumberWidget(List<StudentProfile> studentProfiles, StudentFeeReceipt eachTransaction, pw.Font font) {
  return pw.Row(
    children: [
      pw.Expanded(
        flex: 3,
        child: pw.Text(
          "Class: ${studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.sectionName ?? "-"}",
          style: pw.TextStyle(font: font, fontSize: 16),
        ),
      ),
      pw.Expanded(
        flex: 2,
        child: pw.Text(
          "Roll No.: ${studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.rollNumber ?? "-"}",
          style: pw.TextStyle(font: font, fontSize: 16),
        ),
      ),
    ],
  );
}

pw.Row parentNameWidget(String parentName, pw.Font font) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: pw.Text(
          "S/o / D/o: $parentName",
          style: pw.TextStyle(font: font, fontSize: 14),
        ),
      ),
    ],
  );
}

pw.Row studentNameWidget(StudentProfile studentProfile, pw.Font font) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: pw.Text(
          "Student Name: ${studentProfile.studentFirstName ?? "-"}",
          style: pw.TextStyle(font: font, fontSize: 14),
        ),
      ),
      pw.SizedBox(width: 10),
      if (studentProfile.admissionNo != null)
        pw.Text(
          "Admission No.: ${studentProfile.admissionNo ?? "-"}",
          style: pw.TextStyle(font: font, fontSize: 14),
        ),
    ],
  );
}

pw.Row receiptNumberAndDateWidget(pw.Font font, StudentFeeReceipt eachTransaction) {
  return pw.Row(
    children: [
      if (eachTransaction.receiptNumber != null)
        pw.Expanded(
          flex: 3,
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                "Receipt No.: ",
                style: pw.TextStyle(font: font, fontSize: 16),
                textAlign: pw.TextAlign.left,
              ),
              pw.Expanded(
                child: pw.Text(
                  " ${eachTransaction.receiptNumber ?? ""}",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 16,
                    color: PdfColors.red,
                  ),
                  textAlign: pw.TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      pw.Expanded(
        flex: 2,
        child: pw.Text(
          "Date: ${convertDateToDDMMMYYY(eachTransaction.transactionDate)}",
          style: pw.TextStyle(font: font, fontSize: 16),
        ),
      ),
    ],
  );
}

pw.Widget receiptHeaderWidget(SchoolInfoBean schoolInfoBean, pw.Font schoolNameFont, pw.Font font) {
  return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(4, 4, 4, 2),
      child: schoolInfoBean.receiptHeader != null
          ? pw.Image(
              pw.MemoryImage(
                const Base64Decoder().convert(schoolInfoBean.receiptHeader!),
              ),
              fit: pw.BoxFit.scaleDown,
            )
          : pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        schoolInfoBean.schoolDisplayName ?? "-",
                        style: pw.TextStyle(font: schoolNameFont, fontSize: 30, color: PdfColors.blue),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        schoolInfoBean.detailedAddress ?? "-",
                        style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey900),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ));
}

List<pw.TableRow> childTransactionsPdfWidgets(StudentFeeReceipt receipt, pw.Font font, bool isTermWise) {
  // return (e.studentFeeChildTransactionList ?? []).map((e) => Container()).toList();
  List<pw.TableRow> childTxnWidgets = [];
  (receipt.feeTypes ?? []).where((e) => e != null).map((e) => e!).forEach((eachFeeType) {
    if ((eachFeeType.customFeeTypes ?? []).isEmpty) {
      childTxnWidgets.add(
        pw.TableRow(
          children: [
            pw.Expanded(
              child: paddedText(eachFeeType.feeType ?? "-", font),
            ),
            !isTermWise || (eachFeeType.termWiseFeeComponents ?? []).isEmpty
                ? paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeType.amountPaidForTheReceipt ?? 0) / 100.0)} /-", font,
                    align: pw.TextAlign.right)
                : paddedText("", font),
          ],
        ),
      );
      if (isTermWise && (eachFeeType.termWiseFeeComponents ?? []).isNotEmpty) {
        for (TermWiseFeeComponent eachTermComponent in (eachFeeType.termWiseFeeComponents ?? []).where((e) => e != null).map((e) => e!)) {
          childTxnWidgets.add(
            pw.TableRow(
              children: [
                pw.Expanded(
                  child: paddedText(eachTermComponent.termName ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(12, 6, 6, 6)),
                ),
                paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.termWiseAmountPaidForTheReceipt ?? 0) / 100.0)} /-", font,
                    align: pw.TextAlign.right)
              ],
            ),
          );
        }
      }
    } else {
      childTxnWidgets.add(
        pw.TableRow(
          children: [
            pw.Expanded(
              child: paddedText(eachFeeType.feeType ?? "-", font),
            ),
          ],
        ),
      );
      (eachFeeType.customFeeTypes ?? []).where((e) => e != null).map((e) => e!).forEach((eachCustomFeeType) {
        // eachCustomFeeType
        childTxnWidgets.add(
          pw.TableRow(
            children: [
              pw.Expanded(
                child: paddedText(eachCustomFeeType.customFeeType ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(8, 6, 6, 6)),
              ),
              !isTermWise || (eachCustomFeeType.termWiseFeeComponents ?? []).isEmpty
                  ? paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachCustomFeeType.amountPaidForTheReceipt ?? 0) / 100.0)} /-", font,
                      align: pw.TextAlign.right)
                  : paddedText("", font),
            ],
          ),
        );
        if (isTermWise && (eachCustomFeeType.termWiseFeeComponents ?? []).isNotEmpty) {
          for (TermWiseFeeComponent eachTermComponent in (eachCustomFeeType.termWiseFeeComponents ?? []).where((e) => e != null).map((e) => e!)) {
            childTxnWidgets.add(
              pw.TableRow(
                children: [
                  pw.Expanded(
                    child: paddedText(eachTermComponent.termName ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(12, 6, 6, 6)),
                  ),
                  paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.termWiseAmountPaidForTheReceipt ?? 0) / 100.0)} /-", font,
                      align: pw.TextAlign.right)
                ],
              ),
            );
          }
        }
      });
    }
  });

  if ((receipt.busFeePaid ?? 0) != 0) {
    childTxnWidgets.add(
      pw.TableRow(
        children: [
          pw.Expanded(
            child: paddedText("Bus Fee", font),
          ),
          paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((receipt.busFeePaid ?? 0) / 100.0)} /-", font, align: pw.TextAlign.right),
        ],
      ),
    );
  }

  return childTxnWidgets;
}

pw.Widget paddedText(
  final String text,
  final pw.Font font, {
  final pw.EdgeInsets padding = const pw.EdgeInsets.all(6),
  final pw.TextAlign align = pw.TextAlign.left,
  final double fontSize = 16,
  final pw.FontWeight fontWeight = pw.FontWeight.normal,
  final PdfColor? textColor,
}) =>
    pw.Padding(
      padding: padding,
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
    );
