import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';

class UpdateSectionWiseStudentFeeInBulk {
  List<StudentProfile> studentsList;
  List<StudentAnnualFeeBean> studentAnnualFeeList;
  Section selectedSection;
  int agentId;
  int schoolId;
  List<FeeType> feeTypesForSelectedSection;

  late List<String> headerStrings;
  int startIndexOfNewStudents = 0;

  UpdateSectionWiseStudentFeeInBulk({
    required this.studentsList,
    required this.studentAnnualFeeList,
    required this.selectedSection,
    required this.agentId,
    required this.schoolId,
    required this.feeTypesForSelectedSection,
  }) {
    debugPrint("30: ${studentsList.length} :: ${studentAnnualFeeList.length}");
    headerStrings = [
      ...[
        "Roll No.",
        "Admission No.",
        "Student Name",
        "Student Accommodation Type",
      ],
      ...feeTypesForSelectedSection
          .map((eft) {
            List<CustomFeeType> customFeeTypeList = (eft.customFeeTypesList ?? []).whereNotNull().toList();
            if (customFeeTypeList.isNotEmpty) {
              return customFeeTypeList.map((ecft) => "${eft.feeType}\n${ecft.customFeeType}").toList();
            }
            return ["${eft.feeType}"];
          })
          .expand((i) => i)
          .map((e) => ["$e\nActual Fee", "$e\nDiscount"])
          .expand((i) => i),
      ...[
        "Bus Fee",
      ],
    ];
    startIndexOfNewStudents = 4 + studentsList.length;
  }

  Future<void> downloadTemplate() async {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel['Fee Data for ${selectedSection.sectionName ?? ""}'];

    int rowIndex = 0;
    sheet.appendRow([(selectedSection.sectionName ?? "")]);
    CellStyle sectionNameStyle = CellStyle(
      bold: true,
      fontSize: 24,
      horizontalAlign: HorizontalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = sectionNameStyle;
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: headerStrings.length - 1, rowIndex: 0));
    rowIndex++; // 1

