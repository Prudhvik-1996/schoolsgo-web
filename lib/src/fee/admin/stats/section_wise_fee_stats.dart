import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class SectionWiseFeeStats extends StatefulWidget {
  const SectionWiseFeeStats({
    Key? key,
    required this.adminProfile,
    required this.studentFeeReceipts,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<StudentFeeReceipt> studentFeeReceipts;

  @override
  State<SectionWiseFeeStats> createState() => _SectionWiseFeeStatsState();
}

class _SectionWiseFeeStatsState extends State<SectionWiseFeeStats> {
  bool _isLoading = true;
  List<Section> sections = [];
  List<StudentProfile> studentProfiles = [];
  List<StudentAnnualFeeBean> studentAnnualFeeBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sections = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
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
      studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
    }
    await generateStudentMap();
    setState(() => _isLoading = false);
  }

  Future<void> generateStudentMap() async {
    List<FeeType> feeTypes = [];
    List<StudentWiseAnnualFeesBean> studentWiseAnnualFeesBeans = [];
    List<SectionWiseAnnualFeesBean> sectionWiseAnnualFeeBeansList = [];
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
    GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = await getStudentWiseAnnualFees(GetStudentWiseAnnualFeesRequest(
      schoolId: widget.adminProfile.schoolId,
      // studentId: 101,
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
    }
    studentAnnualFeeBeans = [];
    studentWiseAnnualFeesBeans.sort((a, b) => ((int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))));
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
          studentAnnualFeeTypeBeans: feeTypes
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
        )..computeDiscount(sectionWiseAnnualFeeBeansList),
      );
    }
    studentAnnualFeeBeans = studentAnnualFeeBeans.where((e) => e.status != "inactive").toList();
    studentAnnualFeeBeans.sort(
      (a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Section wise Fee Stats"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: widget.studentFeeReceipts.isEmpty
          ? const Center(child: Text("No transactions to display"))
          : _isLoading
              ? Center(
                  child: Image.asset(
                    'assets/images/eis_loader.gif',
                    height: 500,
                    width: 500,
                  ),
                )
              : ListView.builder(
        itemCount: sections.length,
        itemBuilder: (context, index) {
          Section section = sections[index];
          List<StudentProfile> sectionStudentProfiles = studentProfiles.where((studentProfile) => studentProfile.sectionId == section.sectionId).toList();
          List<StudentAnnualFeeBean> sectionAnnualFeeBeans = studentAnnualFeeBeans
              .where((feeBean) => sectionStudentProfiles.any((profile) => profile.studentId == feeBean.studentId))
              .toList();
          int actualTotalFee = sectionAnnualFeeBeans.map((e) => e.totalFee ?? 0).sum;
          int totalFeesPaid = sectionAnnualFeeBeans.map((e) => e.totalFeePaid ?? 0).sum;
          int totalFeesPending = actualTotalFee - totalFeesPaid;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: ClayButton(
              depth: 40,
              color: clayContainerColor(context),
              spread: 2,
              borderRadius: 10,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  title: Text(
                    section.sectionName ?? '-',
                    style: GoogleFonts.archivoBlack(
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Expanded(
                            child: Text("Total Fee"),
                          ),
                          Text(
                            "$INR_SYMBOL ${doubleToStringAsFixedForINR(actualTotalFee / 100)}",
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Expanded(
                            child: Text("Fee Paid"),
                          ),
                          Text(
                            "$INR_SYMBOL ${doubleToStringAsFixedForINR(totalFeesPaid / 100)}",
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Expanded(
                            child: Text("Fee to be collected"),
                          ),
                          Text(
                            "$INR_SYMBOL ${doubleToStringAsFixedForINR(totalFeesPending / 100)}",
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 30, // Adjust this value as needed
                          columns: const [
                            DataColumn(label: Text('Student Name')),
                            DataColumn(label: Text('Total Fee')),
                            DataColumn(label: Text('Fee Paid')),
                            DataColumn(label: Text('Discount')),
                            DataColumn(label: Text('Fee Pending')),
                          ],
                          rows: sectionAnnualFeeBeans.map((feeBean) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    "${feeBean.rollNumber ?? ''}${feeBean.rollNumber != null ? '. ' : ''}${feeBean.studentName ?? ''}",
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    feeBean.totalFee == null
                                        ? "-"
                                        : "$INR_SYMBOL ${doubleToStringAsFixedForINR((feeBean.totalFee ?? 0) / 100)}",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    feeBean.totalFeePaid == null
                                        ? "-"
                                        : "$INR_SYMBOL ${doubleToStringAsFixedForINR((feeBean.totalFeePaid ?? 0) / 100)}",
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    feeBean.totalFeePaid == null
                                        ? "-"
                                        : "$INR_SYMBOL ${doubleToStringAsFixedForINR((feeBean.discount ?? 0) / 100)}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    feeBean.totalFee == null
                                        ? "-"
                                        : "$INR_SYMBOL ${doubleToStringAsFixedForINR(((feeBean.totalFee ?? 0) - (feeBean.totalFeePaid ?? 0)) / 100)}",
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
