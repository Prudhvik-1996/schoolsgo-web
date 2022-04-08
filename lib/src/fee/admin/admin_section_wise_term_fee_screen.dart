import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminSectionWiseTermFeeScreen extends StatefulWidget {
  const AdminSectionWiseTermFeeScreen({
    Key? key,
    required this.adminProfile,
    required this.termIndex,
    required this.terms,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final int termIndex;
  final List<TermBean> terms;

  @override
  _AdminSectionWiseTermFeeScreenState createState() => _AdminSectionWiseTermFeeScreenState();
}

class _AdminSectionWiseTermFeeScreenState extends State<AdminSectionWiseTermFeeScreen> {
  bool _isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Section> sectionsList = [];
  int? editingSectionId;
  List<SectionWiseAnnualFeesBean> sectionWiseAnnualFeeBeansList = [];

  Map<TermBean, Map<Section, SectionWiseTermFeeMapBean>> actualSectionWiseTermFeeBeanMap = {};

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
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
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
    for (TermBean term in widget.terms) {
      await _loadTermFeeMap(term);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadTermFeeMap(TermBean term) async {
    setState(() {
      _isLoading = true;
    });
    List<SectionWiseTermFeesBean> sectionWiseTermFeesBeans = [];
    GetSectionWiseTermFeesResponse getSectionWiseTermFeesResponse = await getSectionWiseTermFees(GetSectionWiseTermFeesRequest(
      termId: term.termId,
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSectionWiseTermFeesResponse.httpStatus != "OK" || getSectionWiseTermFeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      sectionWiseTermFeesBeans = (getSectionWiseTermFeesResponse.sectionWiseTermFeesBeanList ?? []).where((e) => e != null).map((e) => e!).toList();
    }
    actualSectionWiseTermFeeBeanMap[term] = {};
    for (Section eachSection in sectionsList) {
      List<TermWiseFeeType> termWiseFeeTypes = [];
      actualSectionWiseTermFeeBeanMap[term]![eachSection] = SectionWiseTermFeeMapBean(
        sectionId: eachSection.sectionId,
        sectionName: eachSection.sectionName,
        termWiseFeeTypes: sectionWiseAnnualFeeBeansList
            .where((e) => e.sectionId == eachSection.sectionId)
            .map((SectionWiseAnnualFeesBean sectionWiseAnnualFeesBean) {
              if (!termWiseFeeTypes.map((e) => e.feeTypeId).contains(sectionWiseAnnualFeesBean.feeTypeId) &&
                  sectionWiseAnnualFeesBean.customFeeTypeId == null) {
                termWiseFeeTypes.add(
                  TermWiseFeeType(
                    feeTypeId: sectionWiseAnnualFeesBean.feeTypeId,
                    feeType: sectionWiseAnnualFeesBean.feeType,
                    sectionFeeMapId: sectionWiseAnnualFeesBean.sectionFeeMapId,
                    actualAmount: sectionWiseAnnualFeesBean.amount,
                    termAmount: sectionWiseTermFeesBeans
                        .where((e) =>
                            e.sectionId == eachSection.sectionId && e.feeTypeId == sectionWiseAnnualFeesBean.feeTypeId && e.customFeeTypeId == null)
                        .firstOrNull
                        ?.termFeeAmount,
                    termFeeMapId: sectionWiseTermFeesBeans
                        .where((e) =>
                            e.sectionId == eachSection.sectionId && e.feeTypeId == sectionWiseAnnualFeesBean.feeTypeId && e.customFeeTypeId == null)
                        .firstOrNull
                        ?.termFeeMapId,
                  ),
                );
              } else {
                if ((termWiseFeeTypes.where((e) => e.feeTypeId == sectionWiseAnnualFeesBean.feeTypeId).firstOrNull?.termWiseCustomFeeTypes ?? [])
                    .isEmpty) {
                  termWiseFeeTypes.add(
                    TermWiseFeeType(
                      feeTypeId: sectionWiseAnnualFeesBean.feeTypeId,
                      feeType: sectionWiseAnnualFeesBean.feeType,
                      sectionFeeMapId: null,
                      actualAmount: null,
                      termWiseCustomFeeTypes: [
                        TermWiseCustomFeeType(
                          customFeeTypeId: sectionWiseAnnualFeesBean.customFeeTypeId,
                          customFeeType: sectionWiseAnnualFeesBean.customFeeType,
                          sectionFeeMapId: sectionWiseAnnualFeesBean.sectionFeeMapId,
                          actualAmount: sectionWiseAnnualFeesBean.amount,
                          termAmount: sectionWiseTermFeesBeans
                              .where((e) =>
                                  e.sectionId == eachSection.sectionId &&
                                  e.feeTypeId == sectionWiseAnnualFeesBean.feeTypeId &&
                                  e.customFeeTypeId == sectionWiseAnnualFeesBean.customFeeTypeId)
                              .firstOrNull
                              ?.termFeeAmount,
                          termFeeMapId: sectionWiseTermFeesBeans
                              .where((e) =>
                                  e.sectionId == eachSection.sectionId &&
                                  e.feeTypeId == sectionWiseAnnualFeesBean.feeTypeId &&
                                  e.customFeeTypeId == sectionWiseAnnualFeesBean.customFeeTypeId)
                              .firstOrNull
                              ?.termFeeMapId,
                        )
                      ],
                    ),
                  );
                } else {
                  termWiseFeeTypes.where((e) => e.feeTypeId == sectionWiseAnnualFeesBean.feeTypeId).firstOrNull?.termWiseCustomFeeTypes?.add(
                        TermWiseCustomFeeType(
                          customFeeTypeId: sectionWiseAnnualFeesBean.customFeeTypeId,
                          customFeeType: sectionWiseAnnualFeesBean.customFeeType,
                          sectionFeeMapId: sectionWiseAnnualFeesBean.sectionFeeMapId,
                          actualAmount: sectionWiseAnnualFeesBean.amount,
                          termAmount: sectionWiseTermFeesBeans
                              .where((e) =>
                                  e.sectionId == eachSection.sectionId &&
                                  e.feeTypeId == sectionWiseAnnualFeesBean.feeTypeId &&
                                  e.customFeeTypeId == sectionWiseAnnualFeesBean.customFeeTypeId)
                              .firstOrNull
                              ?.termFeeAmount,
                          termFeeMapId: sectionWiseTermFeesBeans
                              .where((e) =>
                                  e.sectionId == eachSection.sectionId &&
                                  e.feeTypeId == sectionWiseAnnualFeesBean.feeTypeId &&
                                  e.customFeeTypeId == sectionWiseAnnualFeesBean.customFeeTypeId)
                              .firstOrNull
                              ?.termFeeMapId,
                        ),
                      );
                }
              }
              return termWiseFeeTypes;
            })
            .expand((i) => i)
            .toSet() // TODO figure out what's happening here
            .toList(),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int perRowCount = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 1;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.terms[widget.termIndex].termName ?? "-"),
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
                for (int i = 0; i < sectionsList.length / perRowCount; i = i + 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int j = 0; j < perRowCount; j++)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                            width: perRowCount == 3 ? (MediaQuery.of(context).size.width / 3) - (3 * 25) : MediaQuery.of(context).size.width - 25,
                            child: ((i * perRowCount + j) >= sectionsList.length)
                                ? Container()
                                : sectionWiseTermFeeWidget(sectionsList[(i * perRowCount + j)]),
                          ),
                        )
                    ],
                  ),
              ],
            ),
    );
  }

  Widget sectionWiseTermFeeWidget(Section section) {
    SectionWiseTermFeeMapBean sectionWiseTermFeeMapBean = actualSectionWiseTermFeeBeanMap[widget.terms[widget.termIndex]]![section]!;
    List<Widget> widgets = [];
    for (TermWiseFeeType termWiseFeeType in sectionWiseTermFeeMapBean.termWiseFeeTypes ?? []) {
      if ((termWiseFeeType.termWiseCustomFeeTypes ?? []).isEmpty) {
        widgets.add(
          const SizedBox(
            height: 15,
          ),
        );
        widgets.add(
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(termWiseFeeType.feeType ?? "-"),
                    Text(
                      "Annual Fee: ${termWiseFeeType.actualAmount == null ? "-" : INR_SYMBOL + (termWiseFeeType.actualAmount! / 100).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              editingSectionId == section.sectionId
                  ? SizedBox(
                      width: 60,
                      child: TextField(
                        controller: termWiseFeeType.termAmountController,
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
                            try {
                              termWiseFeeType.termAmount = (double.parse(e) * 100).round();
                            } catch (e) {}
                          });
                        },
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        autofocus: true,
                      ),
                    )
                  : Text(termWiseFeeType.termAmount == null ? "-" : INR_SYMBOL + (termWiseFeeType.termAmount! / 100).toStringAsFixed(2)),
            ],
          ),
        );
      } else {
        widgets.add(
          const SizedBox(
            height: 15,
          ),
        );
        widgets.add(
          Row(
            children: [
              Expanded(
                child: Text(
                  (termWiseFeeType.feeType ?? "-"),
                ),
              ),
            ],
          ),
        );
        for (TermWiseCustomFeeType termWiseCustomFeeType in (termWiseFeeType.termWiseCustomFeeTypes ?? [])) {
          widgets.add(
            const SizedBox(
              height: 15,
            ),
          );
          widgets.add(
            Row(
              children: [
                const CustomVerticalDivider(),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(termWiseCustomFeeType.customFeeType ?? "-"),
                      Text(
                        "Annual Fee: ${termWiseCustomFeeType.actualAmount == null ? "-" : INR_SYMBOL + (termWiseCustomFeeType.actualAmount! / 100).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                editingSectionId == section.sectionId
                    ? SizedBox(
                        width: 60,
                        child: TextField(
                          controller: termWiseCustomFeeType.termAmountController,
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
                              try {
                                termWiseCustomFeeType.termAmount = (double.parse(e) * 100).round();
                              } catch (e) {}
                            });
                          },
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          autofocus: true,
                        ),
                      )
                    : Text(
                        termWiseCustomFeeType.termAmount == null ? "-" : INR_SYMBOL + (termWiseCustomFeeType.termAmount! / 100).toStringAsFixed(2),
                      ),
              ],
            ),
          );
        }
      }
    }
    return ClayContainer(
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      depth: 40,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    section.sectionName ?? "-",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                if (editingSectionId == null && widgets.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        editingSectionId = section.sectionId;
                      });
                    },
                    child: ClayButton(
                      depth: 40,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 100,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                if (editingSectionId == null && widgets.isNotEmpty)
                  const SizedBox(
                    width: 15,
                  ),
                if (editingSectionId == section.sectionId)
                  GestureDetector(
                    onTap: () async {
                      await _loadData();
                      setState(() {
                        editingSectionId = null;
                      });
                    },
                    child: ClayButton(
                      depth: 40,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 100,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.clear,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                if (editingSectionId == section.sectionId)
                  const SizedBox(
                    width: 15,
                  ),
                if (editingSectionId == section.sectionId)
                  GestureDetector(
                    onTap: () async {
                      //  TODO saveChanges
                      CreateOrUpdateSectionWiseTermFeeMapRequest createOrUpdateSectionWiseTermFeeMapRequest =
                          CreateOrUpdateSectionWiseTermFeeMapRequest(
                        schoolId: widget.adminProfile.schoolId,
                        agent: widget.adminProfile.userId,
                        sectionWiseTermFeeList: (sectionWiseTermFeeMapBean.termWiseFeeTypes ?? [])
                            .map((TermWiseFeeType eachTermWiseFeeType) {
                              List<UpdateSectionWiseTermFeeBean> beans = [];
                              if ((eachTermWiseFeeType.termWiseCustomFeeTypes ?? []).isEmpty) {
                                beans.add(UpdateSectionWiseTermFeeBean(
                                  termId: widget.terms[widget.termIndex].termId,
                                  schoolId: section.schoolId,
                                  sectionId: section.sectionId,
                                  termFeeMapId: eachTermWiseFeeType.termFeeMapId,
                                  sectionFeeMapId: eachTermWiseFeeType.sectionFeeMapId,
                                  amount: eachTermWiseFeeType.termAmount,
                                ));
                              } else {
                                for (TermWiseCustomFeeType eachTermWiseCustomFeeType in (eachTermWiseFeeType.termWiseCustomFeeTypes ?? [])) {
                                  beans.add(UpdateSectionWiseTermFeeBean(
                                    termId: widget.terms[widget.termIndex].termId,
                                    schoolId: section.schoolId,
                                    sectionId: section.sectionId,
                                    termFeeMapId: eachTermWiseCustomFeeType.termFeeMapId,
                                    sectionFeeMapId: eachTermWiseCustomFeeType.sectionFeeMapId,
                                    amount: eachTermWiseCustomFeeType.termAmount,
                                  ));
                                }
                              }
                              return beans;
                            })
                            .expand((i) => i)
                            .toList(),
                      );
                      CreateOrUpdateSectionWiseTermFeeMapResponse createOrUpdateSectionWiseTermFeeMapResponse =
                          await createOrUpdateSectionWiseTermFeeMap(createOrUpdateSectionWiseTermFeeMapRequest);
                      if (createOrUpdateSectionWiseTermFeeMapResponse.httpStatus != "OK" ||
                          createOrUpdateSectionWiseTermFeeMapResponse.responseStatus != "success") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Something went wrong! Try again later.."),
                          ),
                        );
                      } else {
                        await _loadData();
                        setState(() {
                          editingSectionId = null;
                        });
                      }
                    },
                    child: ClayButton(
                      depth: 40,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 100,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.check,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                if (editingSectionId == section.sectionId)
                  const SizedBox(
                    width: 15,
                  ),
                GestureDetector(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('All terms fees for section ${section.sectionName ?? "-"}'),
                          content: moreInfoWidgetPerSection(section),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 100,
                    child: const Icon(Icons.info_outline, size: 15),
                  ),
                ),
              ],
            ),
            ...widgets,
          ],
        ),
      ),
    );
  }

  Widget moreInfoWidgetPerSection(Section section) {
    List<String> lhsHeaderWidgets = widget.terms
        .map((e) => actualSectionWiseTermFeeBeanMap[e])
        .map((e) => e![section])
        .where((e) => e != null)
        .map((e) => e!)
        .map((e) => e.termWiseFeeTypes)
        .map((e) => e ?? [])
        .expand((i) => i)
        .map(
          (e) => (e.termWiseCustomFeeTypes ?? []).isEmpty
              ? [(e.feeType ?? "-") + "\n" + (e.actualAmount == null ? "-" : INR_SYMBOL + (e.actualAmount! / 100).toStringAsFixed(2))]
              : e.termWiseCustomFeeTypes!
                  .map((c) =>
                      (e.feeType ?? "-") +
                      "\n" +
                      (c.customFeeType ?? "-") +
                      "\n" +
                      (c.actualAmount == null ? "-" : INR_SYMBOL + (c.actualAmount! / 100).toStringAsFixed(2)))
                  .toList(),
        )
        .expand((i) => i)
        .toSet()
        .toList();
    List<String> rhsHeaderWidgets = widget.terms.map((e) => e.termName ?? "-").toList();
    List<List<String>> rhsWidgets = [];
    for (String eachType in lhsHeaderWidgets) {
      List<String> y = [];
      for (TermBean eachTerm in widget.terms) {
        for (TermWiseFeeType e in (actualSectionWiseTermFeeBeanMap[eachTerm]![section]!.termWiseFeeTypes ?? [])) {
          String? feeType = eachType.split("\n")[0];
          String? customFeeType = eachType.split("\n").length > 1 ? eachType.split("\n")[1] : null;
          if ((e.feeType ?? "-") == (feeType)) {
            if ((e.termWiseCustomFeeTypes ?? []).isEmpty) {
              y.add(e.termAmount == null ? "-" : (e.termAmount! / 100).toStringAsFixed(2));
            } else {
              TermWiseCustomFeeType? x =
                  (e.termWiseCustomFeeTypes ?? []).where((c) => customFeeType != null && (c.customFeeType ?? "-") == customFeeType).firstOrNull;
              y.add(x == null
                  ? "-"
                  : x.termAmount == null
                      ? "-"
                      : (x.termAmount! / 100).toStringAsFixed(2));
            }
          }
        }
      }
      rhsWidgets.add(y);
    }
    return Center(
      child: SizedBox(
        width: 160.0 * rhsHeaderWidgets.length + 150,
        height: 64.0 * (lhsHeaderWidgets.length + 1),
        child: HorizontalDataTable(
          leftHandSideColumnWidth: 150,
          rightHandSideColumnWidth: 160.0 * rhsHeaderWidgets.length,
          isFixedHeader: true,
          headerWidgets: <Widget>[
                lhsHeaderTableCell("Fee Types"),
              ] +
              rhsHeaderWidgets.map((e) => tableCell(e)).toList(),
          leftSideChildren: lhsHeaderWidgets.map((e) => lhsHeaderTableCell(e)).toList(),
          rightSideItemBuilder: (BuildContext context, int index) {
            return Row(
              children: rhsWidgets[index].map((e) => tableCell(e)).toList(),
            );
          },
          itemCount: lhsHeaderWidgets.length,
          elevation: 0.0,
          leftHandSideColBackgroundColor: clayContainerColor(context),
          rightHandSideColBackgroundColor: clayContainerColor(context),
        ),
      ),
    );
  }

  Widget lhsHeaderTableCell(String e) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: SizedBox(
        width: 150,
        height: 52,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Center(
            child: Text(
              e,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget tableCell(String e) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: SizedBox(
        width: 150,
        height: 52,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Center(
            child: Text(
              e,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class SectionWiseTermFeeMapBean {
  int? sectionId;
  String? sectionName;
  List<TermWiseFeeType>? termWiseFeeTypes;

  SectionWiseTermFeeMapBean({
    this.sectionId,
    this.sectionName,
    this.termWiseFeeTypes,
  });

  @override
  String toString() {
    return "{\n\t'sectionId': $sectionId, \n\t'sectionName': $sectionName, \n\t'termWiseFeeTypes': $termWiseFeeTypes \n}";
  }
}

class TermWiseFeeType {
  int? feeTypeId;
  String? feeType;
  int? actualAmount;
  int? termAmount;
  TextEditingController termAmountController = TextEditingController();
  int? termFeeMapId;
  int? sectionFeeMapId;
  List<TermWiseCustomFeeType>? termWiseCustomFeeTypes;

  TermWiseFeeType({
    this.feeTypeId,
    this.feeType,
    this.actualAmount,
    this.termAmount,
    this.termFeeMapId,
    this.sectionFeeMapId,
    this.termWiseCustomFeeTypes,
  }) {
    termAmountController.text = "${termAmount == null ? "" : (termAmount! / 100)}";
  }

  @override
  String toString() {
    return "{\n\t'feeTypeId': $feeTypeId, \n\t'feeType': $feeType, \n\t'actualAmount': $actualAmount, \n\t'termAmount': $termAmount, \n\t'termFeeMapId': $termFeeMapId, \n\t'sectionFeeMapId': $sectionFeeMapId, \n\t'termWiseCustomFeeTypes': $termWiseCustomFeeTypes\n}";
  }
}

class TermWiseCustomFeeType {
  int? customFeeTypeId;
  String? customFeeType;
  int? actualAmount;
  int? termAmount;
  TextEditingController termAmountController = TextEditingController();
  int? termFeeMapId;
  int? sectionFeeMapId;

  TermWiseCustomFeeType({
    this.customFeeTypeId,
    this.customFeeType,
    this.actualAmount,
    this.termAmount,
    this.termFeeMapId,
    this.sectionFeeMapId,
  }) {
    termAmountController.text = "${termAmount == null ? "" : (termAmount! / 100)}";
  }

  @override
  String toString() {
    return "{\n\t'customFeeTypeId': $customFeeTypeId, \n\t'customFeeType': $customFeeType, \n\t'actualAmount': $actualAmount, \n\t'termAmount': $termAmount, \n\t'termFeeMapId': $termFeeMapId, \n\t'sectionFeeMapId': $sectionFeeMapId \n}\n";
  }
}
