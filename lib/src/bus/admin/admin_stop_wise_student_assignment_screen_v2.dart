import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/widgets/clay_container.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';

class AdminStopWiseStudentAssignmentScreenV2 extends StatefulWidget {
  const AdminStopWiseStudentAssignmentScreenV2({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<AdminStopWiseStudentAssignmentScreenV2> createState() => _AdminStopWiseStudentAssignmentScreenV2State();
}

class _AdminStopWiseStudentAssignmentScreenV2State extends State<AdminStopWiseStudentAssignmentScreenV2> {
  bool _isLoading = true;
  bool _isEditMode = false;
  bool _isFileDownloading = false;
  final String reportName = "Bus Route Wise Fee Report.xlsx";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<BusRouteInfo> busRouteInfoBeans = [];

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
      _isFileDownloading = false;
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
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            onPressed: () async {
              if (_isEditMode) {
                await _loadData();
              } else {
                setState(() => _isEditMode = !_isEditMode);
              }
            },
          )
        ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                ...busRouteInfoBeans.map((e) => busRouteInfoWidget(e)),
                const SizedBox(
                  height: 250,
                ),
              ],
            ),
    );
  }

  Widget busRouteInfoWidget(BusRouteInfo busRouteInfo) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape ? const EdgeInsets.all(25) : const EdgeInsets.fromLTRB(15, 25, 15, 25),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          padding: MediaQuery.of(context).orientation == Orientation.landscape ? const EdgeInsets.all(25) : const EdgeInsets.fromLTRB(15, 25, 15, 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        busRouteInfo.busRouteName ?? "-",
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.people_sharp,
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ((busRouteInfo.busRouteStopsList ?? []).map((e) => e?.students ?? []).expand((i) => i).length.toString()),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => busRouteInfo.isExpanded = !busRouteInfo.isExpanded),
                      child: ClayButton(
                        depth: 15,
                        surfaceColor: clayContainerColor(context),
                        parentColor: clayContainerColor(context),
                        spread: 2,
                        borderRadius: 100,
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Icon(busRouteInfo.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (!_isEditMode) buildBusFareDetailsWidget(busRouteInfo),
              const SizedBox(height: 12),
              ...(busRouteInfo.busRouteStopsList ?? []).whereNotNull().mapIndexed((index, _) => stopWiseWidget(index, busRouteInfo)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBusFareDetailsWidget(BusRouteInfo busRouteInfo) {
    List<RouteStopWiseStudent> students = (busRouteInfo.busRouteStopsList ?? [])
        .where((e) => e != null)
        .map((e) => e!)
        .map((e) => e.students ?? [])
        .expand((i) => i)
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
    students.sort(
      (a, b) => (a.sectionId ?? 0).compareTo(b.sectionId ?? 0) == 0
          ? (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))
          : (a.sectionId ?? 0).compareTo(b.sectionId ?? 0),
    );
    int totalFee = students.isEmpty ? 0 : students.map((e) => e.busFee ?? 0).reduce((a, b) => a + b);
    int totalFeePaid = students.isEmpty ? 0 : students.map((e) => e.busFeePaid ?? 0).reduce((a, b) => a + b);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        emboss: true,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      "Total Bus Fee:",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Text(
                    "$INR_SYMBOL ${doubleToStringAsFixedForINR(totalFee / 100.0)} /-",
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      "Total Bus Fee Collected",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                  Text(
                    "$INR_SYMBOL ${doubleToStringAsFixedForINR(totalFeePaid / 100.0)} /-",
                    style: const TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      "Total Due",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Text(
                    "$INR_SYMBOL ${doubleToStringAsFixedForINR((totalFee - totalFeePaid) / 100.0)} /-",
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget stopWiseWidget(int index, BusRouteInfo busRouteInfo) {
    BusRouteStop stop = (busRouteInfo.busRouteStopsList ?? []).tryGet(index);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        emboss: true,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, busRouteInfo.isExpanded ? 24 : 12, 18, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${index + 1}"),
                  const SizedBox(width: 8),
                  Expanded(child: Text(stop.terminalName ?? "-")),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.people_sharp,
                    size: 12,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (stop.students ?? []).length.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            if (busRouteInfo.isExpanded)
              Padding(
                padding: const EdgeInsets.all(12),
                child: studentsTableForStop(stop),
              ),
          ],
        ),
      ),
    );
  }

  Widget studentsTableForStop(BusRouteStop stop) {
    return ClayContainer(
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      depth: 40,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 8.0,
            controller: stop.scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: stop.scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DataTable(
                    columns: [
                      const DataColumn(label: Text('S. No.')),
                      const DataColumn(label: Text('Section')),
                      const DataColumn(label: Text('Roll No.')),
                      const DataColumn(label: Text('Student')),
                      if (_isEditMode) const DataColumn(label: Text('Actions')),
                      if (!_isEditMode) const DataColumn(label: Text('Amount')),
                      if (!_isEditMode) const DataColumn(label: Text('Amount Paid')),
                      if (!_isEditMode) const DataColumn(label: Text('Due')),
                    ],
                    rows: [
                      ...(stop.students ?? []).map((e) => e!).where((e) => e.status == 'active').mapIndexed(
                            (index, e) => DataRow(
                              cells: [
                                DataCell(
                                  Text("${index + 1}"),
                                ),
                                DataCell(
                                  Text(e.sectionName ?? "-"),
                                ),
                                DataCell(
                                  Text(e.rollNumber ?? "-"),
                                ),
                                DataCell(
                                  Text(e.studentName ?? "-"),
                                ),
                                if (_isEditMode)
                                  DataCell(
                                    deleteStudentButton(index, stop),
                                  ),
                                if (!_isEditMode)
                                  DataCell(
                                    Text(
                                      "$INR_SYMBOL ${doubleToStringAsFixedForINR((e.busFee ?? 0) / 100.0)} /-   ",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                if (!_isEditMode)
                                  DataCell(
                                    Text(
                                      "$INR_SYMBOL ${doubleToStringAsFixedForINR((e.busFeePaid ?? 0) / 100.0)} /-   ",
                                      style: const TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                if (!_isEditMode)
                                  DataCell(
                                    Text(
                                      "$INR_SYMBOL ${doubleToStringAsFixedForINR(((e.busFee ?? 0) - (e.busFeePaid ?? 0)) / 100.0)} /-   ",
                                      style: const TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                    ],
                  ),
                  if (_isEditMode) addStudentToStop(stop),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget deleteStudentButton(int studentIndex, BusRouteStop stop) {
    RouteStopWiseStudent e = stop.students!.tryGet(studentIndex);
    return IconButton(
      onPressed: () {
        List<StopWiseStudentUpdateBean> toUpdateBeans = [];
        setState(() {
          e.status = 'inactive';
          e.agent = widget.adminProfile.userId;
          toUpdateBeans.add(
            StopWiseStudentUpdateBean(
              studentId: e.studentId,
              oldStopId: e.busStopId,
              newStopId: null,
            ),
          );
          stop.students!.removeAt(studentIndex);
        });
        saveChanges(toUpdateBeans);
        // TODO : make API call
      },
      icon: ClayButton(
        color: clayContainerColor(context),
        height: 75,
        width: 75,
        borderRadius: 100,
        spread: 2,
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget addStudentToStop(BusRouteStop stop) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          _studentSearchableDropDown(stop),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              List<StopWiseStudentUpdateBean> toUpdateBeans = [];
              StudentProfile? newStudent = stop.newStudentToBeAdded;
              if (newStudent == null) return;
              List<RouteStopWiseStudent> routeStopWiseStudentsList = busRouteInfoBeans
                  .map((e) => (e.busRouteStopsList ?? []))
                  .expand((i) => i)
                  .map((e) => e?.students ?? [])
                  .expand((i) => i)
                  .whereNotNull()
                  .toList();
              RouteStopWiseStudent? alreadyAssignedStop =
                  routeStopWiseStudentsList.firstWhereOrNull((e) => e.studentId == newStudent.studentId && e.status == 'active');
              if (alreadyAssignedStop != null) {
                //  showAlertToReassign
                final action = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Reassigning ${newStudent.studentNameAsStringWithSectionAndRollNumber()} from\n"
                        "${alreadyAssignedStop.routeName} :: ${alreadyAssignedStop.busStopName} to\n"
                        "${stop.routeName} :: ${stop.terminalName}",
                      ),
                      content: const Text('Do you want to proceed?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop('Cancel');
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop('OK');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
                if (action != "OK") return;
                setState(() {
                  toUpdateBeans.add(StopWiseStudentUpdateBean(
                    studentId: alreadyAssignedStop.studentId,
                    newStopId: stop.busRouteStopId,
                    oldStopId: alreadyAssignedStop.busStopId,
                  ));
                  stop.newStudentToBeAdded = null;
                });
              } else {
                setState(() {
                  toUpdateBeans.add(StopWiseStudentUpdateBean(
                    studentId: newStudent.studentId,
                    newStopId: stop.busRouteStopId,
                    oldStopId: null,
                  ));
                  stop.newStudentToBeAdded = null;
                });
              }
              RouteStopWiseStudent newStudentInStop = RouteStopWiseStudent(
                studentId: newStudent.studentId,
                sectionName: newStudent.sectionName,
                sectionId: newStudent.sectionId,
                studentName: newStudent.studentFirstName,
                busStopId: stop.busRouteStopId,
                routeId: stop.busRouteStopId,
                status: 'active',
                agent: widget.adminProfile.userId,
                busFee: stop.fare,
                busFeePaid: alreadyAssignedStop?.busFeePaid,
              );
              setState(() {
                alreadyAssignedStop?.status = 'inactive';
                alreadyAssignedStop?.agent = widget.adminProfile.userId;
                stop.students?.add(newStudentInStop);
              });
              saveChanges(toUpdateBeans);
            },
            child: ClayButton(
              depth: 15,
              surfaceColor: Colors.blue,
              parentColor: clayContainerColor(context),
              spread: 2,
              borderRadius: 100,
              height: 36,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(Icons.add),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Future<void> saveChanges(List<StopWiseStudentUpdateBean> toUpdateBeans) async {
    CreateOrUpdateStopWiseStudentsAssignmentResponse createOrUpdateStopWiseStudentsAssignmentResponse =
        await createOrUpdateStopWiseStudentsAssignment(CreateOrUpdateStopWiseStudentsAssignmentRequest(
      agent: widget.adminProfile.userId,
      schoolId: widget.adminProfile.schoolId,
      stopWiseStudentBeans: toUpdateBeans.toSet().toList(),
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
    }
  }

  Widget _studentSearchableDropDown(BusRouteStop stop) {
    return SizedBox(
      width: 250,
      child: InputDecorator(
        isFocused: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          label: Text(
            "New Student",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
          child: DropdownSearch<StudentProfile>(
            mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
            selectedItem: stop.newStudentToBeAdded,
            items: students,
            itemAsString: (StudentProfile? student) {
              return student == null ? "" : student.studentNameAsStringWithSectionAndRollNumber();
            },
            showSearchBox: true,
            dropdownBuilder: (BuildContext context, StudentProfile? student) {
              return buildStudentWidget(student ?? StudentProfile());
            },
            onChanged: (StudentProfile? student) => setState(() => stop.newStudentToBeAdded = student),
            showClearButton: false,
            compareFn: (item, selectedItem) => item?.studentId == selectedItem?.studentId,
            dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
            filterFn: (StudentProfile? student, String? key) {
              return ([
                        ((student?.rollNumber ?? "") == "" ? "" : student!.rollNumber! + "."),
                        student?.studentFirstName ?? "",
                        student?.studentMiddleName ?? "",
                        student?.studentLastName ?? ""
                      ].where((e) => e != "").join(" ") +
                      " - ${student?.sectionName ?? ""}")
                  .toLowerCase()
                  .trim()
                  .contains(key!.toLowerCase());
            },
          ),
        ),
      ),
    );
  }

  Widget buildStudentWidget(StudentProfile e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: ListTile(
        leading: MediaQuery.of(context).orientation == Orientation.portrait
            ? null
            : Container(
                width: 50,
                padding: const EdgeInsets.all(5),
                child: e.studentPhotoUrl == null
                    ? Image.asset(
                        "assets/images/avatar.png",
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        e.studentPhotoUrl!,
                        fit: BoxFit.contain,
                      ),
              ),
        title: AutoSizeText(
          ((e.rollNumber ?? "") == "" ? "" : e.rollNumber! + ". ") +
              ([e.studentFirstName ?? "", e.studentMiddleName ?? "", e.studentLastName ?? ""].where((e) => e != "").join(" ") +
                      " - ${e.sectionName ?? ""}")
                  .trim(),
          style: const TextStyle(
            fontSize: 14,
          ),
          overflow: TextOverflow.visible,
          maxLines: 3,
          minFontSize: 12,
        ),
      ),
    );
  }
}
