import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/hostel/model/hostels.dart';
import 'package:schoolsgo_web/src/model/academic_years.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_pocket_money/admin/admin_student_pocket_money_receipts_screen.dart';
import 'package:schoolsgo_web/src/student_pocket_money/modal/student_pocket_money.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class AdminStudentPocketMoneyScreen extends StatefulWidget {
  const AdminStudentPocketMoneyScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<AdminStudentPocketMoneyScreen> createState() => _AdminStudentPocketMoneyScreenState();
}

class _AdminStudentPocketMoneyScreenState extends State<AdminStudentPocketMoneyScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool _isEditMode = true;
  bool _showHostelInfo = false;

  late DateTime academicYearStartDate;
  late DateTime academicYearEndDate;

  List<StudentProfile> studentProfiles = [];
  List<StudentProfile> filteredStudentsList = [];
  TextEditingController studentNameSearchController = TextEditingController();
  TextEditingController studentRollNoSearchController = TextEditingController();
  TextEditingController phoneNoSearchController = TextEditingController();
  List<Section> sectionsList = [];
  Section? selectedSection;

  List<StudentPocketMoneyBean> studentPocketMoneyBeans = [];

  List<Hostel> hostels = [];
  List<SchoolWiseEmployeeBean> employees = [];
  Map<StudentProfile, StudentBedInfo?> studentBedInfoMap = {};
  Map<StudentProfile, StudentPocketMoneyBean?> studentPocketMoneyMap = {};

  ScrollController studentPocketMoneyTableController = ScrollController();
  ScrollController studentTransactionsTableController = ScrollController();

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID');
    GetSchoolWiseAcademicYearsResponse response = await getSchoolWiseAcademicYears(
      GetSchoolWiseAcademicYearsRequest(schoolId: widget.adminProfile.schoolId),
    );
    List<AcademicYearBean> academicYears = response.academicYearBeanList?.whereNotNull().toList() ?? [];
    if (academicYears.isNotEmpty) {
      if (selectedAcademicYearId != null) {
        if (academicYears.any((e) => e.academicYearId == selectedAcademicYearId)) {
          academicYearStartDate =
              convertYYYYMMDDFormatToDateTime(academicYears.where((e) => e.academicYearId == selectedAcademicYearId).first.academicYearStartDate);
          academicYearEndDate =
              convertYYYYMMDDFormatToDateTime(academicYears.where((e) => e.academicYearId == selectedAcademicYearId).first.academicYearEndDate);
        } else {
          academicYearStartDate = convertYYYYMMDDFormatToDateTime(academicYears.last.academicYearStartDate);
          academicYearEndDate = convertYYYYMMDDFormatToDateTime(academicYears.last.academicYearEndDate);
        }
      } else {
        academicYearStartDate = convertYYYYMMDDFormatToDateTime(academicYears.last.academicYearStartDate);
        academicYearEndDate = convertYYYYMMDDFormatToDateTime(academicYears.last.academicYearEndDate);
      }
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
      studentProfiles.sort(
        (a, b) {
          int aStudentSectionSeq = a.sectionSeqOrder ?? 0;
          int bStudentSectionSeq = b.sectionSeqOrder ?? 0;
          int aStudentRollNo = int.tryParse(a.rollNumber ?? "") ?? 0;
          int bStudentRollNo = int.tryParse(b.rollNumber ?? "") ?? 0;
          return aStudentSectionSeq.compareTo(bStudentSectionSeq) == 0
              ? aStudentRollNo.compareTo(bStudentRollNo)
              : aStudentSectionSeq.compareTo(bStudentSectionSeq);
        },
      );
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
    }
    await loadStudentPocketMoney();
    await loadHostelsInfo();
    GetSchoolWiseEmployeesResponse getSchoolWiseEmployeesResponse = await getSchoolWiseEmployees(GetSchoolWiseEmployeesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSchoolWiseEmployeesResponse.httpStatus != "OK" || getSchoolWiseEmployeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      employees = (getSchoolWiseEmployeesResponse.employees ?? []).map((e) => e!).toList();
    }
    filterStudentsList();
    setState(() => _isLoading = false);
  }

  Future<void> loadHostelsInfo() async {
    GetHostelsResponse getHostelsResponse = await getHostels(GetHostelsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getHostelsResponse.httpStatus == "OK" && getHostelsResponse.responseStatus == "success") {
      hostels = getHostelsResponse.hostelsList!.map((e) => e!).toList();
      for (var eachStudentProfile in studentProfiles) {
        studentBedInfoMap[eachStudentProfile] = hostels
            .map((e) => (e.rooms ?? []))
            .expand((i) => i)
            .whereNotNull()
            .map((e) => e.studentBedInfoList ?? [])
            .expand((i) => i)
            .whereNotNull()
            .firstWhereOrNull((e) => e.studentId == eachStudentProfile.studentId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }
  }

  Future<void> loadStudentPocketMoney() async {
    GetStudentPocketMoneyResponse getStudentPocketMoneyResponse = await getStudentPocketMoney(GetStudentPocketMoneyRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getStudentPocketMoneyResponse.httpStatus != "OK" || getStudentPocketMoneyResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentPocketMoneyBeans = (getStudentPocketMoneyResponse.studentPocketMoneyBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      for (var eachStudentProfile in studentProfiles) {
        studentPocketMoneyMap[eachStudentProfile] = studentPocketMoneyBeans.firstWhereOrNull((e) => e.studentId == eachStudentProfile.studentId);
      }
    }
  }

  SchoolWiseEmployeeBean? hostelIncharge(Hostel? hostel) =>
      hostel == null ? null : employees.firstWhereOrNull((e) => e.employeeId == hostel.hostelInchargeId);

  void filterStudentsList() => setState(() {
        filteredStudentsList = studentProfiles.where((e) => selectedSection != null ? e.sectionId == selectedSection?.sectionId : true).toList();
        if (_showHostelInfo) {
          filteredStudentsList.removeWhere((e) => studentBedInfoMap[e] == null);
        }
        if (studentNameSearchController.text.trim().isNotEmpty) {
          filteredStudentsList = filteredStudentsList.where((student) {
            String searchObject = [
                  ((student.rollNumber ?? "") == "" ? "" : student.rollNumber! + "."),
                  student.studentFirstName ?? "",
                  student.studentMiddleName ?? "",
                  student.studentLastName ?? ""
                ].where((e) => e != "").join(" ").trim() +
                " - ${student.sectionName}";
            return searchObject.toLowerCase().contains(studentNameSearchController.text.trim().toLowerCase());
          }).toList();
        }
        if (studentRollNoSearchController.text.trim().isNotEmpty) {
          filteredStudentsList =
              filteredStudentsList.where((es) => (es.rollNumber ?? "").contains(studentRollNoSearchController.text.trim())).toList();
        }
        if (phoneNoSearchController.text.trim().isNotEmpty) {
          filteredStudentsList = filteredStudentsList.where((es) => (es.gaurdianMobile ?? "").contains(phoneNoSearchController.text.trim())).toList();
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("Student Pocket Money"),
          actions: [
            // if (!_isLoading)
            //   Tooltip(
            //     message: _isEditMode ? "Done" : "Edit",
            //     child: IconButton(
            //       icon: _isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
            //       onPressed: () => setState(() => _isEditMode = !_isEditMode),
            //     ),
            //   ),
            if (!_isLoading)
              Tooltip(
                message: _showHostelInfo ? "Show All" : "Show only hostelers",
                child: IconButton(
                  icon: _showHostelInfo ? const Icon(Icons.house) : const Icon(Icons.house_outlined),
                  onPressed: () {
                    setState(() => _showHostelInfo = !_showHostelInfo);
                    filterStudentsList();
                  },
                ),
              ),
          ],
        ),
        drawer: AdminAppDrawer(adminProfile: widget.adminProfile),
        body: _isLoading
            ? const EpsilonDiaryLoadingWidget()
            : studentPocketMoneyTable());
  }

  Widget studentPocketMoneyTable() {
    return ClayTable2DWidget(
      context: context,
      horizontalScrollController: studentPocketMoneyTableController,
      dataTable: DataTable(
        columns: [
          DataColumn(label: sectionLabel()),
          DataColumn(label: rollNoLabel()),
          DataColumn(label: studentNameLabel()),
          if (_showHostelInfo) const DataColumn(label: Text('Info')),
          const DataColumn(label: Text('Pocket Money')),
          const DataColumn(label: Text('Transactions')),
          if (_isEditMode) const DataColumn(label: Text('Actions')),
        ],
        rows: filteredStudentsList.map(
          (eachStudent) {
            StudentPocketMoneyBean? studentPocketMoneyBean = studentPocketMoneyMap[eachStudent];
            StudentBedInfo? studentBedInfoBean = studentBedInfoMap[eachStudent];
            return DataRow(
              cells: [
                DataCell(Text(eachStudent.sectionName ?? '')),
                DataCell(Text(eachStudent.rollNumber ?? '')),
                DataCell(Text(eachStudent.studentFirstName ?? '')),
                if (_showHostelInfo)
                  DataCell(
                    Tooltip(
                      child: const Icon(Icons.info),
                      message: studentBedInfoString(eachStudent, studentBedInfoBean),
                    ),
                  ),
                DataCell(Text(INR_SYMBOL + " " + doubleToStringAsFixedForINR((studentPocketMoneyBean?.pocketMoney ?? 0) / 100.0) + " /-")),
                DataCell(
                  GestureDetector(
                    child: ClayButton(
                      color: clayContainerColor(context),
                      borderRadius: 4,
                      spread: 2,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Transactions"),
                      ),
                    ),
                    onTap: () async {
                      if (studentPocketMoneyBean == null || (studentPocketMoneyBean.loadOrDebitStudentPocketMoneyTransactionBeans ?? []).isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "No Transactions for student, ${eachStudent.studentFirstName ?? ''} [${eachStudent.sectionName ?? ''} ${eachStudent.rollNumber ?? ''}]..",
                            ),
                          ),
                        );
                        return;
                      }
                      await showTransactionsList(eachStudent, studentPocketMoneyBean);
                    },
                  ),
                ),
                if (_isEditMode)
                  DataCell(
                    GestureDetector(
                      child: ClayButton(
                        color: clayContainerColor(context),
                        borderRadius: 4,
                        spread: 2,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Load / Debit",
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      onTap: () async => await showLoadOrDebitDialog(eachStudent, studentPocketMoneyBean),
                    ),
                  ),
              ],
            );
          },
        ).toList(),
      ),
      bottomMessage: "Showing ${filteredStudentsList.length} records",
    );
  }

  Widget rollNoLabel() {
    return SizedBox(
      width: 100,
      child: TextField(
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'Roll No.',
          hintText: 'Roll No.',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
        ),
        style: const TextStyle(
          fontSize: 12,
        ),
        controller: studentRollNoSearchController,
        autofocus: true,
        onChanged: (_) {
          filterStudentsList();
        },
      ),
    );
  }

  Widget studentNameLabel() {
    return SizedBox(
      width: 100,
      child: TextField(
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'Student Name',
          hintText: 'Student Name',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
        ),
        style: const TextStyle(
          fontSize: 12,
        ),
        controller: studentNameSearchController,
        autofocus: true,
        onChanged: (_) {
          filterStudentsList();
        },
      ),
    );
  }

  Widget sectionLabel() {
    return SizedBox(
      width: 100,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DropdownButton<Section>(
          hint: const Center(child: Text("Select Section")),
          value: selectedSection,
          onChanged: (Section? section) {
            setState(() {
              selectedSection = section;
            });
            filterStudentsList();
          },
          items: [null, ...sectionsList]
              .map(
                (e) => DropdownMenuItem<Section>(
                  value: e,
                  child: SizedBox(
                    width: 75,
                    height: 50,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          e?.sectionName ?? "All",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> showTransactionsList(StudentProfile eachStudent, StudentPocketMoneyBean? studentPocketMoneyBean) async {
    List<LoadOrDebitStudentPocketMoneyTransactionBean> pocketMoneyTransactions =
        (studentPocketMoneyBean?.loadOrDebitStudentPocketMoneyTransactionBeans ?? [])
            .whereNotNull()
            .sorted((b, a) => convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)));
    await showDialog(
      barrierDismissible: false,
      context: _scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text("${eachStudent.sectionName ?? "-"} - ${eachStudent.rollNumber ?? ""}. ${eachStudent.studentFirstName}")),
              if (pocketMoneyTransactions.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.open_in_new_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return AdminStudentPocketMoneyReceiptsScreen(
                            adminProfile: widget.adminProfile,
                            studentProfiles: [eachStudent],
                            pocketMoneyTransactions: pocketMoneyTransactions,
                          );
                        },
                      ),
                    ).then((value) async {
                      setState(() => _isLoading = true);
                      await loadStudentPocketMoney();
                      setState(() => _isLoading = false);
                    });
                  },
                ),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              if (studentPocketMoneyBean == null || (studentPocketMoneyBean.loadOrDebitStudentPocketMoneyTransactionBeans ?? []).isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text("No Transactions.."),
                  ),
                );
              }
              return SizedBox(
                width: getAlertBoxWidth(context),
                height: getAlertBoxHeight(context),
                child: ClayTable2DWidget(
                  context: context,
                  horizontalScrollController: studentTransactionsTableController,
                  dataTable: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Mode Of Payment')),
                      DataColumn(label: Text('Comment')),
                    ],
                    rows: pocketMoneyTransactions.map((e) {
                      return DataRow(cells: [
                        DataCell(
                          Text(
                            convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(e.transactionDate)),
                            style: transactionTextStyle(e),
                          ),
                        ),
                        DataCell(
                          e.transactionKind == "CR"
                              ? const Icon(
                                  Icons.arrow_drop_up_outlined,
                                  color: Colors.green,
                                )
                              : const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Colors.red,
                                ),
                        ),
                        DataCell(
                          Text(
                            INR_SYMBOL + " " + doubleToStringAsFixedForINR((e.amount ?? 0) / 100.0) + " /-",
                            style: transactionTextStyle(e),
                          ),
                        ),
                        DataCell(
                          Text(
                            e.modeOfPayment ?? "-",
                            style: transactionTextStyle(e),
                          ),
                        ),
                        DataCell(
                          Text(
                            e.status == 'active' ? e.comment ?? "-" : e.transactionDescription ?? "-",
                            style: transactionTextStyle(e),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                  bottomMessage:
                      "Showing ${(studentPocketMoneyBean.loadOrDebitStudentPocketMoneyTransactionBeans ?? []).whereNotNull().length} transactions",
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }

  TextStyle transactionTextStyle(LoadOrDebitStudentPocketMoneyTransactionBean e) => TextStyle(
        color: e.status != "active" ? Colors.red : null,
      );

  double getAlertBoxHeight(BuildContext context, {double scaleFactor = 2}) => MediaQuery.of(context).size.height / scaleFactor;

  double getAlertBoxWidth(BuildContext context, {double scaleFactor = 2}) => max(500, MediaQuery.of(context).size.width / scaleFactor);

  String studentBedInfoString(StudentProfile eachStudent, StudentBedInfo? studentBedInfoBean) => studentBedInfoBean == null
      ? ""
      : "Hostel Incharge: ${hostelIncharge(hostels.firstWhereOrNull((e) => e.hostelId == studentBedInfoBean.hostelId))?.employeeName ?? "-"}\n"
          "Hostel Name: ${studentBedInfoBean.hostelName ?? "-"}\n"
          "Room: ${studentBedInfoBean.roomName ?? "-"}\n"
          "Bed: ${studentBedInfoBean.bedInfo ?? "-"}";

  Future<void> showLoadOrDebitDialog(StudentProfile eachStudent, StudentPocketMoneyBean? studentPocketMoneyBean) async {
    LoadOrDebitStudentPocketMoneyTransactionBean loadOrDebitStudentPocketMoneyTransactionBean = LoadOrDebitStudentPocketMoneyTransactionBean(
      schoolId: eachStudent.studentId,
      transactionDate: convertDateTimeToYYYYMMDDFormat(DateTime.now()),
      modeOfPayment: ModeOfPayment.CASH.name,
      studentId: eachStudent.studentId,
      pocketMoneyStatus: "active",
      studentStatus: "active",
      txnStatus: "SUCCESS",
      transactionKind: "CR",
      transactionType: "STUDENT_POCKET_MONEY",
      agent: widget.adminProfile.userId,
    );
    await showDialog(
      barrierDismissible: false,
      context: _scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: Text("${eachStudent.sectionName ?? "-"} - ${eachStudent.rollNumber ?? ""}. ${eachStudent.studentFirstName}"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: getAlertBoxWidth(context),
                height: getAlertBoxHeight(context),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text("Current Wallet Balance:")),
                        Text(INR_SYMBOL + " " + doubleToStringAsFixedForINR((studentPocketMoneyBean?.pocketMoney ?? 0) / 100.0) + " /-")
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...["CR", "DB"].map(
                          (e) {
                            return Expanded(
                              child: RadioListTile(
                                title: Text(e == "CR" ? "Load" : "Debit"),
                                selected: loadOrDebitStudentPocketMoneyTransactionBean.transactionKind == e,
                                value: e,
                                onChanged: (String? value) {
                                  if (value == null) return;
                                  setState(() => loadOrDebitStudentPocketMoneyTransactionBean.transactionKind = value);
                                },
                                groupValue: loadOrDebitStudentPocketMoneyTransactionBean.transactionKind,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: loadOrDebitStudentPocketMoneyTransactionBean.amountController,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        label: Text("Amount"),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            if (newValue.text == "") return newValue;
                            final text = newValue.text;
                            double? payingAmount = double.tryParse(text);
                            if (payingAmount == null) {
                              return oldValue;
                            }
                            return newValue;
                          } catch (e) {
                            return oldValue;
                          }
                        }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(child: Text("Date:")),
                        InkWell(
                          onTap: () async {
                            DateTime? _newDate = await showDatePicker(
                              context: context,
                              initialDate: convertYYYYMMDDFormatToDateTime(loadOrDebitStudentPocketMoneyTransactionBean.transactionDate),
                              firstDate: academicYearStartDate,
                              lastDate: DateTime.now(),
                              helpText: "Select a date",
                            );
                            if (_newDate == null) return;
                            setState(() => loadOrDebitStudentPocketMoneyTransactionBean.transactionDate = convertDateTimeToYYYYMMDDFormat(_newDate));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(convertDateTimeToDDMMYYYYFormat(
                                  convertYYYYMMDDFormatToDateTime(loadOrDebitStudentPocketMoneyTransactionBean.transactionDate))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: loadOrDebitStudentPocketMoneyTransactionBean.commentController,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        label: Text("Comments"),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (loadOrDebitStudentPocketMoneyTransactionBean.amountController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Amount cannot be empty.."),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                loadOrDebitStudentPocketMoneyTransactionBean.populateFromControllers();
                await loadOrDebitStudentPocketMoneyAction(loadOrDebitStudentPocketMoneyTransactionBean);
              },
              child: const Text("Proceed"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadOrDebitStudentPocketMoneyAction(LoadOrDebitStudentPocketMoneyTransactionBean loadOrDebitStudentPocketMoneyTransactionBean) async {
    LoadOrDebitStudentPocketMoneyRequest loadOrDebitStudentPocketMoneyRequest = LoadOrDebitStudentPocketMoneyRequest(
      agent: widget.adminProfile.userId,
      schoolId: widget.adminProfile.schoolId,
      loadOrDebitStudentPocketMoneyTransactionBeans: [loadOrDebitStudentPocketMoneyTransactionBean],
    );
    setState(() => _isLoading = true);
    LoadOrDebitStudentPocketMoneyResponse loadOrDebitStudentPocketMoneyResponse =
        await loadOrDebitStudentPocketMoney(loadOrDebitStudentPocketMoneyRequest);
    if (loadOrDebitStudentPocketMoneyResponse.httpStatus != "OK" || loadOrDebitStudentPocketMoneyResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      await loadStudentPocketMoney();
    }
    setState(() => _isLoading = false);
  }
}
