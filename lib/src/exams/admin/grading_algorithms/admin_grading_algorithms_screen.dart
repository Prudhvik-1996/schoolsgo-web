import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/decimal_text_input_formatter.dart';
import 'package:schoolsgo_web/src/common_components/number_range_input_formatter.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminGradingAlgorithmsScreen extends StatefulWidget {
  const AdminGradingAlgorithmsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/grading_algorithms";

  @override
  _AdminGradingAlgorithmsScreenState createState() => _AdminGradingAlgorithmsScreenState();
}

class _AdminGradingAlgorithmsScreenState extends State<AdminGradingAlgorithmsScreen> {
  bool _isLoading = true;
  bool _isAddNew = false;

  List<MarkingAlgorithmBean> _markingAlgorithmBeans = [];
  late MarkingAlgorithmBean _newMarkingAlgorithm;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _newMarkingAlgorithm = MarkingAlgorithmBean(
        schoolName: widget.adminProfile.schoolName,
        schoolId: widget.adminProfile.schoolId,
        agent: widget.adminProfile.userId,
        markingAlgorithmRangeBeanList: [
          MarkingAlgorithmRangeBean(
            schoolId: widget.adminProfile.schoolId,
            status: "inactive",
            agent: widget.adminProfile.userId,
            schoolName: widget.adminProfile.schoolName,
            endRange: 100,
          ),
        ],
      );
    });

    GetMarkingAlgorithmsResponse getMarkingAlgorithmsResponse = await getMarkingAlgorithms(GetMarkingAlgorithmsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getMarkingAlgorithmsResponse.httpStatus == "OK" && getMarkingAlgorithmsResponse.responseStatus == "success") {
      setState(() {
        _markingAlgorithmBeans = getMarkingAlgorithmsResponse.markingAlgorithmBeanList!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grading Algorithms"),
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
          : _bodyScreen(),
      floatingActionButton: _isLoading || widget.adminProfile.isMegaAdmin
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                !_isAddNew ? _addNewExamButton(context) : _createMarkingAlgorithmButton(context),
              ],
            ),
    );
  }

  GestureDetector _createMarkingAlgorithmButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_newMarkingAlgorithm.algorithmName == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Enter Algorithm Name to continue.."),
            ),
          );
          return;
        }
        if (_markingAlgorithmBeans.map((e) => e.algorithmName ?? "-").contains(_newMarkingAlgorithm.algorithmName ?? "-")) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Algorithm name already exists"),
            ),
          );
          return;
        }
        if (!_validateRanges(_newMarkingAlgorithm)) {
          return;
        }
        setState(() {
          _newMarkingAlgorithm.status = "active";
          _isLoading = true;
        });
        CreateOrUpdateMarkingAlgorithmResponse createOrUpdateMarkingAlgorithmResponse =
            await createOrUpdateMarkingAlgorithm(CreateOrUpdateMarkingAlgorithmRequest(
          markingAlgorithmRangeBeanList: _newMarkingAlgorithm.markingAlgorithmRangeBeanList,
          status: _newMarkingAlgorithm.status,
          agent: _newMarkingAlgorithm.agent,
          schoolId: _newMarkingAlgorithm.schoolId,
          schoolName: _newMarkingAlgorithm.schoolName,
          algorithmName: _newMarkingAlgorithm.algorithmName,
          markingAlgorithmId: _newMarkingAlgorithm.markingAlgorithmId,
        ));
        if (createOrUpdateMarkingAlgorithmResponse.httpStatus != "OK" || createOrUpdateMarkingAlgorithmResponse.responseStatus != "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong! Try again later.."),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _markingAlgorithmBeans.add(_newMarkingAlgorithm);
            _newMarkingAlgorithm = MarkingAlgorithmBean(
              schoolName: widget.adminProfile.schoolName,
              schoolId: widget.adminProfile.schoolId,
              agent: widget.adminProfile.userId,
              markingAlgorithmRangeBeanList: [
                MarkingAlgorithmRangeBean(
                  schoolId: widget.adminProfile.schoolId,
                  agent: widget.adminProfile.userId,
                  schoolName: widget.adminProfile.schoolName,
                  endRange: 100,
                ),
              ],
            );
            _isAddNew = !_isAddNew;
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
          margin: const EdgeInsets.all(10),
          child: const Icon(Icons.check),
        ),
      ),
    );
  }

  bool _validateRanges(MarkingAlgorithmBean markingAlgorithm) {
    List<int> allStartRanges =
        markingAlgorithm.markingAlgorithmRangeBeanList!.where((e) => e!.status == 'active').map((e) => e!.startRange ?? 101).toList()..sort();
    if (allStartRanges.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ranges from 0 to 100 are missing"),
        ),
      );
      return false;
    }
    if (allStartRanges[0] != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ranges from 0 to ${allStartRanges[0] - 1} are missing"),
        ),
      );
      return false;
    }
    return true;
  }

  GestureDetector _addNewExamButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAddNew = !_isAddNew;
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
    );
  }

  Widget _bodyScreen() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ListView(
        children: [
          for (MarkingAlgorithmBean eachMarkingAlgorithmBean
              in (_isAddNew ? [_newMarkingAlgorithm] : _markingAlgorithmBeans).where((e) => e.status == null || e.status == 'active'))
            _markingAlgorithmBeanWidget(eachMarkingAlgorithmBean),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }

  Widget _markingAlgorithmBeanWidget(MarkingAlgorithmBean eachMarkingAlgorithmBean) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        child: ClayContainer(
                          depth: 20,
                          color: clayContainerColor(context),
                          spread: 1,
                          borderRadius: 10,
                          child: TextField(
                            enabled: _isAddNew || eachMarkingAlgorithmBean.isEditMode,
                            controller: eachMarkingAlgorithmBean.algorithmNameController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              labelText: 'Algorithm Name',
                              hintText: 'New Marking Algorithm',
                              contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                            ),
                            onChanged: (String e) {
                              setState(() {
                                eachMarkingAlgorithmBean.algorithmName = e;
                              });
                            },
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!widget.adminProfile.isMegaAdmin && _isAddNew)
                    const SizedBox(
                      width: 15,
                    ),
                  if (!widget.adminProfile.isMegaAdmin && _isAddNew)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _newMarkingAlgorithm.markingAlgorithmRangeBeanList = [
                            MarkingAlgorithmRangeBean(
                              schoolId: widget.adminProfile.schoolId,
                              agent: widget.adminProfile.userId,
                              schoolName: widget.adminProfile.schoolName,
                              endRange: 100,
                            ),
                          ];
                        });
                      },
                      child: const ClayButton(
                        borderRadius: 10,
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Center(child: Text("Clear all")),
                        ),
                      ),
                    ),
                  if (!widget.adminProfile.isMegaAdmin && _isAddNew)
                    const SizedBox(
                      width: 15,
                    ),
                  if (!widget.adminProfile.isMegaAdmin && _isAddNew)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isAddNew = !_isAddNew;
                        });
                      },
                      child: const ClayButton(
                        borderRadius: 100,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  if (eachMarkingAlgorithmBean.status != null &&
                      eachMarkingAlgorithmBean.status != "inactive" &&
                      !eachMarkingAlgorithmBean.isEditMode)
                    InkWell(
                      onTap: () {
                        setState(() {
                          eachMarkingAlgorithmBean.isEditMode = !eachMarkingAlgorithmBean.isEditMode;
                        });
                      },
                      child: const ClayButton(
                        borderRadius: 100,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.edit,
                          ),
                        ),
                      ),
                    ),
                  if (eachMarkingAlgorithmBean.status != null && eachMarkingAlgorithmBean.status != "inactive" && eachMarkingAlgorithmBean.isEditMode)
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text("Are you sure you want to delete ${eachMarkingAlgorithmBean.algorithmName ?? "-"}"),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    CreateOrUpdateMarkingAlgorithmResponse createOrUpdateMarkingAlgorithmResponse =
                                        await createOrUpdateMarkingAlgorithm(CreateOrUpdateMarkingAlgorithmRequest(
                                      markingAlgorithmId: eachMarkingAlgorithmBean.markingAlgorithmId,
                                      agent: widget.adminProfile.userId,
                                      status: "inactive",
                                      schoolId: widget.adminProfile.schoolId,
                                    ));
                                    if (createOrUpdateMarkingAlgorithmResponse.httpStatus != "OK" ||
                                        createOrUpdateMarkingAlgorithmResponse.responseStatus != "success") {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Something went wrong! Try again later.."),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        eachMarkingAlgorithmBean.status = "inactive";
                                      });
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  child: const Text(
                                    "YES",
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "NO",
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const ClayButton(
                        borderRadius: 100,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  if (eachMarkingAlgorithmBean.status != null && eachMarkingAlgorithmBean.status != "inactive" && eachMarkingAlgorithmBean.isEditMode)
                    const SizedBox(
                      width: 15,
                    ),
                  if (eachMarkingAlgorithmBean.status != null && eachMarkingAlgorithmBean.status != "inactive" && eachMarkingAlgorithmBean.isEditMode)
                    InkWell(
                      onTap: () async {
                        if (_markingAlgorithmBeans
                            .map((e) => MarkingAlgorithmRangeBean.fromJson(e.origJson()))
                            .map((e) => e.algorithmName ?? "-")
                            .contains(eachMarkingAlgorithmBean.algorithmName ?? "-")) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Algorithm name already exists"),
                            ),
                          );
                          setState(() {
                            eachMarkingAlgorithmBean.isEditMode = false;
                          });
                          return;
                        }
                        setState(() {
                          _isLoading = true;
                        });
                        CreateOrUpdateMarkingAlgorithmResponse createOrUpdateMarkingAlgorithmResponse =
                            await createOrUpdateMarkingAlgorithm(CreateOrUpdateMarkingAlgorithmRequest(
                          markingAlgorithmId: eachMarkingAlgorithmBean.markingAlgorithmId,
                          agent: widget.adminProfile.userId,
                          algorithmName: eachMarkingAlgorithmBean.algorithmName,
                          schoolId: widget.adminProfile.schoolId,
                        ));
                        setState(() {
                          _isLoading = false;
                        });
                        if (createOrUpdateMarkingAlgorithmResponse.httpStatus != "OK" ||
                            createOrUpdateMarkingAlgorithmResponse.responseStatus != "success") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Something went wrong! Try again later.."),
                            ),
                          );
                        } else {
                          setState(() {
                            eachMarkingAlgorithmBean.isEditMode = !eachMarkingAlgorithmBean.isEditMode;
                          });
                        }
                      },
                      child: const ClayButton(
                        borderRadius: 100,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.check,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        "Range",
                        style: TextStyle(
                          color: Colors.blue.shade400,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        "GPA",
                        style: TextStyle(
                          color: Colors.blue.shade400,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        "Grade",
                        style: TextStyle(
                          color: Colors.blue.shade400,
                        ),
                      ),
                    ),
                  ),
                  if (!widget.adminProfile.isMegaAdmin && _isAddNew)
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          "",
                          style: TextStyle(
                            color: Colors.blue.shade400,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              for (MarkingAlgorithmRangeBean eachMarkingAlgorithmRangeBean in (eachMarkingAlgorithmBean.markingAlgorithmRangeBeanList ?? [])
                  .where((e) => e != null)
                  .map((e) => e!)
                  .where((e) => _isAddNew || eachMarkingAlgorithmBean.isEditMode || e.status == 'active'))
                _markingAlgorithmRangeBeanWidget(eachMarkingAlgorithmRangeBean, eachMarkingAlgorithmBean),
            ],
          ),
        ),
      ),
    );
  }

  Widget _markingAlgorithmRangeBeanWidget(MarkingAlgorithmRangeBean eachMarkingAlgorithmRangeBean, MarkingAlgorithmBean eachMarkingAlgorithmBean) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  child: ClayContainer(
                    depth: 20,
                    color: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 10,
                    child: TextField(
                      enabled: _isAddNew,
                      controller: eachMarkingAlgorithmRangeBean.startRangeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                        labelText: 'Start Range',
                        hintText: '91',
                      ),
                      onChanged: (String e) {
                        setState(() {
                          eachMarkingAlgorithmRangeBean.startRange = int.tryParse(e) ?? 0;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        NumericalRangeFormatter(min: 0, max: eachMarkingAlgorithmRangeBean.endRange ?? 100),
                      ],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  child: ClayContainer(
                    depth: 20,
                    color: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 10,
                    child: TextField(
                      enabled: false,
                      controller: eachMarkingAlgorithmRangeBean.endRangeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                        labelText: 'End Range',
                        hintText: '100',
                      ),
                      onChanged: (String e) {
                        setState(() {
                          eachMarkingAlgorithmRangeBean.endRange = int.tryParse(e) ?? 0;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(8),
            child: ClayContainer(
              depth: 20,
              color: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              child: TextField(
                enabled: _isAddNew,
                controller: eachMarkingAlgorithmRangeBean.gpaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  labelText: 'GPA',
                  hintText: '10.0',
                ),
                onChanged: (String e) {
                  setState(() {
                    eachMarkingAlgorithmRangeBean.gpa = double.tryParse(e) ?? 0.0;
                  });
                },
                style: const TextStyle(
                  fontSize: 12,
                ),
                inputFormatters: <TextInputFormatter>[DecimalTextInputFormatter(decimalRange: 2)],
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(8),
            child: ClayContainer(
              depth: 20,
              color: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              child: TextField(
                enabled: _isAddNew,
                controller: eachMarkingAlgorithmRangeBean.gradeController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  labelText: 'Grade',
                  hintText: 'A+',
                ),
                onChanged: (String e) {
                  setState(() {
                    eachMarkingAlgorithmRangeBean.grade = e;
                  });
                },
                style: const TextStyle(
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if (_isAddNew)
          Expanded(
            child: InkWell(
              onTap: () {
                if (eachMarkingAlgorithmRangeBean.status == null || eachMarkingAlgorithmRangeBean.status == "inactive") {
                  if (eachMarkingAlgorithmRangeBean.startRange == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter start range and then continue.."),
                      ),
                    );
                    return;
                  }
                  if (eachMarkingAlgorithmRangeBean.endRange == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter end range and then continue.."),
                      ),
                    );
                    return;
                  }
                  if (eachMarkingAlgorithmRangeBean.grade == null || eachMarkingAlgorithmRangeBean.grade!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter grade and then continue.."),
                      ),
                    );
                    return;
                  }
                  if (eachMarkingAlgorithmRangeBean.gpa == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter gpa and then continue.."),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    eachMarkingAlgorithmRangeBean.status = 'active';
                    if (eachMarkingAlgorithmRangeBean.startRange! != 0) {
                      eachMarkingAlgorithmBean.markingAlgorithmRangeBeanList ??= [];
                      eachMarkingAlgorithmBean.markingAlgorithmRangeBeanList!.add(
                        MarkingAlgorithmRangeBean(
                          schoolId: widget.adminProfile.schoolId,
                          status: "inactive",
                          agent: widget.adminProfile.userId,
                          schoolName: widget.adminProfile.schoolName,
                          endRange: eachMarkingAlgorithmRangeBean.startRange! - 1,
                        ),
                      );
                    }
                  });
                }
              },
              child: eachMarkingAlgorithmRangeBean.status == null || eachMarkingAlgorithmRangeBean.status == "inactive"
                  ? const Icon(
                      Icons.add_circle_outline,
                      color: Colors.green,
                    )
                  : Container(),
            ),
          )
      ],
    );
  }
}
