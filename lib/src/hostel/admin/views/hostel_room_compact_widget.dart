import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/hostel/model/hostels.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class HostelRoomCompactWidget extends StatefulWidget {
  const HostelRoomCompactWidget({
    Key? key,
    required this.adminProfile,
    required this.hostel,
    required this.room,
    required this.employees,
    required this.studentProfiles,
    required this.isEditMode,
    required this.editActionForRoom,
    required this.migrateStudent,
    required this.addStudentActionForRoom,
    required this.newStudentBedInfo,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final Hostel hostel;
  final HostelRoom room;
  final List<SchoolWiseEmployeeBean> employees;
  final List<StudentProfile> studentProfiles;
  final bool isEditMode;
  final Function editActionForRoom;
  final Function migrateStudent;
  final Function addStudentActionForRoom;
  final StudentBedInfo newStudentBedInfo;

  @override
  State<HostelRoomCompactWidget> createState() => _HostelRoomCompactWidgetState();
}

class _HostelRoomCompactWidgetState extends State<HostelRoomCompactWidget> {
  bool isExpanded = true;
  final ScrollController _controller = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  List<StudentBedInfo> get studentBedInfoList => (widget.room.studentBedInfoList ?? []).where((e) => e != null).map((e) => e!).toList();

  SchoolWiseEmployeeBean? get warden => widget.employees.where((e) => e.employeeId == widget.room.wardenId).firstOrNull;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _scaffoldKey,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              roomHeader(),
              if (widget.room.comment != null) const SizedBox(height: 10),
              if (widget.room.comment != null) Text(widget.room.comment ?? "-"),
              if (widget.room.wardenId != null) const SizedBox(height: 10),
              if (widget.room.wardenId != null) Text(warden?.employeeName ?? "-"),
              const SizedBox(height: 10),
              !isExpanded && !widget.isEditMode
                  ? noOfStudentsRow(IconButton(
                      onPressed: () => setState(() => isExpanded = true),
                      icon: const Icon(Icons.arrow_drop_down),
                    ))
                  : Column(
                      children: [
                        noOfStudentsRow(IconButton(
                          onPressed: () {
                            if (!widget.isEditMode) setState(() => isExpanded = false);
                          },
                          icon: const Icon(Icons.arrow_drop_up),
                        )),
                        const SizedBox(height: 10),
                        buildStudentsDatatable(),
                      ],
                    ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Row noOfStudentsRow(Widget iconButton) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Expanded(child: Text("No. of students:")),
        Text("${(widget.room.studentBedInfoList?.map((e) => e?.studentId).whereNotNull() ?? []).length}"),
        const SizedBox(width: 10),
        iconButton,
      ],
    );
  }

  Row noOfBedsRow(Widget iconButton) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Expanded(child: Text("No. of beds:")),
        Text("${(widget.room.studentBedInfoList ?? []).length}"),
        const SizedBox(width: 10),
        iconButton,
      ],
    );
  }

  Widget roomHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            widget.room.roomName ?? "-",
            style: GoogleFonts.archivoBlack(
              textStyle: TextStyle(
                fontSize: 36,
                color: clayContainerTextColor(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        widget.isEditMode
            ? fab(
                const Icon(Icons.check),
                "Done",
                () => widget.editActionForRoom((widget.hostel.rooms ?? []).indexWhere((e) => e == widget.room)),
                color: Colors.green,
              )
            : fab(
                const Icon(Icons.edit),
                "Edit",
                () => widget.editActionForRoom((widget.hostel.rooms ?? []).indexWhere((e) => e == widget.room)),
                color: Colors.blue,
              ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget buildStudentsDatatable() {
    StudentProfile? newStudent = widget.studentProfiles.where((e) => e.studentId == widget.newStudentBedInfo.studentId).firstOrNull;
    return ClayContainer(
      depth: 40,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      emboss: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        width: double.infinity,
        child: Scrollbar(
          thumbVisibility: true,
          controller: _controller,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _controller,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: DataTable(
                columns: [
                  // const DataColumn(label: Text('Admission Number')),
                  const DataColumn(label: Text('Bed Info')),
                  const DataColumn(label: Text('Class')),
                  // const DataColumn(label: Text('Roll No.')),
                  const DataColumn(label: Text('Student Name')),
                  const DataColumn(label: Text('Guardian Name')),
                  const DataColumn(label: Text('Mobile')),
                  if (widget.isEditMode) const DataColumn(label: Text("Transfer")),
                  if (widget.isEditMode) const DataColumn(label: Text("Remove")),
                ],
                rows: studentBedInfoList.map((eachStudentBedInfo) {
                      StudentProfile studentProfile = widget.studentProfiles.where((e) => e.studentId == eachStudentBedInfo.studentId).first;
                      return DataRow(
                        cells: [
                          // DataCell(Text(studentProfile?.admissionNo ?? "-")),
                          DataCell(bedInfoWidget(eachStudentBedInfo)),
                          DataCell(Text(studentProfile.sectionName ?? "-")),
                          // DataCell(Text(studentProfile?.rollNumber ?? "-")),
                          DataCell(Text(studentProfile.studentFirstName ?? "-")),
                          DataCell(Text(studentProfile.gaurdianFirstName ?? "-")),
                          DataCell(Text(studentProfile.gaurdianMobile ?? "-")),
                          if (widget.isEditMode)
                            DataCell(
                              editActionWidget(
                                studentProfile.studentId!,
                                const Icon(Icons.move_down),
                                migrateStudentAlert,
                              ),
                            ),
                          if (widget.isEditMode)
                            DataCell(
                              editActionWidget(
                                studentProfile.studentId!,
                                const Icon(Icons.delete, color: Colors.red),
                                deleteStudentAlert,
                              ),
                            ),
                        ],
                      );
                    }).toList() +
                    [
                      if (widget.isEditMode)
                        DataRow(
                          cells: [
                            // DataCell(Text(studentProfile?.admissionNo ?? "-")),
                            DataCell(bedInfoWidget(widget.newStudentBedInfo)),
                            DataCell(Text(newStudent?.sectionName ?? "-")),
                            // DataCell(Text(newStudent?.rollNumber ?? "-")),
                            DataCell(_studentSearchableDropDown()),
                            DataCell(Text(newStudent?.gaurdianFirstName ?? "-")),
                            DataCell(Text(newStudent?.gaurdianMobile ?? "-")),
                            if (widget.isEditMode)
                              DataCell(
                                addStudentActionWidget(
                                  widget.newStudentBedInfo,
                                  const Icon(Icons.add),
                                  () async {
                                    await widget.addStudentActionForRoom(widget.newStudentBedInfo);
                                  },
                                ),
                              ),
                            if (widget.isEditMode) DataCell(Container()),
                          ],
                        ),
                    ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _studentSearchableDropDown() {
    return InputDecorator(
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.fromLTRB(4, 8, 4, 8),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: DropdownSearch<StudentProfile>(
          mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
          selectedItem: widget.studentProfiles.where((e) => e.studentId == widget.newStudentBedInfo.studentId).firstOrNull,
          items: widget.studentProfiles.where((e) => !(widget.room.studentBedInfoList ?? []).map((e) => e?.studentId).contains(e.studentId)).toList(),
          itemAsString: (StudentProfile? student) {
            return student == null
                ? ""
                : [
                      ((student.rollNumber ?? "") == "" ? "" : student.rollNumber! + "."),
                      student.studentFirstName ?? "",
                      student.studentMiddleName ?? "",
                      student.studentLastName ?? ""
                    ].where((e) => e != "").join(" ").trim() +
                    " - ${student.sectionName}";
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, StudentProfile? student) {
            return buildStudentWidget(student ?? StudentProfile());
          },
          onChanged: (StudentProfile? student) {
            setState(() {
              widget.newStudentBedInfo.studentId = student?.studentId;
            });
          },
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
    );
  }

  Widget buildStudentWidget(StudentProfile e) {
    return SizedBox(
      width: 150,
      child: Text(
        ((e.rollNumber ?? "") == "" ? "" : e.rollNumber! + ". ") +
            ([e.studentFirstName ?? "", e.studentMiddleName ?? "", e.studentLastName ?? ""].where((e) => e != "").join(" ") +
                    " - ${e.sectionName ?? ""}")
                .trim(),
        style: const TextStyle(
          fontSize: 14,
        ),
        overflow: TextOverflow.visible,
        maxLines: 3,
      ),
    );
  }

  Widget bedInfoWidget(StudentBedInfo eachStudentBedInfo) {
    if (widget.isEditMode) {
      return TextFormField(
        controller: eachStudentBedInfo.bedInfoTextEditor,
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
        ),
        onChanged: (String? newText) => setState(() => eachStudentBedInfo.bedInfo = newText),
        maxLines: null,
        style: const TextStyle(
          fontSize: 16,
        ),
        textAlign: TextAlign.start,
      );
    }
    return Text(eachStudentBedInfo.bedInfo ?? "-");
  }

  Widget addStudentActionWidget(StudentBedInfo newStudentBedInfo, Widget icon, Function action) {
    return GestureDetector(
      onTap: () async => newStudentBedInfo.studentId == null ? {} : await action(),
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 100,
        spread: 3,
        height: 25,
        width: 25,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: icon,
          ),
        ),
      ),
    );
  }

  Widget editActionWidget(int studentId, Widget icon, Function action) {
    return GestureDetector(
      onTap: () async => await action(studentId),
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 100,
        spread: 3,
        height: 25,
        width: 25,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: icon,
          ),
        ),
      ),
    );
  }

  Future<void> deleteStudentAlert(int studentId) async {
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: const Text("Remove student"),
          content: const Text("Are you sure you want to remove the student?"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await widget.migrateStudent(studentId, widget.room.roomId, null);
              },
              child: const Text("YES"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> migrateStudentAlert(int studentId) async {
    int? newRoomId = widget.room.roomId;
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: const Text("Transfer Student To"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                child: ListView(
                  children: [
                    ...(widget.hostel.rooms ?? []).map(
                      (e) => RadioListTile<int?>(
                        value: e?.roomId,
                        groupValue: newRoomId,
                        onChanged: (onChanged) => setState(() => newRoomId = onChanged),
                        title: Text(e?.roomName ?? "-"),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text("YES"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
    if (newRoomId != null) {
      await widget.migrateStudent(studentId, widget.room.roomId, newRoomId);
    }
  }

  Widget fab(Icon icon, String text, Function() action, {Function()? postAction, Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await action();
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (postAction != null) {
              await postAction();
            }
          });
        },
        child: ClayButton(
          surfaceColor: color ?? clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 3,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
