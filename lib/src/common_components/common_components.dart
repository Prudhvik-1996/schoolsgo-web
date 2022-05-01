import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/admin_dashboard/admin_dashboard.dart';
import 'package:schoolsgo_web/src/mega_admin/mega_admin_home_page.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/settings_view.dart';
import 'package:schoolsgo_web/src/student_dashboard/student_dashboard.dart';
import 'package:schoolsgo_web/src/teacher_dashboard/teacher_dashboard.dart';

import 'dashboard_widgets.dart';

class DefaultAppDrawer extends Drawer {
  const DefaultAppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      width: MediaQuery.of(context).orientation == Orientation.landscape ? 255 : 255,
      child: ListView(
        restorationId: 'DefaultAppDrawer',
        controller: ScrollController(),
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Epsilon Diary',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class StudentAppDrawer extends Drawer {
  const StudentAppDrawer({Key? key, required this.studentProfile}) : super(key: key);

  final StudentProfile studentProfile;

  @override
  Widget build(BuildContext context) {
    final List<DashboardWidget<StudentProfile>> dashBoardWidgets = studentDashBoardWidgets(studentProfile);
    return Container(
      color: Theme.of(context).backgroundColor,
      width: MediaQuery.of(context).orientation == Orientation.landscape ? 255 : 255,
      child: ListView(
        restorationId: 'DefaultAppDrawer',
        children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '${studentProfile.studentFirstName}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ListTile(
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      StudentDashBoard.routeName,
                      (route) => route.isFirst,
                      arguments: studentProfile,
                    );
                  },
                ),
              ),
              const Divider(),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ListTile(
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.restorablePushNamed(context, SettingsView.routeName);
                  },
                ),
              ),
              const Divider(),
            ] +
            dashBoardWidgets
                .map(
                  (e) => e.subWidgets == null || e.subWidgets!.isEmpty
                      ? [
                          Container(
                            margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: ListTile(
                              leading: SizedBox(
                                height: 25,
                                width: 25,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: e.image,
                                ),
                              ),
                              title: Text(
                                "${e.title}",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                print("Entering ${e.routeName}");
                                Navigator.pushNamed(
                                  context,
                                  e.routeName!,
                                  arguments: e.argument as StudentProfile,
                                );
                              },
                            ),
                          ),
                          const Divider(),
                        ]
                      : [
                          ExpansionTile(
                              title: ListTile(
                                leading: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: e.image,
                                  ),
                                ),
                                title: Text(
                                  "${e.title}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              children: e.subWidgets!
                                  .map(
                                    (e1) => [
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                        child: ListTile(
                                          leading: const SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: Icon(Icons.format_list_bulleted),
                                          ),
                                          title: Text(
                                            "${e1.title}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          onTap: () {
                                            print("Entering ${e1.routeName}");
                                          },
                                        ),
                                      ),
                                      const Divider()
                                    ],
                                  )
                                  .expand((i) => i)
                                  .toList()),
                          const Divider(),
                        ],
                )
                .expand((i) => i)
                .toList(),
      ),
    );
  }
}

class TeacherAppDrawer extends Drawer {
  const TeacherAppDrawer({Key? key, required this.teacherProfile}) : super(key: key);

  final TeacherProfile teacherProfile;

