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
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class StudentCardWidgetV2 extends StatefulWidget {
  const StudentCardWidgetV2({
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
  State<StudentCardWidgetV2> createState() => _StudentCardWidgetV2State();
}

class _StudentCardWidgetV2State extends State<StudentCardWidgetV2> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  bool _isOtherLoading = true;
  bool _isEditMode = false;

  final ScrollController _controller = ScrollController();

  bool isBasicDetailsExpanded = true;
  bool isParentDetailsExpanded = false;
  bool isNationalityDetailsExpanded = false;
  bool isAddressDetailsExpanded = false;
  bool isPreviousSchoolRecordDetailsExpanded = false;
  bool isCustomDetailsExpanded = false;
  bool isAdditionalMobileDetailsExpanded = false;

  StudentProfile? sibling;

  List<AdditionalMobile> additionalMobileNumbers = [AdditionalMobile("")];

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
        title: const Text("Student Profile"),
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
          if (!_showFeeDetails && _isEditMode)
            IconButton(
              onPressed: () async {
                setState(() {
                  widget.studentProfile.fromControllers();
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
              icon: const Icon(Icons.check),
            ),
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
                  absorbing: _isOtherLoading,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: ListView(
                          children: [
                            Scrollbar(
                              thumbVisibility: true,
                              controller: _controller,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _controller,
                                child: Container(
                                  margin: MediaQuery.of(context).orientation == Orientation.landscape
                                      ? const EdgeInsets.fromLTRB(50, 8, 50, 8)
                                      : const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      basicDetails(),
                                      const SizedBox(height: 10),
                                      Divider(
                                        thickness: 2,
                                        color: clayContainerTextColor(context),
                                      ),
                                      const SizedBox(height: 10),
                                      parentDetails(),
                                      const SizedBox(height: 10),
                                      nationalityDetails(),
                                      const SizedBox(height: 10),
                                      addressDetails(),
                                      const SizedBox(height: 10),
                                      previousSchoolRecordDetails(),
                                      const SizedBox(height: 10),
                                      identificationMarksDetails(),
                                      const SizedBox(height: 10),
                                      studentStatusDetails(),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isOtherLoading)
                        const EpsilonDiaryLoadingWidget(),
                    ],
                  ),
                ),
    );
  }

  Widget detailHeaderWidget(String headerText) {
    return SizedBox(
      width: 200,
      child: Text(
        headerText,
        overflow: TextOverflow.clip,
        maxLines: 2,
      ),
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
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Student Details"),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    admissionNumberRow(),
                    const SizedBox(height: 10),
                    rollNumberRow(),
                    const SizedBox(height: 10),
                    sectionRow(),
                  ],
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width >= 600 ? MediaQuery.of(context).size.width - 600 : 10),
              studentPhotoWidget(),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 10),
          studentNameRow(),
          const SizedBox(height: 10),
          studentSexRow(),
          const SizedBox(height: 10),
          studentDobRow(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Row studentDobRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Date of birth"),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: clayContainerTextColor(context)),
            ),
          ),
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
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Row studentSexRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Sex"),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: RadioListTile<String?>(
            value: "male",
            groupValue: widget.studentProfile.sex,
            onChanged: !_isEditMode ? null : (String? value) {
              setState(() {
                widget.studentProfile.sex = value;
              });
            },
            title: const SizedBox(
              width: 80,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text("Male"),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: RadioListTile<String?>(
            value: "female",
            groupValue: widget.studentProfile.sex,
            onChanged: !_isEditMode ? null : (String? value) {
              setState(() {
                widget.studentProfile.sex = value;
              });
            },
            title: const SizedBox(
              width: 80,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text("Female"),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Row studentNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Student Name"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode,
            controller: widget.studentProfile.studentNameController,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Container studentPhotoWidget() {
    return Container(
      height: 100,
      width: 80,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
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
            ? const FittedBox(fit: BoxFit.scaleDown, child: Text("Student\nPhoto"))
            : Image.network(
                widget.studentProfile.studentPhotoUrl!,
                fit: BoxFit.scaleDown,
              ),
      ),
    );
  }

  Row sectionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Section"),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: DropdownButton<Section>(
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
                      child: SizedBox(
                        width: 75,
                        height: 50,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              e.sectionName ?? "-",
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
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Row rollNumberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Roll No."),
        const SizedBox(width: 10),
        SizedBox(
          width: 75,
          child: TextFormField(
            enabled: _isEditMode,
            controller: widget.studentProfile.rollNumberController,
            keyboardType: const TextInputType.numberWithOptions(),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Row admissionNumberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Admission No."),
        const SizedBox(width: 10),
        SizedBox(
          width: 75,
          child: TextFormField(
            enabled: _isEditMode,
            controller: widget.studentProfile.admissionNoController,
            keyboardType: const TextInputType.numberWithOptions(),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
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
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Parent Details"),
          const SizedBox(height: 20),
          if (_isEditMode)
            selectSiblingWidget(),
          if (_isEditMode)
            const SizedBox(height: 10),
          ...fatherDetailsRows(),
          const SizedBox(height: 10),
          ...motherDetailsRows(),
          const SizedBox(height: 10),
          ...gaurdianDetailsRows(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              detailHeaderWidget("Additional Mobiles"),
              const SizedBox(width: 10),
              Column(
                children: [
                  ...additionalMobileNumbersRows(),
                  const SizedBox(height: 10),
                  addNewMobileNumberRow(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget addNewMobileNumberRow() {
    return Row(
      children: [
        const SizedBox(width: 110),
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
        .map((e) => <Widget>[
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextFormField(
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
              const SizedBox(height: 10),
            ])
        .expand((i) => i)
        .toList();
  }

  List<Widget> gaurdianDetailsRows() {
    return [
      const SizedBox(height: 10),
      gaurdianNameRow(),
      const SizedBox(height: 10),
      gaurdianEmailAddressRow(),
      const SizedBox(height: 10),
      gaurdianMobile(),
      const SizedBox(height: 10),
    ];
  }

  Widget gaurdianNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Guardian Name"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.gaurdianNameController.text.trim().isEmpty),
            controller: widget.studentProfile.gaurdianNameController,
            keyboardType: TextInputType.name,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget gaurdianEmailAddressRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Guardian Email"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.emailController.text.trim().isEmpty),
            controller: widget.studentProfile.emailController,
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget gaurdianMobile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Guardian Mobile"),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.phoneController.text.trim().isEmpty),
            controller: widget.studentProfile.phoneController,
            keyboardType: TextInputType.phone,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  List<Widget> motherDetailsRows() {
    return [
      const SizedBox(height: 10),
      motherNameRow(),
      const SizedBox(height: 10),
      motherOccupationWidget(),
      const SizedBox(height: 10),
      motherAnnualIncomeWidget(),
      const SizedBox(height: 10),
    ];
  }

  Widget motherAnnualIncomeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Mother Annual Income"),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.motherAnnualIncomeController.text.trim().isEmpty),
            controller: widget.studentProfile.motherAnnualIncomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.left,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')) // Allow numbers with up to 2 decimal places
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget motherOccupationWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Mother Occupation"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.motherOccupationController.text.trim().isEmpty),
            controller: widget.studentProfile.motherOccupationController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget motherNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Mother Name"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.motherNameController.text.trim().isEmpty),
            controller: widget.studentProfile.motherNameController,
            keyboardType: TextInputType.name,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  List<Widget> fatherDetailsRows() {
    return [
      const SizedBox(height: 10),
      fatherNameRow(),
      const SizedBox(height: 10),
      fatherOccupationWidget(),
      const SizedBox(height: 10),
      fatherAnnualIncomeWidget(),
      const SizedBox(height: 10),
    ];
  }

  Widget fatherAnnualIncomeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Father Annual Income"),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.fatherAnnualIncomeController.text.trim().isEmpty),
            controller: widget.studentProfile.fatherAnnualIncomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.left,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')) // Allow numbers with up to 2 decimal places
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget fatherOccupationWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Father Occupation"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.fatherOccupationController.text.trim().isEmpty),
            controller: widget.studentProfile.fatherOccupationController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget fatherNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Father Name"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.fatherNameController.text.trim().isEmpty),
            controller: widget.studentProfile.fatherNameController,
            keyboardType: TextInputType.name,
            textAlign: TextAlign.left,
            onChanged: (String? value) {
              if (widget.studentProfile.gaurdianNameController.text.trim().isNotEmpty) {
                setState(() {
                  widget.studentProfile.gaurdianNameController.text = value ?? "";
                });
              }
            },
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget selectSiblingWidget() {
    // TODO in read mode, show the list of siblings
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: const [
            SizedBox(width: 10),
            Text("Details of sibling already studying in this School"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            SizedBox(
              width: 300,
              child: DropdownSearch<StudentProfile>(
                enabled: true,
                mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
                selectedItem: sibling,
                items: widget.students,
                itemAsString: (StudentProfile? e) {
                  return e == null
                      ? "-"
                      : "${e.rollNumber ?? " - "}. ${e.studentFirstName ?? " - "} [${e.sectionName ?? " - "}] [${e.admissionNo ?? " - "}]";
                },
                showSearchBox: true,
                dropdownBuilder: (BuildContext context, StudentProfile? e) {
                  return Text(e == null
                      ? "-"
                      : "${e.rollNumber ?? " - "}. ${e.studentFirstName ?? " - "} [${e.sectionName ?? " - "}] [${e.admissionNo ?? " - "}]");
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
                dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
                filterFn: (StudentProfile? e, String? key) {
                  return "${e?.rollNumber ?? " - "}. ${e?.studentFirstName ?? " - "} [${e?.sectionName ?? " - "}] [${e?.admissionNo ?? " - "}]"
                      .toLowerCase()
                      .replaceAll(" ", "")
                      .contains((key ?? "").toLowerCase().trim());
                },
              ),
            ),
            const SizedBox(width: 10),
          ],
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
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Nationality Details"),
          const SizedBox(height: 20),
          aadhaarNumberRow(),
          const SizedBox(height: 10),
          aadhaarScannedCopyRow(),
          const SizedBox(height: 10),
          nationalityRow(),
          const SizedBox(height: 10),
          religionRow(),
          const SizedBox(height: 10),
          casteRow(),
          const SizedBox(height: 10),
          categoryRow(),
          const SizedBox(height: 10),
          motherTongueRow(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget motherTongueRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Mother Tongue"),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.motherTongueController.text.trim().isEmpty),
            controller: widget.studentProfile.motherTongueController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget categoryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Category"),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: DropdownButton<String>(
              hint: const Center(child: Text("Select Category")),
              value: CASTE_CATEGORIES.where((e) => e == widget.studentProfile.category).firstOrNull,
              onChanged: !_isEditMode ? null : (String? category) {
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
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget casteRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Caste"),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.casteController.text.trim().isEmpty),
            controller: widget.studentProfile.casteController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget religionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Religion"),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.religionController.text.trim().isEmpty),
            controller: widget.studentProfile.religionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget nationalityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Nationality"),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.nationalityController.text.trim().isEmpty),
            controller: widget.studentProfile.nationalityController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
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
                              print("1276: ${uploadFileResponse.mediaBean?.mediaId}");
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Aadhaar Number"),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            enabled: _isEditMode,
            controller: widget.studentProfile.aadhaarNumberController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget addressDetails() {
    /**
     * Address for communication
     * Permanent Address
     */
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Address"),
          const SizedBox(height: 20),
          addressForCommunicationWidget(),
          const SizedBox(height: 10),
          permanentAddressWidget(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget addressForCommunicationWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Address For Communication"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
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
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget permanentAddressWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Permanent Address"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            maxLines: null,
            minLines: 3,
            enabled: _isEditMode && (sibling == null || widget.studentProfile.permanentAddressController.text.trim().isEmpty),
            controller: widget.studentProfile.permanentAddressController,
            keyboardType: TextInputType.multiline,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
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
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Previous School Records"),
          const SizedBox(height: 20),
          SchoolRecordsTable(records, setPreviousSchoolRecords, _isEditMode),
        ],
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
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
    );
  }

  Widget identificationMarksRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Identification Marks"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode,
            maxLines: null,
            minLines: 3,
            controller: widget.studentProfile.identificationMarksController,
            keyboardType: TextInputType.multiline,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget studentStatusDetails() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Student Status"),
          const SizedBox(height: 20),
          studentStatusRow(),
        ],
      ),
    );
  }

  Widget studentStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Student Status"),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: DropdownButton<StudentStatus>(
              hint: const Center(child: Text("Select Category")),
              value: StudentStatus.values.where((e) => e.name == widget.studentProfile.studentStatus).firstOrNull,
              onChanged: !_isEditMode ? null : (StudentStatus? status) {
                setState(() {
                  widget.studentProfile.studentStatus = status?.name;
                });
              },
              items: StudentStatus.values
                  .map(
                    (e) => DropdownMenuItem<StudentStatus>(
                  value: e,
                  child: SizedBox(
                    width: 75,
                    height: 50,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          e.description,
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
        ),
        const SizedBox(width: 10),
      ],
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
        const SizedBox(height: 10),
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
