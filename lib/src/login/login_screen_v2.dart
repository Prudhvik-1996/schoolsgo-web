import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/login/email_login_widget.dart';
import 'package:schoolsgo_web/src/login/google_login_in_widget.dart';
import 'package:schoolsgo_web/src/login/mobile_login_widget.dart';
import 'package:schoolsgo_web/src/login/model/login.dart';
import 'package:schoolsgo_web/src/login/unique_id_login_widget.dart';
import 'package:schoolsgo_web/src/model/user_details.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as user_details;
import 'package:schoolsgo_web/src/user_dashboard/user_dashboard.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({Key? key}) : super(key: key);

  static const routeName = '/login_room';

  @override
  _LoginScreenV2State createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: "480997552358-t9ir5mnb6t91gcemhdmdivh3a1uo3208.apps.googleusercontent.com",
  );

  String? token;

  ///
  /// login with email otp
  /// login with mobile otp
  /// login with unique id
  /// login with google
  ///

  String loginMode = "mobile";

  @override
  void initState() {
    super.initState();
    // firebaseAuth.setSettings(appVerificationDisabledForTesting: true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor != Colors.blue ? const Color(0xFF2c2c2c) : const Color(0xFFFFFFFF),
        restorationId: "LoginScreen",
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Theme.of(context).primaryColor != Colors.blue ? const Color(0xFF2c2c2c) : const Color(0xFFFFFFFF),
          iconTheme:
              Theme.of(context).primaryColor == Colors.blue ? const IconThemeData(color: Colors.black) : const IconThemeData(color: Colors.white),
        ),
        drawer: const DefaultAppDrawer(),
        body: _isLoading
            ? const EpsilonDiaryLoadingWidget()
            : (MediaQuery.of(context).orientation == Orientation.landscape)
                ? buildLandscapeScreen()
                : buildPortraitScreen(),
      ),
    );
  }

  Widget buildLandscapeScreen() {
    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(40, 10, 40, 10),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: MediaQuery.of(context).orientation == Orientation.landscape
                            ? const EdgeInsets.fromLTRB(15, 50, 15, 10)
                            : const EdgeInsets.fromLTRB(15, 5, 15, 10),
                        child: Text(
                          "Login",
                          style: GoogleFonts.archivoBlack(
                            textStyle: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      getLoginWidget(),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(
                        height: 2,
                        thickness: 0.5,
                        color: Colors.blue,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: moreLoginOptionsWidget(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: buildAnimatedWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getLoginWidget() {
    return loginMode == "email"
        ? EmailLoginWidget(
            doAppLogin: doAppLogin,
            signOutFromGoogle: signOutFromGoogle,
          )
        : loginMode == "mobile"
            ? MobileLoginWidget(
                firebaseAuth: firebaseAuth,
              )
            : loginMode == "unique Id"
                ? const UniqueIdLoginWidget()
                : loginMode == "google"
                    ? GoogleLoginWidget(
                        googleSignIn: googleSignIn,
                        firebaseAuth: firebaseAuth,
                        doAppLogin: doAppLogin,
                        signOutFromGoogle: signOutFromGoogle,
                      )
                    : Container();
  }

  Widget buildPortraitScreen() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              width: 300,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomRight,
                child: buildAnimatedWidget(),
              ),
            ),
            Container(
              margin: MediaQuery.of(context).orientation == Orientation.landscape
                  ? const EdgeInsets.fromLTRB(15, 50, 15, 10)
                  : const EdgeInsets.fromLTRB(15, 5, 15, 10),
              child: Text(
                "Login",
                style: GoogleFonts.archivoBlack(
                  textStyle: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: getLoginWidget(),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              height: 2,
              thickness: 0.5,
              color: Colors.blue,
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Row(
                children: [
                  Expanded(
                    child: moreLoginOptionsWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget moreLoginOptionsWidget() {
    return Row(
      children: [
        const Expanded(child: Text("Login with")),
        DropdownButton(
          isExpanded: false,
          value: loginMode,
          items: ["mobile", "unique Id", "email", "google"]
              .map((e) => DropdownMenuItem(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8,0,8,0),
                      child: Text(e.capitalize()),
                    ),
                    value: e,
                  ))
              .toList(),
          onChanged: (String? e) {
            if (e != null) {
              setState(() => loginMode = e);
            }
          },
        ),
      ],
    );
  }

  Future<void> doAppLogin(String email) async {
    user_details.UserDetails getUserDetailsRequest = user_details.UserDetails(
      mailId: email,
    );
    setState(() {
      _isLoading = true;
    });
    GetUserDetailsResponse getUserDetailsResponse = await getUserDetails(getUserDetailsRequest);
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
      await prefs.setString('LOGGED_IN_USER_EMAIL', email);
      await prefs.setBool("IS_EMAIL_LOGIN", true);
      if (getUserDetailsResponse.userDetails!.first.fourDigitPin != null) {
        await prefs.setString('USER_FOUR_DIGIT_PIN', getUserDetailsResponse.userDetails!.first.fourDigitPin!);
      }
      await doLogin(
        DoLoginRequest(
          createOrUpdateFcmTokenRequest: CreateOrUpdateFcmTokenRequest(
            fcmBean: FcmBean(
              userId: getUserDetailsResponse.userDetails!.first.userId!,
              fcmToken: token,
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
        UserDashboard.routeName,
        (route) => false,
        arguments: getUserDetailsResponse.userDetails!.first.userId!,
      );
      return;
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      await googleSignIn.signOut();
    } catch (_) {
      debugPrint("Something went wrong while trying to sign out from google");
    }
    try {
      await firebaseAuth.signOut();
    } catch (_) {
      debugPrint("Something went wrong while trying to sign out from firebase");
    }
    await (await SharedPreferences.getInstance()).clear();
  }

  Container buildAnimatedWidget({
    margin = const EdgeInsets.all(20),
    alignment = Alignment.center,
  }) {
    return Container(
      margin: margin,
      child: Align(
        alignment: alignment,
        child: Theme.of(context).primaryColor == Colors.blue
            ? Image.asset("assets/images/login_screen_student_animation_light.gif")
            : Image.asset("assets/images/login_screen_student_animation_dark.gif"),
      ),
    );
  }
}
