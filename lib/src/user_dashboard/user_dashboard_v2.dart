import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:schoolsgo_web/src/admin_dashboard/admin_dashboard.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/ed_admin/add_new_school_page.dart';
import 'package:schoolsgo_web/src/mega_admin/mega_admin_home_page.dart';
import 'package:schoolsgo_web/src/model/academic_years.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/receptionist_dashboard/receptionist_dashboard.dart';
import 'package:schoolsgo_web/src/settings/notification_preference_settings.dart';
import 'package:schoolsgo_web/src/splash_screen/splash_screen.dart';
import 'package:schoolsgo_web/src/student_dashboard/student_dashboard.dart';
import 'package:schoolsgo_web/src/teacher_dashboard/teacher_dashboard.dart';
import 'package:schoolsgo_web/src/user_dashboard/academic_year_map.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboardV2 extends StatefulWidget {
  const UserDashboardV2({
    super.key,
    required this.mobile,
    required this.schoolId,
  });

  final String mobile;
  final int? schoolId;

  static const routeName = "/user_dashboard";

  @override
  State<UserDashboardV2> createState() => _UserDashboardV2State();
}

class _UserDashboardV2State extends State<UserDashboardV2> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  UserDetails? userDetails;

  List<StudentProfile> _studentProfiles = [];
  List<TeacherProfile> _teacherProfiles = [];
  List<AdminProfile> _adminProfiles = [];
  List<OtherUserRoleProfile> _otherRoleProfile = [];
  List<MegaAdminProfile> _megaAdminProfiles = [];
  List<List<MegaAdminProfile>> _groupedMegaAdminsLists = [];

  List<AcademicYearBean> academicYears = [];
  List<AcademicYearMap> academicYearsMap = [];
  AcademicYearMap? selectedAcademicYearMap;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await NotificationPreferenceSettings(prefs, context, false).init();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetUserRolesRequest getUserRolesRequest = GetUserRolesRequest(mobile: widget.mobile);
    GetUserRolesDetailsResponse getUserRolesResponse = await getUserRoles(getUserRolesRequest);
    if (getUserRolesResponse.httpStatus != "OK" || getUserRolesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error Occurred"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Success"),
        ),
      );
      setState(() {
        userDetails = getUserRolesResponse.userDetails;
        _studentProfiles = (getUserRolesResponse.studentProfiles ?? []).map((e) => e!).toList();
        _teacherProfiles = (getUserRolesResponse.teacherProfiles ?? [])
            .map((e) => e!)
            .where((e) => widget.schoolId == null || e.schoolId == widget.schoolId)
            .toList();
        _adminProfiles =
            (getUserRolesResponse.adminProfiles ?? []).map((e) => e!).where((e) => widget.schoolId == null || e.schoolId == widget.schoolId).toList();
        _otherRoleProfile = (getUserRolesResponse.otherUserRoleProfiles ?? [])
            .map((e) => e!)
            .where((e) => widget.schoolId == null || e.schoolId == widget.schoolId)
            .toList();
        _megaAdminProfiles = (getUserRolesResponse.megaAdminProfiles ?? [])
            .map((e) => e!)
            .where((e) => widget.schoolId == null || e.schoolId == widget.schoolId)
            .toList();
        _groupedMegaAdminsLists = groupBy(
          _megaAdminProfiles,
          (MegaAdminProfile profile) => profile.franchiseId,
        ).values.toList();
      });
    }
    GetSchoolWiseAcademicYearsResponse getSchoolWiseAcademicYearsResponse = await getSchoolWiseAcademicYears(
      GetSchoolWiseAcademicYearsRequest(),
    );
    if (getSchoolWiseAcademicYearsResponse.httpStatus == "OK" && getSchoolWiseAcademicYearsResponse.responseStatus == "success") {
      academicYears = getSchoolWiseAcademicYearsResponse.academicYearBeanList?.whereNotNull().toList() ?? [];
      populateAcademicYearsMap(academicYears);
    }
    setState(() => _isLoading = false);
  }

  void populateAcademicYearsMap(List<AcademicYearBean> academicYears) {
    Set<int> uniqueSchoolIds = {};
    _studentProfiles.map((e) => e.schoolId).whereNotNull().forEach((es) => uniqueSchoolIds.add(es));
    _teacherProfiles.map((e) => e.schoolId).whereNotNull().forEach((es) => uniqueSchoolIds.add(es));
    _adminProfiles.map((e) => e.schoolId).whereNotNull().forEach((es) => uniqueSchoolIds.add(es));
    _otherRoleProfile.map((e) => e.schoolId).whereNotNull().forEach((es) => uniqueSchoolIds.add(es));
    academicYears.removeWhere((ea) => !uniqueSchoolIds.contains(ea.schoolId));
    for (AcademicYearBean eachAcademicYear in academicYears) {
      AcademicYearMap? academicYearMap = academicYearsMap.firstWhereOrNull((eam) =>
          eam.startMonth == eachAcademicYear.getStartMonth() &&
          eam.endMonth == eachAcademicYear.getEndMonth() &&
          eam.startYear == eachAcademicYear.getStartYear() &&
          eam.endYear == eachAcademicYear.getEndYear());
      if (academicYearMap == null) {
        academicYearMap = AcademicYearMap(eachAcademicYear.getStartMonth(), eachAcademicYear.getEndMonth(), eachAcademicYear.getStartYear(),
            eachAcademicYear.getEndYear(), [eachAcademicYear.schoolId!]);
        setState(() {
          academicYearsMap.add(academicYearMap!);
        });
      } else {
        setState(() {
          academicYearMap!.schoolIds.add(eachAcademicYear.schoolId!);
        });
      }
    }
    academicYearsMap.sort((b, a) => a.endEquivalent.compareTo(b.endEquivalent));
    setState(() => selectedAcademicYearMap = academicYearsMap.first);
  }

  Future<void> updateSchoolIdInPrefs(int? schoolId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (schoolId == null) {
      prefs.remove('LOGGED_IN_SCHOOL_ID');
    } else {
      prefs.setInt('LOGGED_IN_SCHOOL_ID', schoolId);
    }
  }

  Future<void> updateAcademicYearIdInPrefs(int? academicYearId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (academicYearId == null) {
      prefs.remove('SELECTED_ACADEMIC_YEAR_ID');
    } else {
      prefs.setInt('SELECTED_ACADEMIC_YEAR_ID', academicYearId ?? -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        restorationId: 'UserDashboard',
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("Epsilon Diary"),
          actions: [
            if ([127, 128].contains(userDetails?.userId))
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddNewSchoolPage(
                    userId: userDetails!.userId!,
                  );
                })).then((value) => _loadData()),
                icon: const Icon(Icons.add),
              ),
            logoutButton(context),
          ],
        ),
        drawer: DefaultAppDrawer(
          selectedAcademicYearMap: selectedAcademicYearMap,
          academicYearsMap: academicYearsMap,
          onAcademicYearChange: (AcademicYearMap? newAcademicYearMap) {
            if (newAcademicYearMap == null) return;
            setState(() => selectedAcademicYearMap = newAcademicYearMap);
            Navigator.pop(context);
          },
        ),
        body: SafeArea(
          child: _isLoading
              ? const EpsilonDiaryLoadingWidget()
              : ListView(
                  children: megaAdminProfileButtons(context) +
                      adminProfileButtons(context) +
                      studentProfileButtons(context) +
                      teacherProfileButtons(context) +
                      otherProfileButtons(context) +
                      [
                        const SizedBox(
                          height: 50,
                        ),
                        Image.asset(
                          "assets/images/dashboard_background.png",
                          fit: BoxFit.cover,
                        ),
                      ],
                ),
        ),
      ),
    );
  }

  List<Widget> otherProfileButtons(BuildContext context) {
    return _otherRoleProfile
        .where((e) => doesOtherUserSupportSelectedAcademicYear(e))
        .map(
          (e) => buildRoleButton(
            context,
            (e.roleName ?? "-").capitalize(),
            (e.userName ?? "-"),
            e.schoolName ?? '',
            e,
          ),
        )
        .toList();
  }

  List<Widget> teacherProfileButtons(BuildContext context) {
    return _teacherProfiles
        .where((e) => doesTeacherSupportSelectedAcademicYear(e))
        .map(
          (e) => buildRoleButton(
            context,
            "Teacher",
            (e.firstName ?? ""),
            e.schoolName ?? '',
            e,
          ),
        )
        .toList();
  }

  List<Widget> studentProfileButtons(BuildContext context) {
    return _studentProfiles
        .where((e) => doesStudentSupportSelectedAcademicYear(e))
        .map(
          (e) => buildRoleButton(
            context,
            "Student",
            ((e.studentFirstName ?? "" ' ') + (e.studentMiddleName ?? "" ' ') + (e.studentLastName ?? "" ' '))
                .split(" ")
                .where((i) => i != "")
                .join(" "),
            e.schoolName ?? '',
            e,
          ),
        )
        .toList();
  }

  List<Widget> adminProfileButtons(BuildContext context) {
    return _adminProfiles
        .where((e) => doesAdminSupportSelectedAcademicYear(e))
        .map(
          (e) => buildRoleButton(
            context,
            "Admin",
            (e.firstName ?? ""),
            e.schoolName ?? '',
            e,
          ),
        )
        .toList();
  }

  List<Widget> megaAdminProfileButtons(BuildContext context) {
    return _groupedMegaAdminsLists
        .map((List<MegaAdminProfile> megaAdmins) => megaAdmins.isEmpty || doesMegaAdminSupportSelectedAcademicYear(megaAdmins)
            ? Container()
            : buildRoleButton(
                context,
                "Mega Admin",
                (_groupedMegaAdminsLists.firstOrNull?.firstOrNull?.userName ?? ""),
                "Franchise: " + (megaAdmins.firstOrNull?.franchiseName ?? "-").capitalize(),
                megaAdmins,
              ))
        .toList();
  }

  InkWell logoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: _scaffoldKey.currentContext!,
          builder: (dialogueContext) {
            return AlertDialog(
              title: const Text('Epsilon Diary'),
              content: const Text("Are you sure you want to logout?"),
              actions: <Widget>[
                TextButton(
                  child: const Text("Yes"),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      SplashScreen.routeName,
                      (route) => route.isFirst,
                      arguments: true,
                    );
                    await Restart.restartApp(webOrigin: null);
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("No"),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        child: const Icon(
          Icons.logout,
          color: Colors.white,
        ),
      ),
    );
  }

  bool doesAdminSupportSelectedAcademicYear(AdminProfile e) => (selectedAcademicYearMap?.schoolIds ?? []).contains(e.schoolId);

  bool doesTeacherSupportSelectedAcademicYear(TeacherProfile e) => (selectedAcademicYearMap?.schoolIds ?? []).contains(e.schoolId);

  bool doesStudentSupportSelectedAcademicYear(StudentProfile e) => (selectedAcademicYearMap?.schoolIds ?? []).contains(e.schoolId);

  bool doesOtherUserSupportSelectedAcademicYear(OtherUserRoleProfile e) => (selectedAcademicYearMap?.schoolIds ?? []).contains(e.schoolId);

  bool doesMegaAdminSupportSelectedAcademicYear(List<MegaAdminProfile> megaAdmins) =>
      !megaAdmins.map((e) => (selectedAcademicYearMap?.schoolIds ?? []).contains(e.schoolId)).contains(true);

  Widget buildRoleButton(BuildContext context, String role, String name, String schoolName, Object? profile) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: GestureDetector(
        onTap: () async {
          if (role == "Student") {
            var studentProfile = profile as StudentProfile;
            await updateSchoolIdInPrefs((studentProfile).schoolId);
            int? academicYearId = academicYears.firstWhereOrNull((e) => e.schoolId == studentProfile.schoolId)?.academicYearId;
            await updateAcademicYearIdInPrefs(academicYearId);
            Navigator.pushNamed(
              context,
              StudentDashBoard.routeName,
              arguments: profile,
            ).then((_) => updateSchoolIdInPrefs(null));
          } else if (role == "Admin") {
            AdminProfile adminProfile = (profile as AdminProfile);
            await updateSchoolIdInPrefs(adminProfile.schoolId);
            await updateAdminProfilePin(adminProfile);
            int? academicYearId = academicYears.firstWhereOrNull((e) => e.schoolId == adminProfile.schoolId)?.academicYearId;
            await updateAcademicYearIdInPrefs(academicYearId);
            Navigator.pushNamed(
              context,
              AdminDashboard.routeName,
              arguments: profile,
            ).then((_) => updateSchoolIdInPrefs(null));
          } else if (role == "Teacher") {
            TeacherProfile teacherProfile = (profile as TeacherProfile);
            await updateSchoolIdInPrefs(teacherProfile.schoolId);
            await updateTeacherProfilePin(teacherProfile);
            int? academicYearId = academicYears.firstWhereOrNull((e) => e.schoolId == teacherProfile.schoolId)?.academicYearId;
            await updateAcademicYearIdInPrefs(academicYearId);
            Navigator.pushNamed(
              context,
              TeacherDashboard.routeName,
              arguments: profile,
            ).then((_) => updateSchoolIdInPrefs(null));
          } else if (role == "Mega Admin") {
            MegaAdminProfile x = (profile as List<MegaAdminProfile>).first;
            MegaAdminProfile megaAdminProfile = MegaAdminProfile(
                franchiseId: x.franchiseId,
                userName: x.userName,
                userId: x.userId,
                mailId: x.mailId,
                franchiseContactInfo: x.franchiseContactInfo,
                franchiseName: x.franchiseName,
                roleDescription: "Mega Admin",
                roleId: x.roleId,
                roleName: x.roleName,
                adminProfiles: profile
                    .map((e) => AdminProfile(
                          schoolId: e.schoolId,
                          schoolName: e.schoolName,
                          userId: e.userId,
                          firstName: e.userName,
                          mailId: e.mailId,
                          schoolPhotoUrl: e.schoolPhotoUrl,
                          city: e.city,
                          branchCode: e.branchCode,
                          isMegaAdmin: true,
                        ))
                    .toList());
            Navigator.pushNamed(
              context,
              MegaAdminHomePage.routeName,
              arguments: megaAdminProfile,
            );
          } else if (role == "Receptionist") {
            var otherUserRoleProfile = profile as OtherUserRoleProfile;
            await updateSchoolIdInPrefs((otherUserRoleProfile).schoolId);
            int? academicYearId = academicYears.firstWhereOrNull((e) => e.schoolId == otherUserRoleProfile.schoolId)?.academicYearId;
            await updateAcademicYearIdInPrefs(academicYearId);
            Navigator.pushNamed(
              context,
              ReceptionistDashboard.routeName,
              arguments: profile,
            ).then((_) => updateSchoolIdInPrefs(null));
          }
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(20), // child: Text("Student: ${e.studentFirstName}"),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).dialogBackgroundColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 50,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            role,
                            style: Theme.of(context).textTheme.bodyText1,
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        schoolName,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateAdminProfilePin(AdminProfile profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (profile.fourDigitPin != null) {
      await prefs.setString('USER_FOUR_DIGIT_PIN', profile.fourDigitPin!);
    }
  }

  Future<void> updateTeacherProfilePin(TeacherProfile profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (profile.fourDigitPin != null) {
      await prefs.setString('USER_FOUR_DIGIT_PIN', profile.fourDigitPin!);
    }
  }

  Future<void> updateMegaAdminProfilePin(MegaAdminProfile profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (profile.fourDigitPin != null) {
      await prefs.setString('USER_FOUR_DIGIT_PIN', profile.fourDigitPin!);
    }
  }
}
