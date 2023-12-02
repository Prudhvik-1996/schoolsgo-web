import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/upper_case_text_formatter.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/login/generate_new_login_pin_screen.dart';
import 'package:schoolsgo_web/src/login/model/login.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as user_details;
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/splash_screen/splash_screen.dart';
import 'package:schoolsgo_web/src/student_dashboard/student_dashboard.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UniqueIdLoginWidget extends StatefulWidget {
  const UniqueIdLoginWidget({super.key});

  @override
  State<UniqueIdLoginWidget> createState() => _UniqueIdLoginWidgetState();
}

class _UniqueIdLoginWidgetState extends State<UniqueIdLoginWidget> {
  bool _isLoading = false;
  TextEditingController loginIdEditingController = TextEditingController();
  TextEditingController loginPinEditingController = TextEditingController();
  String loginIdErrorText = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onTap: () {
                    setState(() {
                      loginIdErrorText = "";
                    });
                  },
                  controller: loginIdEditingController,
                  enabled: true,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'User Id',
                    hintText: 'User Id',
                    contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  autofocus: true,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  onChanged: (String e) {
                    setState(() {
                      loginIdErrorText = "";
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: TextField(
            onTap: () {
              setState(() {
                loginIdErrorText = "";
              });
            },
            controller: loginPinEditingController,
            enabled: true,
            keyboardType: TextInputType.number,
            obscureText: true,
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
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                try {
                  final text = newValue.text;
                  if (text.length > 6) return oldValue;
                  if (text.isNotEmpty) int.parse(text);
                  return newValue;
                } catch (_, e) {
                  debugPrintStack(stackTrace: e);
                }
                return oldValue;
              }),
            ],
            autofocus: true,
            onChanged: (String value) {
              // doAppLogin(emailEditingController.text);
            },
          ),
        ),
        if (loginIdErrorText != "")
          Row(
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
                  loginIdErrorText ?? "",
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Row(
            children: [
              Expanded(
                child: buildVerifyCredentials(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  GestureDetector buildVerifyCredentials(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        user_details.DoLoginWithLoginUserIdAndPasswordResponse doLoginWithLoginUserIdAndPasswordResponse =
            await user_details.doLoginWithLoginUserIdAndPassword(
          user_details.DoLoginWithLoginUserIdAndPasswordRequest(
            userLoginId: loginIdEditingController.text,
            password: loginPinEditingController.text,
          ),
        );
        if (doLoginWithLoginUserIdAndPasswordResponse.errorCode != null) {
          setState(() {
            loginIdErrorText = doLoginWithLoginUserIdAndPasswordResponse.errorCode!.replaceAll("_", " ").toLowerCase().capitalize();
          });
        } else {
          if (doLoginWithLoginUserIdAndPasswordResponse.errorCode == null && loginPinEditingController.text == "123456") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) {
                return GenerateNewLoginPinScreen(
                  userId: doLoginWithLoginUserIdAndPasswordResponse.userId,
                  studentId: doLoginWithLoginUserIdAndPasswordResponse.studentId,
                );
              }),
              (Route<dynamic> route) => false,
            );
          } else {
            if (doLoginWithLoginUserIdAndPasswordResponse.userId != null) {
              user_details.UserDetails getUserDetailsRequest = user_details.UserDetails(
                userId: doLoginWithLoginUserIdAndPasswordResponse.userId,
              );
              user_details.GetUserDetailsResponse getUserDetailsResponse = await getUserDetails(getUserDetailsRequest);
              if (getUserDetailsResponse.responseStatus != "success" ||
                  getUserDetailsResponse.httpStatus != "OK" ||
                  getUserDetailsResponse.userDetails!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error Occurred"),
                  ),
                );
                setState(() {
                  _isLoading = false;
                });
                return;
              } else {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('IS_USER_LOGGED_IN', true);
                await prefs.setInt('LOGGED_IN_USER_ID', getUserDetailsResponse.userDetails!.first.userId!);
                await prefs.setBool("IS_EMAIL_LOGIN", false);
                if (getUserDetailsResponse.userDetails!.first.fourDigitPin != null) {
                  await prefs.setString('USER_FOUR_DIGIT_PIN', getUserDetailsResponse.userDetails!.first.fourDigitPin!);
                }
                await doLogin(
                  DoLoginRequest(
                    createOrUpdateFcmTokenRequest: CreateOrUpdateFcmTokenRequest(
                      fcmBean: FcmBean(
                        userId: getUserDetailsResponse.userDetails!.first.userId!,
                        fcmToken: null,
                        fcmTokenId: null,
                        requestedDevice: "web",
                        userName: getUserDetailsResponse.userDetails!.first.firstName,
                      ),
                    ),
                  ),
                );
                setState(() {
                  _isLoading = false;
                });
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  SplashScreen.routeName,
                  (route) => false,
                  arguments: getUserDetailsResponse.userDetails!.first.userId!,
                );
                return;
              }
            } else if (doLoginWithLoginUserIdAndPasswordResponse.studentId != null) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('IS_USER_LOGGED_IN', true);
              await prefs.setInt('LOGGED_IN_STUDENT_ID', doLoginWithLoginUserIdAndPasswordResponse.studentId!);
              await prefs.setBool("IS_EMAIL_LOGIN", false);
              GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
                studentId: doLoginWithLoginUserIdAndPasswordResponse.studentId,
              ));
              setState(() {
                _isLoading = false;
              });
              Navigator.pushNamedAndRemoveUntil(
                context,
                StudentDashBoard.routeName,
                (route) => false,
                arguments: getStudentProfileResponse.studentProfiles!.first!,
              );
              return;
            }
          }
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text(
                    "Submit",
                  ),
          ),
        ),
      ),
    );
  }
}