  @override
  Widget build(BuildContext context) {
    final List<DashboardWidget<TeacherProfile>> dashBoardWidgets = teacherDashBoardWidgets(teacherProfile);
    return Container(
      color: Theme.of(context).backgroundColor,
      width: MediaQuery.of(context).orientation == Orientation.landscape ? 255 : 255,
      child: ListView(
        restorationId: 'DefaultAppDrawer',
        children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '${teacherProfile.firstName}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ListTile(
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      TeacherDashboard.routeName,
                      (route) => route.isFirst,
                      arguments: teacherProfile,
                    );
                  },
                ),
              ),
              const Divider(),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ListTile(
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.restorablePushNamed(context, SettingsView.routeName);
                  },
                ),
              ),
              const Divider(),
            ] +
            dashBoardWidgets
                .map(
                  (e) => e.subWidgets == null || e.subWidgets!.isEmpty
                      ? [
                          Container(
                            margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: ListTile(
                              leading: SizedBox(
                                height: 25,
                                width: 25,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: e.image,
                                ),
                              ),
                              title: Text(
                                "${e.title}",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  e.routeName!,
                                  arguments: e.argument as TeacherProfile,
                                );
                              },
                            ),
                          ),
                          const Divider(),
                        ]
                      : [
                          ExpansionTile(
                              title: ListTile(
                                leading: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: e.image,
                                  ),
                                ),
                                title: Text(
                                  "${e.title}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              children: e.subWidgets!
                                  .map(
                                    (e1) => [
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                        child: ListTile(
                                          leading: const SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: Icon(Icons.format_list_bulleted),
                                          ),
                                          title: Text(
                                            "${e1.title}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          onTap: () {
                                            print("Entering ${e1.routeName}");
                                          },
                                        ),
                                      ),
                                      const Divider()
                                    ],
                                  )
                                  .expand((i) => i)
                                  .toList()),
                          const Divider(),
                        ],
                )
                .expand((i) => i)
                .toList(),
      ),
    );
  }
}

class AdminAppDrawer extends Drawer {
  const AdminAppDrawer({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;

  @override
  Widget build(BuildContext context) {
    final List<DashboardWidget<AdminProfile>> dashBoardWidgets = adminDashBoardWidgets(adminProfile);
    return Container(
      color: Theme.of(context).backgroundColor,
      width: MediaQuery.of(context).orientation == Orientation.landscape ? 255 : 255,
      child: ListView(
        restorationId: 'DefaultAppDrawer',
        children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '${adminProfile.firstName}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ListTile(
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AdminDashboard.routeName,
                      (route) => route.isFirst,
                      arguments: adminProfile,
                    );
                  },
                ),
              ),
              const Divider(),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ListTile(
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.restorablePushNamed(context, SettingsView.routeName);
                  },
                ),
              ),
              const Divider(),
            ] +
            dashBoardWidgets
                .map(
                  (e) => e.subWidgets == null || e.subWidgets!.isEmpty
                      ? [
                          Container(
                            margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: ListTile(
                              leading: SizedBox(
                                height: 25,
                                width: 25,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: e.image,
                                ),
                              ),
                              title: Text(
                                "${e.title}",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                print("Entering ${e.routeName}");
                                Navigator.pushNamed(
                                  context,
                                  e.routeName!,
                                  arguments: e.argument as AdminProfile,
                                );
                              },
                            ),
                          ),
                          const Divider(),
                        ]
                      : [
                          ExpansionTile(
                              title: ListTile(
                                leading: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: e.image,
                                  ),
                                ),
                                title: Text(
                                  "${e.title}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              children: e.subWidgets!
                                  .map(
                                    (e1) => [
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                        child: ListTile(
                                          leading: const SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: Icon(Icons.format_list_bulleted),
                                          ),
                                          title: Text(
                                            "${e1.title}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              e1.routeName!,
                                              arguments: e1.argument,
                                            );
                                          },
                                        ),
                                      ),
                                      const Divider()
                                    ],
                                  )
                                  .expand((i) => i)
                                  .toList()),
                          const Divider(),
                        ],
                )
                .expand((i) => i)
                .toList(),
      ),
    );
  }
}

class MegaAdminAppDrawer extends Drawer {
  const MegaAdminAppDrawer({Key? key, required this.megaAdminProfile}) : super(key: key);

  final MegaAdminProfile megaAdminProfile;