    sheet.appendRow(["Date: ${(convertDateTimeToDDMMYYYYFormat(DateTime.now()))}"]);
    CellStyle dateStyle = CellStyle(
      bold: true,
      fontSize: 18,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).cellStyle = dateStyle;
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1), CellIndex.indexByColumnRow(columnIndex: headerStrings.length - 1, rowIndex: 1));
    rowIndex++; // 2

    String rules =
        """Guidelines for Adding Students in the Excel Template\n\nThank you for your dedication to maintaining the integrity of the data within the Excel template. To ensure consistent and accurate data management, please adhere to the following guidelines when updating student fees.\n\nPreserve Template Structure:\n\nKindly refrain from altering the template's file name or sheet name. This ensures seamless data synchronization and validation.\n\nMaintain Core Data:\n\nPlease refrain from modifying the sequence and content of essential elements such as Student Names, Roll Numbers, etc. These details are crucial for proper identification and tracking.\n\nExisting Student Data:\n\nThe existing student data will not be modified in any case.\nValid Input Characters:\n\nPlease refrain from using any other characters except numbers, as they will be considered invalid.\n\nYour attention to these guidelines contributes significantly to data consistency and reliability. If you have any questions or require assistance, do not hesitate to reach out to the support team.\n\nThank you for your cooperation.""";
    rules += "\n\n\n\n\n";
    sheet.appendRow([rules.replaceAll("\n\n", "\r\n")]);
    CellStyle rulesDataStyle = CellStyle(
      bold: false,
      fontSize: 10,
      textWrapping: TextWrapping.WrapText,
      backgroundColorHex: "#FF0000",
      fontColorHex: "#FFFFFF",
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).cellStyle = rulesDataStyle;
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2), CellIndex.indexByColumnRow(columnIndex: headerStrings.length - 1, rowIndex: 2));
    rowIndex++; // 3

    sheet.appendRow(headerStrings);
    for (int j = 0; j < sheet.maxCols; j++) {
      CellStyle headerDataCellStyle = CellStyle(
        bold: false,
        fontSize: 10,
        textWrapping: TextWrapping.WrapText,
        backgroundColorHex: "#000000",
        fontColorHex: "#FFFFFF",
      );
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 3)).cellStyle = headerDataCellStyle;
    }
    rowIndex++; // 4

    for (StudentProfile eachStudent in studentsList) {
      StudentAnnualFeeBean? eachStudentAnnualFeeBean = studentAnnualFeeList.firstWhereOrNull((eaf) => eaf.studentId == eachStudent.studentId);
      if (eachStudentAnnualFeeBean == null) continue;
      debugPrint("${eachStudent.studentFirstName}");
      List<double> feeTypeWiseFeesForStudent = feeTypesForSelectedSection
          .map((eft) {
            StudentAnnualFeeTypeBean eachStudentAnnualFeeTypeBean =
                (eachStudentAnnualFeeBean.studentAnnualFeeTypeBeans ?? []).firstWhere((e) => e.feeTypeId == eft.feeTypeId);
            List<CustomFeeType> customFeeTypeList = (eft.customFeeTypesList ?? []).whereNotNull().toList();
            if (customFeeTypeList.isNotEmpty) {
              return customFeeTypeList
                  .map((ecft) {
                    StudentAnnualCustomFeeTypeBean eachStudentAnnualCustomFeeTypeBean =
                        (eachStudentAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? [])
                            .firstWhere((e) => e.customFeeTypeId == ecft.customFeeTypeId);
                    debugPrint(
                        "\t${eft.feeType} - ${ecft.customFeeType} :: ${eachStudentAnnualCustomFeeTypeBean.amount} :: ${eachStudentAnnualCustomFeeTypeBean.discount}");
                    return [(eachStudentAnnualCustomFeeTypeBean.amount ?? 0) / 100, (eachStudentAnnualCustomFeeTypeBean.discount ?? 0) / 100];
                  })
                  .expand((i) => i)
                  .toList();
            }
            debugPrint("\t${eft.feeType} :: ${eachStudentAnnualFeeTypeBean.amount} :: ${eachStudentAnnualFeeTypeBean.discount}");
            return [(eachStudentAnnualFeeTypeBean.amount ?? 0) / 100, (eachStudentAnnualFeeTypeBean.discount ?? 0) / 100];
          })
          .expand((i) => i)
          .toList();
      debugPrint("\tBus :: ${eachStudentAnnualFeeBean.studentBusFeeBean?.fare}");
      double eachStudentBusFare = (eachStudentAnnualFeeBean.studentBusFeeBean?.fare ?? 0) / 100;
      sheet.appendRow([
        ...[
          eachStudent.rollNumber ?? "",
          eachStudent.admissionNo ?? "",
          eachStudent.studentFirstName ?? "",
          eachStudent.getAccommodationType(),
        ],
        ...feeTypeWiseFeesForStudent,
        ...[eachStudentBusFare],
      ]);
      rowIndex++;
    }

    for (int i = 4; i < rowIndex; i++) {
      for (int j = 0; j < sheet.maxCols; j++) {
        CellStyle studentDataCellStyle = CellStyle(
          bold: false,
          fontSize: 10,
          textWrapping: TextWrapping.WrapText,
          backgroundColorHex: "#F0FF00",
          fontColorHex: "#000000",
        );
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i)).cellStyle = studentDataCellStyle;
      }
    }

    // Auto fit the columns
    for (var i = 1; i < sheet.maxCols; i++) {
      sheet.setColAutoFit(i);
    }

    // Deleting default sheet
    if (excel.getDefaultSheet() != null) {
      excel.delete(excel.getDefaultSheet()!);
    }

    // Generate the Excel file as bytes
    List<int>? excelBytes = excel.encode();
    if (excelBytes == null) return;
    Uint8List excelUint8List = Uint8List.fromList(excelBytes);

    // Save the Excel file
    saveFile(excelUint8List, 'Student Fee Data bulk update ${selectedSection.sectionName}.xlsx');
  }

  Future<CreateOrUpdateStudentAnnualFeeMapRequest?> uploadFromTemplateActionToEdit(BuildContext context) async {
    List<StudentAnnualFeeMapUpdateBean> updatedFeeBeans = [];
    List<StudentStopFare> updatedBusFareBeans = [];
    Uint8List? bytes = await pickFile();
    if (bytes == null) return null;
    Excel excel = Excel.decodeBytes(bytes);
    for (String table in excel.tables.keys) {
      for (int rowIndex = 4; rowIndex < startIndexOfNewStudents; rowIndex++) {
        var studentIndex = rowIndex - 4;
        StudentProfile eachStudent = studentsList[studentIndex];
        int colIndex = 0;
        StudentAnnualFeeBean? eachStudentAnnualFeeBean = studentAnnualFeeList.firstWhereOrNull((eaf) => eaf.studentId == eachStudent.studentId);
        if (eachStudentAnnualFeeBean == null) continue;
        String inputtedRollNo = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? ""; // Roll No.
        if (inputtedRollNo.trim() != (eachStudent.rollNumber?.trim() ?? "")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Roll No. edited for student ${eachStudent.studentNameAsStringWithSectionAndRollNumber()} which is not allowed"),
            ),
          );
          return null;
        }
        String inputtedAdmissionNo = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? ""; // "Admission No.",
        if (inputtedAdmissionNo.trim() != (eachStudent.admissionNo?.trim() ?? "")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Admission No. edited for student ${eachStudent.studentNameAsStringWithSectionAndRollNumber()} which is not allowed"),
            ),
          );
          return null;
        }
        String inputtedStudentName = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? ""; // "Student Name",
        if (inputtedStudentName.trim() != (eachStudent.studentFirstName?.trim() ?? "")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Student Name edited for student ${eachStudent.studentNameAsStringWithSectionAndRollNumber()} which is not allowed"),
            ),
          );
          return null;
        }
        String inputtedAccommodationType =
            excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? ""; // "Student Accommodation Type",
        if (inputtedAccommodationType.trim() != eachStudent.getAccommodationType().trim()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Student Accommodation Type edited for student ${eachStudent.studentNameAsStringWithSectionAndRollNumber()} which is not allowed"),
            ),
          );
          return null;
        }
        debugPrint("${eachStudent.studentFirstName}");
        for (FeeType eft in feeTypesForSelectedSection) {
          StudentAnnualFeeTypeBean eachStudentAnnualFeeTypeBean =
              (eachStudentAnnualFeeBean.studentAnnualFeeTypeBeans ?? []).firstWhere((e) => e.feeTypeId == eft.feeTypeId);
          List<CustomFeeType> customFeeTypeList = (eft.customFeeTypesList ?? []).whereNotNull().toList();
          if (customFeeTypeList.isNotEmpty) {
            for (CustomFeeType ecft in customFeeTypeList) {
              StudentAnnualCustomFeeTypeBean eachStudentAnnualCustomFeeTypeBean =
                  (eachStudentAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).firstWhere((e) => e.customFeeTypeId == ecft.customFeeTypeId);
              int editedCftAmount = (int.tryParse(excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? "") ?? 0) * 100;
              int editedCftDiscount = (int.tryParse(excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? "") ?? 0) * 100;
              if (editedCftAmount != eachStudentAnnualCustomFeeTypeBean.amount || editedCftDiscount != eachStudentAnnualCustomFeeTypeBean.discount) {
                updatedFeeBeans.add(StudentAnnualFeeMapUpdateBean(
                  schoolId: schoolId,
                  studentId: eachStudentAnnualFeeBean.studentId,
                  amount: editedCftAmount,
                  discount: editedCftDiscount,
                  comments: null,
                  sectionFeeMapId: eachStudentAnnualCustomFeeTypeBean.sectionFeeMapId,
                  studentFeeMapId: eachStudentAnnualCustomFeeTypeBean.studentFeeMapId,
                ));
              }
              debugPrint("Edited: \t${eft.feeType} - ${ecft.customFeeType} :: $editedCftAmount :: $editedCftDiscount");
            }
          } else {
            int editedFtAmount = (int.tryParse(excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? "") ?? 0) * 100;
            int editedFtDiscount = (int.tryParse(excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? "") ?? 0) * 100;
            if (editedFtAmount != eachStudentAnnualFeeTypeBean.amount || editedFtDiscount != eachStudentAnnualFeeTypeBean.discount) {
              updatedFeeBeans.add(StudentAnnualFeeMapUpdateBean(
                schoolId: schoolId,
                studentId: eachStudentAnnualFeeBean.studentId,
                amount: editedFtAmount,
                discount: editedFtDiscount,
                comments: null,
                sectionFeeMapId: eachStudentAnnualFeeTypeBean.sectionFeeMapId,
                studentFeeMapId: eachStudentAnnualFeeTypeBean.studentFeeMapId,
              ));
            }
            debugPrint("Edited: \t${eft.feeType} :: $editedFtAmount :: $editedFtDiscount");
          }
        }
        int editedBusFee = (int.tryParse(excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? "") ?? 0) * 100;
        if (editedBusFee != eachStudentAnnualFeeBean.studentBusFeeBean?.fare) {
          updatedBusFareBeans.add(StudentStopFare(
            studentId: eachStudentAnnualFeeBean.studentId,
            fare: editedBusFee,
          ));
        }
        debugPrint("Edited: \tBus :: $editedBusFee");
      }
    }
    return CreateOrUpdateStudentAnnualFeeMapRequest(
      schoolId: schoolId,
      agent: agentId,
      studentAnnualFeeMapBeanList: updatedFeeBeans,
      studentRouteStopFares: updatedBusFareBeans,
    );
  }
}
