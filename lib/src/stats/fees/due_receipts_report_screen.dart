import 'dart:html' as html;

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/fee_support_classes.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class DueReceiptsScreen extends StatefulWidget {
  const DueReceiptsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<DueReceiptsScreen> createState() => _DueReceiptsScreenState();
}

class _DueReceiptsScreenState extends State<DueReceiptsScreen> {
  bool _isLoading = true;
  bool _isSectionPickerOpen = false;
  final bool _isTermWise = false;
  bool showPreviousTransactions = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SchoolInfoBean schoolInfoBean;
  List<Section> sectionsList = [];
  List<Section> selectedSectionsList = [];
  List<StudentProfile> studentProfiles = [];
  List<StudentProfile> selectedStudentProfiles = [];
  List<FeeType> feeTypes = [];

  List<StudentFeeDetailsBean> studentFeeDetailsBeans = [];
  String? _renderingReceiptText;
  double? _loadingReceiptPercentage;
  Uint8List? pdfInBytes;

  List<StudentAnnualFeeSupportBean> studentAnnualFeeBeanBeans = [];
  List<StudentTermWiseFeeSupportBean> studentTermWiseFeeBeans = [];
  List<StudentMasterTransactionSupportBean> studentMasterTransactionBeans = [];
  List<StudentWiseFeePaidSupportBean> studentWiseFeePaidBeans = [];
  List<StudentBusFeeLogBean> busFeeBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isSectionPickerOpen = false;
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
      sectionsList = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
      selectedSectionsList.addAll(sectionsList);
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
      feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
    }
    GetStudentFeeDetailsSupportClassesResponse getStudentFeeDetailsSupportClassesResponse =
        await getStudentFeeDetailsSupportClasses(GetStudentFeeDetailsRequest(
      schoolId: widget.adminProfile.schoolId,
      // sectionIds: [240], // TODO comment before pushing
    ));
    if (getStudentFeeDetailsSupportClassesResponse.httpStatus != "OK" || getStudentFeeDetailsSupportClassesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentAnnualFeeBeanBeans =
          (getStudentFeeDetailsSupportClassesResponse.studentAnnualFeeBeanBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      studentTermWiseFeeBeans =
          (getStudentFeeDetailsSupportClassesResponse.studentTermWiseFeeBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      studentMasterTransactionBeans =
          (getStudentFeeDetailsSupportClassesResponse.studentMasterTransactionBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      studentWiseFeePaidBeans =
          (getStudentFeeDetailsSupportClassesResponse.studentWiseFeePaidBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      busFeeBeans = (getStudentFeeDetailsSupportClassesResponse.busFeeBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      studentFeeDetailsBeans = mergeAndGetStudentFeeDetailsBeans();
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<StudentFeeDetailsBean> mergeAndGetStudentFeeDetailsBeans() {
    for (var studentAnnualFeeBean in studentAnnualFeeBeanBeans) {
      if (studentFeeDetailsBeans.where((studentFeeDetailsBean) => studentFeeDetailsBean.studentId == studentAnnualFeeBean.studentId).isEmpty) {
        StudentFeeDetailsBean newStudentBean = StudentFeeDetailsBean();
        newStudentBean.studentId = studentAnnualFeeBean.studentId;
        newStudentBean.rollNumber = studentAnnualFeeBean.rollNumber;
        newStudentBean.studentName = studentAnnualFeeBean.studentName;
        newStudentBean.sectionId = studentAnnualFeeBean.sectionId;
        newStudentBean.sectionName = studentAnnualFeeBean.sectionName;
        newStudentBean.schoolId = studentAnnualFeeBean.schoolId;
        newStudentBean.schoolName = studentAnnualFeeBean.schoolDisplayName;
        newStudentBean.studentWiseFeeTypeDetailsList = [];
        newStudentBean.studentFeeTransactionList = [];
        studentFeeDetailsBeans.add(newStudentBean);
      }
    }
    for (var studentFeeDetailsBean in studentFeeDetailsBeans) {
      studentAnnualFeeBeanBeans
          .where((studentAnnualFeeBean) => studentAnnualFeeBean.studentId == studentFeeDetailsBean.studentId)
          .forEach((studentAnnualFeeBean) => {
                studentFeeDetailsBean.totalAnnualFee = studentAnnualFeeBean.amount,
                studentFeeDetailsBean.totalFeePaid = studentAnnualFeeBean.amountPaid,
                studentFeeDetailsBean.sectionId = studentAnnualFeeBean.sectionId,
                studentFeeDetailsBean.sectionName = studentAnnualFeeBean.sectionName,
                studentFeeDetailsBean.studentName = studentAnnualFeeBean.studentName,
                studentFeeDetailsBean.studentWiseFeeTypeDetailsList = [],
                studentFeeDetailsBean.studentFeeTransactionList = [],
              });
    }
    for (var studentFeeDetailsBean in studentFeeDetailsBeans) {
      studentMasterTransactionBeans
          .where((studentMasterTransactionBean) => (studentMasterTransactionBean.studentId == studentFeeDetailsBean.studentId))
          .forEach((studentMasterTransactionBean) => {
                studentFeeDetailsBean.studentFeeTransactionList!.add(StudentFeeTransactionBean(
                  studentId: studentMasterTransactionBean.studentId,
                  studentName: studentMasterTransactionBean.studentName,
                  masterTransactionId: studentMasterTransactionBean.transactionId,
                  transactionDate: studentMasterTransactionBean.transactionTime,
                  transactionAmount: studentMasterTransactionBean.amount,
                  receiptId: studentMasterTransactionBean.receiptId,
                  studentFeeChildTransactionList: [],
                )),
              });
    }
    studentFeeDetailsBeans
        .forEach((studentFeeDetailsBean) => (studentFeeDetailsBean.studentFeeTransactionList ?? []).forEach((studentFeeTransactionBean) {
              studentFeeTransactionBean?.studentFeeChildTransactionList ??= [];
              studentFeeTransactionBean?.studentFeeChildTransactionList = (studentWiseFeePaidBeans.where(
                      (studentWiseFeePaidBean) => (studentWiseFeePaidBean.masterTransactionId == studentFeeTransactionBean.masterTransactionId)))
                  .map((studentWiseFeePaidBean) {
                return StudentFeeChildTransactionBean(
                  studentId: studentWiseFeePaidBean.studentId,
                  studentName: studentWiseFeePaidBean.studentName,
                  masterTransactionId: studentWiseFeePaidBean.masterTransactionId,
                  transactionId: studentWiseFeePaidBean.transactionId,
                  transactionDate: studentWiseFeePaidBean.transactionDate,
                  feePaidAmount: studentWiseFeePaidBean.amount,
                  feeTypeId: studentWiseFeePaidBean.feeTypeId,
                  feeType: studentWiseFeePaidBean.feeType,
                  customFeeTypeId: studentWiseFeePaidBean.customFeeTypeId,
                  customFeeType: studentWiseFeePaidBean.customFeeType,
                  termComponents: [],
                );
              }).toList();
            }));
    for (var eachStudentFeeDetails in studentFeeDetailsBeans) {
      busFeeBeans.where((eachBusFee) => eachBusFee.studentId == eachStudentFeeDetails.studentId).forEach((eachBusFee) {
        eachStudentFeeDetails.busFee = eachBusFee.fare;
        eachStudentFeeDetails.busFeePaid = studentWiseFeePaidBeans
            .where((e) => e.studentId == eachStudentFeeDetails.studentId && e.feeType == "Bus Fee")
            .map((e) => e.amount ?? 0)
            .toList()
            .fold(0, (int? a, b) => (a ?? 0) + b);
      });
    }
    populateTermTxnWiseComponents();
    return studentFeeDetailsBeans;
  }

  void populateTermTxnWiseComponents() {
    for (StudentFeeDetailsBean eachStudentFeeDetailsBean in studentFeeDetailsBeans) {
      List<StudentTermWiseFeeSupportBean> studentWiseTermFeeTypes = (studentTermWiseFeeBeans)
          .where((e) => e.studentId == eachStudentFeeDetailsBean.studentId)
          .map((e) => StudentTermWiseFeeSupportBean.fromJson(e.origJson()))
          .toList();
      studentWiseTermFeeTypes.sort((a, b) => (a.termId ?? 0).compareTo((b.termId ?? 0)));
      (eachStudentFeeDetailsBean.studentFeeTransactionList ?? []).forEach((StudentFeeTransactionBean? eachStudentFeeTransactionBean) {
        if (eachStudentFeeTransactionBean == null) return;
        (eachStudentFeeTransactionBean.studentFeeChildTransactionList ?? []).forEach((StudentFeeChildTransactionBean? eachChildTxn) {
          if (eachChildTxn == null) return;
          int paidAmountDec = eachChildTxn.feePaidAmount ?? 0;
          while (paidAmountDec != 0) {
            StudentTermWiseFeeSupportBean? x = studentWiseTermFeeTypes
                .where((e) =>
                    e.feeTypeId == eachChildTxn.feeTypeId &&
                    (eachChildTxn.customFeeTypeId == null || eachChildTxn.customFeeTypeId == e.customFeeTypeId))
                .where((e) => (e.termWiseAmount ?? 0) > 0)
                .firstOrNull;
            if (x == null) {
              break;
            }
            int amountPaidForTerm = 0;
            int termFee = x.termWiseAmount ?? 0;
            if ((x.termWiseAmount ?? 0) > paidAmountDec) {
              amountPaidForTerm = paidAmountDec;
              x.termWiseAmount = termFee - paidAmountDec;
              paidAmountDec = 0;
            } else {
              amountPaidForTerm = termFee;
              paidAmountDec = paidAmountDec - termFee;
              x.termWiseAmount = 0;
            }
            eachChildTxn.termComponents ??= [];
            eachChildTxn.termComponents!.add(TermComponent(x.termId, x.termName, amountPaidForTerm, termFee));
          }
        });
      });
    }
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: _isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: _selectSectionExpanded(),
                ),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget _buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          if (_isLoading) return;
          setState(() {
            if (selectedSectionsList.map((e) => e.sectionId!).contains(section.sectionId)) {
              selectedSectionsList.removeWhere((e) => e.sectionId == section.sectionId);
              selectedStudentProfiles.clear();
            } else {
              selectedSectionsList.add(section);
              selectedStudentProfiles.clear();
            }
            // _isSectionPickerOpen = false;
          });
        },
        child: ClayButton(
          depth: 40,
          spread: selectedSectionsList.map((e) => e.sectionId!).contains(section.sectionId) ? 0 : 2,
          surfaceColor:
              selectedSectionsList.map((e) => e.sectionId!).contains(section.sectionId) ? Colors.blue.shade300 : clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 10,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              section.sectionName!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectSectionExpanded() {
    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () {
              if (_isLoading) return;
              setState(() {
                _isSectionPickerOpen = !_isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      selectedSectionsList.isEmpty
                          ? "Select a section"
                          : "Selected sections: ${selectedSectionsList.map((e) => e.sectionName ?? "-").join(", ")}",
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: const Icon(Icons.expand_less),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
            shrinkWrap: true,
            children: sectionsList.map((e) => _buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSectionsList.map((e) => e).toList().forEach((e) {
                        selectedSectionsList.remove(e);
                      });
                      selectedSectionsList.addAll(sectionsList.map((e) => e).toList());
                      _isSectionPickerOpen = false;
                    });
                  },
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 25,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: const Text("Select All"),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSectionsList = [];
                      _isSectionPickerOpen = false;
                    });
                  },
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 25,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: const Text("Clear"),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          if (_isLoading) return;
          setState(() {
            _isSectionPickerOpen = !_isSectionPickerOpen;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      selectedSectionsList.isEmpty
                          ? "Select Section"
                          : "Selected sections: ${selectedSectionsList.map((e) => e.sectionName ?? "-").join(", ")}",
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDialogueToSelectStudents() async {
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return _MyDialog(
          studentProfiles: studentProfiles.where((e) => selectedSectionsList.map((es) => es.sectionId).contains(e.sectionId)).toList(),
          selectedStudentProfiles: studentProfiles.where((e) => selectedSectionsList.map((es) => es.sectionId).contains(e.sectionId)).toList(),
          showPreviousTransactions: showPreviousTransactions,
        );
      },
    ).then((value) => setState(() {
          if (value == null) {
            return;
          }
          try {
            List<Object> returned = value as List<Object>;
            List<StudentProfile> _selectedStudents = returned[0] as List<StudentProfile>;
            bool _showPreviousTransactions = returned[1] as bool;
            setState(() {
              selectedStudentProfiles = _selectedStudents;
              showPreviousTransactions = _showPreviousTransactions;
            });
            makePdf();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Something went wrong! Try again later.."),
              ),
            );
          }
        }));
  }

  Future<void> makePdf() async {
    setState(() {
      _renderingReceiptText = "Preparing report";
    });
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

    selectedStudentProfiles.sort(
      (a, b) => (a.sectionId ?? 0).compareTo(b.sectionId ?? 0) == 0
          ? (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0)
          : (a.sectionId ?? 0).compareTo(b.sectionId ?? 0),
    );
    for (int si = 0; si < selectedStudentProfiles.length; si++) {
      StudentProfile studentProfile = selectedStudentProfiles[si];
      String reportBeingPreparedFor =
          "Preparing report for ${studentProfile.rollNumber}. ${((studentProfile.studentFirstName ?? "" ' ') + (studentProfile.studentMiddleName ?? "" ' ') + (studentProfile.studentLastName ?? "" ' ')).split(" ").where((i) => i != "").join(" ")} - [${studentProfile.sectionName}]";
      debugPrint(reportBeingPreparedFor);
      setState(() {
        _loadingReceiptPercentage = si * 100 / selectedStudentProfiles.length;
        _renderingReceiptText = reportBeingPreparedFor;
      });
      StudentFeeDetailsBean? detailBean = studentFeeDetailsBeans.where((e) => e.studentId == studentProfile.studentId).firstOrNull;

      List<StudentFeeTransactionBean> txns = (studentFeeDetailsBeans
          .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null && e.studentId == studentProfile.studentId).map((e) => e!))
          .expand((i) => i)
          .toList()
        ..sort(
          (b, a) => convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)) == 0
              ? (a.receiptId ?? 0) == 0 || (b.receiptId ?? 0) == 0 || (a.receiptId ?? 0).compareTo(b.receiptId ?? 0) == 0
                  ? (a.masterTransactionId ?? 0).compareTo((b.masterTransactionId ?? 0))
                  : (a.receiptId ?? 0).compareTo(b.receiptId ?? 0)
              : convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)),
        ));

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
            pw.SizedBox(width: 10),
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
        ),
      );
      pw.Container eachTxnContainer = pw.Container(
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
                    "Student Name: ${((studentProfile.studentFirstName ?? "" ' ') + (studentProfile.studentMiddleName ?? "" ' ') + (studentProfile.studentLastName ?? "" ' ')).split(" ").where((i) => i != "").join(" ")}",
                    style: pw.TextStyle(font: font, fontSize: 18),
                  ),
                ),
              ],
            ),
            if (studentProfile.fatherName != null)
              pw.SizedBox(
                height: 10,
              ),
            if (studentProfile.fatherName != null)
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "S/o / D/o: ${studentProfile.fatherName ?? "-"}",
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
                    "Section: ${studentProfile.sectionName ?? "-"}",
                    style: pw.TextStyle(font: font, fontSize: 16),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    "Roll No.: ${studentProfile.rollNumber ?? "-"}",
                    style: pw.TextStyle(font: font, fontSize: 16),
                  ),
                ),
              ],
            ),
            pw.SizedBox(
              height: 10,
            ),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black),
              children: [
                pw.TableRow(
                  children: [
                    pw.Expanded(
                      child: paddedText(
                        "Particular",
                        font,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        align: pw.TextAlign.left,
                        color: PdfColors.blue,
                      ),
                    ),
                    paddedText(
                      "Term",
                      font,
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.center,
                      color: PdfColors.blue,
                    ),
                    paddedText(
                      "Actual",
                      font,
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.center,
                      color: PdfColors.blue,
                    ),
                    paddedText(
                      "Paid",
                      font,
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.center,
                      color: PdfColors.blue,
                    ),
                    paddedText(
                      "Due",
                      font,
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.center,
                      color: PdfColors.blue,
                    ),
                  ],
                ),
                ...studentTermWiseFeeBeans
                    .where((e) => e.studentId == studentProfile.studentId)
                    .sorted((a, b) => (a.termId ?? 0).compareTo(b.termId ?? 0))
                    .map(
                      (eachTerm) => pw.TableRow(
                        children: [
                          pw.Expanded(
                            child: paddedText(
                              eachTerm.feeType ?? "-",
                              font,
                              fontSize: 15,
                              align: pw.TextAlign.left,
                            ),
                          ),
                          paddedText(
                            eachTerm.termName ?? "-",
                            font,
                            fontSize: 16,
                            align: pw.TextAlign.left,
                          ),
                          paddedText(
                            "$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTerm.termWiseAmount ?? 0) / 100)}",
                            font,
                            fontSize: 13,
                            align: pw.TextAlign.right,
                          ),
                          paddedText(
                            "$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTerm.termWiseAmountPaid ?? 0) / 100)}",
                            font,
                            fontSize: 13,
                            align: pw.TextAlign.right,
                            color: PdfColors.green,
                          ),
                          paddedText(
                            "$INR_SYMBOL ${doubleToStringAsFixedForINR(((eachTerm.termWiseAmount ?? 0) - (eachTerm.termWiseAmountPaid ?? 0)) / 100)}",
                            font,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            align: pw.TextAlign.right,
                            color: PdfColors.red,
                          ),
                        ],
                      ),
                    )
                    .toList(),
                // Bus
                pw.TableRow(
                  children: [
                    pw.Expanded(
                      child: paddedText(
                        "Bus Fee",
                        font,
                        fontSize: 15,
                        align: pw.TextAlign.left,
                      ),
                    ),
                    paddedText(
                      "-",
                      font,
                      fontSize: 15,
                      align: pw.TextAlign.left,
                    ),
                    paddedText(
                      "$INR_SYMBOL ${doubleToStringAsFixedForINR((detailBean?.busFee ?? 0) / 100)}",
                      font,
                      fontSize: 13,
                      align: pw.TextAlign.right,
                    ),
                    paddedText(
                      "$INR_SYMBOL ${doubleToStringAsFixedForINR((detailBean?.busFeePaid ?? 0) / 100)}",
                      font,
                      fontSize: 13,
                      align: pw.TextAlign.right,
                      color: PdfColors.green,
                    ),
                    paddedText(
                      "$INR_SYMBOL ${doubleToStringAsFixedForINR(((detailBean?.busFee ?? 0) - (detailBean?.busFeePaid ?? 0)) / 100)}",
                      font,
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.right,
                      color: PdfColors.red,
                    ),
                  ],
                ),
                // Total
                pw.TableRow(
                  children: [
                    pw.Expanded(
                      child: paddedText(
                        "",
                        font,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        align: pw.TextAlign.left,
                      ),
                    ),
                    paddedText(
                      "",
                      font,
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.left,
                    ),
                    paddedText(
                      "$INR_SYMBOL ${doubleToStringAsFixedForINR(((detailBean?.totalAnnualFee ?? 0) + (detailBean?.busFee ?? 0)) / 100)}",
                      font,
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.right,
                    ),
                    paddedText(
                      "$INR_SYMBOL ${doubleToStringAsFixedForINR(((detailBean?.totalFeePaid ?? 0) + (detailBean?.busFeePaid ?? 0)) / 100)}",
                      font,
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.right,
                      color: PdfColors.green,
                    ),
                    paddedText(
                      "$INR_SYMBOL ${doubleToStringAsFixedForINR((((detailBean?.totalAnnualFee ?? 0) + (detailBean?.busFee ?? 0)) - ((detailBean?.totalFeePaid ?? 0) + (detailBean?.busFeePaid ?? 0))) / 100)}",
                      font,
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.right,
                      color: PdfColors.red,
                    ),
                  ],
                ),
              ],
            ),
            if (showPreviousTransactions && txns.isNotEmpty)
              pw.SizedBox(
                height: 30,
              ),
            if (showPreviousTransactions && txns.isNotEmpty)
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      "Previous Transactions",
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        color: PdfColors.blue,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
            if (showPreviousTransactions && txns.isNotEmpty)
              pw.SizedBox(
                height: 10,
              ),
          ],
        ),
      );
      widgets.add(eachTxnContainer);

      if (showPreviousTransactions && txns.isNotEmpty) {
        for (int ti = 0; ti < txns.length; ti++) {
          StudentFeeTransactionBean eachTransaction = txns[ti];
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
                          "Receipt No.: ${eachTransaction.receiptId ?? "-"}",
                          font,
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          align: pw.TextAlign.left,
                          color: PdfColors.red,
                        ),
                      ),
                      paddedText(
                        convertDateToDDMMMYYY(eachTransaction.transactionDate),
                        font,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        align: pw.TextAlign.center,
                        color: PdfColors.blue,
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
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          align: pw.TextAlign.right,
                        ),
                      ),
                      paddedText(
                        "$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTransaction.transactionAmount ?? 0) / 100)} /-",
                        font,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        align: pw.TextAlign.right,
                        color: PdfColors.green,
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Expanded(
                        child: paddedText(
                          "Mode Of Payment",
                          font,
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          align: pw.TextAlign.right,
                        ),
                      ),
                      paddedText(
                        eachTransaction.modeOfPayment ?? "CASH",
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
        }
      }

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return widgets;
        },
      ));
    }

    var x = await pdf.save();
    setState(() {
      pdfInBytes = x;
    });

    final blob = html.Blob([pdfInBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = "DueReport.pdf";
    anchorElement.click();
    setState(() {
      _renderingReceiptText = null;
      // pdfInBytes = null;
      _loadingReceiptPercentage = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<StudentFeeDetailsBean> studentsToBeShown =
        studentFeeDetailsBeans.where((e) => selectedSectionsList.map((es) => es.sectionId).contains(e.sectionId)).toList();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Due Receipts"),
        actions: _isLoading || _renderingReceiptText != null
            ? []
            : pdfInBytes != null
                ? [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          pdfInBytes = null;
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ]
                : [
                    IconButton(
                      onPressed: showDialogueToSelectStudents,
                      icon: const Icon(Icons.download),
                    ),
                  ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : _renderingReceiptText != null
              ? buildRenderingReceiptsWidget()
              : pdfInBytes != null
                  ? buildPdfPreviewWidget()
                  : ListView(
                      padding: EdgeInsets.zero,
                      primary: false,
                      children: <Widget>[
                        _sectionPicker(),
                        const SizedBox(
                          height: 10,
                        ),
                        ...studentsToBeShown.map(
                          (eachStudentDetail) => Container(
                            margin: const EdgeInsets.all(10),
                            child: buildEachStudentFeeDetailsWidget(eachStudentDetail),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Column buildRenderingReceiptsWidget() {
    return Column(
      children: [
        const Expanded(
          flex: 1,
          child: Center(
            child: Text("Generating PDF"),
          ),
        ),
        Expanded(
          flex: 3,
          child: Image.asset(
            'assets/images/eis_loader.gif',
            fit: BoxFit.scaleDown,
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(_renderingReceiptText ?? "-"),
          ),
        ),
        Expanded(
          child: Center(
            child: LinearPercentIndicator(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              alignment: MainAxisAlignment.center,
              width: 140.0,
              lineHeight: 14.0,
              percent: _loadingReceiptPercentage ?? 0.0,
              center: Text(
                "${(_loadingReceiptPercentage ?? 0.0).toStringAsFixed(2)} %",
                style: const TextStyle(fontSize: 12.0),
              ),
              leading: const Icon(Icons.file_upload),
              barRadius: const Radius.circular(2.0),
              backgroundColor: Colors.grey,
              progressColor: Colors.blue,
            ),
          ),
        )
      ],
    );
  }

  PdfPreview buildPdfPreviewWidget() {
    return PdfPreview(
      build: (format) => pdfInBytes!,
      pdfFileName: "Fee Receipts",
      canDebug: false,
    );
  }

  Widget buildEachStudentFeeDetailsWidget(StudentFeeDetailsBean eachStudentDetail) {
    StudentProfile? profile = studentProfiles.where((e) => e.studentId == eachStudentDetail.studentId).firstOrNull;
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.fromLTRB(0, 10, 0, 10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // SelectableText("${eachStudentDetail.toJson()}"),
              // const SizedBox(height: 10),
              detailWidget(
                eachStudentDetail.studentName ?? "-",
                eachStudentDetail.rollNumber ?? "-",
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              detailWidget("Parent Name:", profile?.fatherName ?? "-"),
              const SizedBox(height: 8),
              detailWidget("Section Name:", eachStudentDetail.sectionName ?? "-"),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              detailWidget(
                "Total Fee:",
                "$INR_SYMBOL ${doubleToStringAsFixedForINR(((eachStudentDetail.totalAnnualFee ?? 0) + (eachStudentDetail.busFee ?? 0)) / 100)}",
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              detailWidget(
                "Fee Paid:",
                "$INR_SYMBOL ${doubleToStringAsFixedForINR(((eachStudentDetail.totalFeePaid ?? 0) + (eachStudentDetail.busFeePaid ?? 0)) / 100)}",
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              detailWidget(
                "Due:",
                "$INR_SYMBOL ${doubleToStringAsFixedForINR((((eachStudentDetail.totalAnnualFee ?? 0) + (eachStudentDetail.busFee ?? 0)) - ((eachStudentDetail.totalFeePaid ?? 0) + (eachStudentDetail.busFeePaid ?? 0))) / 100)}",
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget detailWidget(String subject, String detail, {Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 4, 15, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              subject,
              style: TextStyle(color: color),
            ),
          ),
          Text(
            detail,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  List<pw.TableRow> childTransactionsPdfWidgets(StudentFeeTransactionBean e, pw.Font font) {
    List<pw.TableRow> childTxnWidgets = [];
    List<StudentFeeChildTransactionBean> childTxns =
        (e.studentFeeChildTransactionList ?? []).map((e) => e!).where((e) => e.feeTypeId != null).toList();
    List<StudentFeeChildTransactionBean> busFeeTxns = (e.studentFeeChildTransactionList ?? []).map((e) => e!).where((e) {
      return e.feeTypeId == null || e.feeType == "Bus Fee";
    }).toList();
    List<FeeTypeTxn> feeTypeTxns = [];
    for (StudentFeeChildTransactionBean eachChildTxn in childTxns) {
      if (eachChildTxn.customFeeTypeId == null) {
        feeTypeTxns.add(FeeTypeTxn(eachChildTxn.feeTypeId, eachChildTxn.feeType, null, null, [], eachChildTxn.termComponents ?? []));
      } else {
        if (!feeTypeTxns.map((e) => e.feeTypeId).contains(eachChildTxn.feeTypeId)) {
          feeTypeTxns.add(FeeTypeTxn(eachChildTxn.feeTypeId, eachChildTxn.feeType, null, null, [], eachChildTxn.termComponents ?? []));
        }
      }
    }
    for (StudentFeeChildTransactionBean eachChildTxn in childTxns) {
      if (eachChildTxn.customFeeTypeId != null && eachChildTxn.customFeeTypeId != 0) {
        feeTypeTxns.where((e) => e.feeTypeId == eachChildTxn.feeTypeId).forEach((eachFeeTypeTxn) {
          eachFeeTypeTxn.customFeeTypeTxns?.add(CustomFeeTypeTxn(eachChildTxn.customFeeTypeId, eachChildTxn.customFeeType, eachChildTxn.feePaidAmount,
              eachFeeTypeTxn.transactionId, eachChildTxn.termComponents ?? []));
        });
      }
    }
    for (StudentFeeChildTransactionBean eachChildTxn in busFeeTxns) {
      if (!feeTypeTxns.map((e) => e.feeTypeId).contains(eachChildTxn.feeTypeId)) {
        feeTypeTxns.add(FeeTypeTxn(
            eachChildTxn.feeTypeId, "Bus Fee", eachChildTxn.feePaidAmount, eachChildTxn.transactionId, [], eachChildTxn.termComponents ?? []));
      }
    }
    feeTypeTxns.sort(
      (a, b) => a.feeType == "Bus Fee"
          ? -2
          : (a.customFeeTypeTxns ?? []).isEmpty
              ? -1
              : 1,
    );
    for (FeeTypeTxn eachFeeTypeTxn in feeTypeTxns.where((e) => e.feeTypeId != null)) {
      if (eachFeeTypeTxn.customFeeTypeTxns?.isEmpty ?? true) {
        eachFeeTypeTxn.feePaidAmount =
            childTxns.where((e) => e.feeTypeId == eachFeeTypeTxn.feeTypeId).map((e) => e.feePaidAmount).reduce((c1, c2) => (c1 ?? 0) + (c2 ?? 0));
        eachFeeTypeTxn.transactionId = childTxns.where((e) => e.feeTypeId == eachFeeTypeTxn.feeTypeId).map((e) => e.transactionId).firstOrNull;
      } else {
        eachFeeTypeTxn.feePaidAmount = eachFeeTypeTxn.customFeeTypeTxns?.map((e) => e.feePaidAmount).reduce((c1, c2) => (c1 ?? 0) + (c2 ?? 0));
      }
    }
    for (FeeTypeTxn eachFeeTypeTxn in feeTypeTxns.toSet()) {
      if ((eachFeeTypeTxn.customFeeTypeTxns ?? []).isEmpty) {
        childTxnWidgets.add(
          pw.TableRow(
            children: [
              pw.Expanded(
                child: paddedText(eachFeeTypeTxn.feeType ?? "-", font),
              ),
              !_isTermWise || (eachFeeTypeTxn.termComponents).isEmpty
                  ? paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeTypeTxn.feePaidAmount ?? 0) / 100.0)} /-", font,
                      align: pw.TextAlign.right)
                  : paddedText("", font),
            ],
          ),
        );
        if (_isTermWise && (eachFeeTypeTxn.termComponents).isNotEmpty) {
          for (TermComponent eachTermComponent in eachFeeTypeTxn.termComponents) {
            childTxnWidgets.add(
              pw.TableRow(
                children: [
                  pw.Expanded(
                    child: paddedText(eachTermComponent.termName ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(12, 6, 6, 6)),
                  ),
                  paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.feePaid ?? 0) / 100.0)} /-", font,
                      align: pw.TextAlign.right)
                ],
              ),
            );
          }
        }
      } else {
        childTxnWidgets.add(pw.TableRow(
          children: [
            pw.Expanded(
              child: paddedText(eachFeeTypeTxn.feeType ?? "-", font),
            ),
          ],
        ));
        for (var eachCustomFeeTypeTxn in (eachFeeTypeTxn.customFeeTypeTxns ?? [])) {
          childTxnWidgets.add(pw.TableRow(
            children: [
              pw.Expanded(
                child: paddedText(eachCustomFeeTypeTxn.customFeeType ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(8, 6, 6, 6)),
              ),
              !_isTermWise || (eachCustomFeeTypeTxn.termComponents).isEmpty
                  ? paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachCustomFeeTypeTxn.feePaidAmount ?? 0) / 100.0)} /-", font,
                      align: pw.TextAlign.right)
                  : paddedText("", font),
            ],
          ));
          if (_isTermWise && (eachCustomFeeTypeTxn.termComponents).isNotEmpty) {
            for (TermComponent eachTermComponent in eachCustomFeeTypeTxn.termComponents) {
              childTxnWidgets.add(
                pw.TableRow(
                  children: [
                    pw.Expanded(
                      child: paddedText(eachTermComponent.termName ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(12, 6, 6, 6)),
                    ),
                    paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.feePaid ?? 0) / 100.0)} /-", font,
                        align: pw.TextAlign.right)
                  ],
                ),
              );
            }
          }
        }
      }
    }

    return childTxnWidgets;
  }

  pw.Widget paddedText(
    final String text,
    final pw.Font font, {
    final pw.EdgeInsets padding = const pw.EdgeInsets.all(6),
    final pw.TextAlign align = pw.TextAlign.left,
    final double fontSize = 14,
    final pw.FontWeight fontWeight = pw.FontWeight.normal,
    final PdfColor color = PdfColors.black,
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
            color: color,
          ),
        ),
      );
}

