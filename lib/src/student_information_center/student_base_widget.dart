import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentBaseWidget extends StatelessWidget {
  const StudentBaseWidget({
    Key? key,
    required this.context,
    required this.studentProfile,
    this.isButton = false,
    this.emboss = false,
  }) : super(key: key);

  final BuildContext context;
  final StudentProfile studentProfile;

  final bool isButton;
  final bool emboss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: isButton
          ? ClayButton(
              depth: 40,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              child: buildChild(),
            )
          : ClayContainer(
              depth: 40,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              emboss: emboss,
              child: buildChild(),
            ),
    );
  }

  Container buildChild() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ((studentProfile.studentFirstName == null ? "" : (studentProfile.studentFirstName ?? "").capitalize() + " ") +
                      (studentProfile.studentMiddleName == null ? "" : (studentProfile.studentMiddleName ?? "").capitalize() + " ") +
                      (studentProfile.studentLastName == null ? "" : (studentProfile.studentLastName ?? "").capitalize() + " ")),
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 10),
                  Text("Section Name: ${studentProfile.sectionName ?? "-"}"),
                  const SizedBox(height: 10),
                  Text("Roll No.: ${studentProfile.rollNumber ?? "-"}"),
                  const SizedBox(height: 10),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text("Admission No.: ${studentProfile.admissionNo ?? "-"}"),
                    const SizedBox(height: 10),
                    Text(
                      "Parent Name: ${((studentProfile.gaurdianFirstName == null ? "" : (studentProfile.gaurdianFirstName ?? "").capitalize() + " ") + (studentProfile.gaurdianMiddleName == null ? "" : (studentProfile.gaurdianMiddleName ?? "").capitalize() + " ") + (studentProfile.gaurdianLastName == null ? "" : (studentProfile.gaurdianLastName ?? "").capitalize() + " "))}",
                    ),
                    const SizedBox(height: 10),
                    Text("Email: ${studentProfile.gaurdianMailId ?? "-"}"),
                    const SizedBox(height: 10),
                    Text("Mobile: ${studentProfile.gaurdianMobile ?? "-"}"),
                    const SizedBox(height: 10),
                    Text("Alternate Mobile: ${studentProfile.alternateMobile ?? "-"}"),
                    const SizedBox(height: 10),
                    if (studentProfile.studentId != null) Text("Login Id: ${studentProfile.loginId ?? "-"}"),
                    if (studentProfile.studentId != null) const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 75,
                height: 75,
                child: studentProfile.studentPhotoUrl == null
                    ? Image.asset(
                        "assets/images/avatar.png",
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        studentProfile.studentPhotoUrl!,
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
