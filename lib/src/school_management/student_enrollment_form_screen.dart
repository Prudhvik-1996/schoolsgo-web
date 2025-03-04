import 'dart:convert';
import 'dart:html';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_wise_fee_receipt_screen.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/fee/student/student_fee_screen_v3.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/student_status.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class StudentEnrollmentFormScreen extends StatefulWidget {
  const StudentEnrollmentFormScreen({
    Key? key,
    required this.studentProfile,
    required this.students,
    required this.sections,
    required this.adminProfile,
    required this.isEditMode,
  }) : super(key: key);

  final StudentProfile studentProfile;
  final List<StudentProfile> students;
  final List<Section> sections;
  final AdminProfile? adminProfile;
  final bool isEditMode;

  @override
  State<StudentEnrollmentFormScreen> createState() => _StudentEnrollmentFormScreenState();
}

class _StudentEnrollmentFormScreenState extends State<StudentEnrollmentFormScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  bool _isOtherLoading = true;
  bool _isEditMode = false;

  StudentProfile? sibling;
  String? primaryContactType = "Father";

  late List<AdditionalMobile> additionalMobileNumbers;
  bool showAdditionalPhoneNumbers = false;
  bool sameAsPermanentAddress = false;

  bool _showFeeDetails = false;
  StudentAnnualFeeBean? studentAnnualFeeBean;
  List<FeeType> feeTypes = [];
  List<FeeType> feeTypesForSelectedSection = [];
  List<StudentWiseAnnualFeesBean> studentWiseAnnualFeesBeans = [];
  List<SectionWiseAnnualFeesBean> sectionWiseAnnualFeeBeansList = [];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.isEditMode;
    additionalMobileNumbers = (widget.studentProfile.otherPhoneNumbers ?? "").split(",").map((e) => AdditionalMobile(e)).toList();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isOtherLoading = false;
      _showFeeDetails = false;
    });
    if (widget.studentProfile.studentId != null && widget.studentProfile.sectionId != null) {
      await loadSectionWiseStudentsFeeMap();
    }
    setState(() => _isLoading = false);
  }

  loadSectionWiseStudentsFeeMap() async {
    if (widget.studentProfile.studentId == null) return;
    setState(() {
      _isLoading = true;
    });
    GetFeeTypesResponse getFeeTypesResponse = await getFeeTypes(GetFeeTypesRequest(
      schoolId: widget.studentProfile.schoolId,
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

    GetSectionWiseAnnualFeesResponse getSectionWiseAnnualFeesResponse = await getSectionWiseAnnualFees(GetSectionWiseAnnualFeesRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
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
              .where((e) => e.sectionId == widget.studentProfile.sectionId)
              .toList()
              .map((e) => e.feeTypeId)
              .contains(eachFeeType.feeTypeId)) {
            feeTypesForSelectedSection.add(eachFeeType);
          }
        } else {
          if (sectionWiseAnnualFeeBeansList
              .where((e) => e.sectionId == widget.studentProfile.sectionId)
              .toList()
              .map((e) => e.feeTypeId)
              .contains(eachFeeType.feeTypeId)) {
            feeTypesForSelectedSection.add(eachFeeType);
            (feeTypesForSelectedSection.last.customFeeTypesList ?? []).where((e) => e != null).map((e) => e!).toList().removeWhere(
                (eachCustomFeeType) => (!sectionWiseAnnualFeeBeansList
                    .where((e) => e.sectionId == widget.studentProfile.sectionId)
                    .toList()
                    .map((e) => e.customFeeTypeId)
                    .contains(eachCustomFeeType.customFeeTypeId)));
          }
        }
      }
    });
    GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = await getStudentWiseAnnualFees(GetStudentWiseAnnualFeesRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
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
      StudentWiseAnnualFeesBean? eachAnnualFeeBean = studentWiseAnnualFeesBeans
          .where((e) => e.studentId == widget.studentProfile.studentId)
          .sorted((a, b) => ((int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))))
          .firstOrNull;
      studentAnnualFeeBean = StudentAnnualFeeBean(
        studentId: eachAnnualFeeBean?.studentId,
        rollNumber: eachAnnualFeeBean?.rollNumber,
        studentName: eachAnnualFeeBean?.studentName,
        totalFee: eachAnnualFeeBean?.actualFee,
        totalFeePaid: eachAnnualFeeBean?.feePaid,
        walletBalance: eachAnnualFeeBean?.studentWalletBalance,
        sectionId: eachAnnualFeeBean?.sectionId,
        sectionName: eachAnnualFeeBean?.sectionName,
        status: eachAnnualFeeBean?.status,
        studentBusFeeBean: eachAnnualFeeBean?.studentBusFeeBean ??
            StudentBusFeeBean(
              schoolId: widget.studentProfile.schoolId,
              studentId: eachAnnualFeeBean?.studentId,
            ),
        studentAnnualFeeTypeBeans: feeTypesForSelectedSection
            .map(
              (eachFeeType) => StudentAnnualFeeTypeBean(
                feeTypeId: eachFeeType.feeTypeId,
                feeType: eachFeeType.feeType,
                studentFeeMapId: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
                    .map((e) => e!)
                    .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                        eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                    .firstOrNull
                    ?.studentFeeMapId,
                sectionFeeMapId: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
                    .map((e) => e!)
                    .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                        eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                    .firstOrNull
                    ?.sectionFeeMapId,
                amount: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
                    .map((e) => e!)
                    .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                        eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                    .firstOrNull
                    ?.amount,
                discount: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
                    .map((e) => e!)
                    .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                        eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                    .firstOrNull
                    ?.discount,
                comments: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
                    .map((e) => e!)
                    .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                        eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                    .firstOrNull
                    ?.comments,
                amountPaid: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
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
                        studentFeeMapId: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
                            .map((e) => e!)
                            .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                            .firstOrNull
                            ?.studentFeeMapId,
                        sectionFeeMapId: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
                            .map((e) => e!)
                            .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                            .firstOrNull
                            ?.sectionFeeMapId,
                        amount: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
                            .map((e) => e!)
                            .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                            .firstOrNull
                            ?.amount,
                        discount: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
                            .map((e) => e!)
                            .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                            .firstOrNull
                            ?.discount,
                        amountPaid: (eachAnnualFeeBean?.studentAnnualFeeMapBeanList ?? [])
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
      );
    });
  }

  Future<void> saveFeeChanges() async {
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
                  schoolId: widget.studentProfile.schoolId,
                  agent: widget.adminProfile?.userId,
                  studentAnnualFeeMapBeanList: (studentAnnualFeeBean?.studentAnnualFeeTypeBeans ?? [])
                          .where((e) => (e.studentAnnualCustomFeeTypeBeans ?? []).isEmpty)
                          .map((e) => StudentAnnualFeeMapUpdateBean(
                                schoolId: widget.studentProfile.schoolId,
                                studentId: widget.studentProfile.studentId,
                                amount: e.amount,
                                discount: e.discount,
                                comments: e.comments,
                                sectionFeeMapId: e.sectionFeeMapId,
                                studentFeeMapId: e.studentFeeMapId,
                              ))
                          .toList() +
                      (studentAnnualFeeBean?.studentAnnualFeeTypeBeans ?? [])
                          .map((e) => e.studentAnnualCustomFeeTypeBeans ?? [])
                          .expand((i) => i)
                          .map((e) => StudentAnnualFeeMapUpdateBean(
                                schoolId: widget.studentProfile.schoolId,
                                studentId: widget.studentProfile.studentId,
                                amount: e.amount,
                                discount: e.discount,
                                comments: e.comments,
                                sectionFeeMapId: e.sectionFeeMapId,
                                studentFeeMapId: e.studentFeeMapId,
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

  Future<void> saveChanges() async {
    setState(() => _isLoading = true);
    CreateOrUpdateStudentProfileRequest createOrUpdateStudentProfileRequest =
        CreateOrUpdateStudentProfileRequest.fromStudentProfile(widget.adminProfile?.userId, widget.studentProfile);
    CreateOrUpdateStudentProfileResponse createOrUpdateStudentProfileResponse =
        await createOrUpdateStudentProfile(createOrUpdateStudentProfileRequest);
    if (createOrUpdateStudentProfileResponse.httpStatus != "OK" || createOrUpdateStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      setState(() => _isLoading = false);
    } else {
      GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
        schoolId: widget.adminProfile?.schoolId,
        studentId: widget.studentProfile.studentId ?? createOrUpdateStudentProfileResponse.studentId,
      ));
      if (getStudentProfileResponse.httpStatus != "OK" ||
          getStudentProfileResponse.responseStatus != "success" ||
          (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        widget.studentProfile.modifyAsPerJson(
            (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList().firstOrNull?.origJson() ?? {});
        setState(() => _isEditMode = false);
        await _loadData();
      }
      setState(() => _isLoading = false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Application Form"),
        actions: [
          if (widget.studentProfile.sectionId != null && widget.studentProfile.studentId != null && !_isEditMode)
            IconButton(
                onPressed: () {
                  if (!_showFeeDetails && studentAnnualFeeBean == null) {
                    loadSectionWiseStudentsFeeMap();
                  }
                  setState(() => _showFeeDetails = !_showFeeDetails);
                },
                icon: _showFeeDetails ? const Icon(Icons.money_off) : const Icon(Icons.money)),
          if (widget.studentProfile.sectionId != null && widget.studentProfile.studentId != null) const SizedBox(width: 10),
          if (!_showFeeDetails && !_isEditMode)
            IconButton(
              onPressed: () {
                setState(() => _isEditMode = true);
              },
              icon: const Icon(Icons.edit),
            ),
          // if (!_showFeeDetails && _isEditMode)
          //   IconButton(
          //     onPressed: () async {
          //       setState(() {
          //         widget.studentProfile.fromControllers();
          //       });
          //       if (widget.studentProfile.isModified()) {
          //         showDialog(
          //           context: _scaffoldKey.currentContext!,
          //           builder: (currentContext) {
          //             return AlertDialog(
          //               title: const Text("Student Profile"),
          //               content: const Text("Are you sure you want to save changes?"),
          //               actions: [
          //                 TextButton(
          //                   onPressed: () {
          //                     Navigator.pop(context);
          //                     saveChanges();
          //                     // _loadData();
          //                   },
          //                   child: const Text("YES"),
          //                 ),
          //                 TextButton(
          //                   onPressed: () {
          //                     Navigator.pop(context);
          //                     setState(() {
          //                       widget.studentProfile.modifyAsPerJson(widget.studentProfile.origJson());
          //                       _isEditMode = false;
          //                     });
          //                   },
          //                   child: const Text("No"),
          //                 ),
          //                 TextButton(
          //                   onPressed: () {
          //                     Navigator.pop(context);
          //                     setState(() => _isEditMode = true);
          //                   },
          //                   child: const Text("Cancel"),
          //                 ),
          //               ],
          //             );
          //           },
          //         );
          //       }
          //       setState(() => _isEditMode = false);
          //     },
          //     icon: const Icon(Icons.check),
          //   ),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : _showFeeDetails
              ? ListView(
                  children: [
                    buildStudentWiseAnnualFeeMapCard(),
                  ],
                )
              : AbsorbPointer(
                  absorbing: _isOtherLoading, child: newLayout(), // oldLayout(context),
                ),
    );
  }

  Widget newLayout() {
    if (isLandscape()) {
      return landscapeLayout();
    }
    return portraitLayout();
  }

  ListView portraitLayout() {
    return ListView(
      children: [
        const SizedBox(height: 20),
        basicDetails(),
        const SizedBox(height: 20),
        parentDetails(),
        const SizedBox(height: 20),
        nationalityDetails(),
        const SizedBox(height: 20),
        addressDetails(),
        const SizedBox(height: 20),
        previousSchoolRecordDetails(),
        const SizedBox(height: 20),
        identificationMarksDetails(),
        const SizedBox(height: 20),
        studentStatusDetails(),
        const SizedBox(height: 20),
        if (showSubmitChangesButton()) submitChangesButton(),
        if (showSubmitWarning()) incompleteWarningBox(),
        const SizedBox(height: 200),
      ],
    );
  }

  ListView landscapeLayout() {
    return ListView(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  basicDetails(),
                  const SizedBox(height: 20),
                  nationalityDetails(),
                  const SizedBox(height: 20),
                  addressDetails(),
                  const SizedBox(height: 20),
                  identificationMarksDetails(),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  parentDetails(),
                  const SizedBox(height: 20),
                  previousSchoolRecordDetails(),
                  const SizedBox(height: 20),
                  studentStatusDetails(),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        const SizedBox(height: 20),
        if (showSubmitChangesButton()) submitChangesButton(),
        if (showSubmitWarning()) incompleteWarningBox(),
        const SizedBox(height: 200),
      ],
    );
  }

  Widget incompleteWarningBox() {
    return const Center(child: Text("Fill in all the mandatory values (*) to submit changes"));
  }

  bool showSubmitChangesButton() => !_showFeeDetails && _isEditMode && isValidEntry();

  bool showSubmitWarning() => !_showFeeDetails && _isEditMode && !isValidEntry();

  bool isValidEntry() {
    return !(widget.studentProfile.studentNameController.text.trim().isEmpty || widget.studentProfile.sectionId == null);
  }

  Widget submitChangesButton() {
    return Container(
      margin: !isLandscape()
          ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            widget.studentProfile.fromControllers();
            widget.studentProfile.otherPhoneNumbers = additionalMobileNumbers.map((e) => e.controller.text).join(",");
          });
          if (widget.studentProfile.isModified()) {
            showDialog(
              context: _scaffoldKey.currentContext!,
              builder: (currentContext) {
                return AlertDialog(
                  title: const Text("Student Profile"),
                  content: const Text("Are you sure you want to save changes?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        saveChanges();
                        // _loadData();
                      },
                      child: const Text("YES"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          widget.studentProfile.modifyAsPerJson(widget.studentProfile.origJson());
                          _isEditMode = false;
                        });
                      },
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => _isEditMode = true);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                );
              },
            );
          }
          setState(() => _isEditMode = false);
        },
        child: ClayButton(
          surfaceColor: Colors.green,
          parentColor: clayContainerColor(context),
          borderRadius: 10,
          spread: 2,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget detailHeaderWidget(String headerText, {Color? textColor}) {
    return Text(
      headerText,
      overflow: TextOverflow.clip,
      maxLines: 2,
      style: TextStyle(color: textColor),
    );
  }

  Widget headerWidget(String headerText) {
    return Text(
      headerText,
      style: GoogleFonts.archivoBlack(
        textStyle: const TextStyle(
          fontSize: 24,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget basicDetails() {
    /**
     * Admission No.
     * Section
     * Student Name
     * Student Sex
     * Student DOB
     */
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          padding: isLandscape() ? const EdgeInsets.all(30) : const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget("Student Details"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        admissionNumberRow(),
                        const SizedBox(height: 20),
                        rollNumberRow(),
                        const SizedBox(height: 20),
                        sectionRow(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  studentPhotoWidget(),
                ],
              ),
              const SizedBox(height: 20),
              studentNameRow(),
              const SizedBox(height: 20),
              studentDobRow(),
              const SizedBox(height: 20),
              studentSexRow(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget studentDobRow() {
    return InputDecorator(
      decoration: getTextFieldInputDecoration("Date Of Birth"),
      child: GestureDetector(
        onTap: () async {
          if (!_isEditMode) return;
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: convertYYYYMMDDFormatToDateTime(widget.studentProfile.studentDob),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            helpText: "Pick Student Date Of Birth",
          );
          setState(() {
            widget.studentProfile.studentDob = convertDateTimeToYYYYMMDDFormat(_newDate);
          });
        },
        child: Text(
          widget.studentProfile.studentDob == null
              ? "-"
              : convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(widget.studentProfile.studentDob)),
        ),
      ),
    );
  }

  Widget studentSexRow() {
    return InputDecorator(
        decoration: getTextFieldInputDecoration("Gender"),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: maleRadioButton()),
            Expanded(child: femaleRadioButton()),
          ],
        ));
  }

  Widget femaleRadioButton() {
    return RadioListTile<String?>(
      value: "female",
      groupValue: widget.studentProfile.sex,
      onChanged: !_isEditMode ? null : (String? value) => setState(() => widget.studentProfile.sex = value),
      title: const SizedBox(
        width: 120,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text("Female", style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget maleRadioButton() {
    return RadioListTile<String?>(
      value: "male",
      groupValue: widget.studentProfile.sex,
      onChanged: !_isEditMode ? null : (String? value) => setState(() => widget.studentProfile.sex = value),
      title: const SizedBox(
        width: 120,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text("Male", style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget studentNameRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Student Name *"),
      enabled: _isEditMode,
      controller: widget.studentProfile.studentNameController,
    );
  }

  Widget studentPhotoWidget() {
    return ClayButton(
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      borderRadius: 15,
      spread: 2,
      height: 150,
      width: 120,
      child: GestureDetector(
        onTap: () {
          if (!_isEditMode) return;
          try {
            FileUploadInputElement uploadInput = FileUploadInputElement();
            uploadInput.multiple = false;
            uploadInput.draggable = true;
            uploadInput.accept = '.png,.jpg,.jpeg';
            uploadInput.click();
            uploadInput.onChange.listen(
              (changeEvent) async {
                final files = uploadInput.files!;
                for (File file in files) {
                  final reader = FileReader();
                  reader.readAsDataUrl(file);
                  reader.onLoadEnd.listen(
                    (loadEndEvent) async {
                      debugPrint("File uploaded: " + file.name);
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        UploadFileToDriveResponse uploadFileResponse = await uploadFileToDrive(reader.result!, file.name);
                        setState(() => widget.studentProfile.studentPhotoUrl = uploadFileResponse.mediaBean!.mediaUrl!);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Something went wrong while trying to upload, ${file.name}..\nPlease try again later"),
                          ),
                        );
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  );
                }
              },
            );
          } catch (e) {
            const SnackBar(
              content: Text("Something went wrong..\nPlease try again later"),
            );
          }
        },
        child: widget.studentProfile.studentPhotoUrl == null
            ? const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Student\nPhoto",
                  textAlign: TextAlign.center,
                ))
            : Image.network(
                widget.studentProfile.studentPhotoUrl!,
                fit: BoxFit.scaleDown,
              ),
      ),
    );
  }

  Widget sectionRow() {
    return InputDecorator(
      decoration: getTextFieldInputDecoration("Section *"),
      child: DropdownButton<Section>(
        isExpanded: true,
        underline: Container(),
        hint: const Center(child: Text("Select Section")),
        value: widget.sections.where((e) => e.sectionId == widget.studentProfile.sectionId).firstOrNull,
        onChanged: widget.studentProfile.studentId == null
            ? (Section? section) {
                setState(() {
                  widget.studentProfile.sectionId = section?.sectionId;
                  widget.studentProfile.sectionName = section?.sectionName;
                });
              }
            : null,
        items: widget.sections
            .map(
              (e) => DropdownMenuItem<Section>(
                value: e,
                child: Text(
                  e.sectionName ?? "-",
                  textAlign: TextAlign.start,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget rollNumberRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Roll No."),
      enabled: _isEditMode,
      controller: widget.studentProfile.rollNumberController,
      keyboardType: const TextInputType.numberWithOptions(),
      textAlign: TextAlign.left,
    );
  }

  Widget admissionNumberRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Admission No."),
      enabled: _isEditMode,
      controller: widget.studentProfile.admissionNoController,
      keyboardType: const TextInputType.numberWithOptions(),
      textAlign: TextAlign.left,
    );
  }

  InputDecoration getTextFieldInputDecoration(String labelText, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: (hintText ?? labelText).replaceAll(" *", ""),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget parentDetails() {
    /**
     * Siblings from same school Dropdown
     * Father's Name
     * Father's qualification, occupation, salary
     * Mother's Name
     * Mother's qualification, occupation, salary
     * Auto populate gaurdian name, email, mobile with father's details
     */
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          padding: isLandscape() ? const EdgeInsets.all(30) : const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget("Parent Details"),
              const SizedBox(height: 20),
              if (_isEditMode) selectSiblingWidget(),
              if (_isEditMode) const SizedBox(height: 20),
              detailHeaderWidget("Father Details", textColor: Colors.blue),
              const SizedBox(height: 20),
              ...fatherDetailsRows(),
              const SizedBox(height: 20),
              detailHeaderWidget("Mother Details", textColor: Colors.blue),
              const SizedBox(height: 20),
              ...motherDetailsRows(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: detailHeaderWidget("Primary Contact Details", textColor: Colors.blue)),
                  const Tooltip(
                    message: "Student Login, Fee Receipts, Exam Memos, etc., will only use Primary Contact Details",
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              ...primaryContactDetailsRows(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: detailHeaderWidget("Additional Mobiles", textColor: Colors.blue)),
                  GestureDetector(
                    onTap: () => setState(() => showAdditionalPhoneNumbers = !showAdditionalPhoneNumbers),
                    child: ClayButton(
                      color: clayContainerColor(context),
                      height: 30,
                      width: 30,
                      borderRadius: 50,
                      spread: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: showAdditionalPhoneNumbers ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (showAdditionalPhoneNumbers) ...additionalMobileNumbersRows(),
              if (showAdditionalPhoneNumbers) addNewMobileNumberRow(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget addNewMobileNumberRow() {
    return Row(
      children: [
        const Expanded(child: Text("")),
        GestureDetector(
          onTap: () {
            setState(() {
              additionalMobileNumbers.add(AdditionalMobile(""));
            });
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            spread: 2,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  Icons.add,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> additionalMobileNumbersRows() {
    return additionalMobileNumbers
        .mapIndexed((index, e) => <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: getTextFieldInputDecoration("Additional Mobile ${index + 1}"),
                      enabled: _isEditMode && (sibling == null || e.controller.text.trim().isEmpty),
                      controller: e.controller,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        additionalMobileNumbers.remove(e);
                      });
                    },
                    child: ClayButton(
                      color: clayContainerColor(context),
                      height: 30,
                      width: 30,
                      borderRadius: 50,
                      spread: 2,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ])
        .expand((i) => i)
        .toList();
  }

  List<Widget> primaryContactDetailsRows() {
    return [
      const SizedBox(height: 10),
      gaurdianPickerRow(),
      const SizedBox(height: 20),
      gaurdianNameRow(),
      const SizedBox(height: 20),
      gaurdianEmailAddressRow(),
      const SizedBox(height: 20),
      gaurdianMobile(),
    ];
  }

  Widget gaurdianPickerRow() {
    return InputDecorator(
      decoration: getTextFieldInputDecoration("Primary Contact"),
      child: isLandscape()
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: fatherRadioButton()),
                Expanded(child: motherRadioButton()),
                Expanded(child: otherRadioButton()),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                fatherRadioButton(),
                motherRadioButton(),
                otherRadioButton(),
              ],
            ),
    );
  }

  bool isLandscape() => (MediaQuery.of(context).orientation == Orientation.landscape);

  Widget otherRadioButton() {
    return RadioListTile<String?>(
      value: "other",
      groupValue: primaryContactType?.toLowerCase(),
      onChanged: !_isEditMode ? null : (String? value) => setState(() => primaryContactType = value),
      title: Text(
        "Other",
        style: TextStyle(fontSize: isLandscape() ? 10 : null),
      ),
    );
  }

  Widget motherRadioButton() {
    return RadioListTile<String?>(
      value: "mother",
      groupValue: primaryContactType?.toLowerCase(),
      onChanged: !_isEditMode
          ? null
          : (String? value) {
              if (value == null) return;
              setState(() {
                primaryContactType = value;
                widget.studentProfile.gaurdianNameController.text = widget.studentProfile.motherNameController.text;
              });
            },
      title: Text(
        "Mother",
        style: TextStyle(fontSize: isLandscape() ? 10 : null),
      ),
    );
  }

  Widget fatherRadioButton() {
    return RadioListTile<String?>(
      value: "father",
      groupValue: primaryContactType?.toLowerCase(),
      onChanged: !_isEditMode
          ? null
          : (String? value) {
              if (value == null) return;
              setState(() {
                primaryContactType = value;
                widget.studentProfile.gaurdianNameController.text = widget.studentProfile.fatherNameController.text;
              });
            },
      title: Text(
        "Father",
        style: TextStyle(fontSize: isLandscape() ? 10 : null),
      ),
    );
  }

  Widget gaurdianNameRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Primary Contact Name"),
      enabled: _isEditMode &&
          (sibling == null || widget.studentProfile.gaurdianNameController.text.trim().isEmpty) &&
          (primaryContactType ?? "other").toLowerCase() == "other",
      controller: widget.studentProfile.gaurdianNameController,
      keyboardType: TextInputType.name,
      textAlign: TextAlign.left,
    );
  }

  Widget gaurdianEmailAddressRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Primary Email Contact"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.emailController.text.trim().isEmpty),
      controller: widget.studentProfile.emailController,
      keyboardType: TextInputType.emailAddress,
      textAlign: TextAlign.left,
    );
  }

  Widget gaurdianMobile() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Primary Mobile Contact"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.phoneController.text.trim().isEmpty),
      controller: widget.studentProfile.phoneController,
      keyboardType: TextInputType.phone,
      textAlign: TextAlign.left,
    );
  }

  List<Widget> motherDetailsRows() {
    return [
      motherNameRow(),
      const SizedBox(height: 20),
      motherOccupationWidget(),
      const SizedBox(height: 20),
      motherAnnualIncomeWidget(),
    ];
  }

  Widget motherAnnualIncomeWidget() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Mother Annual Income"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.motherAnnualIncomeController.text.trim().isEmpty),
      controller: widget.studentProfile.motherAnnualIncomeController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.left,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')) // Allow numbers with up to 2 decimal places
      ],
    );
  }

  Widget motherOccupationWidget() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Mother Occupation"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.motherOccupationController.text.trim().isEmpty),
      controller: widget.studentProfile.motherOccupationController,
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
    );
  }

  Widget motherNameRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Mother Name"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.motherNameController.text.trim().isEmpty),
      controller: widget.studentProfile.motherNameController,
      keyboardType: TextInputType.name,
      textAlign: TextAlign.left,
      onChanged: (String? value) {
        if ((primaryContactType ?? "other").toLowerCase() == "mother") {
          setState(() {
            widget.studentProfile.gaurdianNameController.text = value ?? "";
          });
        }
      },
    );
  }

  List<Widget> fatherDetailsRows() {
    return [
      fatherNameRow(),
      const SizedBox(height: 20),
      fatherOccupationWidget(),
      const SizedBox(height: 20),
      fatherAnnualIncomeWidget(),
    ];
  }

  Widget fatherAnnualIncomeWidget() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Father Annual Income"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.fatherAnnualIncomeController.text.trim().isEmpty),
      controller: widget.studentProfile.fatherAnnualIncomeController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.left,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')) // Allow numbers with up to 2 decimal places
      ],
    );
  }

  Widget fatherOccupationWidget() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Father Occupation"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.fatherOccupationController.text.trim().isEmpty),
      controller: widget.studentProfile.fatherOccupationController,
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
    );
  }

  Widget fatherNameRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Father Name"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.fatherNameController.text.trim().isEmpty),
      controller: widget.studentProfile.fatherNameController,
      keyboardType: TextInputType.name,
      textAlign: TextAlign.left,
      onChanged: (String? value) {
        if ((primaryContactType ?? "other").toLowerCase() == "father") {
          setState(() {
            widget.studentProfile.gaurdianNameController.text = value ?? "";
          });
        }
      },
    );
  }

  Widget selectSiblingWidget() {
    // TODO in read mode, show the list of siblings
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Details of sibling already studying in this School"),
        const SizedBox(height: 30),
        DropdownSearch<StudentProfile>(
          enabled: true,
          mode: !isLandscape() ? Mode.BOTTOM_SHEET : Mode.MENU,
          selectedItem: sibling,
          items: widget.students,
          itemAsString: (StudentProfile? e) {
            return e == null
                ? "-"
                : "${e.rollNumber ?? " - "}. ${e.studentFirstName ?? " - "} [${e.sectionName ?? " - "}] [${e.admissionNo ?? " - "}]";
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, StudentProfile? e) {
            return Text(
                e == null ? "-" : "${e.rollNumber ?? " - "}. ${e.studentFirstName ?? " - "} [${e.sectionName ?? " - "}] [${e.admissionNo ?? " - "}]");
          },
          onChanged: (StudentProfile? selectedSibling) {
            if (_isLoading) return;
            setState(() {
              sibling = selectedSibling;
              widget.studentProfile.fatherNameController.text = selectedSibling?.fatherName?.trim() ?? "";
              widget.studentProfile.fatherOccupationController.text = selectedSibling?.fatherOccupation?.trim() ?? "";
              widget.studentProfile.fatherAnnualIncomeController.text = "${selectedSibling?.fatherAnnualIncome ?? ""}".trim();
              widget.studentProfile.motherNameController.text = selectedSibling?.motherName?.trim() ?? "";
              widget.studentProfile.motherOccupationController.text = selectedSibling?.motherOccupation?.trim() ?? "";
              widget.studentProfile.motherAnnualIncomeController.text = "${selectedSibling?.motherAnnualIncome ?? ""}".trim();
              widget.studentProfile.gaurdianNameController.text = selectedSibling?.gaurdianFirstName?.trim() ?? "";
              widget.studentProfile.emailController.text = selectedSibling?.gaurdianMailId ?? "";
              widget.studentProfile.phoneController.text = selectedSibling?.gaurdianMobile ?? "";
              widget.studentProfile.nationalityController.text = (selectedSibling?.nationality ?? "").trim();
              widget.studentProfile.religionController.text = (selectedSibling?.religion ?? "").trim();
              widget.studentProfile.casteController.text = (selectedSibling?.caste ?? "").trim();
              widget.studentProfile.motherTongueController.text = (selectedSibling?.motherTongue ?? "").trim();
              widget.studentProfile.category = selectedSibling?.category;
              widget.studentProfile.gaurdianId = selectedSibling?.gaurdianId;
            });
          },
          showClearButton: true,
          compareFn: (item, selectedItem) => item?.studentId == selectedItem?.studentId,
          dropdownSearchDecoration: getTextFieldInputDecoration("Select Sibling"),
          filterFn: (StudentProfile? e, String? key) {
            return "${e?.rollNumber ?? " - "}. ${e?.studentFirstName ?? " - "} [${e?.sectionName ?? " - "}] [${e?.admissionNo ?? " - "}]"
                .toLowerCase()
                .replaceAll(" ", "")
                .contains((key ?? "").toLowerCase().trim());
          },
        ),
      ],
    );
  }

  Widget nationalityDetails() {
    /**
     * Aadhaar Number
     * Aadhaar scanned copy
     * Nationality
     * Religion
     * Caste
     * Category
     * Mother Tongue
     */
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          padding: isLandscape() ? const EdgeInsets.all(30) : const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget("Nationality Details"),
              const SizedBox(height: 20),
              aadhaarNumberRow(),
              const SizedBox(height: 20),
              aadhaarScannedCopyRow(),
              const SizedBox(height: 20),
              nationalityRow(),
              const SizedBox(height: 20),
              religionRow(),
              const SizedBox(height: 20),
              casteRow(),
              const SizedBox(height: 20),
              categoryRow(),
              const SizedBox(height: 20),
              motherTongueRow(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget motherTongueRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Mother Tongue"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.motherTongueController.text.trim().isEmpty),
      controller: widget.studentProfile.motherTongueController,
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
    );
  }

  Widget categoryRow() {
    return InputDecorator(
      decoration: getTextFieldInputDecoration("Category"),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: Container(),
        hint: const Center(child: Text("Select Category")),
        value: CASTE_CATEGORIES.where((e) => e == widget.studentProfile.category).firstOrNull,
        onChanged: !_isEditMode
            ? null
            : (String? category) {
                setState(() {
                  widget.studentProfile.category = category;
                });
              },
        items: CASTE_CATEGORIES
            .map(
              (e) => DropdownMenuItem<String>(
                value: e,
                child: SizedBox(
                  width: 75,
                  height: 50,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        e,
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
    );
  }

  Widget casteRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Caste"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.casteController.text.trim().isEmpty),
      controller: widget.studentProfile.casteController,
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
    );
  }

  Widget religionRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Religion"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.religionController.text.trim().isEmpty),
      controller: widget.studentProfile.religionController,
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
    );
  }

  Widget nationalityRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Nationality"),
      enabled: _isEditMode && (sibling == null || widget.studentProfile.nationalityController.text.trim().isEmpty),
      controller: widget.studentProfile.nationalityController,
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
    );
  }

  Widget aadhaarScannedCopyRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Aadhaar Document"),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.studentProfile.aadhaarPhotoUrl != null)
              InkWell(
                onTap: () async {
                  var mediaUri = Uri.parse(widget.studentProfile.aadhaarPhotoUrl!);
                  if (await canLaunchUrl(mediaUri)) {
                    await launchUrl(mediaUri, webOnlyWindowName: "_blank");
                  } else {
                    throw 'Could not launch $mediaUri';
                  }
                },
                child: const Text(
                  "Aadhaar Copy",
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
            if (widget.studentProfile.aadhaarPhotoUrl != null) const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () {
                if (!_isEditMode) return;
                try {
                  FileUploadInputElement uploadInput = FileUploadInputElement();
                  uploadInput.multiple = false;
                  uploadInput.draggable = true;
                  uploadInput.accept = '.png,.jpg,.jpeg,.PNG,.JPG,.JPEG,.pdf';
                  uploadInput.click();
                  uploadInput.onChange.listen(
                    (changeEvent) async {
                      final files = uploadInput.files!;
                      for (File file in files) {
                        final reader = FileReader();
                        reader.readAsDataUrl(file);
                        reader.onLoadEnd.listen(
                          (loadEndEvent) async {
                            debugPrint("File uploaded: " + file.name);
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              UploadFileToDriveResponse uploadFileResponse = await uploadFileToDrive(reader.result!, file.name);
                              setState(() {
                                widget.studentProfile.aadhaarPhotoUrlId = uploadFileResponse.mediaBean!.mediaId!;
                                widget.studentProfile.aadhaarPhotoUrl = uploadFileResponse.mediaBean!.mediaUrl!;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Something went wrong while trying to upload, ${file.name}..\nPlease try again later"),
                                ),
                              );
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                        );
                      }
                    },
                  );
                } catch (e) {
                  const SnackBar(
                    content: Text("Something went wrong..\nPlease try again later"),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget aadhaarNumberRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Aadhaar Number"),
      enabled: _isEditMode,
      controller: widget.studentProfile.aadhaarNumberController,
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
    );
  }

  Widget addressDetails() {
    /**
     * Address for communication
     * Permanent Address
     */
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          padding: isLandscape() ? const EdgeInsets.all(30) : const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget("Address"),
              const SizedBox(height: 20),
              permanentAddressWidget(),
              const SizedBox(height: 20),
              sameAsPermanentAddressToggle(),
              const SizedBox(height: 20),
              addressForCommunicationWidget(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget sameAsPermanentAddressToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
            value: sameAsPermanentAddress,
            onChanged: (bool? value) {
              if (value == null) return;
              setState(() {
                if (value) {
                  widget.studentProfile.addressForCommunicationController.text = widget.studentProfile.permanentAddressController.text;
                }
                sameAsPermanentAddress = !sameAsPermanentAddress;
              });
            }),
        const SizedBox(width: 10),
        const Expanded(child: Text("Same As Permanent Address")),
      ],
    );
  }

  Widget addressForCommunicationWidget() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Address For Communication"),
      maxLines: null,
      minLines: 3,
      enabled: _isEditMode && (sibling == null || widget.studentProfile.addressForCommunicationController.text.trim().isEmpty),
      controller: widget.studentProfile.addressForCommunicationController,
      keyboardType: TextInputType.multiline,
      textAlign: TextAlign.left,
      onChanged: (String? value) {
        if ((value ?? "").trim().isNotEmpty) {
          setState(() {
            widget.studentProfile.permanentAddressController.text = value ?? "";
          });
        }
      },
    );
  }

  Widget permanentAddressWidget() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Permanent Address"),
      maxLines: null,
      minLines: 3,
      enabled: _isEditMode && (sibling == null || widget.studentProfile.permanentAddressController.text.trim().isEmpty),
      controller: widget.studentProfile.permanentAddressController,
      keyboardType: TextInputType.multiline,
      textAlign: TextAlign.left,
    );
  }

  Widget previousSchoolRecordDetails() {
    /**
     * Data Table for PrevSchoolRecord
     */
    List<PreviousSchoolRecord> records = [];
    try {
      final v = jsonDecode(widget.studentProfile.previousSchoolRecords ?? "[]");
      final arr0 = <PreviousSchoolRecord>[];
      v.forEach((v) {
        arr0.add(PreviousSchoolRecord.fromJson(v));
      });
      records = arr0;
    } catch (e) {
      debugPrint("1196: Couldn't parse ${widget.studentProfile.previousSchoolRecords ?? "[]"}\n$e");
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          padding: isLandscape() ? const EdgeInsets.all(30) : const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget("Previous School Records"),
              const SizedBox(height: 20),
              ClayContainer(
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                depth: 40,
                emboss: true,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: SchoolRecordsTable(records, setPreviousSchoolRecords, _isEditMode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setPreviousSchoolRecords(List<PreviousSchoolRecord> previousSchoolRecords) {
    final v = previousSchoolRecords;
    final arr0 = [];
    for (var v in v) {
      arr0.add(v.toJson());
    }
    setState(() => widget.studentProfile.previousSchoolRecords = jsonEncode(arr0));
  }

  Widget identificationMarksDetails() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          padding: isLandscape() ? const EdgeInsets.all(30) : const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget("Student Identification Marks"),
              const SizedBox(height: 20),
              identificationMarksRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget identificationMarksRow() {
    return TextFormField(
      decoration: getTextFieldInputDecoration("Identification Marks"),
      enabled: _isEditMode,
      maxLines: null,
      minLines: 3,
      controller: widget.studentProfile.identificationMarksController,
      keyboardType: TextInputType.multiline,
      textAlign: TextAlign.left,
    );
  }

  Widget studentStatusDetails() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          padding: isLandscape() ? const EdgeInsets.all(30) : const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget("Student Status"),
              const SizedBox(height: 20),
              studentAccommodationTypeRow(),
              const SizedBox(height: 20),
              studentStatusRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget studentAccommodationTypeRow() {
    return InputDecorator(
      decoration: getTextFieldInputDecoration("Primary Contact"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: ["D", "R", "S"]
            .map((e) => RadioListTile<String?>(
                  value: e,
                  groupValue: widget.studentProfile.studentAccommodationType,
                  onChanged: !_isEditMode
                      ? null
                      : (String? value) {
                          if (value == null) return;
                          setState(() {
                            widget.studentProfile.studentAccommodationType = e;
                          });
                        },
                  title: Text(
                    widget.studentProfile.getAccommodationType(e: e),
                    style: const TextStyle(fontSize: 12),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget studentStatusRow() {
    return InputDecorator(
      decoration: getTextFieldInputDecoration("Student Status"),
      child: DropdownButton<StudentStatus>(
        isExpanded: true,
        underline: Container(),
        hint: const Center(child: Text("Select Student Status")),
        value: StudentStatus.values.where((e) => e.name == widget.studentProfile.studentStatus).firstOrNull,
        onChanged: !_isEditMode
            ? null
            : (StudentStatus? status) {
                setState(() {
                  widget.studentProfile.studentStatus = status?.name;
                });
              },
        items: StudentStatus.values
            .map(
              (e) => DropdownMenuItem<StudentStatus>(
                value: e,
                child: Text(
                  e.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget buildStudentWiseAnnualFeeMapCard() {
    var editingStudentId = widget.studentProfile.studentId;
    var studentAnnualFeeBeanK = studentAnnualFeeBean!;
    List<Widget> rows = [];
    rows.add(
      Row(
        children: [
          Expanded(
            child: Text(
              "${studentAnnualFeeBeanK.rollNumber ?? "-"}. ${studentAnnualFeeBeanK.studentName}",
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (editingStudentId != null && editingStudentId == studentAnnualFeeBeanK.studentId)
            Container(
              margin: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () async {
                  await saveFeeChanges();
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
    for (StudentAnnualFeeTypeBean eachStudentAnnualFeeTypeBean in (studentAnnualFeeBeanK.studentAnnualFeeTypeBeans ?? [])) {
      feeStats.add(
        (eachStudentAnnualFeeTypeBean.amount == null || eachStudentAnnualFeeTypeBean.amount == 0) &&
                ((eachStudentAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isEmpty ||
                    ((eachStudentAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).map((e) => e.amount ?? 0).reduce((a, b) => a + b)) == 0) &&
                editingStudentId != studentAnnualFeeBeanK.studentId
            ? Container()
            : Row(
                children: [
                  Expanded(
                    child: Text(eachStudentAnnualFeeTypeBean.feeType ?? "-"),
                  ),
                  (editingStudentId != null && editingStudentId == studentAnnualFeeBeanK.studentId)
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
                                    eachStudentAnnualFeeTypeBean.amount = (double.parse(e) * 100).round();
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
        if ((editingStudentId != studentAnnualFeeBeanK.studentId) && (eachStudentAnnualCustomFeeTypeBean.amount ?? 0) == 0) {
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
              (editingStudentId != null && editingStudentId == studentAnnualFeeBeanK.studentId)
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

    if (studentAnnualFeeBeanK.studentBusFeeBean != null &&
        (studentAnnualFeeBeanK.studentBusFeeBean?.fare ?? 0) != 0 &&
        (editingStudentId != studentAnnualFeeBeanK.studentId)) {
      feeStats.add(Row(
        children: [
          const Expanded(child: Text("Bus Fee")),
          const SizedBox(
            width: 10,
          ),
          Text(
            studentAnnualFeeBeanK.studentBusFeeBean?.fare == null
                ? "-"
                : INR_SYMBOL + " " + doubleToStringAsFixedForINR(studentAnnualFeeBeanK.studentBusFeeBean!.fare! / 100),
          ),
        ],
      ));
      feeStats.add(
        const SizedBox(
          height: 15,
        ),
      );
    } else if (editingStudentId != null && editingStudentId == studentAnnualFeeBeanK.studentId) {
      feeStats.add(
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            const Expanded(
              child: Text("Bus Fee"),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: studentAnnualFeeBeanK.studentBusFeeBean!.fareController,
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
    if (studentAnnualFeeBeanK.discount > 0) {
      feeStats.add(
        Row(
          children: [
            const Expanded(
              child: Text("Discount:"),
            ),
            Text(
              "$INR_SYMBOL ${doubleToStringAsFixedForINR(studentAnnualFeeBeanK.discount / 100)}",
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
            studentAnnualFeeBeanK.totalFee == null ? "-" : "$INR_SYMBOL ${doubleToStringAsFixedForINR((studentAnnualFeeBeanK.totalFee ?? 0) / 100)}",
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
            studentAnnualFeeBeanK.totalFeePaid == null
                ? "-"
                : "$INR_SYMBOL ${doubleToStringAsFixedForINR((studentAnnualFeeBeanK.totalFeePaid ?? 0) / 100)}",
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
            "$INR_SYMBOL ${doubleToStringAsFixedForINR(((studentAnnualFeeBeanK.totalFee ?? 0) - (studentAnnualFeeBeanK.totalFeePaid ?? 0) - (studentAnnualFeeBeanK.walletBalance ?? 0)) / 100)}",
            textAlign: TextAlign.end,
            style: TextStyle(
              color:
                  ((studentAnnualFeeBeanK.totalFee ?? 0) - (studentAnnualFeeBeanK.totalFeePaid ?? 0) - (studentAnnualFeeBeanK.walletBalance ?? 0)) ==
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
                                  ((await getStudentProfile(GetStudentProfileRequest(studentId: studentAnnualFeeBeanK.studentId))).studentProfiles ??
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
                                        studentAnnualFeeBean: studentAnnualFeeBeanK,
                                        adminProfile: widget.adminProfile!,
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
}

class AdditionalMobile {
  String? mobile;
  TextEditingController controller = TextEditingController();

  AdditionalMobile(this.mobile) {
    controller.text = mobile ?? "";
  }
}

class PreviousSchoolRecord {
  String? schoolName;
  String? yearsOfStudy;
  String? classPassed;

  PreviousSchoolRecord(this.schoolName, this.yearsOfStudy, this.classPassed);

  PreviousSchoolRecord.fromString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    schoolName = json['School Name'];
    yearsOfStudy = json['Years Of Study'];
    classPassed = json['Class Passed'];
  }

  PreviousSchoolRecord.fromJson(Map<String, dynamic> json) {
    schoolName = json['School Name'];
    yearsOfStudy = json['Years Of Study'];
    classPassed = json['Class Passed'];
  }

  Map<String, dynamic> toJson() {
    return {
      'School Name': schoolName,
      'Years Of Study': yearsOfStudy,
      'Class Passed': classPassed,
    };
  }
}

class SchoolRecordsTable extends StatefulWidget {
  const SchoolRecordsTable(this.records, this.setPreviousSchoolRecords, this.isEditMode, {super.key});

  final List<PreviousSchoolRecord> records;
  final Function setPreviousSchoolRecords;
  final bool isEditMode;

  @override
  _SchoolRecordsTableState createState() => _SchoolRecordsTableState();
}

class _SchoolRecordsTableState extends State<SchoolRecordsTable> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void addRecord() {
    setState(() {
      widget.records.add(PreviousSchoolRecord('', '', ''));
    });
    widget.setPreviousSchoolRecords(widget.records);
  }

  void deleteRecord(int index) {
    setState(() {
      widget.records.removeAt(index);
    });
    widget.setPreviousSchoolRecords(widget.records);
  }

  void updateRecord(int index, PreviousSchoolRecord record) {
    setState(() {
      widget.records[index] = record;
    });
    widget.setPreviousSchoolRecords(widget.records);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Scrollbar(
          thumbVisibility: true,
          controller: _controller,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _controller,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('School Name')),
                  const DataColumn(label: Text('Years of Study')),
                  const DataColumn(label: Text('Class Passed')),
                  if (widget.isEditMode) const DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (int index = 0; index < widget.records.length; index++)
                    DataRow(
                      onSelectChanged: null,
                      cells: [
                        DataCell(
                          TextFormField(
                            enabled: widget.isEditMode,
                            initialValue: widget.records[index].schoolName,
                            onChanged: (value) => widget.records[index].schoolName = value,
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            enabled: widget.isEditMode,
                            initialValue: widget.records[index].yearsOfStudy,
                            onChanged: (value) => widget.records[index].yearsOfStudy = value,
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            enabled: widget.isEditMode,
                            initialValue: widget.records[index].classPassed,
                            onChanged: (value) => widget.records[index].classPassed = value,
                          ),
                        ),
                        if (widget.isEditMode)
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteRecord(index),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (widget.isEditMode)
          GestureDetector(
            onTap: addRecord,
            child: ClayButton(
              color: clayContainerColor(context),
              width: 150,
              borderRadius: 10,
              spread: 2,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Add Entry',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
