import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
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

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      setState(() {
        _currentUser = googleSignInAccount;
      });
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

  Future<void> _handleSignOut() async {
    await signOutFromGoogle();
  }

  Widget _getHeaderWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[200],
      ),
      height: 250,
      child: Center(
        child: Text(
          "Epsilon Diary",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return InkWell(
      onTap: () {
        _handleSignIn();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(50),
          color: Colors.grey.shade50,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2.5,
            ),
          ],
        ),
        margin: const EdgeInsets.fromLTRB(50, 50, 50, 10),
        padding: const EdgeInsets.all(15),
        child: _currentUser != null
            ? const Text(
                "Sign in with other account",
                textAlign: TextAlign.center,
              )
            : Row(
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
                  const Text(
                    "Sign in with Google",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _getGoogleAvatar() {
    return InkWell(
      onTap: () async {
        setState(() {
          _isLoading = true;
        });
        if (_currentUser != null) {
          UserDetails getUserDetailsRequest = UserDetails(
            mailId: _currentUser!.email,
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
            if (getUserDetailsResponse.userDetails!.first.fourDigitPin != null) {
              await prefs.setString('USER_FOUR_DIGIT_PIN', getUserDetailsResponse.userDetails!.first.fourDigitPin!);
            }
            setState(() {
              _isLoading = false;
            });
            // Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              UserDashboard.routeName,
              (route) => false,
              arguments: getUserDetailsResponse.userDetails!.first.userId!,
            );
            return;
          }
        }
      },
      child: ListTile(
        leading: GoogleUserCircleAvatar(
          identity: _currentUser!,
        ),
        title: Text(_currentUser!.displayName ?? ''),
        subtitle: Text(_currentUser!.email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      restorationId: "LoginScreen",
      // appBar: AppBar(
      //   title: const Text("Epsilon Diary"),
      // ),
      // drawer: const DefaultAppDrawer(),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : ListView(
              children: [
                _getHeaderWidget(),
                _currentUser == null ? Container() : _getGoogleAvatar(),
                _googleSignInButton(),
                _currentUser == null ? Container() : Container(),
              ],
            ),
    );
  }
}