class _MyDialog extends StatefulWidget {
  const _MyDialog({
    required this.studentProfiles,
    required this.selectedStudentProfiles,
    required this.showPreviousTransactions,
  });

  final List<StudentProfile> studentProfiles;
  final List<StudentProfile> selectedStudentProfiles;
  final bool showPreviousTransactions;

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<_MyDialog> {
  List<StudentProfile> _tempSelectedStudentProfiles = [];
  late bool _tempShowPreviousTransactions;

  @override
  void initState() {
    _tempSelectedStudentProfiles = widget.selectedStudentProfiles;
    _tempShowPreviousTransactions = widget.showPreviousTransactions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(
                width: 20,
              ),
              const Expanded(
                child: Text(
                  'Students',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  if (_tempSelectedStudentProfiles.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Select at least one student.."),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, [_tempSelectedStudentProfiles, _tempShowPreviousTransactions]);
                },
                child: ClayButton(
                  depth: 40,
                  spread: 2,
                  surfaceColor: Colors.blue,
                  parentColor: clayContainerColor(context),
                  borderRadius: 100,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(Icons.download),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: ClayButton(
                  depth: 40,
                  spread: 2,
                  surfaceColor: Colors.red,
                  parentColor: clayContainerColor(context),
                  borderRadius: 100,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(Icons.close),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _tempSelectedStudentProfiles.clear();
                        _tempSelectedStudentProfiles.addAll(widget.studentProfiles);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClayButton(
                        depth: 40,
                        surfaceColor: clayContainerColor(context),
                        parentColor: clayContainerColor(context),
                        spread: 1,
                        borderRadius: 25,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          child: const Center(child: Text("Select All")),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _tempSelectedStudentProfiles.clear();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClayButton(
                        depth: 40,
                        surfaceColor: clayContainerColor(context),
                        parentColor: clayContainerColor(context),
                        spread: 1,
                        borderRadius: 25,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          child: const Center(child: Text("Clear")),
                        ),
                      ),
                    ),
                  ),
                ),
                if (MediaQuery.of(context).orientation == Orientation.landscape)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SwitchListTile(
                        title: const Text(
                          "Show Transaction\nHistory",
                          textAlign: TextAlign.center,
                        ),
                        value: _tempShowPreviousTransactions,
                        onChanged: (value) {
                          setState(() {
                            _tempShowPreviousTransactions = value;
                          });
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (MediaQuery.of(context).orientation == Orientation.portrait)
            const SizedBox(
              height: 20,
            ),
          if (MediaQuery.of(context).orientation == Orientation.portrait)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SwitchListTile(
                title: const Text(
                  "Show Transaction\nHistory",
                  textAlign: TextAlign.center,
                ),
                value: _tempShowPreviousTransactions,
                onChanged: (value) {
                  setState(() {
                    _tempShowPreviousTransactions = value;
                  });
                },
              ),
            ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView(
              children: [
                ...widget.studentProfiles.map((studentProfile) => CheckboxListTile(
                    title:
                        Text("${studentProfile.rollNumber ?? "-"}. ${studentProfile.studentFirstName ?? "-"} [${studentProfile.sectionName ?? "-"}]"),
                    value: _tempSelectedStudentProfiles.contains(studentProfile),
                    onChanged: (bool? value) {
                      if (value == null || value == false) {
                        if (_tempSelectedStudentProfiles.contains(studentProfile)) {
                          setState(() {
                            _tempSelectedStudentProfiles.remove(studentProfile);
                          });
                        }
                      } else {
                        if (!_tempSelectedStudentProfiles.contains(studentProfile)) {
                          setState(() {
                            _tempSelectedStudentProfiles.add(studentProfile);
                          });
                        }
                      }
                    })),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
