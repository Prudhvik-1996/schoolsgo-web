import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/common_components/glass_container/glass_container.dart';
import 'package:schoolsgo_web/src/common_components/upper_case_text_formatter.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/login/generate_new_login_pin_screen.dart';
import 'package:schoolsgo_web/src/login/model/login.dart';
import 'package:schoolsgo_web/src/model/auth.dart';
import 'package:schoolsgo_web/src/model/user_details.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as user_details;
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/splash_screen/splash_screen.dart';
import 'package:schoolsgo_web/src/student_dashboard/student_dashboard.dart';
import 'package:schoolsgo_web/src/user_dashboard/user_dashboard.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login_room';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignInAccount? _currentUser;

  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "480997552358-t9ir5mnb6t91gcemhdmdivh3a1uo3208.apps.googleusercontent.com",
  );

  String? token;

  TextEditingController emailEditingController = TextEditingController();
  TextEditingController loginIdEditingController = TextEditingController();
  TextEditingController loginPinEditingController = TextEditingController();
  bool _loggingWithEmail = false;
  bool loginWithOtp = true;
  bool otpToBeEntered = false;
  String otp = "2107";
  String emailErrorText = "";
  String loginIdErrorText = "";
  bool _isSendingOtp = false;

  final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'ySchrZKZO1w',
    params: const YoutubePlayerParams(
      startAt: Duration(seconds: 30),
      showControls: true,
      showFullscreenButton: true,
      autoPlay: false,
      mute: true,
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      setState(() {
        _currentUser = googleSignInAccount;
      });
      if (_currentUser != null) {
        doAppLogin(_currentUser!.email);
      }
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint("43");
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _handleSignIn() async {
    try {
      // await _googleSignIn.signIn();
      await signInWithGoogle();
    } catch (error) {
      debugPrint("$error");
    }
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

  Widget _newGoogleSignInButton() {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await _handleSignIn();
        if (_currentUser != null) {
          setState(() {
            loginWithOtp = false;
          });
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/google-logo.png",
                height: 20,
                width: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Sign in with Google",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getGoogleAvatar() {
    return ListTile(
      leading: GoogleUserCircleAvatar(
        identity: _currentUser!,
      ),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(_currentUser!.displayName ?? ''),
      ),
      subtitle: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(_currentUser!.email),
      ),
      trailing: InkWell(
        onTap: () async {
          await signOutFromGoogle();
          setState(() {
            _currentUser = null;
          });
        },
        child: const Icon(Icons.clear),
      ),
    );
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
                  child: loginWithOtp || _currentUser == null ? buildLoginWithOtpColumn() : buildLoginWithGoogleColumn(),
                ),
              ),
              Expanded(
                flex: 1,
                child: buildAnimatedWidget(),
              ),
            ],
          ),
        ),
        // buildYoutubeVideoContainer(),
        // Text(
        //   '<iframe width="811" height="456" src="https://www.youtube.com/embed/ySchrZKZO1w" title="Epsilon Diary" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>',
        // ),
      ],
    );
  }

  Container buildYoutubeVideoContainer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: YoutubePlayerControllerProvider(
        controller: _controller,
        child: const YoutubePlayerIFrame(
          aspectRatio: 16 / 9,
        ),
      ),
    );
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
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: loginWithOtp || _currentUser == null ? buildLoginWithOtpColumn() : buildLoginWithGoogleColumn(),
            ),
            const SizedBox(
              height: 20,
            ),
            // buildYoutubeVideoContainer(),
          ],
        ),
      ),
    );
  }

  Widget buildPortraitScreenV2() {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: buildAnimatedWidget(margin: const EdgeInsets.all(0), alignment: Alignment.bottomRight),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          padding: const EdgeInsets.all(20),
          child: GlassContainer(
            start: 0.9,
            end: 0.6,
            child: loginWithOtp || _currentUser == null ? buildLoginWithOtpColumn() : buildLoginWithGoogleColumn(),
          ),
        ),
      ],
    );
  }

  Column buildLoginWithGoogleColumn() {
    return Column(
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
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: _getGoogleAvatar(),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Row(
            children: [
              Expanded(
                child: buildLoginButton(),
              ),
            ],
          ),
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
                child: doOtpLoginWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLoginButton() {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isLoading = true;
        });
        if (_currentUser != null) {
          await doAppLogin(_currentUser!.email);
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
              "Continue",
            ),
          ),
        ),
      ),
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

  Widget doOtpLoginWidget() {
    return GestureDetector(
      onTap: () {
        setState(() {
          loginWithOtp = true;
        });
      },
      child: ClayButton(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: const Center(
            child: Text("Login with OTP"),
          ),
        ),
      ),
    );
  }

  Column buildLoginWithOtpColumn() {
    return Column(
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
            )),
          ),
        ),
        if (_loggingWithEmail) ...emailLoginWidgets(),
        if (!_loggingWithEmail) ...userIdLoginWidgets(),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const Spacer(),
            InkWell(
              onTap: () {
                setState(() => _loggingWithEmail = !_loggingWithEmail);
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  _loggingWithEmail ? "Login with User Id" : "Login with e-mail",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
          ],
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
                child: _newGoogleSignInButton(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> emailLoginWidgets() {
    return [
      Container(
        margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onTap: () {
                  setState(() {
                    emailErrorText = "";
                  });
                },
                controller: emailEditingController,
                enabled: !otpToBeEntered,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  labelText: 'Email Address',
                  hintText: 'Email Address',
                  contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                ),
                style: const TextStyle(
                  fontSize: 12,
                ),
                autofocus: true,
                onChanged: (String e) {
                  setState(() {
                    emailErrorText = "";
                  });
                },
              ),
            ),
            if (otpToBeEntered)
              Container(
                margin: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      otpToBeEntered = false;
                      otp = "";
                    });
                  },
                  child: const Icon(Icons.clear),
                ),
              )
          ],
        ),
      ),
      if (otpToBeEntered && !_isSendingOtp)
        Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: TextField(
            onTap: () {
              setState(() {
                emailErrorText = "";
              });
            },
            controller: TextEditingController(),
            enabled: otpToBeEntered,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              labelText: 'OTP',
              hintText: 'OTP',
              contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
            ),
            style: const TextStyle(
              fontSize: 12,
            ),
            autofocus: true,
            onChanged: (String value) {
              if (value.length == 4 && value != otp) {
                setState(() {
                  emailErrorText = "Invalid OTP";
                });
              }
              if (value == otp) {
                doAppLogin(emailEditingController.text);
              }
            },
          ),
        ),
      if (emailErrorText != "")
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
                emailErrorText,
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
              child: buildRequestLoginOtp(context),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> userIdLoginWidgets() {
    return [
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
                loginIdErrorText,
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
    ];
  }

  GestureDetector buildRequestLoginOtp(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        user_details.UserDetails getUserDetailsRequest = user_details.UserDetails(
          mailId: emailEditingController.text,
        );
        GetUserDetailsResponse getUserDetailsResponse = await getUserDetails(getUserDetailsRequest);
        if (getUserDetailsResponse.responseStatus != "success" ||
            getUserDetailsResponse.httpStatus != "OK" ||
            getUserDetailsResponse.userDetails!.isEmpty) {
          setState(() {
            emailErrorText = "Your email has not been registered";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Your email has not been registered"),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        } else {
          _sendOtp(getUserDetailsResponse.userDetails!.first);
          setState(() {
            otpToBeEntered = true;
          });
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
          child: _isSendingOtp
              ? const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                  ),
                )
              : const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Request OTP",
                  ),
                ),
        ),
      ),
    );
  }

  GestureDetector buildVerifyCredentials(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        DoLoginWithLoginUserIdAndPasswordResponse doLoginWithLoginUserIdAndPasswordResponse = await doLoginWithLoginUserIdAndPassword(
          DoLoginWithLoginUserIdAndPasswordRequest(
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
                await prefs.setBool("IS_EMAIL_LOGIN", false);
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

  Future<void> _sendOtp(user_details.UserDetails userDetails) async {
    setState(() {
      _isSendingOtp = true;
    });
    GenerateOtpRequest generateOtpRequest = GenerateOtpRequest(
      userId: userDetails.userId,
      channel: "WEB",
      deviceName: "-",
      otpType: "LOGIN",
      requestedEmail: userDetails.mailId,
    );
    GenerateOtpResponse generateOtpResponse = await generateOtp(generateOtpRequest);
    if (generateOtpResponse.httpStatus != "OK" || generateOtpResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      setState(() {
        _isSendingOtp = false;
      });
    } else {
      setState(() {
        otp = generateOtpResponse.otpBean?.otpValue ?? "";
      });
      SendEmailRequest sendEmailRequest = SendEmailRequest(
        recipient: userDetails.mailId,
        subject: "Epsilon Diary: OTP for Logging in",
        msgBody: "OTP to authenticate your request to login is $otp",
      );
      String sendEmailResponse = await sendEmail(sendEmailRequest);
      if (sendEmailResponse.contains("Error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
    setState(() {
      _isSendingOtp = false;
    });
  }
}
