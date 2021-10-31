import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({Key? key, required this.teacherProfile})
      : super(key: key);

  final TeacherProfile teacherProfile;

  static const routeName = "/profile";

  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          buildRoleButtonForAppBar(context, widget.teacherProfile),
        ],
      ),
      drawer: TeacherAppDrawer(
        teacherProfile: widget.teacherProfile,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).orientation == Orientation.landscape
                ? MediaQuery.of(context).size.height * 0.6 + 75
                : MediaQuery.of(context).size.height * 0.4 + 50,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? MediaQuery.of(context).size.height * 0.6
                        : MediaQuery.of(context).size.height * 0.4,
                    width: double.infinity,
                    child: FadeInImage(
                      placeholder: const AssetImage(
                        'assets/images/loading_grey_white.gif',
                      ),
                      image: NetworkImage(
                        widget.teacherProfile.schoolPhotoUrl!,
                        // "https://i.pinimg.com/originals/68/23/cc/6823ccc28eec17d215f029cc46102406.jpg",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 150
                        : 100,
                    width: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 150
                        : 100,
                    margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                    child: ClayButton(
                      depth: 100,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 0,
                      borderRadius: 150,
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(150.0),
                            topRight: Radius.circular(150.0),
                            bottomRight: Radius.circular(150.0),
                            bottomLeft: Radius.circular(150.0),
                          ),
                          child: FadeInImage(
                            placeholder: const AssetImage(
                              'assets/images/loading_grey_white.gif',
                            ),
                            image: NetworkImage(
                              widget.teacherProfile.teacherPhotoUrl!,
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: MediaQuery.of(context).orientation == Orientation.landscape
                ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20,
                    MediaQuery.of(context).size.width / 4, 20)
                : const EdgeInsets.all(20),
            // padding: EdgeInsets.all(25),
            child: ClayContainer(
              depth: 10,
              color: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Text(
                            "Name: ${widget.teacherProfile.teacherName ?? "-"}",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Text(
                            "School: ${widget.teacherProfile.schoolName ?? "-"}",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Text(
                            "Father: ${widget.teacherProfile.fatherName ?? "-"}",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Text(
                            "Mother: ${widget.teacherProfile.motherName ?? "-"}",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Text(
                            "Mail Id: ${widget.teacherProfile.mailId ?? "-"}",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
