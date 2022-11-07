import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/admin_dashboard/admin_dashboard.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/login/model/login.dart';
import 'package:schoolsgo_web/src/mega_admin/mega_admin_home_page.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as userDetails;
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/splash_screen/splash_screen.dart';
import 'package:schoolsgo_web/src/student_dashboard/student_dashboard.dart';
import 'package:schoolsgo_web/src/teacher_dashboard/teacher_dashboard.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key, required this.loggedInUserId}) : super(key: key);

  final int? loggedInUserId;

  static const routeName = "/user_dashboard";

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  bool _isLoading = true;

  late UserDetails _userDetails;
  List<StudentProfile> _studentProfiles = [];
  List<TeacherProfile> _teacherProfiles = [];
  List<AdminProfile> _adminProfiles = [];
  List<OtherUserRoleProfile> _otherRoleProfile = [];
  List<MegaAdminProfile> _megaAdminProfiles = [];

  String? fourDigitPin;

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
    GetUserRolesRequest getUserRolesRequest = GetUserRolesRequest(userId: widget.loggedInUserId);
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
        _userDetails = getUserRolesResponse.userDetails!;
        _studentProfiles = (getUserRolesResponse.studentProfiles ?? []).map((e) => e!).toList();
        _teacherProfiles = (getUserRolesResponse.teacherProfiles ?? []).map((e) => e!).toList();
        _adminProfiles = (getUserRolesResponse.adminProfiles ?? []).map((e) => e!).toList();
        _otherRoleProfile = (getUserRolesResponse.otherUserRoleProfiles ?? []).map((e) => e!).toList();
        _megaAdminProfiles = (getUserRolesResponse.megaAdminProfiles ?? []).map((e) => e!).toList();
      });
    }

    userDetails.GetUserDetailsResponse getUserDetailsResponse = await getUserDetails(
      userDetails.UserDetails(
        userId: widget.loggedInUserId,
      ),
    );
    if (getUserDetailsResponse.userDetails!.first.fourDigitPin != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('USER_FOUR_DIGIT_PIN', getUserDetailsResponse.userDetails!.first.fourDigitPin!);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('USER_FOUR_DIGIT_PIN');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget buildUserDetailsWidget(UserDetails userDetails) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 40,
        surfaceColor: Theme.of(context).primaryColor == Colors.blue ? Colors.blue[200] : Theme.of(context).primaryColor,
        parentColor: Theme.of(context).primaryColor == Colors.blue ? Colors.blue[200] : Theme.of(context).primaryColor,
        spread: 1,
        emboss: false,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Text(
              "${((userDetails.firstName ?? " ") + (userDetails.middleName ?? " ") + (userDetails.lastName ?? " ")).split(" ").where((i) => i != "").join(" ")}\n${userDetails.mailId}"),
        ),
      ),
    );
  }

  Widget buildRoleButton(BuildContext context, String role, String name, String schoolName, Object? profile) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: GestureDetector(
        onTap: () {
          if (role == "Student") {
            Navigator.pushNamed(
              context,
              StudentDashBoard.routeName,
              arguments: profile as StudentProfile,
            );
          } else if (role == "Admin") {
            Navigator.pushNamed(
              context,
              AdminDashboard.routeName,
              arguments: profile as AdminProfile,
            );
          } else if (role == "Teacher") {
            Navigator.pushNamed(
              context,
              TeacherDashboard.routeName,
              arguments: profile as TeacherProfile,
            );
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
          }
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            // child: Text("Student: ${e.studentFirstName}"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      restorationId: 'UserDashboard',
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Epsilon Diary"),
        actions: [
          InkWell(
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
                          int? userId = prefs.getInt('LOGGED_IN_USER_ID');
                          String? fcmToken = prefs.getString('USER_FCM_TOKEN');
                          await doLogout(DoLogoutRequest(
                            userId: userId,
                            fcmToken: fcmToken,
                          ));
                          await prefs.clear();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            SplashScreen.routeName,
                            (route) => route.isFirst,
                            arguments: true,
                          );
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
          ),
        ],
      ),
      drawer: const DefaultAppDrawer(),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Image.asset(
                  'assets/images/eis_loader.gif',
                  height: 500,
                  width: 500,
                ),
              )
            : ListView(
                children: [buildUserDetailsWidget(_userDetails)] +
                    [
                      _megaAdminProfiles.isNotEmpty
                          ? buildRoleButton(
                              context,
                              "Mega Admin",
                              ((_userDetails.firstName ?? "" ' ') + (_userDetails.middleName ?? "" ' ') + (_userDetails.lastName ?? "" ' '))
                                  .split(" ")
                                  .where((i) => i != "")
                                  .join(" "),
                              "Franchise: " + (_megaAdminProfiles[0].franchiseName ?? "-").capitalize(),
                              _megaAdminProfiles,
                            )
                          : Container()
                    ] +
                    _adminProfiles
                        .map(
                          (e) => buildRoleButton(
                            context,
                            "Admin",
                            ((_userDetails.firstName ?? "" ' ') + (_userDetails.middleName ?? "" ' ') + (_userDetails.lastName ?? "" ' '))
                                .split(" ")
                                .where((i) => i != "")
                                .join(" "),
                            e.schoolName ?? '',
                            e,
                          ),
                        )
                        .toList() +
                    _studentProfiles
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
                        .toList() +
                    _teacherProfiles
                        .map(
                          (e) => buildRoleButton(
                            context,
                            "Teacher",
                            ((_userDetails.firstName ?? "" ' ') + (_userDetails.middleName ?? "" ' ') + (_userDetails.lastName ?? "" ' '))
                                .split(" ")
                                .where((i) => i != "")
                                .join(" "),
                            e.schoolName ?? '',
                            e,
                          ),
                        )
                        .toList() +
                    _otherRoleProfile
                        .map(
                          (e) => buildRoleButton(
                            context,
                            (e.roleName ?? "-").capitalize(),
                            (e.userName ?? "-"),
                            e.schoolName ?? '',
                            e,
                          ),
                        )
                        .toList() +
                    [
                      const SizedBox(
                        height: 100,
                      ),
                    ],
              ),
      ),
    );
  }
}
