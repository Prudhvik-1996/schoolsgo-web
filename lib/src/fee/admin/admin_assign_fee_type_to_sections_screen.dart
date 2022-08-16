import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_manage_fee_types_screen.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminAssignFeeTypesToSectionsScreen extends StatefulWidget {
  const AdminAssignFeeTypesToSectionsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _AdminAssignFeeTypesToSectionsScreenState createState() => _AdminAssignFeeTypesToSectionsScreenState();
}

class _AdminAssignFeeTypesToSectionsScreenState extends State<AdminAssignFeeTypesToSectionsScreen> {
  bool _isLoading = true;

  List<FeeType> _feeTypes = [];
  List<SectionWiseAnnualFeesBean> sectionWiseAnnualFeeBeansList = [];
  List<Section> _sectionsList = [];
  Map<Section, SectionWiseAnnualFeeMapBean> actualSectionWiseAnnualFeeBeanMap = {};
  Section? toBeEdited;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      toBeEdited = null;
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
        _feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
        for (var feeType in _feeTypes) {
          setState(() {
            feeType.customFeeTypesList ??= [];
            feeType.customFeeTypesList!.add(CustomFeeType(
              schoolId: feeType.schoolId,
              feeType: feeType.feeType,
              feeTypeId: feeType.feeTypeId,
            ));
          });
        }
      });
    }

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

    for (Section eachSection in _sectionsList) {
      loadSectionWiseAnnualFeeMap(eachSection);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void loadSectionWiseAnnualFeeMap(Section eachSection) {
    setState(() {
      actualSectionWiseAnnualFeeBeanMap[eachSection] = SectionWiseAnnualFeeMapBean(
        schoolId: eachSection.schoolId,
        schoolDisplayName: widget.adminProfile.schoolName,
        sectionId: eachSection.sectionId,
        sectionName: eachSection.sectionName,
        feeTypes: _feeTypes.map((FeeType eachFeeType) {
          SectionWiseAnnualFeesBean? forFeeType = sectionWiseAnnualFeeBeansList
              .where((eachFeeBean) =>
                  eachFeeBean.sectionId == eachSection.sectionId &&
                  eachFeeBean.feeTypeId == eachFeeType.feeTypeId &&
                  eachFeeBean.customFeeTypeId == null)
              .firstOrNull;
          return SectionWiseAnnualFeeTypeBean(
            feeTypeId: eachFeeType.feeTypeId,
            feeType: eachFeeType.feeType,
            amount: forFeeType?.amount,
            sectionFeeMapId: forFeeType?.sectionFeeMapId,
            sectionWiseFeesStatus: forFeeType?.sectionWiseFeesStatus,
            sectionWiseAnnualCustomFeeTypeBeans: (eachFeeType.customFeeTypesList ?? [])
                .where((e) => e != null)
                .map((e) => e!)
                .map((CustomFeeType eachCustomFeeType) {
                  SectionWiseAnnualFeesBean? forCustomFeeType = sectionWiseAnnualFeeBeansList
                      .where((eachFeeBean) =>
                          eachFeeBean.sectionId == eachSection.sectionId &&
                          eachFeeBean.feeTypeId == eachFeeType.feeTypeId &&
                          eachFeeBean.customFeeTypeId != null &&
                          eachFeeBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                      .firstOrNull;
                  if (eachCustomFeeType.customFeeTypeId == null) return null;
                  return SectionWiseAnnualCustomFeeTypeBean(
                    sectionFeeMapId: forCustomFeeType?.sectionFeeMapId,
                    feeType: eachFeeType.feeType,
                    feeTypeId: eachFeeType.feeTypeId,
                    sectionWiseFeesStatus: forCustomFeeType?.sectionWiseFeesStatus,
                    amount: forCustomFeeType?.amount,
                    customFeeType: eachCustomFeeType.customFeeType,
                    customFeeTypeId: eachCustomFeeType.customFeeTypeId,
                  );
                })
                .where((e) => e != null)
                .map((e) => e!)
                .toList(),
          );
        }).toList(),
      );
    });
  }

  Future<void> _saveChanges(Section section) async {
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
                CreateOrUpdateSectionFeeMapRequest createOrUpdateSectionFeeMapRequest = CreateOrUpdateSectionFeeMapRequest(
                  schoolId: widget.adminProfile.schoolId,
                  agent: widget.adminProfile.userId,
                  sectionWiseFeesBeanList: (actualSectionWiseAnnualFeeBeanMap[section]?.feeTypes ?? [])
                      .map((SectionWiseAnnualFeeTypeBean eachFeeType) {
                        List<SectionWiseAnnualFeesBean> list = [];
                        if ((eachFeeType.sectionWiseAnnualCustomFeeTypeBeans ?? []).isEmpty) {
                          list.add(
                            SectionWiseAnnualFeesBean(
                              sectionId: toBeEdited!.sectionId,
                              feeTypeId: eachFeeType.feeTypeId,
                              sectionWiseFeesStatus: eachFeeType.sectionWiseFeesStatus,
                              sectionFeeMapId: eachFeeType.sectionFeeMapId,
                              schoolId: toBeEdited!.schoolId,
                              amount: eachFeeType.amount,
                            ),
                          );
                        } else {
                          for (SectionWiseAnnualCustomFeeTypeBean eachCustomFeeType in (eachFeeType.sectionWiseAnnualCustomFeeTypeBeans ?? [])) {
                            list.add(
                              SectionWiseAnnualFeesBean(
                                sectionId: toBeEdited!.sectionId,
                                feeTypeId: eachFeeType.feeTypeId,
                                sectionWiseFeesStatus: eachCustomFeeType.sectionWiseFeesStatus,
                                sectionFeeMapId: eachFeeType.sectionFeeMapId,
                                schoolId: toBeEdited!.schoolId,
                                amount: eachCustomFeeType.amount,
                                customFeeTypeId: eachCustomFeeType.customFeeTypeId,
                              ),
                            );
                          }
                        }
                        return list;
                      })
                      .expand((i) => i)
                      .toList(),
                );
                CreateOrUpdateSectionFeeMapResponse createOrUpdateSectionFeeMapResponse =
                    await createOrUpdateSectionFeeMap(createOrUpdateSectionFeeMapRequest);
                if (createOrUpdateSectionFeeMapResponse.httpStatus == "OK" && createOrUpdateSectionFeeMapResponse.responseStatus == "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Changes updated successfully"),
                    ),
                  );
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
                _loadData();
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
        title: const Text("Assign Fee Types To Sections"),
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
          : ListView(
              children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin: MediaQuery.of(context).orientation == Orientation.landscape
                          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
                          : const EdgeInsets.fromLTRB(25, 10, 25, 10),
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
                            children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          "Fee Types",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return AdminManageFeeTypesScreen(
                                              adminProfile: widget.adminProfile,
                                            );
                                          })).then((value) => _loadData());
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
                                      const SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ] +
                                _feeTypes.map((e) => _feeTypeWidget(e)).toList(),
                          ),
                        ),
                      ),
                    ),
                  ] +
                  [
                    // GridView.count(
                    //   crossAxisCount: 3,
                    //   shrinkWrap: true,
                    //   childAspectRatio: 9 / 16,
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   children: _sectionsList
                    //       .map((eachSection) => sectionWiseAnnualFeeBeanWidget(actualSectionWiseAnnualFeeBeanMap[eachSection]!))
                    //       .toList(),
                    // ),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (int i = 0; i < _sectionsList.length / perRowCount; i = i + 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int j = 0; j < perRowCount; j++)
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                                    width: perRowCount == 3
                                        ? (MediaQuery.of(context).size.width / 3) - (3 * 25)
                                        : MediaQuery.of(context).size.width - 25,
                                    child: ClayContainer(
                                      surfaceColor: clayContainerColor(context),
                                      parentColor: clayContainerColor(context),
                                      spread: 1,
                                      borderRadius: 10,
                                      depth: 40,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        child: ((i * perRowCount + j) >= _sectionsList.length)
                                            ? Container()
                                            : sectionWiseAnnualFeeBeanWidget(
                                                actualSectionWiseAnnualFeeBeanMap[_sectionsList[(i * perRowCount + j)]]!),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ],
            ),
    );
  }

  Widget sectionWiseAnnualFeeBeanWidget(SectionWiseAnnualFeeMapBean sectionWiseAnnualFee) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                sectionWiseAnnualFee.sectionName ?? "-",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            ),
            if (toBeEdited != null && toBeEdited!.sectionId == sectionWiseAnnualFee.sectionId)
              Container(
                margin: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () {
                    loadSectionWiseAnnualFeeMap(_sectionsList.where((e) => e.sectionId == toBeEdited!.sectionId).first);
                    setState(() {
                      toBeEdited = null;
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
            Container(
              margin: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () async {
                  if (toBeEdited == null) {
                    setState(() {
                      toBeEdited = Section(sectionId: sectionWiseAnnualFee.sectionId, sectionName: sectionWiseAnnualFee.sectionName);
                    });
                  } else if (toBeEdited!.sectionId == sectionWiseAnnualFee.sectionId) {
                    await _saveChanges(_sectionsList.where((e) => e.sectionId == toBeEdited!.sectionId).first);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Save changes for ${toBeEdited!.sectionName} to proceed.."),
                      ),
                    );
                  }
                },
                child: ClayButton(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 1,
                  borderRadius: 100,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: toBeEdited != null && toBeEdited!.sectionId == sectionWiseAnnualFee.sectionId
                        ? const Icon(Icons.check)
                        : const Icon(Icons.edit),
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          // physics: const BouncingScrollPhysics(),
          children: buildSectionWiseAnnualFeesWidgets(sectionWiseAnnualFee),
        ),
      ],
    );
  }

  List<Widget> buildSectionWiseAnnualFeesWidgets(SectionWiseAnnualFeeMapBean sectionWiseAnnualFeeMapBean) {
    List<Widget> widgets = [];
    for (SectionWiseAnnualFeeTypeBean sectionWiseAnnualFeeTypeBean in (sectionWiseAnnualFeeMapBean.feeTypes ?? []).where((e) => toBeEdited != null &&
            sectionWiseAnnualFeeMapBean.sectionId == toBeEdited!.sectionId
        ? true
        : (e.sectionWiseFeesStatus != null && e.sectionWiseFeesStatus == "active") ||
            (e.sectionWiseAnnualCustomFeeTypeBeans ?? []).map((e) => e.sectionWiseFeesStatus).where((e) => e != null && e == "active").isNotEmpty)) {
      widgets.add(const SizedBox(
        height: 15,
      ));
      widgets.add(
          buildFeeTypeWidget(sectionWiseAnnualFeeTypeBean, toBeEdited != null && sectionWiseAnnualFeeMapBean.sectionId == toBeEdited!.sectionId));
      for (SectionWiseAnnualCustomFeeTypeBean sectionWiseAnnualCustomFeeTypeBean
          in (sectionWiseAnnualFeeTypeBean.sectionWiseAnnualCustomFeeTypeBeans ?? []).where((e) =>
              toBeEdited != null && sectionWiseAnnualFeeMapBean.sectionId == toBeEdited!.sectionId
                  ? true
                  : e.sectionWiseFeesStatus != null && e.sectionWiseFeesStatus == "active")) {
        widgets.add(const SizedBox(
          height: 15,
        ));
        widgets.add(buildCustomFeeTypeWidget(
            sectionWiseAnnualCustomFeeTypeBean, toBeEdited != null && sectionWiseAnnualFeeMapBean.sectionId == toBeEdited!.sectionId));
      }
    }
    return widgets;
  }

  Row buildFeeTypeWidget(SectionWiseAnnualFeeTypeBean sectionWiseAnnualFeeTypeBean, bool isEditMode) {
    return Row(
      children: [
        if (isEditMode && (sectionWiseAnnualFeeTypeBean.sectionWiseAnnualCustomFeeTypeBeans ?? []).isEmpty)
          Checkbox(
              value: (sectionWiseAnnualFeeTypeBean.sectionWiseFeesStatus ?? "") == 'active',
              onChanged: (bool? newValue) {
                if (newValue!) {
                  setState(() {
                    sectionWiseAnnualFeeTypeBean.sectionWiseFeesStatus = "active";
                    FocusScope.of(context).requestFocus(sectionWiseAnnualFeeTypeBean.focusNode);
                  });
                } else {
                  setState(() {
                    sectionWiseAnnualFeeTypeBean.sectionWiseFeesStatus = "inactive";
                    sectionWiseAnnualFeeTypeBean.amountController.text = '';
                    sectionWiseAnnualFeeTypeBean.amount = null;
                  });
                }
              }),
        Expanded(
          child: Text(sectionWiseAnnualFeeTypeBean.feeType ?? '-'),
        ),
        isEditMode && (sectionWiseAnnualFeeTypeBean.sectionWiseAnnualCustomFeeTypeBeans ?? []).isEmpty
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  height: 50,
                  width: 75,
                  child: TextField(
                    controller: sectionWiseAnnualFeeTypeBean.amountController,
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
                        } on Exception catch (_, e) {
                          debugPrintStack(stackTrace: e, label: "Assign Fee Types To Sections");
                        }
                        return oldValue;
                      }),
                    ],
                    onChanged: (String e) {
                      setState(() {
                        sectionWiseAnnualFeeTypeBean.amount = (double.parse(e) * 100).round();
                        sectionWiseAnnualFeeTypeBean.sectionWiseFeesStatus = "active";
                      });
                    },
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    autofocus: true,
                    focusNode: sectionWiseAnnualFeeTypeBean.focusNode,
                  ),
                ),
              )
            : Text(
                (sectionWiseAnnualFeeTypeBean.sectionWiseAnnualCustomFeeTypeBeans ?? []).isNotEmpty
                    ? ""
                    : sectionWiseAnnualFeeTypeBean.amount == null
                        ? ""
                        : INR_SYMBOL + " " + ((sectionWiseAnnualFeeTypeBean.amount ?? 0) / 100).toStringAsFixed(2),
              )
      ],
    );
  }

  Row buildCustomFeeTypeWidget(SectionWiseAnnualCustomFeeTypeBean sectionWiseAnnualCustomFeeTypeBean, bool isEditMode) {
    return Row(
      children: [
        isEditMode
            ? Checkbox(
                value: (sectionWiseAnnualCustomFeeTypeBean.sectionWiseFeesStatus ?? "") == 'active',
                onChanged: (bool? newValue) {
                  if (newValue!) {
                    setState(() {
                      sectionWiseAnnualCustomFeeTypeBean.sectionWiseFeesStatus = "active";
                      FocusScope.of(context).requestFocus(sectionWiseAnnualCustomFeeTypeBean.focusNode);
                    });
                  } else {
                    setState(() {
                      sectionWiseAnnualCustomFeeTypeBean.sectionWiseFeesStatus = "inactive";
                      sectionWiseAnnualCustomFeeTypeBean.amountController.text = '';
                      sectionWiseAnnualCustomFeeTypeBean.amount = null;
                    });
                  }
                })
            : const CustomVerticalDivider(),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(sectionWiseAnnualCustomFeeTypeBean.customFeeType ?? "-"),
        ),
        isEditMode
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  height: 50,
                  width: 75,
                  child: TextField(
                    controller: sectionWiseAnnualCustomFeeTypeBean.amountController,
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
                        } on Exception catch (_, e) {
                          debugPrintStack(stackTrace: e, label: "Assign Fee Types To Sections");
                        }
                        return oldValue;
                      }),
                    ],
                    onChanged: (String e) {
                      setState(() {
                        sectionWiseAnnualCustomFeeTypeBean.amount = (double.parse(e) * 100).round();
                        sectionWiseAnnualCustomFeeTypeBean.sectionWiseFeesStatus = "active";
                      });
                    },
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    autofocus: true,
                    focusNode: sectionWiseAnnualCustomFeeTypeBean.focusNode,
                  ),
                ),
              )
            : Text(sectionWiseAnnualCustomFeeTypeBean.amount == null
                ? ""
                : INR_SYMBOL + " " + ((sectionWiseAnnualCustomFeeTypeBean.amount ?? 0) / 100).toStringAsFixed(2))
      ],
    );
  }

  Widget _feeTypeWidget(FeeType feeType) {
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          (feeType.feeType ?? "-").capitalize(),
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((feeType.customFeeTypesList ?? []).isNotEmpty)
                    const SizedBox(
                      height: 5,
                    ),
                ] +
                (feeType.customFeeTypesList ?? [])
                    .map((e) => e!)
                    .where((e) => (e.customFeeTypeStatus != null && e.customFeeTypeStatus == "active"))
                    .map((e) => _customFeeTypeWidget(feeType, (feeType.customFeeTypesList ?? []).indexOf(e)))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _customFeeTypeWidget(FeeType feeType, int index) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        children: [
          const CustomVerticalDivider(),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(((feeType.customFeeTypesList ?? [])[index]!.customFeeType ?? "-").capitalize()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionWiseAnnualFeeMapBean {
  String? schoolDisplayName;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  List<SectionWiseAnnualFeeTypeBean>? feeTypes;

  SectionWiseAnnualFeeMapBean({
    this.schoolDisplayName,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.feeTypes,
  });

  @override
  String toString() {
    return "{\n\t'schoolDisplayName': $schoolDisplayName,\n\t'schoolId': $schoolId,\n\t'sectionId': $sectionId,\n\t'sectionName': $sectionName,\n\t'feeTypes': $feeTypes\n}";
  }
}

class SectionWiseAnnualFeeTypeBean {
  int? amount;
  TextEditingController amountController = TextEditingController();
  int? sectionFeeMapId;
  int? feeTypeId;
  String? feeType;
  String? sectionWiseFeesStatus;
  List<SectionWiseAnnualCustomFeeTypeBean>? sectionWiseAnnualCustomFeeTypeBeans;
  FocusNode focusNode = FocusNode();

  SectionWiseAnnualFeeTypeBean({
    this.amount,
    this.sectionFeeMapId,
    this.feeTypeId,
    this.feeType,
    this.sectionWiseFeesStatus,
    this.sectionWiseAnnualCustomFeeTypeBeans,
  }) {
    amountController.text = "${amount == null ? "" : amount! / 100.0}";
  }

  @override
  String toString() {
    return "{\n\t'amount': $amount,\n\t'sectionFeeMapId': $sectionFeeMapId,\n\t'feeTypeId': $feeTypeId,\n\t'feeType': $feeType,\n\t'sectionWiseFeesStatus': $sectionWiseFeesStatus,\n\t'sectionWiseAnnualCustomFeeTypeBeans': $sectionWiseAnnualCustomFeeTypeBeans\n}";
  }
}

class SectionWiseAnnualCustomFeeTypeBean {
  int? amount;
  TextEditingController amountController = TextEditingController();
  int? sectionFeeMapId;
  int? feeTypeId;
  String? feeType;
  int? customFeeTypeId;
  String? customFeeType;
  String? sectionWiseFeesStatus;
  FocusNode focusNode = FocusNode();

  SectionWiseAnnualCustomFeeTypeBean({
    this.amount,
    this.sectionFeeMapId,
    this.feeTypeId,
    this.feeType,
    this.customFeeTypeId,
    this.customFeeType,
    this.sectionWiseFeesStatus,
  }) {
    amountController.text = "${amount == null ? "" : amount! / 100.0}";
  }

  @override
  String toString() {
    return "{\n\t'amount': $amount,\n\t'sectionFeeMapId': $sectionFeeMapId,\n\t'feeTypeId': $feeTypeId,\n\t'feeType': $feeType,\n\t'customFeeTypeId': $customFeeTypeId,\n\t'customFeeType': $customFeeType,\n\t'sectionWiseFeesStatus': $sectionWiseFeesStatus\n}";
  }
}
