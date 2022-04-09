import 'package:clay_containers/widgets/clay_container.dart';
// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_pay_fee_screen.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

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
            (feeTypesForSelectedSection.last.customFeeTypesList ?? []).where((e) => e != null).map((e) => e!).forEach((eachCustomFeeType) {
              if (!sectionWiseAnnualFeeBeansList
                  .where((e) => e.sectionId == selectedSection!.sectionId)
                  .toList()
                  .map((e) => e.customFeeTypeId)
                  .contains(eachCustomFeeType.customFeeTypeId)) {
                (feeTypesForSelectedSection.last.customFeeTypesList ?? []).remove(eachCustomFeeType);
              }
            });
          }
        }
      }
    });
    GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = await getStudentWiseAnnualFees(GetStudentWiseAnnualFeesRequest(
      schoolId: widget.adminProfile.schoolId,
      sectionId: selectedSection!.sectionId,
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
      generateStudentMap();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void generateStudentMap() {
    setState(() {
      studentAnnualFeeBeans = [];
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
          ),
        );
      }
    });
  }

  Future<void> _saveChanges(int studentId) async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Fee Management'),
          content: const Text("Are you sure to save changes?\n"
              "These changes will effect the student fees (if already paid, difference amount would be added to the student wallet balance)"),
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

  @override
  Widget build(BuildContext context) {
    int perRowCount = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 1;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Fee Management"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : ListView(
              children: [
                _sectionPicker(),
                for (int i = 0; i < studentAnnualFeeBeans.length / perRowCount; i = i + 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int j = 0; j < perRowCount; j++)
                        Expanded(
                          child: ((i * perRowCount + j) >= studentAnnualFeeBeans.length)
                              ? Container()
                              : buildStudentWiseAnnualFeeMapCard(studentAnnualFeeBeans[(i * perRowCount + j)]),
                        ),
                    ],
                  ),
              ],
            ),
    );
  }

  Widget buildStudentWiseAnnualFeeMapCard(StudentAnnualFeeBean studentWiseAnnualFeesBean) {
    List<Widget> rows = [];
    rows.add(
      Row(
        children: [
          Expanded(
            child: Text(
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
                  setState(() {
                    editingStudentId = studentWiseAnnualFeesBean.studentId;
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
        Row(
          children: [
            Expanded(
              child: Text(eachStudentAnnualFeeTypeBean.feeType ?? "-"),
            ),
            eachStudentAnnualFeeTypeBean.amount == null
                ? Container()
                : (editingStudentId != null && editingStudentId == studentWiseAnnualFeesBean.studentId)
                    ? SizedBox(
                        width: 60,
                        child: TextField(
                          controller: eachStudentAnnualFeeTypeBean.amountController,
                          keyboardType: TextInputType.text,
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
                              } catch (e) {}
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
                        : Text("$INR_SYMBOL ${(eachStudentAnnualFeeTypeBean.amount! / 100).toStringAsFixed(2)}"),
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
              eachStudentAnnualCustomFeeTypeBean.amount == null
                  ? Container()
                  : (editingStudentId != null && editingStudentId == studentWiseAnnualFeesBean.studentId)
                      ? SizedBox(
                          width: 60,
                          child: TextField(
                            controller: eachStudentAnnualCustomFeeTypeBean.amountController,
                            keyboardType: TextInputType.text,
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
                                } catch (e) {}
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
                          : Text("$INR_SYMBOL ${(eachStudentAnnualCustomFeeTypeBean.amount! / 100).toStringAsFixed(2)}"),
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

    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text("Total:"),
          ),
          Text(
            studentWiseAnnualFeesBean.totalFee == null ? "-" : "$INR_SYMBOL ${((studentWiseAnnualFeesBean.totalFee ?? 0) / 100).toStringAsFixed(2)}",
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
                : "$INR_SYMBOL ${((studentWiseAnnualFeesBean.totalFeePaid ?? 0) / 100).toStringAsFixed(2)}",
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text(
              "Wallet Balance:",
            ),
          ),
          Text(
            "$INR_SYMBOL ${((studentWiseAnnualFeesBean.walletBalance ?? 0) / 100).toStringAsFixed(2)}",
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text(
              "Fee to be paid:",
            ),
          ),
          Text(
            "$INR_SYMBOL ${(((studentWiseAnnualFeesBean.totalFee ?? 0) - (studentWiseAnnualFeesBean.totalFeePaid ?? 0) - (studentWiseAnnualFeesBean.walletBalance ?? 0)) / 100).toStringAsFixed(2)}",
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
                            onTap: () {
                              // TODO Go to receipt page
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
                      ),
                      Expanded(
                        child: ((studentWiseAnnualFeesBean.totalFee ?? 0) -
                                    (studentWiseAnnualFeesBean.totalFeePaid ?? 0) -
                                    (studentWiseAnnualFeesBean.walletBalance ?? 0)) ==
                                0
                            ? const Text("")
                            : Container(
                                margin: const EdgeInsets.all(8),
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO Go to pay fee page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AdminPayFeeScreen(
                                            studentWiseAnnualFeesBean: studentWiseAnnualFeesBean,
                                            adminProfile: widget.adminProfile,
                                          );
                                        },
                                      ),
                                    );
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
                                          "Pay Fee",
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  )
                ],
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
      child: ClayButton(
        depth: 40,
        spread: selectedSection != null && selectedSection!.sectionId == section.sectionId ? 0 : 2,
        surfaceColor: selectedSection != null && selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          child: InkWell(
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
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  section.sectionName!,
                ),
              ),
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
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 125,
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

class StudentAnnualFeeBean {
  int? studentId;
  String? studentName;
  String? rollNumber;
  List<StudentAnnualFeeTypeBean>? studentAnnualFeeTypeBeans;
  int? totalFee;
  int? totalFeePaid;
  int? walletBalance;
  int? sectionId;
  String? sectionName;

  StudentAnnualFeeBean({
    this.studentId,
    this.studentName,
    this.rollNumber,
    this.studentAnnualFeeTypeBeans,
    this.totalFee,
    this.totalFeePaid,
    this.walletBalance,
    this.sectionId,
    this.sectionName,
  });

  @override
  String toString() {
    return "\n{\n\t'studentId': $studentId, \n\t'studentName': $studentName, \n\t'rollNumber': $rollNumber, \n\t'studentAnnualFeeTypeBeans': $studentAnnualFeeTypeBeans, \n\t'totalFee': $totalFee, \n\t'totalFeePaid': $totalFeePaid\n\t'walletBalance': $walletBalance}";
  }
}

class StudentAnnualFeeTypeBean {
  int? feeTypeId;
  String? feeType;
  int? amount;
  int? amountPaid;
  int? studentFeeMapId;
  int? sectionFeeMapId;
  List<StudentAnnualCustomFeeTypeBean>? studentAnnualCustomFeeTypeBeans;

  TextEditingController amountController = TextEditingController();

  StudentAnnualFeeTypeBean({
    this.feeTypeId,
    this.feeType,
    this.amount,
    this.amountPaid,
    this.studentFeeMapId,
    this.sectionFeeMapId,
    this.studentAnnualCustomFeeTypeBeans,
  }) {
    amountController.text = amount == null ? "" : "${amount! / 100}";
  }

  @override
  String toString() {
    return "\n{\n\t'feeTypeId': $feeTypeId, \n\t'feeType': $feeType, \n\t'amount': $amount, \n\t'amountPaid': $amountPaid, \n\t'studentFeeMapId': $studentFeeMapId, \n\t'studentAnnualCustomFeeTypeBeans': $studentAnnualCustomFeeTypeBeans \n}";
  }
}

class StudentAnnualCustomFeeTypeBean {
  int? customFeeTypeId;
  String? customFeeType;
  int? amount;
  int? amountPaid;
  int? sectionFeeMapId;
  int? studentFeeMapId;

  TextEditingController amountController = TextEditingController();

  StudentAnnualCustomFeeTypeBean({
    this.customFeeTypeId,
    this.customFeeType,
    this.amount,
    this.amountPaid,
    this.sectionFeeMapId,
    this.studentFeeMapId,
  }) {
    amountController.text = amount == null ? "" : "${amount! / 100}";
  }

  @override
  String toString() {
    return "\n{\n\t'customFeeTypeId': $customFeeTypeId, \n\t'customFeeType': $customFeeType, \n\t'amount': $amount, \n\t'amountPaid': $amountPaid, \n\t'studentFeeMapId': $studentFeeMapId \n}";
  }
}
