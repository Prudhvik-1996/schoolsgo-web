import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as user_details;
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/splash_screen/splash_screen.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerateNewLoginPinScreen extends StatefulWidget {
  const GenerateNewLoginPinScreen({
    Key? key,
    required this.userId,
    required this.studentId,
  }) : super(key: key);

  final int? userId;
  final int? studentId;

  @override
  State<GenerateNewLoginPinScreen> createState() => _GenerateNewLoginPinScreenState();
}

class _GenerateNewLoginPinScreenState extends State<GenerateNewLoginPinScreen> {
  bool _isLoading = true;

  UserDetails? userDetails;
  StudentProfile? studentProfile;

  String? schoolName;
  List<String> roles = [];

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  String newPinError = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    if (widget.userId != null) {
      GetUserRolesRequest getUserRolesRequest = GetUserRolesRequest(userId: widget.userId!);
      GetUserRolesDetailsResponse getUserRolesResponse = await getUserRoles(getUserRolesRequest);
      if (getUserRolesResponse.httpStatus != "OK" || getUserRolesResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error Occurred"),
          ),
        );
      } else {
        userDetails = getUserRolesResponse.userDetails!;
        if ((getUserRolesResponse.adminProfiles ?? []).isNotEmpty) {
          roles.add("Admin");
        }
        if ((getUserRolesResponse.teacherProfiles ?? []).isNotEmpty) {
          roles.add("Teacher");
        }
        if ((getUserRolesResponse.megaAdminProfiles ?? []).isNotEmpty) {
          roles.add("Mega Admin");
        }
        if ((getUserRolesResponse.otherUserRoleProfiles ?? []).isNotEmpty) {
          getUserRolesResponse.otherUserRoleProfiles?.forEach((eachRole) {
            roles.add(eachRole?.roleName ?? "-");
          });
        }
        List<String?> schoolNameFromAdminProfiles =
            ((getUserRolesResponse.adminProfiles ?? []).map((e) => e?.schoolName)).toList();
        List<String?> schoolNameFromTeacherProfiles =
            ((getUserRolesResponse.teacherProfiles ?? []).map((e) => e?.schoolName)).toList();
        List<String?> schoolNameFromMegaAdminProfiles =
            ((getUserRolesResponse.megaAdminProfiles ?? []).map((e) => e?.schoolName)).toList();
        List<String?> schoolNameFromOtherUserRoleProfiles =
            ((getUserRolesResponse.otherUserRoleProfiles ?? []).map((e) => e?.schoolName)).toList();

        schoolName = [
              ...schoolNameFromAdminProfiles,
              ...schoolNameFromTeacherProfiles,
              ...schoolNameFromMegaAdminProfiles,
              ...schoolNameFromOtherUserRoleProfiles
            ].where((e) => e != null).firstOrNull ??
            "";
      }
    }
    if (widget.studentId != null) {
      studentProfile = (await getStudentProfile(GetStudentProfileRequest(studentId: widget.studentId))).studentProfiles?.first;
      schoolName = studentProfile?.schoolName ?? "-";
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Update Login Pin"),
      ),
      body: Container(
        margin: MediaQuery.of(context).orientation == Orientation.portrait
            ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
            : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
        child: Center(
          child: ClayContainer(
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 20,
            emboss: true,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  if (studentProfile != null) ..._getStudentDetailsWidgets(),
                  if (studentProfile == null && userDetails != null) ..._getUserDetailsWidgets(),
                  const SizedBox(
                    height: 20,
                  ),
                  buildNewPinTextField(),
                  const SizedBox(
                    height: 10,
                  ),
                  buildConfirmNewPinTextField(),
                  const SizedBox(
                    height: 10,
                  ),
                  if (newPinError != "") buildErrorRow(),
                  const SizedBox(
                    height: 10,
                  ),
                  buildSubmitButton(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector buildSubmitButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (newPinError != "") {
          return;
        }
        if (newPasswordController.text == "123456") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("New Pin CANNOT be 123456"),
            ),
          );
          return;
        }
        user_details.UpdateLoginCredentialsResponse updateLoginCredentialsResponse =
            await user_details.updateLoginCredentials(user_details.UpdateLoginCredentialsRequest(
          studentId: widget.studentId,
          userId: widget.userId,
          agentId: widget.userId ?? widget.studentId,
          newSixDigitPin: newPasswordController.text,
        ));
        if (updateLoginCredentialsResponse.httpStatus != "OK" || updateLoginCredentialsResponse.responseStatus != "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong..\nPlease try again later!"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Updated successfully.."),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          Navigator.pushNamedAndRemoveUntil(
            context,
            SplashScreen.routeName,
            (route) => route.isFirst,
            arguments: true,
          );
          await Restart.restartApp(webOrigin: null);
        }
      },
      child: ClayButton(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Submit",
            ),
          ),
        ),
      ),
    );
  }

  Row buildErrorRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 15,
        ),
        SizedBox(
          height: 15,
          width: 15,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
              ),
              borderRadius: BorderRadius.circular(30),
              color: Colors.transparent,
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                "!",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          flex: 1,
          child: Text(
            newPinError,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  TextField buildConfirmNewPinTextField() {
    return TextField(
      onTap: () {
        setState(() {
          newPinError = "";
        });
      },
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.length > 6) return oldValue;
            if (text.isNotEmpty) int.parse(text);
            return newValue;
          } catch (e) {}
          return oldValue;
        }),
      ],
      controller: confirmNewPasswordController,
      enabled: true,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'Confirm 6-Digit PIN',
        hintText: 'Confirm 6-Digit PIN',
        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      style: const TextStyle(
        fontSize: 12,
      ),
      autofocus: true,
      onChanged: (String e) {
        if (e != newPasswordController.text) {
          setState(() {
            newPinError = "Pin does not match";
          });
        } else {
          setState(() {
            newPinError = "";
          });
        }
      },
    );
  }

  TextField buildNewPinTextField() {
    return TextField(
      onTap: () {
        setState(() {
          newPinError = "";
        });
      },
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.length > 6) return oldValue;
            if (text.isNotEmpty) int.parse(text);
            return newValue;
          } catch (e) {}
          return oldValue;
        }),
      ],
      controller: newPasswordController,
      enabled: true,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: '6-Digit PIN',
        hintText: '6-Digit PIN',
        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      style: const TextStyle(
        fontSize: 12,
      ),
      autofocus: true,
      onChanged: (String e) {
        setState(() {
          newPinError = "";
        });
      },
    );
  }

  List<Widget> _getStudentDetailsWidgets() {
    return [
      Text(
        schoolName ?? "-",
        style: GoogleFonts.archivoBlack(
          textStyle: const TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Text(
        "${studentProfile?.studentFirstName ?? "-"} ${studentProfile?.studentLastName ?? "-"}",
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Text(
        "Section: ${studentProfile?.sectionName ?? "-"}",
        style: const TextStyle(
          fontSize: 10,
        ),
      ),
    ];
  }

  List<Widget> _getUserDetailsWidgets() {
    return [
      // Text(
      //   schoolName ?? "-",
      //   style: GoogleFonts.archivoBlack(
      //     textStyle: const TextStyle(
      //       fontSize: 24,
      //     ),
      //   ),
      // ),
      const SizedBox(
        height: 10,
      ),
      Text(
        "${userDetails?.firstName ?? ""} ${userDetails?.lastName ?? ""}".trim(),
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Text(
        "Roles: ${roles.map((e) => e.replaceAll("_", " ").capitalize()).join(", ")}",
        style: const TextStyle(
          fontSize: 10,
        ),
      ),
    ];
  }
}
