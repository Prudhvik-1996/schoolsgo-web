import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/glass_container/glass_container.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/login/model/login.dart';
import 'package:schoolsgo_web/src/model/auth.dart';
import 'package:schoolsgo_web/src/model/user_details.dart';
import 'package:schoolsgo_web/src/user_dashboard/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login_room';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignInAccount? _currentUser;

  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "480997552358-t9ir5mnb6t91gcemhdmdivh3a1uo3208.apps.googleusercontent.com",
  );

  String? token = DateTime.now().millisecondsSinceEpoch.toString();

  TextEditingController emailEditingController = TextEditingController();
  bool loginWithOtp = true;
  bool otpToBeEntered = false;
  String otp = "2107";
  String emailErrorText = "";
  bool _isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    loadFcmToken();
  }

  Future<void> loadFcmToken() async {
    try {
      token = await FirebaseMessaging.instance.getToken();
      print("40: $token");
    } catch (e) {
      debugPrint("Exception occurred while trying to retrieve FCM Token, $e");
    }
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
      print("43");
      print(e.message);
      throw e;
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
      print("$error");
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
            // ? Lottie.asset('assets/lottie/login_screen_student_animation_light.json')
            // ? Lottie.network("https://assets9.lottiefiles.com/packages/lf20_opmrx1hj.json")
            // : Lottie.network("https://assets2.lottiefiles.com/packages/lf20_tvrsi6y6.json"),
            // : Lottie.asset('assets/lottie/login_screen_student_animation_dark.json'),
            ? Image.asset("assets/images/login_screen_student_animation_light.gif")
            : Image.asset("assets/images/login_screen_student_animation_dark.gif"),
      ),
    );
  }

  Widget _newGoogleSignInButton() {
    return GestureDetector(
      onTap: () async {
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
    return Scaffold(
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
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : (MediaQuery.of(context).orientation == Orientation.landscape)
              ? buildLandscapeScreen()
              : buildPortraitScreen(),
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
      ],
    );
  }

  Widget buildPortraitScreen() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Column(
          children: [
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
            SizedBox(
              height: 250,
              width: 300,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomRight,
                child: buildAnimatedWidget(),
              ),
            ),
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
            )),
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
    UserDetails getUserDetailsRequest = UserDetails(
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
      if (getUserDetailsResponse.userDetails!.first.fourDigitPin != null) {
        await prefs.setString('USER_FOUR_DIGIT_PIN', getUserDetailsResponse.userDetails!.first.fourDigitPin!);
      }
      DoLoginResponse doLoginResponse = await doLogin(
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

  GestureDetector buildRequestLoginOtp(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        UserDetails getUserDetailsRequest = UserDetails(
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

  Future<void> _sendOtp(UserDetails userDetails) async {
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
        content: EmailContent(
          subject: "Epsilon Diary: OTP for Logging in",
          body: "OTP to authenticate your request to login is $otp",
          html: true,
        ),
        recieverEmailIds: [
          userDetails.mailId,
        ],
      );
      SendEmailResponse sendEmailResponse = await sendEmail(sendEmailRequest);
      if (sendEmailResponse.httpStatus != "OK" || sendEmailResponse.responseStatus != "success") {
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
