import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/hostel/admin/views/hostel_room_compact_widget.dart';
import 'package:schoolsgo_web/src/hostel/model/hostels.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class HostelRoomsScreen extends StatefulWidget {
  const HostelRoomsScreen({
    Key? key,
    required this.adminProfile,
    required this.hostel,
    required this.employees,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final Hostel hostel;
  final List<SchoolWiseEmployeeBean> employees;

  @override
  State<HostelRoomsScreen> createState() => _HostelRoomsScreenState();
}

class _HostelRoomsScreenState extends State<HostelRoomsScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<StudentProfile> studentProfiles = [];
  int? editingRoomId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
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
      studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.hostel.hostelName ?? "-"),
        actions: [
          buildRoleButtonForAppBar(context, widget.adminProfile),
        ],
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled() ? null : AdminAppDrawer(adminProfile: widget.adminProfile),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : (widget.hostel.rooms ?? []).isEmpty
              ? const Center(
                  child: Text("No rooms registered.."),
                )
              : ListView(
                  children: [
                    for (int i = 0; i < (widget.hostel.rooms ?? []).length; i++) eachRoomWidget(i),
                  ],
                ),
    );
  }

  Widget eachRoomWidget(int hostelRoomIndex) {
    if ((widget.hostel.rooms ?? []).isEmpty ||
        hostelRoomIndex > (widget.hostel.rooms ?? []).length ||
        (widget.hostel.rooms ?? [])[hostelRoomIndex] == null) return Container();
    return HostelRoomCompactWidget(
      adminProfile: widget.adminProfile,
      hostel: widget.hostel,
      room: (widget.hostel.rooms ?? [])[hostelRoomIndex]!,
      employees: widget.employees,
      studentProfiles: studentProfiles,
      isEditMode: editingRoomId == hostelRoomIndex,
      editActionForRoom: editActionForRoom,
      migrateStudent: migrateStudent,
      addStudentActionForRoom: addStudentActionForRoom,
      newStudentBedInfo: StudentBedInfo(
        studentId: null,
        bedInfo: null,
        hostelId: widget.hostel.hostelId,
        hostelName: widget.hostel.hostelName,
        roomId: widget.hostel.rooms![hostelRoomIndex]!.roomId,
        roomName: widget.hostel.rooms![hostelRoomIndex]!.roomName,
        wardenId: widget.hostel.rooms![hostelRoomIndex]!.wardenId,
      ),
    );
  }

  Future<void> addStudentActionForRoom(StudentBedInfo newStudent) async {
    setState(() => _isLoading = true);
    print("101: ${newStudent.toJson()}");
    (widget.hostel.rooms ?? []).where((e) => e?.roomId == newStudent.roomId).forEach((eachRoom) {
      setState(() {
        eachRoom!.studentBedInfoList ??= [];
        eachRoom.studentBedInfoList?.add(newStudent);
      });
    });
    setState(() => _isLoading = false);
  }

  Future<void> editActionForRoom(int roomIndex) async {
    setState(() => _isLoading = true);
    if (editingRoomId == roomIndex) {
      //  TODO save changes
      setState(() => editingRoomId = null);
    } else {
      setState(() => editingRoomId = roomIndex);
    }
    setState(() => _isLoading = false);
  }

  Future<void> migrateStudent(int studentId, int oldRoomId, int? newRoomId) async {
    print("110: $studentId, $oldRoomId, $newRoomId");
    setState(() => _isLoading = true);
    (widget.hostel.rooms ?? []).where((e) => e?.roomId == oldRoomId).forEach((eachRoom) {
      setState(() {
        int studentIndex = (eachRoom?.studentBedInfoList ?? []).indexWhere((e) => e?.studentId == studentId);
        if (studentIndex >= 0) {
          (eachRoom?.studentBedInfoList ?? []).removeAt(studentIndex);
        }
      });
    });
    if (newRoomId != null) {
      (widget.hostel.rooms ?? []).where((e) => e?.roomId == newRoomId).forEach((eachRoom) {
        setState(() {
          eachRoom!.studentBedInfoList ??= [];
          eachRoom.studentBedInfoList!.add(StudentBedInfo(
            studentId: studentId,
            bedInfo: null,
            hostelId: eachRoom.hostelId,
            hostelName: eachRoom.hostelName,
            roomId: eachRoom.roomId,
            roomName: eachRoom.roomName,
            wardenId: eachRoom.wardenId,
          ));
        });
      });
    }
    setState(() => _isLoading = false);
    print("124: $studentId, $oldRoomId, $newRoomId");
  }
}
