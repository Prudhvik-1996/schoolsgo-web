// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/fee_receipts_search_widget.dart';
import 'package:schoolsgo_web/src/fee/admin/new_student_fee_receipt_widget.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AdminFeeReceiptsScreenV3 extends StatefulWidget {
  const AdminFeeReceiptsScreenV3({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<AdminFeeReceiptsScreenV3> createState() => _AdminFeeReceiptsScreenV3State();
}

class _AdminFeeReceiptsScreenV3State extends State<AdminFeeReceiptsScreenV3> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<StudentFeeReceipt> studentFeeReceipts = [];
  List<StudentFeeReceipt> filteredStudentFeeReceipts = [];
  final ItemScrollController _itemScrollController = ItemScrollController();

  bool isSearchBarSelected = false;

  bool isTermWise = false;

  SchoolInfoBean? schoolInfoBean;
  List<StudentProfile> studentProfiles = [];
  List<Section> sections = [];
  List<FeeType> feeTypes = [];
  String? _renderingReceiptText;
  double? _loadingReceiptPercentage;
  Uint8List? pdfInBytes;

  bool isAddNew = false;
  ScrollController newReceiptsListViewController = ScrollController();

  List<NewReceipt> newReceipts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      studentFeeReceipts = [];
      filteredStudentFeeReceipts = [];
      newReceipts = [
        NewReceipt(
          schoolId: widget.adminProfile.schoolId,
          agentId: widget.adminProfile.userId,
          date: DateTime.now().millisecondsSinceEpoch,
          modeOfPayment: ModeOfPayment.CASH.name,
        ),
      ];
    });
    await loadReceipts();
    setState(() {
      newReceipts[newReceipts.length - 1].receiptNumber = newReceipts.isEmpty
          ? studentFeeReceipts.isEmpty
              ? 1
              : (studentFeeReceipts[0].receiptNumber ?? 0) + 1
          : (newReceipts[newReceipts.length - 1].receiptNumber ?? 0) + 1;
      newReceipts[newReceipts.length - 1].receiptNumberController.text = "${newReceipts[newReceipts.length - 1].receiptNumber}";
      newReceipts[newReceipts.length - 1].date = newReceipts.isEmpty
          ? studentFeeReceipts.isEmpty
              ? DateTime.now().millisecondsSinceEpoch
              : convertYYYYMMDDFormatToDateTime(studentFeeReceipts[0].transactionDate).millisecondsSinceEpoch
          : (newReceipts[newReceipts.length - 1].date ?? DateTime.now().millisecondsSinceEpoch);
      _isLoading = false;
    });
  }

  Future<void> loadReceipts() async {
    setState(() {
      _isLoading = true;
    });

    GetStudentFeeReceiptsResponse studentFeeReceiptsResponse = await getStudentFeeReceipts(GetStudentFeeReceiptsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (studentFeeReceiptsResponse.httpStatus != "OK" || studentFeeReceiptsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        studentFeeReceipts = studentFeeReceiptsResponse.studentFeeReceipts!.map((e) => e!).toList();
        filteredStudentFeeReceipts = studentFeeReceiptsResponse.studentFeeReceipts!.map((e) => e!).toList();
        studentFeeReceipts.sort((b, a) {
          int dateCom = convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate));
          return (dateCom == 0) ? (a.receiptNumber ?? 0).compareTo(b.receiptNumber ?? 0) : dateCom;
        });
        filteredStudentFeeReceipts.sort((b, a) {
          int dateComp = convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate));
          return (dateComp == 0) ? (a.receiptNumber ?? 0).compareTo(b.receiptNumber ?? 0) : dateComp;
        });
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getDataReadyToPrint() async {
    setState(() {
      _isLoading = true;
    });
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      schoolInfoBean = getSchoolsResponse.schoolInfo!;
    }

    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
    }

    GetSectionsResponse getSectionsResponse = await getSections(GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSectionsResponse.httpStatus != "OK" || getSectionsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      sections = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
    }

    GetFeeTypesResponse getFeeTypesResponse = await getFeeTypes(GetFeeTypesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getFeeTypesResponse.httpStatus != "OK" || getFeeTypesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void scrollToReceiptNumber(int e) {
    if (e == -1) return;
    _itemScrollController.scrollTo(
      index: e,
      duration: const Duration(milliseconds: 100),
      curve: Curves.bounceInOut,
    );
  }

  void isSearchButtonSelected(bool isSelected) {
    setState(() {
      isSearchBarSelected = isSelected;
    });
  }

  Future<void> handleClick(String choice) async {
    if (choice == "Go to date") {
      await goToDateAction();
    } else if (choice == "Term Wise") {
      setState(() => isTermWise = !isTermWise);
    } else if (choice == "Print") {
      makePdf();
    } else {
      debugPrint("Clicked on $choice");
      // Navigator.push(context, MaterialPageRoute(builder: (context) {
      //   return AdminFeeReceiptsStatsScreen(
      //     adminProfile: widget.adminProfile,
      //     studentFeeDetailsBeanList: studentFeeDetailsBeans,
      //     feeTypes: feeTypes,
      //     studentTermWiseFeeBeans: studentTermWiseFeeBeans,
      //   );
      // }));
    }
  }

  Future<void> goToDateAction() async {
    if (filteredStudentFeeReceipts.isEmpty) return;
    Set<DateTime> transactionDatesSet = filteredStudentFeeReceipts.map((e) => convertYYYYMMDDFormatToDateTime(e.transactionDate)).toSet();
    DateTime? _newDate = await showDatePicker(
      context: context,
      initialDate: transactionDatesSet.firstOrNull ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: "Select a date",
      initialEntryMode: DatePickerEntryMode.calendar,
      selectableDayPredicate: (DateTime? eachDate) {
        return transactionDatesSet.contains(eachDate);
      },
    );
    if (_newDate == null) return;
    scrollToReceiptNumber(
        filteredStudentFeeReceipts.map((e) => e.transactionDate).toList().indexWhere((e) => convertDateTimeToYYYYMMDDFormat(_newDate) == e));
  }

  pw.Widget paddedText(
    final String text,
    final pw.Font font, {
    final pw.EdgeInsets padding = const pw.EdgeInsets.all(6),
    final pw.TextAlign align = pw.TextAlign.left,
    final double fontSize = 16,
    final pw.FontWeight fontWeight = pw.FontWeight.normal,
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
          ),
        ),
      );

  Future<void> makePdf({int? transactionId}) async {
    bool isAdminCopySelected = true;
    bool isStudentCopySelected = transactionId != null;
    bool proceedPrint = true;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text('Download receipts'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text("Admin Copy"),
                    selected: isAdminCopySelected,
                    value: isAdminCopySelected,
                    onChanged: (bool value) {
                      setState(() => isAdminCopySelected = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Student Copy"),
                    selected: isStudentCopySelected,
                    value: isStudentCopySelected,
                    onChanged: (bool value) {
                      setState(() => isStudentCopySelected = value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Proceed to download"),
              onPressed: () async {
                if (!isAdminCopySelected && !isStudentCopySelected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("At least one in Admin Copy or Student Copy must be selected"),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                setState(() => proceedPrint = false);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    if (!proceedPrint) return;

    setState(() {
      _renderingReceiptText = "Preparing receipts";
    });
    if (schoolInfoBean == null) await getDataReadyToPrint();
    if (schoolInfoBean == null) return;
    final pdf = pw.Document();
    final schoolNameFont = await PdfGoogleFonts.acmeRegular();
    final font = await PdfGoogleFonts.merriweatherRegular();

    // pw.ImageProvider logoImageProvider;
    //
    // try {
    //   logoImageProvider = await networkImage(
    //     schoolInfoBean.logoPictureUrl ?? "https://storage.googleapis.com/storage-schools-go/Episilon%20infinity.jpg",
    //   );
    // } catch (e) {
    //   logoImageProvider = pw.MemoryImage(
    //     (await rootBundle.load('images/EISlogo.png')).buffer.asUint8List(),
    //   );
    // }

    List<StudentFeeReceipt> receiptsToPrint = studentFeeReceipts.where((e) => transactionId == null || e.transactionId == transactionId).toList();
    for (int i = 0; i < receiptsToPrint.length; i++) {
      [isAdminCopySelected ? "Admin Copy" : null, isStudentCopySelected ? "Student Copy" : null].whereNotNull().forEach((copyType) {
        StudentFeeReceipt eachTransaction = receiptsToPrint[i];
        setState(() {
          _renderingReceiptText = "Rendering receipt ${eachTransaction.receiptNumber}";
          _loadingReceiptPercentage = 100.0 * (i / receiptsToPrint.length);
        });
        List<pw.Widget> widgets = [];
        widgets.add(
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              // pw.Padding(
              //   padding: const pw.EdgeInsets.fromLTRB(5, 5, 5, 5),
              //   child: pw.Image(
              //     logoImageProvider,
              //     width: 60,
              //     height: 60,
              //   ),
              // ),
              // pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      schoolInfoBean?.schoolDisplayName ?? "-",
                      style: pw.TextStyle(font: schoolNameFont, fontSize: 30, color: PdfColors.blue),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      schoolInfoBean?.detailedAddress ?? "-",
                      style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey900),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        pw.Container eachTxnContainer = pw.Container(
          // decoration: pw.BoxDecoration(
          //   border: pw.Border.all(color: PdfColors.black),
          // ),
          padding: const pw.EdgeInsets.fromLTRB(50, 10, 50, 10),
          child: pw.Column(
            children: [
              pw.SizedBox(
                height: 10,
              ),
              pw.Row(
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
              ),
              pw.SizedBox(
                height: 10,
              ),
              pw.Text(
                copyType,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 14,
                  color: PdfColors.grey,
                  decoration: pw.TextDecoration.underline,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(
                height: 10,
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
                        pw.Text(
                          "Receipt No.: ",
                          style: pw.TextStyle(font: font, fontSize: 16),
                          textAlign: pw.TextAlign.left,
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            " ${eachTransaction.receiptNumber ?? "-"}",
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 16,
                              color: PdfColors.red,
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                      ])),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      "Date: ${convertDateToDDMMMYYY(eachTransaction.transactionDate)}",
                      style: pw.TextStyle(font: font, fontSize: 16),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(
                height: 10,
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "Student Name: ${eachTransaction.studentName ?? "-"}",
                      style: pw.TextStyle(font: font, fontSize: 18),
                    ),
                  ),
                ],
              ),
              if (studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.fatherName != null)
                pw.SizedBox(
                  height: 10,
                ),
              if (studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.fatherName != null)
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        "S/o / D/o: ${studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.fatherName ?? "-"}",
                        style: pw.TextStyle(font: font, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              pw.SizedBox(
                height: 10,
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      "Section: ${studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.sectionName ?? "-"}",
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
              ),
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
            child: pw.Table(
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
                ...childTransactionsPdfWidgets(eachTransaction, font),
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
            ),
          ),
        );
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(50, 10, 50, 10),
            child: pw.Row(
              children: [
                paddedText(
                  "Mode Of Payment: ${eachTransaction.modeOfPayment ?? "CASH"}",
                  font,
                  fontSize: 14,
                  align: pw.TextAlign.left,
                ),
                pw.Expanded(
                  child: paddedText(
                    "Signature",
                    font,
                    fontSize: 16,
                    align: pw.TextAlign.right,
                    padding: const pw.EdgeInsets.fromLTRB(6, 60, 6, 6),
                  ),
                ),
              ],
            ),
          ),
        );
        pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return widgets;
          },
        ));
      });
    }

    var x = await pdf.save();
    setState(() {
      pdfInBytes = x;
    });

    final blob = html.Blob([pdfInBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = "Receipts.pdf";
    anchorElement.click();
    setState(() {
      _renderingReceiptText = null;
    });
  }

  List<pw.TableRow> childTransactionsPdfWidgets(StudentFeeReceipt receipt, pw.Font font) {
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
                    ? paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeType.amountPaidForTheReceipt ?? 0) / 100.0)} /-", font,
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
                    paddedText(
                        "$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.termWiseAmountPaidForTheReceipt ?? 0) / 100.0)} /-", font,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Fee Receipts"),
        actions: _isLoading || filteredStudentFeeReceipts.isEmpty || isAddNew
            ? []
            : [
                if (!isSearchBarSelected)
                  SearchWidget(
                    isSearchBarSelectedByDefault: false,
                    onComplete: scrollToReceiptNumber,
                    receiptNumbers: filteredStudentFeeReceipts.map((e) => "${e.receiptNumber ?? ""}").toList(),
                    isSearchButtonSelected: isSearchButtonSelected,
                  ),
                if (_renderingReceiptText != null)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                PopupMenuButton<String>(
                  onSelected: (String choice) async => await handleClick(choice),
                  itemBuilder: (BuildContext context) {
                    return (_renderingReceiptText == null ? {"Go to date", "Term Wise", "Stats", "Print"} : {"Go to date", "Term Wise", "Stats"})
                        .map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: choice == "Term Wise"
                            ? isTermWise
                                ? const Text("Disable Term Wise")
                                : const Text("Enable Term Wise")
                            : Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : isAddNew
              ? ListView(
                  controller: newReceiptsListViewController,
                  children: [
                    ...newReceipts.where((e) => e.status != "deleted").toList().reversed.map(
                          (e) => NewStudentFeeReceiptWidget(
                            context: _scaffoldKey.currentContext!,
                            setState: setState,
                            feeTypesForSelectedSection: feeTypes,
                            newReceipt: e,
                            schoolInfoBean: schoolInfoBean!,
                            sections: sections,
                            studentProfiles: studentProfiles
                              ..sort(
                                (a, b) {
                                  int sectionComp = (a.sectionId ?? 0).compareTo(b.sectionId ?? 0);
                                  int rollNumberComp = (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0);
                                  return sectionComp == 0
                                      ? rollNumberComp == 0
                                          ? (a.studentFirstName ?? "").compareTo((b.studentFirstName ?? ""))
                                          : rollNumberComp
                                      : sectionComp;
                                },
                              ),
                          ),
                        ),
                  ],
                )
              : filteredStudentFeeReceipts.isEmpty
                  ? const Center(
                      child: Text("No Transactions to display"),
                    )
                  : Stack(
                      children: [
                        ScrollablePositionedList.builder(
                          initialScrollIndex: 0,
                          physics: const BouncingScrollPhysics(),
                          itemScrollController: _itemScrollController,
                          itemCount: filteredStudentFeeReceipts.length,
                          itemBuilder: (BuildContext context, int index) {
                            return filteredStudentFeeReceipts[index].widget(
                              _scaffoldKey.currentContext ?? context,
                              adminId: widget.adminProfile.userId,
                              isTermWise: isTermWise,
                              setState: setState,
                              reload: _loadData,
                              makePdf: filteredStudentFeeReceipts[index].isEditMode
                                  ? null
                                  : (int? transactionId) async {
                                      makePdf(transactionId: transactionId);
                                    },
                            );
                          },
                        ),
                        if (isSearchBarSelected)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              height: 75,
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                              child: Container(
                                color: clayContainerColor(context),
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                child: SearchWidget(
                                  isSearchBarSelectedByDefault: true,
                                  onComplete: scrollToReceiptNumber,
                                  receiptNumbers: filteredStudentFeeReceipts.map((e) => "${e.receiptNumber ?? ""}").toList(),
                                  isSearchButtonSelected: isSearchButtonSelected,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
      floatingActionButton: _isLoading
          ? null
          : (isAddNew && (newReceipts.isEmpty || newReceipts.map((e) => e.status).contains("inactive")))
              ? buildCloseAddNewReceiptButton(context)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAddNew && newReceipts.map((e) => e.status).contains("active") && !newReceipts.map((e) => e.status).contains("inactive"))
                      buildSubmitReceiptsButton(context),
                    const SizedBox(height: 20),
                    if (isAddNew) buildCloseAddNewReceiptButton(context),
                    const SizedBox(height: 20),
                    buildAddNewReceiptButton(context),
                  ],
                ),
    );
  }

  Widget buildCloseAddNewReceiptButton(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isAddNew = false),
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 100,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    String? errorText;
    if (errorText != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorText),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    List<NewReceiptBean> newReceiptsToBePaid = newReceipts
        .where((e) => e.status == "active")
        .map((eachNewReceipt) => NewReceiptBean(
              agentId: widget.adminProfile.userId,
              date: eachNewReceipt.date,
              receiptNumber: eachNewReceipt.receiptNumber,
              schoolId: eachNewReceipt.schoolId,
              sectionId: eachNewReceipt.sectionId,
              studentId: eachNewReceipt.studentId,
              subBeans: (eachNewReceipt.subBeans ?? [])
                  .where((e) => e != null)
                  .map((e) => e!)
                  .map((eachSubBean) => NewReceiptBeanSubBean(
                        customFeeTypeId: eachSubBean.customFeeTypeId,
                        feePaying: eachSubBean.feePaying,
                        feeTypeId: eachSubBean.feeTypeId,
                      ))
                  .toList(),
              busFeePaidAmount: eachNewReceipt.busFeePaidAmount,
              modeOfPayment: eachNewReceipt.modeOfPayment,
            ))
        .toList();
    if (newReceiptsToBePaid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please check all the necessary details correctly"),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    CreateNewReceiptsResponse createNewReceiptsResponse = await createNewReceipts(CreateNewReceiptsRequest(
      newReceiptBeans: newReceiptsToBePaid,
    ));
    if (createNewReceiptsResponse.httpStatus != "OK" || createNewReceiptsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Receipts submitted successfully, Please wait while we load your data.."),
        ),
      );
      await _loadData();
    }
    setState(() => isAddNew = false);
    setState(() => _isLoading = false);
  }

  Widget buildSubmitReceiptsButton(BuildContext context) {
    return GestureDetector(
      onTap: _saveChanges,
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 100,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.check),
        ),
      ),
    );
  }

  void addNewReceiptAction() async {
    if (schoolInfoBean == null) await getDataReadyToPrint();
    if (!isAddNew) {
      setState(() => isAddNew = true);
    } else if (newReceipts.map((e) => e.status).contains("inactive")) {
      return;
    } else {
      setState(() {
        newReceipts.add(
          NewReceipt(
            schoolId: widget.adminProfile.schoolId,
            agentId: widget.adminProfile.userId,
            date: newReceipts.isEmpty
                ? studentFeeReceipts.isEmpty
                    ? DateTime.now().millisecondsSinceEpoch
                    : convertYYYYMMDDFormatToDateTime(studentFeeReceipts[0].transactionDate).millisecondsSinceEpoch
                : (newReceipts[newReceipts.length - 1].date ?? DateTime.now().millisecondsSinceEpoch),
            modeOfPayment: ModeOfPayment.CASH.name,
            receiptNumber: newReceipts.isEmpty
                ? studentFeeReceipts.isEmpty
                    ? 1
                    : (studentFeeReceipts[0].receiptNumber ?? 0) + 1
                : (newReceipts[newReceipts.length - 1].receiptNumber ?? 0) + 1,
          ),
        );
        newReceiptsListViewController.animateTo(
          newReceiptsListViewController.position.minScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
        );
      });
    }
  }

  GestureDetector buildAddNewReceiptButton(BuildContext context) {
    return GestureDetector(
      onTap: addNewReceiptAction,
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 100,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
