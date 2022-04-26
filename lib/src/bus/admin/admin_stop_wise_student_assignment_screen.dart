import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_stepper/custom_stepper.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class AdminStopWiseStudentAssignmentScreen extends StatefulWidget {
  const AdminStopWiseStudentAssignmentScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _AdminStopWiseStudentAssignmentScreenState createState() => _AdminStopWiseStudentAssignmentScreenState();
}

class _AdminStopWiseStudentAssignmentScreenState extends State<AdminStopWiseStudentAssignmentScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<BusRouteInfo> busRouteInfoBeans = [];
  List<BusRouteInfo> originalBusRouteInfoBeans = [];

  List<_SectionWiseStudentsBean> sectionWiseStudentBeans = [];
  List<StudentProfile> students = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isEditMode = false;
    });

    GetBusRouteDetailsResponse getBusRouteDetailsResponse = await getBusRouteDetails(GetBusRouteDetailsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getBusRouteDetailsResponse.httpStatus != "OK" || getBusRouteDetailsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        busRouteInfoBeans = getBusRouteDetailsResponse.busRouteInfoBeanList?.map((e) => e!).toList() ?? [];
        originalBusRouteInfoBeans =
            GetBusRouteDetailsResponse.fromJson(getBusRouteDetailsResponse.origJson()).busRouteInfoBeanList?.map((e) => e!).toList() ?? [];
      });
    }

    List<Section> sections = [];
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sections = getSectionsResponse.sections!.map((e) => e!).toList();
      });
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
    } else {
      setState(() {
        students = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
        students.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      });
    }

    for (Section eachSection in sections) {
      List<StudentProfile> sectionWiseStudents = [];
      for (StudentProfile eachStudent in students) {
        if (eachSection.sectionId == eachStudent.sectionId) {
          sectionWiseStudents.add(eachStudent);
        }
      }
      sectionWiseStudentBeans.add(_SectionWiseStudentsBean(
        section: eachSection,
        students: sectionWiseStudents,
      ));
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
        title: const Text("Student - Bus Assignment"),
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
              children: busRouteInfoBeans.map((e) => busRouteWidget(e)).toList() +
                  [
                    const SizedBox(
                      height: 250,
                    ),
                  ],
            ),
      floatingActionButton: _buildEditButton(context),
    );
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });
    List<StopWiseStudentUpdateBean> updateBeans = [];
    List<RouteStopWiseStudent> oldStudentsList = originalBusRouteInfoBeans
        .map((e) => e.busRouteStopsList ?? [])
        .expand((i) => i)
        .where((e) => e != null)
        .map((e) => e!)
        .map((e) => e.students ?? [])
        .expand((i) => i)
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
    List<RouteStopWiseStudent> newStudentsList = busRouteInfoBeans
        .map((e) => e.busRouteStopsList ?? [])
        .expand((i) => i)
        .where((e) => e != null)
        .map((e) => e!)
        .map((e) => e.students ?? [])
        .expand((i) => i)
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
    for (StudentProfile eachStudent in students) {
      int? oldStopId = oldStudentsList.where((e) => e.studentId == eachStudent.studentId).firstOrNull?.busStopId;
      int? newStopId = newStudentsList.where((e) => e.studentId == eachStudent.studentId).firstOrNull?.busStopId;
      print("170: ${eachStudent.studentId} - $oldStopId - $newStopId");
      if ((oldStopId == null && newStopId != null) ||
          (oldStopId != null && newStopId == null) ||
          (oldStopId != null && newStopId != null && oldStopId != newStopId)) {
        updateBeans.add(StopWiseStudentUpdateBean(
          studentId: eachStudent.studentId,
          oldStopId: oldStopId,
          newStopId: newStopId,
        ));
      }
    }
    print("178: ${updateBeans.map((e) => e.toJson()).join("\n")}");
    if (updateBeans.isNotEmpty) {
      CreateOrUpdateStopWiseStudentsAssignmentResponse createOrUpdateStopWiseStudentsAssignmentResponse =
          await createOrUpdateStopWiseStudentsAssignment(CreateOrUpdateStopWiseStudentsAssignmentRequest(
        agent: widget.adminProfile.userId,
        schoolId: widget.adminProfile.schoolId,
        stopWiseStudentBeans: updateBeans,
      ));
      if (createOrUpdateStopWiseStudentsAssignmentResponse.httpStatus != "OK" ||
          createOrUpdateStopWiseStudentsAssignmentResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Changes updated successfully..!"),
          ),
        );
        _loadData();
      }
    }
    setState(() {
      _isLoading = false;
      _isEditMode = true;
    });
  }

  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isEditMode) {
          showDialog(
              context: _scaffoldKey.currentContext!,
              builder: (currentContext) {
                return AlertDialog(
                  title: const Text("Student - Bus Assignment"),
                  content: const Text("Are you sure you want to save changes?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _saveChanges();
                      },
                      child: const Text("YES"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadData();
                      },
                      child: const Text("NO"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                );
              });
        } else {
          setState(() {
            _isEditMode = !_isEditMode;
          });
        }
      },
      child: _isEditMode
          ? ClayButton(
              color: clayContainerColor(context),
              height: 50,
              width: 50,
              borderRadius: 100,
              spread: 4,
              child: const Icon(
                Icons.check,
              ),
            )
          : ClayButton(
              color: clayContainerColor(context),
              height: 50,
              width: 50,
              borderRadius: 100,
              spread: 4,
              child: const Icon(
                Icons.edit,
              ),
            ),
    );
  }

  Widget busRouteWidget(BusRouteInfo busRouteInfo) {
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
            children: [
              routeWidget(busRouteInfo),
              busForRouteWidgetReadMode(BusBaseDetails(
                schoolId: busRouteInfo.schoolId,
                busDriverProfilePhotoUrl: busRouteInfo.busDriverProfilePhotoUrl,
                busDriverName: busRouteInfo.busDriverName,
                busDriverId: busRouteInfo.busDriverId,
                busName: busRouteInfo.busName,
                regNo: busRouteInfo.regNo,
                busId: busRouteInfo.busId,
                routeId: busRouteInfo.busRouteId,
                busRouteInfo: busRouteInfo,
              )),
              if (busRouteInfo.isExpanded) busRouteStopsStepper(busRouteInfo),
            ],
          ),
        ),
      ),
    );
  }

  Widget busForRouteWidgetReadMode(BusBaseDetails? bus) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            bus?.busName ?? "-",
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Registration number: ${bus?.regNo ?? "-"}",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      bus == null || bus.busDriverProfilePhotoUrl == null
                          ? SvgPicture.asset(
                              "assets/images/bus_driver.svg",
                              width: 45,
                              height: 45,
                            )
                          : Image.network(
                              bus.busDriverProfilePhotoUrl!,
                              width: 45,
                              height: 45,
                              fit: BoxFit.scaleDown,
                            ),
                      const SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Text(
                          bus?.busDriverName ?? "-",
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget routeWidget(BusRouteInfo busRouteInfo) {
    return Column(
      children: [
        const SizedBox(
          height: 12,
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                busRouteInfo.isExpanded = !busRouteInfo.isExpanded;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    busRouteInfo.busRouteName ?? "-",
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: busRouteInfo.isExpanded ? const Icon(Icons.keyboard_arrow_up) : const Icon(Icons.keyboard_arrow_down),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }

  CustomStepper busRouteStopsStepper(BusRouteInfo busRouteInfo) {
    List<CustomStep> widgets = [];
    for (int stopIndex = 0; stopIndex < (busRouteInfo.busRouteStopsList ?? []).length; stopIndex++) {
      widgets.add(
        CustomStep(
          isActive: busRouteInfo.expandAllStops,
          title: _isEditMode
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        busRouteInfo.busRouteStopsList?[stopIndex]?.terminalName ?? "-",
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (context) {
                            return StudentPickerDialogue(
                              context: _scaffoldKey.currentContext!,
                              busRouteInfoList: busRouteInfoBeans,
                              routeIndex: busRouteInfoBeans.indexOf(busRouteInfo),
                              stopIndex: stopIndex,
                              sectionWiseStudentBeans: sectionWiseStudentBeans,
                              adminProfile: widget.adminProfile,
                            );
                          },
                        );
                        setState(() {});
                      },
                      child: ClayButton(
                        color: clayContainerColor(context),
                        height: 25,
                        width: 25,
                        borderRadius: 100,
                        spread: 4,
                        child: const Icon(
                          Icons.add,
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  busRouteInfo.busRouteStopsList?[stopIndex]?.terminalName ?? "-",
                ),
          subtitle: Text(
            "Pick up time: ${busRouteInfo.busRouteStopsList![stopIndex]!.pickUpTime == null ? "-" : convert24To12HourFormat(busRouteInfo.busRouteStopsList![stopIndex]!.pickUpTime!)}\n"
            "Drop time: ${busRouteInfo.busRouteStopsList![stopIndex]!.dropTime == null ? "-" : convert24To12HourFormat(busRouteInfo.busRouteStopsList![stopIndex]!.dropTime!)}",
          ),
          content: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(20),
              child: ClayContainer(
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                depth: 40,
                emboss: true,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (busRouteInfo.busRouteStopsList?[stopIndex]?.students ?? []).isEmpty
                        ? [const Text("-")]
                        : ((busRouteInfo.busRouteStopsList?[stopIndex]?.students ?? [])
                              ..sort(
                                (a, b) => (a?.sectionId ?? 0).compareTo(b?.sectionId ?? 0) == 0
                                    ? (int.tryParse(a?.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b?.rollNumber ?? "") ?? 0))
                                    : (a?.sectionId ?? 0).compareTo(b?.sectionId ?? 0),
                              ))
                            .map((e) => buildStudentWidget(e))
                            .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return CustomStepper(
      areAllStepsExpanded: busRouteInfo.expandAllStops,
      physics: const BouncingScrollPhysics(),
      canRequestFocus: false,
      lineHeight: 8.0,
      type: StepperType.vertical,
      steps: widgets,
      length: widgets.length,
      currentStep: busRouteInfo.currentStep,
      onStepTapped: (int newStep) {
        setState(() {
          busRouteInfo.expandAllStops = !busRouteInfo.expandAllStops;
          busRouteInfo.currentStep = newStep;
        });
      },
      onStepContinue: () {
        if (busRouteInfo.currentStep < (busRouteInfo.busRouteStopsList ?? []).length - 1) {
          setState(() {
            busRouteInfo.currentStep += 1;
          });
        }
      },
      onStepCancel: () {
        setState(() {
          busRouteInfo.isExpanded = false;
        });
      },
      controlsBuilder: (BuildContext context, CustomControlsDetails details) {
        return Container();
      },
    );
  }

  Widget buildStudentWidget(RouteStopWiseStudent? e) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text("${e?.studentName} (${e?.sectionName}${e?.rollNumber == null ? "" : " - ${e?.rollNumber}"})"),
        ),
      ],
    );
  }
}

class StudentPickerDialogue extends StatefulWidget {
  const StudentPickerDialogue({
    Key? key,
    required this.context,
    required this.busRouteInfoList,
    required this.routeIndex,
    required this.stopIndex,
    required this.sectionWiseStudentBeans,
    required this.adminProfile,
  }) : super(key: key);

  final BuildContext context;
  final List<BusRouteInfo> busRouteInfoList;
  final int routeIndex;
  final int stopIndex;
  final List<_SectionWiseStudentsBean> sectionWiseStudentBeans;
  final AdminProfile adminProfile;

  @override
  State<StudentPickerDialogue> createState() => _StudentPickerDialogueState();
}

class _StudentPickerDialogueState extends State<StudentPickerDialogue> {
  BusRouteStop? stop;
  late BusRouteInfo route;

  @override
  void initState() {
    super.initState();
    route = widget.busRouteInfoList.toList()[widget.routeIndex];
    stop = route.busRouteStopsList?[widget.stopIndex];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("${route.busRouteName} - ${stop?.terminalName}"),
      content: SizedBox(
        height: MediaQuery.of(widget.context).size.height - 100,
        width: MediaQuery.of(widget.context).orientation == Orientation.landscape
            ? MediaQuery.of(widget.context).size.width - 400
            : MediaQuery.of(widget.context).size.width - 100,
        child: ListView(
          children: widget.sectionWiseStudentBeans
              .map((e) => Container(
                    margin: const EdgeInsets.fromLTRB(3, 10, 3, 10),
                    child: ClayContainer(
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 10,
                      depth: 40,
                      emboss: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.section.sectionName ?? "-",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (StudentProfile eachStudent in e.students)
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: CheckboxListTile(
                                controlAffinity: ListTileControlAffinity.leading,
                                value: (stop?.students ?? []).map((e) => e?.studentId).contains(eachStudent.studentId),
                                onChanged: (bool? value) {
                                  if (value != null && value) {
                                    RouteStopWiseStudent? prev = widget.busRouteInfoList
                                        .map((e) => e.busRouteStopsList ?? [])
                                        .expand((i) => i)
                                        .where((e) => e != null)
                                        .map((e) => e!)
                                        .map((e) => e.students ?? [])
                                        .expand((i) => i)
                                        .where((e) => e != null)
                                        .map((e) => e!)
                                        .where((e) => e.studentId == eachStudent.studentId)
                                        .firstOrNull;
                                    if (prev != null) {
                                      showReassignDialogue(eachStudent, prev);
                                    } else {
                                      setState(() {
                                        addStudentToStop(eachStudent);
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      removeStudentFromStop(eachStudent, null);
                                    });
                                  }
                                },
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        (eachStudent.rollNumber == null ? "" : eachStudent.rollNumber! + ". ") +
                                            ((eachStudent.studentFirstName == null ? "" : (eachStudent.studentFirstName ?? "") + " ") +
                                                    (eachStudent.studentMiddleName == null ? "" : (eachStudent.studentMiddleName ?? "") + " ") +
                                                    (eachStudent.studentLastName == null ? "" : (eachStudent.studentLastName ?? "") + " "))
                                                .trim(),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: Text(eachStudent.sectionName ?? "-"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(10),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Confirm",
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
            ),
          ),
        ),
      ],
    );
  }

  void showReassignDialogue(StudentProfile eachStudent, RouteStopWiseStudent prev) {
    showDialog<void>(
      context: widget.context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Student reassignment'),
          content: Text("${eachStudent.studentFirstName} is already assigned to\n"
              "Route: ${prev.routeName}\n"
              "Stop: ${prev.busStopName}.\n"
              "Do you want to reassign?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  removeStudentFromStop(eachStudent, prev.busStopId);
                  addStudentToStop(eachStudent);
                });
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void removeStudentFromStop(StudentProfile eachStudent, int? stopId) {
    if (stopId != null) {
      BusRouteStop? oldStop = widget.busRouteInfoList
          .map((e) => e.busRouteStopsList ?? [])
          .expand((i) => i)
          .where((e) => e != null)
          .map((e) => e!)
          .where((e) => e.busRouteStopId == stopId)
          .firstOrNull;
      if (oldStop != null) {
        oldStop.students?.removeWhere((e) => e?.studentId == eachStudent.studentId);
      }
    } else {
      stop?.students?.removeWhere((e) => e?.studentId == eachStudent.studentId);
    }
  }

  void addStudentToStop(StudentProfile eachStudent) {
    stop?.students?.add(
      RouteStopWiseStudent(
        busStopId: stop?.busRouteStopId,
        busStopName: stop?.terminalName,
        routeId: route.busRouteId,
        routeName: route.busRouteName,
        busId: route.busId,
        busName: route.busName,
        busDiverId: route.busDriverId,
        busDriverName: route.busDriverName,
        studentId: eachStudent.studentId,
        studentName: ((eachStudent.studentFirstName == null ? "" : (eachStudent.studentFirstName ?? "") + " ") +
                (eachStudent.studentMiddleName == null ? "" : (eachStudent.studentMiddleName ?? "") + " ") +
                (eachStudent.studentLastName == null ? "" : (eachStudent.studentLastName ?? "") + " "))
            .trim(),
        rollNumber: eachStudent.rollNumber,
        sectionId: eachStudent.sectionId,
        sectionName: eachStudent.sectionName,
        agent: widget.adminProfile.userId,
      ),
    );
  }
}

class _SectionWiseStudentsBean {
  late Section section;
  late List<StudentProfile> students;

  _SectionWiseStudentsBean({required this.section, required this.students});
}