  @override
  Widget build(BuildContext context) {
    final List<DashboardWidget<MegaAdminProfile>> dashBoardWidgets = megaAdminDashBoardWidgets(megaAdminProfile);
    return Container(
      color: Theme.of(context).backgroundColor,
      width: MediaQuery.of(context).orientation == Orientation.landscape ? 255 : 255,
      child: ListView(
        restorationId: 'MegaAdminAppDrawer',
        children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '${megaAdminProfile.userName}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ListTile(
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      MegaAdminHomePage.routeName,
                      (route) => route.isFirst,
                      arguments: megaAdminProfile,
                    );
                  },
                ),
              ),
              const Divider(),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ListTile(
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.restorablePushNamed(context, SettingsView.routeName);
                  },
                ),
              ),
              const Divider(),
            ] +
            dashBoardWidgets
                .map(
                  (e) => e.subWidgets == null || e.subWidgets!.isEmpty
                      ? [
                          Container(
                            margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: ListTile(
                              leading: SizedBox(
                                height: 25,
                                width: 25,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: e.image,
                                ),
                              ),
                              title: Text(
                                "${e.title}",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                print("Entering ${e.routeName}");
                                Navigator.pushNamed(
                                  context,
                                  e.routeName!,
                                  arguments: e.argument as AdminProfile,
                                );
                              },
                            ),
                          ),
                          const Divider(),
                        ]
                      : [
                          ExpansionTile(
                              title: ListTile(
                                leading: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: e.image,
                                  ),
                                ),
                                title: Text(
                                  "${e.title}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              children: e.subWidgets!
                                  .map(
                                    (e1) => [
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                        child: ListTile(
                                          leading: const SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: Icon(Icons.format_list_bulleted),
                                          ),
                                          title: Text(
                                            "${e1.title}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              e1.routeName!,
                                              arguments: e1.argument,
                                            );
                                          },
                                        ),
                                      ),
                                      const Divider()
                                    ],
                                  )
                                  .expand((i) => i)
                                  .toList()),
                          const Divider(),
                        ],
                )
                .expand((i) => i)
                .toList(),
      ),
    );
  }
}

class EisStandardHeader extends StatelessWidget {
  const EisStandardHeader({Key? key, required this.title}) : super(key: key);

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.5,
          child: ClayContainer(
            surfaceColor: Colors.blueGrey[700],
            parentColor: Colors.blueGrey[700],
            spread: 0,
            height: 210,
            width: MediaQuery.of(context).size.width,
            customBorderRadius: BorderRadius.only(
              bottomLeft: Radius.elliptical(
                MediaQuery.of(context).size.width,
                300,
              ),
              // bottomLeft: Radius.circular(150),
            ),
          ),
        ),
        Opacity(
          opacity: 1,
          child: ClayContainer(
            surfaceColor: Colors.blue,
            parentColor: Colors.blue,
            spread: 0,
            height: 180,
            width: MediaQuery.of(context).size.width,
            customBorderRadius: BorderRadius.only(
              bottomRight: Radius.elliptical(
                MediaQuery.of(context).size.width,
                120,
              ),
              // bottomLeft: Radius.circular(150),
            ),
          ),
        ),
        Opacity(
          opacity: 0.7,
          child: ClayContainer(
            surfaceColor: Colors.lightBlue[300],
            parentColor: Colors.lightBlue[300],
            spread: 0,
            height: 250,
            width: MediaQuery.of(context).size.width,
            customBorderRadius: BorderRadius.only(
              bottomRight: Radius.elliptical(
                MediaQuery.of(context).size.width,
                180,
              ),
              // bottomLeft: Radius.circular(150),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 300,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: title,
            ),
          ),
        )
      ],
    );
  }
}

StatelessWidget buildRoleButtonForAppBar(BuildContext context, Object profile) {
  return MediaQuery.of(context).orientation == Orientation.landscape
      ? InkWell(
          onTap: () {
            //  TODO show dropdown to access different roles
          },
          child: SizedBox(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 50, child: Icon(Icons.account_circle)),
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${profile is TeacherProfile ? profile.firstName : profile is StudentProfile ? profile.studentFirstName : profile is AdminProfile ? profile.firstName : profile is MegaAdminProfile ? profile.userName : ""}",
                      ),
                      Text(
                        "${profile is TeacherProfile ? profile.schoolName : profile is StudentProfile ? profile.schoolName : profile is AdminProfile ? profile.schoolName : profile is MegaAdminProfile ? profile.franchiseName : ""}",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      : Container();
}
