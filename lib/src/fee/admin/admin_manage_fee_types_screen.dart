import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminManageFeeTypesScreen extends StatefulWidget {
  const AdminManageFeeTypesScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _AdminManageFeeTypesScreenState createState() => _AdminManageFeeTypesScreenState();
}

class _AdminManageFeeTypesScreenState extends State<AdminManageFeeTypesScreen> {
  bool _isLoading = true;
  bool _isEditMode = true;

  List<FeeType> _feeTypes = [];
  late SchoolInfoBean schoolInfoBean;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      bool _isEditMode = true;
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
            feeType.isEditMode = false;
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

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fee Types"),
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : AdminAppDrawer(
              adminProfile: widget.adminProfile,
            ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              controller: _controller,
              children: <Widget>[
                    const SizedBox(
                      height: 15,
                    )
                  ] +
                  _feeTypes.map((e) => _feeTypeWidget(e)).toList() +
                  [
                    const SizedBox(
                      height: 250,
                    )
                  ],
            ),
      floatingActionButton: _isLoading || widget.adminProfile.isMegaAdmin ? null : _addNewButton(context),
    );
  }

  Widget _addNewButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.vibrate();
        if (_feeTypes.where((eachFeeType) => eachFeeType.feeTypeId == null).isNotEmpty) {
          if ((_feeTypes.last.feeType ?? "") == "" ||
              ((_feeTypes.last.customFeeTypesList ?? [])
                  .map((e) => e!)
                  .where((e) => (e.customFeeType ?? "") == "" && e.customFeeTypeStatus == "active")
                  .isNotEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please fill all the mandatory details to continue.."),
              ),
            );
            return;
          }
          await _saveChangesForFeeTypes(_feeTypes.last);
        } else {
          setState(() {
            _controller.animateTo(
              _controller.position.maxScrollExtent,
              duration: const Duration(seconds: 2),
              curve: Curves.fastOutSlowIn,
            );
            _feeTypes.add(FeeType(
              schoolId: widget.adminProfile.schoolId,
              schoolDisplayName: widget.adminProfile.schoolName,
              customFeeTypesList: [
                CustomFeeType(
                  schoolId: widget.adminProfile.schoolId,
                ),
              ],
              feeTypeStatus: "active",
            ));
            _feeTypes.last.isEditMode = true;
          });
        }
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 50,
        width: 50,
        borderRadius: 50,
        spread: 1,
        child: Icon(
          _feeTypes.where((eachFeeType) => eachFeeType.feeTypeId == null).isNotEmpty ? Icons.check : Icons.add,
          color: _feeTypes.where((eachFeeType) => eachFeeType.feeTypeId == null).isNotEmpty ? Colors.green[200] : null,
        ),
      ),
    );
  }

  Future<void> _saveChangesForFeeTypes(FeeType feeType) async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      (feeType.customFeeTypesList ?? []).removeWhere((customFeeType) =>
          customFeeType!.customFeeTypeId == null && (customFeeType.customFeeTypeStatus == null || customFeeType.customFeeTypeStatus == "inactive"));
    });
    CreateOrUpdateFeeTypesResponse createOrUpdateFeeTypesResponse = await createOrUpdateFeeTypes(
      CreateOrUpdateFeeTypesRequest(
        schoolId: widget.adminProfile.schoolId,
        agent: widget.adminProfile.userId,
        feeTypesList: [
          feeType,
        ],
      ),
    );
    if (createOrUpdateFeeTypesResponse.httpStatus != "OK" || createOrUpdateFeeTypesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      _loadData();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _feeTypeWidget(FeeType feeType) {
    var showSyncOldDueButton = !feeType.isEditMode &&
        (feeType.customFeeTypesList ?? []).map((e) => e?.customFeeTypeId).where((e) => e != null).isEmpty &&
        feeType.feeTypeStatus == 'active' &&
        schoolInfoBean.linkedSchoolId != null &&
        feeType.feeType == "Old Due";
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
                        child: feeType.isEditMode
                            ? TextField(
                                controller: feeType.feeTypeController,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  labelText: 'Fee Type',
                                  hintText: 'Fee Type',
                                  contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                                ),
                                onChanged: (String e) {
                                  setState(() {
                                    feeType.feeType = e;
                                  });
                                },
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                                autofocus: true,
                              )
                            : Text(
                                (feeType.feeType ?? "-").capitalize(),
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                      ),
                      if (_isEditMode && feeType.isEditMode)
                        const SizedBox(
                          width: 15,
                        ),
                      if (_isEditMode && feeType.isEditMode) _feeTypeCancelButton(feeType),
                      if (_isEditMode)
                        const SizedBox(
                          width: 15,
                        ),
                      if (showSyncOldDueButton) _populateOldDueButton(feeType),
                      if (showSyncOldDueButton) const SizedBox(width: 15),
                      if (_isEditMode && feeType.feeTypeId != null) _feeTypeEditButton(feeType),
                    ],
                  ),
                  if ((feeType.customFeeTypesList ?? []).isNotEmpty)
                    const SizedBox(
                      height: 5,
                    ),
                ] +
                (feeType.customFeeTypesList ?? [])
                    .map((e) => e!)
                    .where((e) => ((feeType.isEditMode && (e.customFeeTypeStatus == null || e.customFeeTypeStatus == "active")) ||
                        (!feeType.isEditMode && (e.customFeeTypeStatus != null && e.customFeeTypeStatus == "active"))))
                    .map((e) => _customFeeTypeWidget(feeType, (feeType.customFeeTypesList ?? []).indexOf(e)))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _populateOldDueButton(FeeType feeType) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.vibrate();
        showDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Are you sure you want to populate all students with their respective old dues from previous academic year"),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    PopulateFeeDuesRequest populateFeeDuesRequest = PopulateFeeDuesRequest(
                      schoolId: widget.adminProfile.schoolId,
                      agentId: widget.adminProfile.userId,
                      oldDueFeeTypeId: feeType.feeTypeId,
                    );
                    CreateOrUpdateStudentAnnualFeeMapResponse createOrUpdateStudentAnnualFeeMapResponse =
                        await populateFeeDues(populateFeeDuesRequest);
                    if (createOrUpdateStudentAnnualFeeMapResponse.httpStatus != "OK" ||
                        createOrUpdateStudentAnnualFeeMapResponse.responseStatus != "success") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Something went wrong! Try again later.."),
                        ),
                      );
                    }
                    setState(() => _isLoading = false);
                  },
                  child: const Text("YES"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
      child: Tooltip(
        message: "Populate all students with their respective old dues from previous academic year",
        child: ClayButton(
          color: clayContainerColor(context),
          height: 30,
          width: 30,
          borderRadius: 30,
          spread: 1,
          child: const Icon(
            Icons.sync,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _feeTypeCancelButton(FeeType feeType) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.vibrate();
        if (feeType.feeTypeId == null) {
          setState(() {
            _feeTypes.remove(feeType);
          });
        } else {
          setState(() {
            feeType.isEditMode = false;
            FeeType oldFeeType = FeeType.fromJson(feeType.origJson());
            feeType.feeTypeId = oldFeeType.feeTypeId;
            feeType.feeType = oldFeeType.feeType;
            feeType.feeTypeController.text = oldFeeType.feeType ?? "";
            feeType.schoolId = oldFeeType.schoolId;
            feeType.feeTypeStatus = oldFeeType.feeTypeStatus;
            feeType.feeTypeDescription = oldFeeType.feeTypeDescription;
            feeType.schoolDisplayName = oldFeeType.schoolDisplayName;
            (feeType.customFeeTypesList ?? []).clear();
            for (var e in (oldFeeType.customFeeTypesList ?? [])) {
              feeType.customFeeTypesList!.add(e);
            }
          });
        }
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 30,
        width: 30,
        borderRadius: 30,
        spread: 1,
        child: const Icon(
          Icons.clear,
          size: 16,
        ),
      ),
    );
  }

  Widget _feeTypeEditButton(FeeType feeType) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.vibrate();
        if (feeType.isEditMode) {
          _saveChangesForFeeTypes(feeType);
          setState(() {
            feeType.isEditMode = false;
          });
        } else {
          setState(() {
            feeType.isEditMode = true;
          });
        }
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 30,
        width: 30,
        borderRadius: 30,
        spread: 1,
        child: Icon(
          feeType.isEditMode ? Icons.check : Icons.edit,
          color: feeType.isEditMode ? Colors.green[200] : null,
          size: 16,
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
                      child: feeType.isEditMode
                          ? TextField(
                              controller: (feeType.customFeeTypesList ?? [])[index]!.customFeeTypeController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                labelText: 'Custom Fee Type',
                                hintText: 'Custom Fee Type',
                                contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              ),
                              onChanged: (String e) {
                                setState(() {
                                  (feeType.customFeeTypesList ?? [])[index]!.customFeeType = e;
                                });
                              },
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              autofocus: true,
                            )
                          : Text(((feeType.customFeeTypesList ?? [])[index]!.customFeeType ?? "-").capitalize()),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (feeType.isEditMode)
            const SizedBox(
              width: 15,
            ),
          if (feeType.isEditMode)
            GestureDetector(
              onTap: () {
                HapticFeedback.vibrate();
                if (((feeType.customFeeTypesList ?? [])[index]!.customFeeType ?? "") == "") {
                  return;
                }
                if (((feeType.customFeeTypesList ?? [])[index]!.customFeeTypeStatus ?? "") == "active") {
                  setState(() {
                    (feeType.customFeeTypesList ?? [])[index]!.customFeeTypeStatus = "inactive";
                  });
                } else {
                  setState(() {
                    (feeType.customFeeTypesList ?? [])[index]!.customFeeTypeStatus = "active";
                    feeType.customFeeTypesList!.add(CustomFeeType(
                      schoolId: feeType.schoolId,
                      feeType: feeType.feeType,
                      feeTypeId: feeType.feeTypeId,
                    ));
                  });
                }
              },
              child: ClayButton(
                color: clayContainerColor(context),
                height: 30,
                width: 30,
                borderRadius: 30,
                spread: 1,
                child: ((feeType.customFeeTypesList ?? [])[index]!.customFeeTypeStatus ?? "") == ""
                    ? const Icon(
                        Icons.add,
                        color: Colors.green,
                        size: 16,
                      )
                    : const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 16,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
