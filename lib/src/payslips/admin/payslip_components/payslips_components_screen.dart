import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/payslips/modal/payslips.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class PayslipComponentsScreen extends StatefulWidget {
  const PayslipComponentsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<PayslipComponentsScreen> createState() => _PayslipComponentsScreenState();
}

class _PayslipComponentsScreenState extends State<PayslipComponentsScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<PayslipComponentBean> payslipComponents = [];
  late PayslipComponentBean newPayslipComponentBean;

  bool _isEditMode = false;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      newPayslipComponentBean = PayslipComponentBean(
        status: "active",
        agent: widget.adminProfile.userId,
        schoolId: widget.adminProfile.schoolId,
        schoolName: widget.adminProfile.schoolName,
        componentName: null,
        componentType: null,
        payslipComponentId: null,
      )..isEditMode = true;
    });
    GetPayslipComponentsResponse getPayslipComponentsResponse = await getPayslipComponents(GetPayslipComponentsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getPayslipComponentsResponse.httpStatus != "OK" || getPayslipComponentsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        payslipComponents = (getPayslipComponentsResponse.payslipComponentBeans ?? []).map((e) => e!).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChanges(PayslipComponentBean payslipComponentBean) async {
    setState(() {
      _isLoading = true;
    });
    CreateOrUpdatePayslipComponentsResponse createOrUpdatePayslipComponentsResponse = await createOrUpdatePayslipComponents(
      CreateOrUpdatePayslipComponentsRequest(
        schoolId: widget.adminProfile.schoolId,
        agent: widget.adminProfile.userId,
        payslipComponents: [payslipComponentBean],
      ),
    );
    if (createOrUpdatePayslipComponentsResponse.httpStatus != "OK" || createOrUpdatePayslipComponentsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        _isEditMode = false;
        payslipComponentBean.isEditMode = !payslipComponentBean.isEditMode;
      });
      _loadData();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChangesDialogue(PayslipComponentBean payslipComponentBean) async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Payslip component'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return payslipComponentWidget(payslipComponentBean);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveChanges(payslipComponentBean);
              },
              child: const Text("YES"),
            ),
            TextButton(
              onPressed: () {
                if (payslipComponentBean.payslipComponentId == null) {
                  setState(() {
                    payslipComponentBean = PayslipComponentBean(
                      status: "active",
                      agent: widget.adminProfile.userId,
                      schoolId: widget.adminProfile.schoolId,
                      schoolName: widget.adminProfile.schoolName,
                      componentName: null,
                      componentType: null,
                      payslipComponentId: null,
                    )..isEditMode = true;
                  });
                } else {
                  setState(() {
                    payslipComponentBean = PayslipComponentBean.fromJson(payslipComponentBean.origJson())..isEditMode = false;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("No"),
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
  }

  GestureDetector _buildAddNewButton() {
    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: _scaffoldKey.currentContext!,
          barrierDismissible: true, // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('New Payslip Component'),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return payslipComponentWidget(
                    newPayslipComponentBean..isEditMode = true,
                    isEditable: true,
                  );
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Proceed'),
                  onPressed: () {
                    if ((newPayslipComponentBean.componentName ?? "").trim() == "" || (newPayslipComponentBean.componentType ?? "").trim() == "") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Both Component name and component type are mandatory"),
                        ),
                      );
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    _saveChangesDialogue(newPayslipComponentBean);
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    setState(() {
                      newPayslipComponentBean = PayslipComponentBean(
                        status: "active",
                        agent: widget.adminProfile.userId,
                        schoolId: widget.adminProfile.schoolId,
                        schoolName: widget.adminProfile.schoolName,
                        componentName: null,
                        componentType: null,
                        payslipComponentId: null,
                      )..isEditMode = true;
                    });
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
        setState(() {});
      },
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        height: 50,
        width: 50,
        borderRadius: 50,
        spread: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Payslip components"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: payslipComponents.map((e) => payslipComponentWidget(e, isEditable: true)).toList(),
            ),
      floatingActionButton: !_isEditMode
          ? _buildEditButton()
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAddNewButton(),
                const SizedBox(
                  height: 25,
                ),
                _buildEditButton(),
              ],
            ),
    );
  }

  GestureDetector _buildEditButton() {
    return GestureDetector(
      onTap: () {
        PayslipComponentBean? editing = payslipComponents.where((e) => e.isEditMode).firstOrNull;
        if (editing == null) {
          setState(() {
            _isEditMode = !_isEditMode;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Save changes for ${editing.componentName} - ${editing.componentType} to continue.."),
            ),
          );
          return;
        }
      },
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        height: 50,
        width: 50,
        borderRadius: 50,
        spread: 1,
        child: !_isEditMode ? const Icon(Icons.edit) : const Icon(Icons.done),
      ),
    );
  }

  Widget payslipComponentWidget(PayslipComponentBean payslipComponent, {bool isEditable = false}) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
          child: Row(
            children: [
              Expanded(
                child: _isEditMode && isEditable && payslipComponent.isEditMode
                    ? getEditablePayslipComponentNameWidget(payslipComponent)
                    : Text(payslipComponent.componentName ?? "-"),
              ),
              const SizedBox(
                width: 15,
              ),
              _isEditMode && isEditable && payslipComponent.isEditMode
                  ? getEditablePayslipComponentTypeWidget(payslipComponent)
                  : Text(payslipComponent.componentType ?? "-"),
              if (_isEditMode && isEditable)
                const SizedBox(
                  width: 15,
                ),
              if (_isEditMode && isEditable && payslipComponent.payslipComponentId != null) getCheckButtonWidgetForPayslipComponent(payslipComponent),
            ],
          ),
        ),
      ),
    );
  }

  Widget getEditablePayslipComponentNameWidget(PayslipComponentBean payslipComponent) {
    return TextField(
      controller: payslipComponent.componentNameController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'Component Name',
        hintText: 'Component Name',
        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      onChanged: (String e) => setState(() => payslipComponent.componentName = e),
      style: const TextStyle(
        fontSize: 12,
      ),
      autofocus: true,
    );
  }

  Widget getEditablePayslipComponentTypeWidget(PayslipComponentBean payslipComponent) {
    return SizedBox(
      height: 75,
      width: 150,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DropdownButton(
            hint: const Center(child: Text("Select Type")),
            underline: Container(),
            isExpanded: false,
            value: payslipComponent.componentType,
            items: ["EARNINGS", "DEDUCTIONS"]
                .map((e) => DropdownMenuItem(
                      child: Text(
                        e.toLowerCase().capitalize(),
                      ),
                      value: e,
                    ))
                .toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => payslipComponent.componentType = newValue);
              }
            }),
      ),
    );
  }

  GestureDetector getCheckButtonWidgetForPayslipComponent(PayslipComponentBean payslipComponent) {
    return GestureDetector(
      onTap: () {
        if (payslipComponent.isEditMode) {
          _saveChangesDialogue(payslipComponent);
        } else {
          setState(() {
            payslipComponent.isEditMode = !payslipComponent.isEditMode;
          });
        }
      },
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        height: 50,
        width: 50,
        borderRadius: 50,
        spread: 1,
        child: !payslipComponent.isEditMode ? const Icon(Icons.edit) : const Icon(Icons.done),
      ),
    );
  }
}
