import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_section_wise_term_fee_screen.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class AdminManageTermsScreen extends StatefulWidget {
  const AdminManageTermsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _AdminManageTermsScreenState createState() => _AdminManageTermsScreenState();
}

class _AdminManageTermsScreenState extends State<AdminManageTermsScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;

  List<TermBean> terms = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetTermsResponse getTermsResponse = await getTerms(GetTermsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getTermsResponse.httpStatus != "OK" || getTermsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        terms = getTermsResponse.termBeanList!.map((e) => e!).toList();
      });
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
        title: const Text("Terms Management"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: terms.map((e) => buildTermWidget(e)).toList(),
            ),
      floatingActionButton: widget.adminProfile.isMegaAdmin
          ? null
          : _isEditMode && !terms.map((e) => e.isEditMode).contains(true)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          terms.add(
                            TermBean(
                              schoolId: widget.adminProfile.schoolId,
                              schoolDisplayName: widget.adminProfile.schoolName,
                              status: "active",
                            )..isEditMode = true,
                          );
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
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    buildMasterEditButton(context),
                  ],
                )
              : buildMasterEditButton(context),
    );
  }

  GestureDetector buildMasterEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (terms.map((e) => e.isEditMode).contains(true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Save changes to proceed.."),
            ),
          );
          return;
        }
        setState(() {
          _isEditMode = !_isEditMode;
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
          child: !_isEditMode ? const Icon(Icons.edit) : const Icon(Icons.clear),
        ),
      ),
    );
  }

  Widget buildTermWidget(TermBean term) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
          : const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: _isEditMode
          ? ClayContainer(
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              depth: 40,
              child: term.isEditMode ? buildTermContentForEditMode(term) : buildTermContentForReadMode(term),
            )
          : GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AdminSectionWiseTermFeeScreen(
                    adminProfile: widget.adminProfile,
                    termIndex: terms.indexOf(term),
                    terms: terms,
                  );
                }));
              },
              child: ClayButton(
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                depth: 40,
                child: buildTermContentForReadMode(term),
              ),
            ),
    );
  }

  Widget buildTermContentForEditMode(TermBean term) {
    return Stack(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: 75,
                    child: TextField(
                      controller: term.termNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Term Name',
                        hintText: 'Term Name',
                        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                      ),
                      onChanged: (String e) {
                        setState(() {
                          term.termName = e;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                      autofocus: true,
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? _newDate = await showDatePicker(
                              context: context,
                              initialDate: convertYYYYMMDDFormatToDateTime(term.termStartDate),
                              firstDate: DateTime.now().subtract(const Duration(days: 364 * 2)),
                              lastDate: DateTime.now().add(const Duration(days: 364 * 2)),
                              helpText: "Select a term start date",
                            );
                            if (_newDate == null) return;
                            setState(() {
                              term.termStartDate = convertDateTimeToYYYYMMDDFormat(_newDate);
                            });
                          },
                          child: ClayButton(
                            surfaceColor: clayContainerColor(context),
                            parentColor: clayContainerColor(context),
                            spread: 1,
                            borderRadius: 10,
                            depth: 40,
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "Start date: ${convertDateToDDMMMYYY(term.termStartDate)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? _newDate = await showDatePicker(
                              context: context,
                              initialDate: convertYYYYMMDDFormatToDateTime(term.termEndDate),
                              firstDate: DateTime.now().subtract(const Duration(days: 364 * 2)),
                              lastDate: DateTime.now().add(const Duration(days: 364 * 2)),
                              helpText: "Select a term end date",
                            );
                            if (_newDate == null) return;
                            setState(() {
                              term.termEndDate = convertDateTimeToYYYYMMDDFormat(_newDate);
                            });
                          },
                          child: ClayButton(
                            surfaceColor: clayContainerColor(context),
                            parentColor: clayContainerColor(context),
                            spread: 1,
                            borderRadius: 10,
                            depth: 40,
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "End date: ${convertDateToDDMMMYYY(term.termEndDate)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                ],
              ),
            ),
          ],
        ),
        if (_isEditMode)
          Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      if (term.termId == null) {
                        setState(() {
                          terms.removeLast();
                        });
                      } else {
                        setState(() {
                          TermBean originalTerm = TermBean.fromJson(term.origJson());
                          term.termName = originalTerm.termName;
                          term.termNumber = originalTerm.termNumber;
                          term.termStartDate = originalTerm.termStartDate;
                          term.termEndDate = originalTerm.termEndDate;
                          term.termNameController.text = originalTerm.termName ?? "";
                          term.isEditMode = false;
                        });
                      }
                    },
                    child: ClayButton(
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 10,
                      depth: 40,
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        child: const Icon(
                          Icons.clear,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      CreateOrUpdateTermResponse createOrUpdateTermResponse = await createOrUpdateTerm(CreateOrUpdateTermRequest(
                        status: term.status,
                        schoolId: term.schoolId,
                        agent: widget.adminProfile.userId,
                        termId: term.termId,
                        termName: term.termName,
                        termStartDate: term.termStartDate,
                        termEndDate: term.termEndDate,
                      ));
                      if (createOrUpdateTermResponse.httpStatus != "OK" || createOrUpdateTermResponse.responseStatus != "success") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Something went wrong! Try again later.."),
                          ),
                        );
                      } else {
                        setState(() {
                          term.termId = createOrUpdateTermResponse.termId;
                          term.isEditMode = false;
                        });
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: ClayButton(
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 10,
                      depth: 40,
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        child: Icon(
                          term.isEditMode ? Icons.check : Icons.edit,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Stack buildTermContentForReadMode(TermBean term) {
    return Stack(
      children: [
        if (_isEditMode)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    term.isEditMode = true;
                  });
                },
                child: ClayButton(
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 1,
                  borderRadius: 10,
                  depth: 40,
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    child: Icon(
                      term.isEditMode ? Icons.check : Icons.edit,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(5, 25, 5, 0),
                  child: Center(
                    child: Text(term.termName ?? "-"),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                  child: Text(
                    "Due Date: ${convertDateToDDMMMYYY(term.termEndDate)}",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      color: convertYYYYMMDDFormatToDateTime(term.termEndDate).millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch
                          ? null
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
