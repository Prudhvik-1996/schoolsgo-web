import 'dart:convert';
import 'dart:html';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/widgets/clay_container.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_wise_fee_receipt_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/edit_student_fee_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/update_section_wise_student_fee_in_bulk.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/fee/student/student_fee_screen_v3.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class AdminStudentFeeManagementScreen extends StatefulWidget {
  const AdminStudentFeeManagementScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _AdminStudentFeeManagementScreenState createState() => _AdminStudentFeeManagementScreenState();
}

class _AdminStudentFeeManagementScreenState extends State<AdminStudentFeeManagementScreen> {
  bool _isLoading = true;

  List<Section> _sectionsList = [];
  Section? selectedSection;
  bool isSectionPickerOpen = false;

  List<FeeType> feeTypes = [];

  List<StudentAnnualFeeBean> studentAnnualFeeBeans = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<FeeType> feeTypesForSelectedSection = [];
  List<StudentWiseAnnualFeesBean> studentWiseAnnualFeesBeans = [];
  List<SectionWiseAnnualFeesBean> sectionWiseAnnualFeeBeansList = [];

  int? editingStudentId;
  List<StudentProfile> studentsList = [];
  StudentProfile? selectedStudent;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Get all sections data
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
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
      return;
    } else {
      setState(() {
        studentsList = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
        studentsList.sort((a, b) {
          int aSection = _sectionsList.where((es) => es.sectionId == a.sectionId).firstOrNull?.seqOrder ?? 0;
          int bSection = _sectionsList.where((es) => es.sectionId == b.sectionId).firstOrNull?.seqOrder ?? 0;
          if (aSection == bSection) {
            return (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0);
          }
          return aSection.compareTo(bSection);
        });
      });
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

    await loadSectionWiseStudentsFeeMap();

    setState(() {
      _isLoading = false;
    });
  }

  loadSectionWiseStudentsFeeMap() async {
    if (selectedSection == null) return;
    setState(() {
      _isLoading = true;
    });
    GetSectionWiseAnnualFeesResponse getSectionWiseAnnualFeesResponse = await getSectionWiseAnnualFees(GetSectionWiseAnnualFeesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSectionWiseAnnualFeesResponse.httpStatus != "OK" || getSectionWiseAnnualFeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        sectionWiseAnnualFeeBeansList = (getSectionWiseAnnualFeesResponse.sectionWiseAnnualFeesBeanList ?? []).map((e) => e!).toList();
      });
    }
    setState(() {
      feeTypesForSelectedSection = [];
      for (var eachFeeType in feeTypes) {
        if ((eachFeeType.customFeeTypesList ?? []).isEmpty) {
          if (sectionWiseAnnualFeeBeansList
              .where((e) => e.sectionId == selectedSection!.sectionId)
              .toList()
              .map((e) => e.feeTypeId)
              .contains(eachFeeType.feeTypeId)) {
            feeTypesForSelectedSection.add(eachFeeType);
          }
        } else {
          if (sectionWiseAnnualFeeBeansList
              .where((e) => e.sectionId == selectedSection!.sectionId)
              .toList()
              .map((e) => e.feeTypeId)
              .contains(eachFeeType.feeTypeId)) {
            feeTypesForSelectedSection.add(eachFeeType);
            (feeTypesForSelectedSection.last.customFeeTypesList ?? []).where((e) => e != null).map((e) => e!).toList().removeWhere(
                (eachCustomFeeType) => (!sectionWiseAnnualFeeBeansList
                    .where((e) => e.sectionId == selectedSection!.sectionId)
                    .toList()
                    .map((e) => e.customFeeTypeId)
                    .contains(eachCustomFeeType.customFeeTypeId)));
          }
        }
      }
    });
    GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = await getStudentWiseAnnualFees(GetStudentWiseAnnualFeesRequest(
      schoolId: widget.adminProfile.schoolId, sectionId: selectedSection!.sectionId,
      // studentId: 1014,
    ));
    if (getStudentWiseAnnualFeesResponse.httpStatus != "OK" || getStudentWiseAnnualFeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        studentWiseAnnualFeesBeans = getStudentWiseAnnualFeesResponse.studentWiseAnnualFeesBeanList!.map((e) => e!).toList();
      });
      generateStudentMap();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void generateStudentMap() {
    setState(() {
      studentAnnualFeeBeans = [];
      studentWiseAnnualFeesBeans.sorted((a, b) => ((int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))));
      for (StudentWiseAnnualFeesBean eachAnnualFeeBean in studentWiseAnnualFeesBeans) {
        studentAnnualFeeBeans.add(
          StudentAnnualFeeBean(
            studentId: eachAnnualFeeBean.studentId,
            rollNumber: eachAnnualFeeBean.rollNumber,
            studentName: eachAnnualFeeBean.studentName,
            totalFee: eachAnnualFeeBean.actualFee,
            totalFeePaid: eachAnnualFeeBean.feePaid,
            walletBalance: eachAnnualFeeBean.studentWalletBalance,
            sectionId: eachAnnualFeeBean.sectionId,
            sectionName: eachAnnualFeeBean.sectionName,
            status: eachAnnualFeeBean.status,
            studentBusFeeBean: eachAnnualFeeBean.studentBusFeeBean ??
                StudentBusFeeBean(
                  schoolId: widget.adminProfile.schoolId,
                  studentId: eachAnnualFeeBean.studentId,
                ),
            studentAnnualFeeTypeBeans: feeTypesForSelectedSection
                .map(
                  (eachFeeType) => StudentAnnualFeeTypeBean(
                    feeTypeId: eachFeeType.feeTypeId,
                    feeType: eachFeeType.feeType,
                    studentFeeMapId: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.studentFeeMapId,
                    sectionFeeMapId: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.sectionFeeMapId,
                    amount: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.amount,
                    discount: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.discount,
                    comments: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.comments,
                    amountPaid: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.amountPaid,
                    studentAnnualCustomFeeTypeBeans: (eachFeeType.customFeeTypesList ?? [])
                        .where((eachCustomFeeType) => eachCustomFeeType != null)
                        .map((eachCustomFeeType) => eachCustomFeeType!)
                        .map(
                          (eachCustomFeeType) => StudentAnnualCustomFeeTypeBean(
                            customFeeTypeId: eachCustomFeeType.customFeeTypeId,
                            customFeeType: eachCustomFeeType.customFeeType,
                            studentFeeMapId: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                                .map((e) => e!)
                                .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                    eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                    eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                                .firstOrNull
                                ?.studentFeeMapId,
                            sectionFeeMapId: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                                .map((e) => e!)
                                .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                    eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                    eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                                .firstOrNull
                                ?.sectionFeeMapId,
                            amount: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                                .map((e) => e!)
                                .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                    eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                    eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                                .firstOrNull
                                ?.amount,
                            discount: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                                .map((e) => e!)
                                .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                    eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                    eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                                .firstOrNull
                                ?.discount,
                            comments: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                                .map((e) => e!)
                                .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                    eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                    eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                                .firstOrNull
                                ?.comments,
                            amountPaid: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                                .map((e) => e!)
                                .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                    eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                    eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                                .firstOrNull
                                ?.amountPaid,
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        );
      }
      studentAnnualFeeBeans = studentAnnualFeeBeans.where((e) => e.status != "inactive").toList();
      studentAnnualFeeBeans.sort(
        (a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0),
      );
    });
  }

  Future<void> _saveChanges(int studentId) async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Fee Management'),
          content: const Text("Are you sure to save changes?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });
                CreateOrUpdateStudentAnnualFeeMapRequest createOrUpdateStudentAnnualFeeMapRequest = CreateOrUpdateStudentAnnualFeeMapRequest(
                  schoolId: widget.adminProfile.schoolId,
                  agent: widget.adminProfile.userId,
                  studentAnnualFeeMapBeanList: studentAnnualFeeBeans
                          .where((e) => e.studentId == studentId)
                          .map((e) => e.studentAnnualFeeTypeBeans ?? [])
                          .expand((i) => i)
                          .where((e) => (e.studentAnnualCustomFeeTypeBeans ?? []).isEmpty)
                          .map((e) => StudentAnnualFeeMapUpdateBean(
                                schoolId: widget.adminProfile.schoolId,
                                studentId: studentId,
                                amount: e.amount,
                                discount: e.discount,
                                comments: e.comments,
                                sectionFeeMapId: e.sectionFeeMapId,
                                studentFeeMapId: e.studentFeeMapId,
                              ))
                          .toList() +
                      studentAnnualFeeBeans
                          .where((e) => e.studentId == studentId)
                          .map((e) => e.studentAnnualFeeTypeBeans ?? [])
                          .expand((i) => i)
                          .map((e) => e.studentAnnualCustomFeeTypeBeans ?? [])
                          .expand((i) => i)
                          .map((e) => StudentAnnualFeeMapUpdateBean(
                                schoolId: widget.adminProfile.schoolId,
                                studentId: studentId,
                                amount: e.amount,
                                discount: e.discount,
                                comments: e.comments,
                                sectionFeeMapId: e.sectionFeeMapId,
                                studentFeeMapId: e.studentFeeMapId,
                              ))
                          .toList(),
                  studentRouteStopFares: studentAnnualFeeBeans
                      .where((e) =>
                              e.studentBusFeeBean != null &&
                              e.studentId == studentId &&
                              (int.tryParse(e.studentBusFeeBean!.fareController.text)) != null
                          // && (e.studentBusFeeBean!.fare ?? 0) != int.tryParse(e.studentBusFeeBean!.fareController.text)
                          )
                      .map((e) => StudentStopFare(
                            studentId: studentId,
                            fare: int.parse(e.studentBusFeeBean!.fareController.text) * 100,
                          ))
                      .toList(),
                );
                CreateOrUpdateStudentAnnualFeeMapResponse createOrUpdateStudentAnnualFeeMapResponse =
                    await createOrUpdateStudentAnnualFeeMap(createOrUpdateStudentAnnualFeeMapRequest);
                if (createOrUpdateStudentAnnualFeeMapResponse.httpStatus == "OK" &&
                    createOrUpdateStudentAnnualFeeMapResponse.responseStatus == "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Changes updated successfully"),
                    ),
                  );
                  await _loadData();
                  setState(() {
                    editingStudentId = null;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong, Please try again later.."),
                    ),
                  );
                }
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> downloadStudentFeeData() async {
    setState(() => _isLoading = true);
    List<int> bytes = await getStudentFeeData(GetStudentProfileRequest(
      schoolId: widget.adminProfile.schoolId,
      sectionId: selectedSection?.sectionId,
    ));
    AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "StudentFeeData_${widget.adminProfile.schoolName ?? "_"}.xlsx")
      ..click();
    setState(() => _isLoading = false);
  }

  Future<void> downloadTemplateAction() async {
    await UpdateSectionWiseStudentFeeInBulk(
      studentsList: studentsList.where((es) => es.sectionId == selectedSection?.sectionId).toList(),
      studentAnnualFeeList: studentAnnualFeeBeans..where((e) => e.sectionId == selectedSection?.sectionId).toList(),
      selectedSection: selectedSection!,
      agentId: widget.adminProfile.userId!,
      schoolId: widget.adminProfile.schoolId!,
      feeTypesForSelectedSection: feeTypesForSelectedSection,
    ).downloadTemplate();
  }

  Future<void> uploadFromTemplateActionToEdit() async {
    CreateOrUpdateStudentAnnualFeeMapRequest? createOrUpdateStudentAnnualFeeMapRequest = await UpdateSectionWiseStudentFeeInBulk(
      studentsList: studentsList.where((es) => es.sectionId == selectedSection?.sectionId).toList(),
      studentAnnualFeeList: studentAnnualFeeBeans.where((e) => e.sectionId == selectedSection?.sectionId).toList(),
      selectedSection: selectedSection!,
      agentId: widget.adminProfile.userId!,
      schoolId: widget.adminProfile.schoolId!,
      feeTypesForSelectedSection: feeTypesForSelectedSection,
    ).uploadFromTemplateActionToEdit(context);
    if (createOrUpdateStudentAnnualFeeMapRequest == null) {
      // Validation Failed
    } else if ((createOrUpdateStudentAnnualFeeMapRequest.studentRouteStopFares ?? []).isEmpty &&
        (createOrUpdateStudentAnnualFeeMapRequest.studentAnnualFeeMapBeanList ?? []).isEmpty) {
      // Nothing to edit
    } else {
      showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Student Fee Management'),
            content: const Text('Are you sure you want to proceed with the changes?'),
            actions: <Widget>[
              TextButton(
                child: const Text("YES"),
                onPressed: () async {
                  HapticFeedback.vibrate();
                  Navigator.of(context).pop();
                  setState(() => _isLoading = true);
                  CreateOrUpdateStudentAnnualFeeMapResponse createOrUpdateStudentAnnualFeeMapResponse =
                      await createOrUpdateStudentAnnualFeeMap(createOrUpdateStudentAnnualFeeMapRequest);
                  if (createOrUpdateStudentAnnualFeeMapResponse.httpStatus == "OK" &&
                      createOrUpdateStudentAnnualFeeMapResponse.responseStatus == "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Changes updated successfully"),
                      ),
                    );
                    await _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Something went wrong, Please try again later.."),
                      ),
                    );
                  }
                  setState(() => _isLoading = false);
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  HapticFeedback.vibrate();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int perRowCount = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 1;
    List<StudentAnnualFeeBean> studentsListToDisplay =
        selectedStudent == null ? studentAnnualFeeBeans : studentAnnualFeeBeans.where((e) => e.studentId == selectedStudent?.studentId).toList();
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Student Fee Management"),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                setState(() => _isLoading = true);
                await downloadStudentFeeData();
                setState(() => _isLoading = false);
              },
            ),
          if (!_isLoading && selectedSection != null)
            PopupMenuButton<String>(
              tooltip: "Templates for student bulk upload",
              onSelected: (String choice) async {
                switch (choice) {
                  case "Download Template":
                    await downloadTemplateAction();
                    return;
                  case "Upload From Template":
                    await uploadFromTemplateActionToEdit();
                    return;
                  default:
                    return;
                }
              },
              itemBuilder: (BuildContext context) {
                return {
                  "Download Template",
                  "Upload From Template",
                }.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
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
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                _sectionPicker(),
                _studentSearchableDropDown(),
                for (int i = 0; i < studentsListToDisplay.length / perRowCount; i = i + 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int j = 0; j < perRowCount; j++)
                        Expanded(
                          child: ((i * perRowCount + j) >= studentsListToDisplay.length)
                              ? Container()
                              : buildStudentWiseAnnualFeeMapCard(studentsListToDisplay[(i * perRowCount + j)]),
                        ),
                    ],
                  ),
              ],
            ),
    );
  }

  Widget _studentSearchableDropDown() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: InputDecorator(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelText: "Student Name",
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
          child: DropdownSearch<StudentProfile>(
            mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
            selectedItem: selectedStudent,
            items: studentsList.where((e) => e.status == "active").toList(),
            itemAsString: (StudentProfile? student) {
              return student == null
                  ? ""
                  : [
                        ((student.rollNumber ?? "") == "" ? "" : student.rollNumber! + "."),
                        student.studentFirstName ?? "",
                        student.studentMiddleName ?? "",
                        student.studentLastName ?? "",
                      ].where((e) => e != "").join(" ").trim() +
                      " - ${student.sectionName}";
            },
            showSearchBox: true,
            dropdownBuilder: (BuildContext context, StudentProfile? student) {
              return buildStudentWidget(student ?? StudentProfile());
            },
            onChanged: (StudentProfile? student) async {
              if (student == null) {
                setState(() {
                  selectedStudent = null;
                });
                return;
              }
              if (selectedSection?.sectionId != student.sectionId) {
                setState(() {
                  selectedSection = _sectionsList.firstWhereOrNull((e) => e.sectionId == student.sectionId);
                });
                await loadSectionWiseStudentsFeeMap();
              }
              setState(() {
                selectedStudent = student;
              });
            },
            showClearButton: true,
            compareFn: (item, selectedItem) => item?.studentId == selectedItem?.studentId,
            dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
            filterFn: (StudentProfile? student, String? key) {
              return ([
                        ((student?.rollNumber ?? "") == "" ? "" : student!.rollNumber! + "."),
                        student?.studentFirstName ?? "",
                        student?.studentMiddleName ?? "",
                        student?.studentLastName ?? "",
                      ].where((e) => e != "").join(" ") +
                      " - ${student?.sectionName ?? ""}")
                  .toLowerCase()
                  .trim()
                  .contains(key!.toLowerCase());
            },
          ),
        ),
      ),
    );
  }

  Widget buildStudentWidget(StudentProfile e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 20,
      child: Center(
        child: AutoSizeText(
          ((e.rollNumber ?? "") == "" ? "" : e.rollNumber! + ". ") +
              ([e.studentFirstName ?? "", e.studentMiddleName ?? "", e.studentLastName ?? ""].where((e) => e != "").join(" ") +
                      " - ${e.sectionName ?? ""}")
                  .trim(),
          style: const TextStyle(
            fontSize: 14,
          ),
          overflow: TextOverflow.visible,
          maxLines: 1,
          minFontSize: 12,
        ),
      ),
    );
  }

  Widget buildStudentWiseAnnualFeeMapCard(StudentAnnualFeeBean studentWiseAnnualFeesBean) {
    List<Widget> rows = [];
    rows.add(
      Row(
        children: [
          Expanded(
            child: SelectableText(
              "${studentWiseAnnualFeesBean.rollNumber ?? "-"}. ${studentWiseAnnualFeesBean.studentName}",
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (editingStudentId == null)
            Container(
              margin: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () {
                  // TODO navigate to new screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return EditStudentFeeScreen(
                          adminProfile: widget.adminProfile,
                          studentWiseAnnualFeesBean: studentWiseAnnualFeesBean,
                        );
                      },
                    ),
                  ); // .then((value) => _loadData());
                  // setState(() {
                  //   editingStudentId = studentWiseAnnualFeesBean.studentId;
                  // });
                },
                child: ClayButton(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 1,
                  borderRadius: 100,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: const Icon(Icons.edit),
                  ),
                ),
              ),
            ),
          if (editingStudentId != null && editingStudentId == studentWiseAnnualFeesBean.studentId)
            Container(
              margin: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  setState(() {
                    editingStudentId = null;
                    generateStudentMap();
                  });
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: ClayButton(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 1,
                  borderRadius: 100,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: const Icon(Icons.clear),
                  ),
                ),
              ),
            ),
          if (editingStudentId != null && editingStudentId == studentWiseAnnualFeesBean.studentId)
            Container(
              margin: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () async {
                  await _saveChanges(editingStudentId!);
                },
                child: ClayButton(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 1,
                  borderRadius: 100,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: const Icon(Icons.check),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    rows.add(
      const SizedBox(
        height: 15,
      ),
    );
    List<Widget> feeStats = [];
    for (StudentAnnualFeeTypeBean eachStudentAnnualFeeTypeBean in (studentWiseAnnualFeesBean.studentAnnualFeeTypeBeans ?? [])) {
      feeStats.add(
        (eachStudentAnnualFeeTypeBean.amount == null || eachStudentAnnualFeeTypeBean.amount == 0) &&
                ((eachStudentAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isEmpty ||
                    ((eachStudentAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).map((e) => e.amount ?? 0).reduce((a, b) => a + b)) == 0) &&
                editingStudentId != studentWiseAnnualFeesBean.studentId
            ? Container()
            : Row(
                children: [
                  Expanded(
                    child: Text(eachStudentAnnualFeeTypeBean.feeType ?? "-"),
                  ),
                  (editingStudentId != null && editingStudentId == studentWiseAnnualFeesBean.studentId)
                      ? ((eachStudentAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isNotEmpty)
                          ? Container()
                          : SizedBox(
                              width: 60,
                              child: TextField(
                                controller: eachStudentAnnualFeeTypeBean.amountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Amount',
                                  hintText: 'Amount',
                                  contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                    try {
                                      final text = newValue.text;
                                      if (text.isNotEmpty) double.parse(text);
                                      return newValue;
                                    } catch (e) {
                                      debugPrintStack();
                                    }
                                    return oldValue;
                                  }),
                                ],
                                onChanged: (String e) {
                                  setState(() {
                                    eachStudentAnnualFeeTypeBean.amount = (double.parse(e) * 100).round(); // TODO
                                  });
                                },
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                                autofocus: true,
                              ),
                            )
                      : eachStudentAnnualFeeTypeBean.amount == null || eachStudentAnnualFeeTypeBean.amount == 0
                          ? Container()
                          : Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(eachStudentAnnualFeeTypeBean.amount! / 100)}"),
                ],
              ),
      );
      feeStats.add(
        const SizedBox(
          height: 15,
        ),
      );
      for (StudentAnnualCustomFeeTypeBean eachStudentAnnualCustomFeeTypeBean
          in (eachStudentAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? [])) {
        if ((editingStudentId != studentWiseAnnualFeesBean.studentId) && (eachStudentAnnualCustomFeeTypeBean.amount ?? 0) == 0) {
          continue;
        }
        feeStats.add(
          Row(
            children: [
              const CustomVerticalDivider(),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(eachStudentAnnualCustomFeeTypeBean.customFeeType ?? "-"),
              ),
              (editingStudentId != null && editingStudentId == studentWiseAnnualFeesBean.studentId)
                  ? SizedBox(
                      width: 60,
                      child: TextField(
                        controller: eachStudentAnnualCustomFeeTypeBean.amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Amount',
                          hintText: 'Amount',
                          contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            try {
                              final text = newValue.text;
                              if (text.isNotEmpty) double.parse(text);
                              return newValue;
                            } catch (e) {
                              debugPrintStack();
                            }
                            return oldValue;
                          }),
                        ],
                        onChanged: (String e) {
                          setState(() {
                            eachStudentAnnualCustomFeeTypeBean.amount = (double.parse(e) * 100).round();
                          });
                        },
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        autofocus: true,
                      ),
                    )
                  : eachStudentAnnualCustomFeeTypeBean.amount == null || eachStudentAnnualCustomFeeTypeBean.amount == 0
                      ? Container()
                      : Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(eachStudentAnnualCustomFeeTypeBean.amount! / 100)}"),
            ],
          ),
        );
        feeStats.add(
          const SizedBox(
            height: 15,
          ),
        );
      }
    }

    if (studentWiseAnnualFeesBean.studentBusFeeBean != null &&
        (studentWiseAnnualFeesBean.studentBusFeeBean?.fare ?? 0) != 0 &&
        (editingStudentId != studentWiseAnnualFeesBean.studentId)) {
      feeStats.add(Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Bus Fee"),
                const SizedBox(width: 10),
                buildBusFeeTooltip(studentWiseAnnualFeesBean),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            studentWiseAnnualFeesBean.studentBusFeeBean?.fare == null
                ? "-"
                : INR_SYMBOL + " " + doubleToStringAsFixedForINR(studentWiseAnnualFeesBean.studentBusFeeBean!.fare! / 100),
          ),
        ],
      ));
      feeStats.add(
        const SizedBox(
          height: 15,
        ),
      );
    } else if (editingStudentId != null && editingStudentId == studentWiseAnnualFeesBean.studentId) {
      feeStats.add(
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Bus Fee"),
                  const SizedBox(width: 10),
                  buildBusFeeTooltip(studentWiseAnnualFeesBean),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: studentWiseAnnualFeesBean.studentBusFeeBean!.fareController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Amount',
                  hintText: 'Amount',
                  contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    try {
                      final text = newValue.text;
                      if (text.isNotEmpty) double.parse(text);
                      return newValue;
                    } catch (e) {
                      debugPrintStack();
                    }
                    return oldValue;
                  }),
                ],
                style: const TextStyle(
                  fontSize: 12,
                ),
                autofocus: true,
              ),
            ),
          ],
        ),
      );
    }

    feeStats.add(
      const Divider(
        thickness: 1,
      ),
    );

    feeStats.add(
      const SizedBox(
        height: 7.5,
      ),
    );
    // TODO: add bus fee discount as well
    if (studentWiseAnnualFeesBean.discount > 0) {
      feeStats.add(
        Row(
          children: [
            const Expanded(
              child: Text("Discount:"),
            ),
            Text(
              "$INR_SYMBOL ${doubleToStringAsFixedForINR(studentWiseAnnualFeesBean.discount / 100)}",
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
    }
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text("Total:"),
          ),
          Text(
            studentWiseAnnualFeesBean.totalFee == null
                ? "-"
                : "$INR_SYMBOL ${doubleToStringAsFixedForINR((studentWiseAnnualFeesBean.totalFee ?? 0) / 100)}",
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text("Total Fee Paid:"),
          ),
          Text(
            studentWiseAnnualFeesBean.totalFeePaid == null
                ? "-"
                : "$INR_SYMBOL ${doubleToStringAsFixedForINR((studentWiseAnnualFeesBean.totalFeePaid ?? 0) / 100)}",
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
    // feeStats.add(
    //   Row(
    //     children: [
    //       const Expanded(
    //         child: Text(
    //           "Wallet Balance:",
    //         ),
    //       ),
    //       Text(
    //         "$INR_SYMBOL ${((studentWiseAnnualFeesBean.walletBalance ?? 0) / 100).toStringAsFixed(2)}",
    //         textAlign: TextAlign.end,
    //         style: const TextStyle(
    //           color: Colors.blue,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text(
              "Fee to be paid:",
            ),
          ),
          Text(
            "$INR_SYMBOL ${doubleToStringAsFixedForINR(((studentWiseAnnualFeesBean.totalFee ?? 0) - (studentWiseAnnualFeesBean.totalFeePaid ?? 0) - (studentWiseAnnualFeesBean.walletBalance ?? 0)) / 100)}",
            textAlign: TextAlign.end,
            style: TextStyle(
              color: ((studentWiseAnnualFeesBean.totalFee ?? 0) -
                          (studentWiseAnnualFeesBean.totalFeePaid ?? 0) -
                          (studentWiseAnnualFeesBean.walletBalance ?? 0)) ==
                      0
                  ? null
                  : const Color(0xffff5733),
            ),
          ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: rows +
                [
                  Container(
                    margin: const EdgeInsets.all(4),
                    child: ClayContainer(
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 10,
                      depth: 40,
                      emboss: true,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: feeStats,
                        ),
                      ),
                    ),
                  ),
                ] +
                [
                  const SizedBox(
                    height: 7.5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () async {
                              StudentProfile? studentProfile =
                                  ((await getStudentProfile(GetStudentProfileRequest(studentId: studentWiseAnnualFeesBean.studentId)))
                                              .studentProfiles ??
                                          [])
                                      .firstOrNull;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    if (studentProfile != null) {
                                      return StudentFeeScreenV3(
                                        studentProfile: studentProfile,
                                        adminProfile: widget.adminProfile,
                                      );
                                    } else {
                                      return AdminStudentWiseFeeReceiptsScreen(
                                        studentAnnualFeeBean: studentWiseAnnualFeesBean,
                                        adminProfile: widget.adminProfile,
                                      );
                                    }
                                  },
                                ),
                              ).then((value) => _loadData());
                            },
                            child: ClayButton(
                              depth: 40,
                              surfaceColor: clayContainerColor(context),
                              parentColor: clayContainerColor(context),
                              spread: 1,
                              borderRadius: 5,
                              child: Center(
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  child: const Text(
                                    "Receipts",
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ), // Expanded(
                      //   child: ((studentWiseAnnualFeesBean.totalFee ?? 0) -
                      //               (studentWiseAnnualFeesBean.totalFeePaid ?? 0) -
                      //               (studentWiseAnnualFeesBean.walletBalance ?? 0)) ==
                      //           0
                      //       ? const Text("")
                      //       : Container(
                      //           margin: const EdgeInsets.all(8),
                      //           child: GestureDetector(
                      //             onTap: () {
                      //               Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                   builder: (context) {
                      //                     return AdminPayStudentFeeScreen(
                      //                       studentWiseAnnualFeesBean: studentWiseAnnualFeesBean,
                      //                       adminProfile: widget.adminProfile,
                      //                     );
                      //                   },
                      //                 ),
                      //               );
                      //             },
                      //             child: ClayButton(
                      //               depth: 40,
                      //               surfaceColor: clayContainerColor(context),
                      //               parentColor: clayContainerColor(context),
                      //               spread: 1,
                      //               borderRadius: 5,
                      //               child: Center(
                      //                 child: Container(
                      //                   margin: const EdgeInsets.all(10),
                      //                   child: const Text(
                      //                     "Pay Fee",
                      //                     style: TextStyle(
                      //                       color: Colors.blue,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      // ),
                    ],
                  )
                ],
          ),
        ),
      ),
    );
  }

  Tooltip buildBusFeeTooltip(StudentAnnualFeeBean studentWiseAnnualFeesBean) {
    return Tooltip(
      message: studentWiseAnnualFeesBean.studentBusFeeBean?.routeName == null || studentWiseAnnualFeesBean.studentBusFeeBean?.stopName == null
          ? ""
          : "Stop: ${studentWiseAnnualFeesBean.studentBusFeeBean!.stopName}\n"
              "Route: ${studentWiseAnnualFeesBean.studentBusFeeBean!.routeName}",
      child: const SizedBox(
        height: 15,
        width: 15,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Icon(
            Icons.directions_bus_outlined,
            color: Colors.yellow,
          ),
        ),
      ),
    );
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: isSectionPickerOpen
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

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.vibrate();
          setState(() {
            if (selectedSection != null && selectedSection!.sectionId == section.sectionId) {
              selectedSection = null;
            } else {
              selectedSection = section;
              loadSectionWiseStudentsFeeMap();
              isSectionPickerOpen = false;
            }
          });
          // _applyFilters();
        },
        child: ClayButton(
          depth: 40,
          spread: selectedSection != null && selectedSection!.sectionId == section.sectionId ? 0 : 2,
          surfaceColor:
              selectedSection != null && selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
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
              HapticFeedback.vibrate();
              setState(() {
                isSectionPickerOpen = !isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName ?? "-"}",
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
            children: _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
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
          HapticFeedback.vibrate();
          setState(() {
            isSectionPickerOpen = !isSectionPickerOpen;
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
                  child: Text(
                    selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName ?? "-"}",
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
}
