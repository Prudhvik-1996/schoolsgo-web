import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_dashboard/student_dashboard.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key, required this.loggedInUserId})
      : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetUserRolesRequest getUserRolesRequest =
        GetUserRolesRequest(userId: widget.loggedInUserId);
    GetUserRolesResponse getUserRolesResponse =
        await getUserRoles(getUserRolesRequest);
    if (getUserRolesResponse.httpStatus != "OK" ||
        getUserRolesResponse.responseStatus != "success") {
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
        _studentProfiles = getUserRolesResponse.studentProfiles!;
        _teacherProfiles = getUserRolesResponse.teacherProfiles!;
        _adminProfiles = getUserRolesResponse.adminProfiles!;
      });
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
        surfaceColor: Theme.of(context).primaryColor == Colors.blue
            ? Colors.blue[200]
            : Theme.of(context).primaryColor,
        parentColor: Theme.of(context).primaryColor == Colors.blue
            ? Colors.blue[200]
            : Theme.of(context).primaryColor,
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

  Widget buildRoleButton(BuildContext context, String role, String name,
      String schoolName, Object profile) {
    return InkWell(
      onTap: () {
        if (role == "Student") {
          Navigator.pushNamed(
            context,
            StudentDashBoard.routeName,
            arguments: profile as StudentProfile,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: ClayContainer(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          emboss: false,
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
      appBar: AppBar(
        title: const Text("Epsilon Diary"),
      ),
      drawer: const DefaultAppDrawer(),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : ListView(
              children: [buildUserDetailsWidget(_userDetails)] +
                  _studentProfiles
                      .map(
                        (e) => buildRoleButton(
                          context,
                          "Student",
                          ((e.studentFirstName ?? "" ' ') +
                                  (e.studentMiddleName ?? "" ' ') +
                                  (e.studentLastName ?? "" ' '))
                              .split(" ")
                              .where((i) => i != "")
                              .join(" "),
                          e.schoolName ?? '',
                          e,
                        ),
                      )
                      .toList() +
                  // [
                  //   GridView.count(
                  //     crossAxisCount: 3,
                  //     childAspectRatio: 2,
                  //     shrinkWrap: true,
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     children: _studentProfiles
                  //         .map(
                  //           (e) => buildRoleButton(
                  //             context,
                  //             "Student",
                  //             (e.studentFirstName ?? "" ' ') +
                  //                 (e.studentMiddleName ?? "" ' ') +
                  //                 (e.studentLastName ?? "" ' '),
                  //             e.schoolName ?? '',
                  //             e,
                  //           ),
                  //         )
                  //         .toList(),
                  //   )
                  // ] +
                  _teacherProfiles
                      .map(
                        (e) => buildRoleButton(
                          context,
                          "Teacher",
                          ((e.firstName ?? "" ' ') +
                                  (e.middleName ?? "" ' ') +
                                  (e.lastName ?? "" ' '))
                              .split(" ")
                              .where((i) => i != "")
                              .join(" "),
                          e.schoolName ?? '',
                          e,
                        ),
                      )
                      .toList() +
                  _adminProfiles
                      .map(
                        (e) => buildRoleButton(
                          context,
                          "Admin",
                          ((e.firstName ?? "" ' ') +
                                  (e.middleName ?? "" ' ') +
                                  (e.lastName ?? "" ' '))
                              .split(" ")
                              .where((i) => i != "")
                              .join(" "),
                          e.schoolName ?? '',
                          e,
                        ),
                      )
                      .toList(),
            ),
    );
  }
}
