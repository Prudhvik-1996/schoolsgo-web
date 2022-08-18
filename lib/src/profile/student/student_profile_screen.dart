import 'dart:html' as html;

import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/media_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/profile/student/profile_picture_screen.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({Key? key, required this.studentProfile}) : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/profile";

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          buildRoleButtonForAppBar(context, widget.studentProfile),
        ],
      ),
      drawer: StudentAppDrawer(
        studentProfile: widget.studentProfile,
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
                          height: MediaQuery.of(context).orientation == Orientation.landscape
                              ? MediaQuery.of(context).size.height * 0.6
                              : MediaQuery.of(context).size.height * 0.4,
                          width: double.infinity,
                          child: MediaLoadingWidget(
                            mediaUrl: widget.studentProfile.schoolPhotoUrl!,
                            mediaFit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: 50 + (MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 100),
                          width: 50 + (MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 100),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  height: MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 100,
                                  width: MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 100,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return ProfilePictureScreen(
                                          name: widget.studentProfile.studentFirstName ?? "-",
                                          pictureUrl: widget.studentProfile.studentPhotoUrl ??
                                              "https://drive.google.com/uc?id=1XC8IaBukQkcmPnysy811oDbZrQImDvs2",
                                        );
                                      }));
                                    },
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
                                          child: MediaLoadingWidget(
                                            mediaUrl: widget.studentProfile.studentPhotoUrl ??
                                                "https://drive.google.com/uc?id=1XC8IaBukQkcmPnysy811oDbZrQImDvs2",
                                            mediaFit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: GestureDetector(
                                  onTap: () {
                                    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                                    uploadInput.multiple = false;
                                    uploadInput.draggable = true;
                                    uploadInput.accept = '.png,.jpg,.jpeg';
                                    uploadInput.click();
                                    uploadInput.onChange.listen(
                                      (changeEvent) {
                                        final files = uploadInput.files!;
                                        for (html.File file in files) {
                                          final reader = html.FileReader();
                                          reader.readAsDataUrl(file);
                                          reader.onLoadEnd.listen(
                                            (loadEndEvent) async {
                                              setState(() {
                                                _isLoading = true;
                                              });

                                              try {
                                                UploadFileToDriveResponse uploadFileResponse = await uploadFileToDrive(reader.result!, file.name);

                                                CreateOrUpdateStudentProfileResponse response =
                                                    await createOrUpdateStudentProfile(CreateOrUpdateStudentProfileRequest(
                                                  studentId: widget.studentProfile.studentId,
                                                  agent: widget.studentProfile.gaurdianId,
                                                  studentPhotoUrl: uploadFileResponse.mediaBean?.mediaUrl,
                                                  schoolId: widget.studentProfile.schoolId,
                                                ));

                                                if (response.httpStatus != "OK" || response.responseStatus != "success") {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("Something went wrong! Try again later.."),
                                                    ),
                                                  );
                                                } else {
                                                  setState(() {
                                                    widget.studentProfile.studentPhotoUrl = uploadFileResponse.mediaBean?.mediaUrl;
                                                  });
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content:
                                                        Text("Something went wrong while trying to upload, ${file.name}..\nPlease try again later"),
                                                  ),
                                                );
                                              }
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            },
                                          );
                                        }
                                      },
                                    );
                                  },
                                  child: ClayButton(
                                    width: MediaQuery.of(context).orientation == Orientation.landscape ? 50 : 40,
                                    height: MediaQuery.of(context).orientation == Orientation.landscape ? 50 : 40,
                                    depth: 40,
                                    borderRadius: 100,
                                    spread: 1,
                                    surfaceColor: Colors.blue,
                                    parentColor: clayContainerColor(context),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Icon(Icons.edit),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: MediaQuery.of(context).orientation == Orientation.landscape
                      ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
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
                                  "Section: ${widget.studentProfile.sectionName ?? "-"}",
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                  ),
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
                                  "Name: ${widget.studentProfile.studentFirstName ?? "-"}",
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
                                  "School: ${widget.studentProfile.schoolName ?? "-"}",
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
                                  "Father: ${widget.studentProfile.fatherName ?? "-"}",
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
                                  "Mother: ${widget.studentProfile.motherName ?? "-"}",
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
                                  "Mail Id: ${widget.studentProfile.gaurdianMailId ?? "-"}",
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
