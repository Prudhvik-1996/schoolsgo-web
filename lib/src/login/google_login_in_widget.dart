import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleLoginWidget extends StatefulWidget {
  final Future<void> Function(String email) doAppLogin;
  final Future<void> Function() signOutFromGoogle;
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;

  const GoogleLoginWidget({
    super.key,
    required this.doAppLogin,
    required this.signOutFromGoogle,
    required this.googleSignIn,
    required this.firebaseAuth,
  });

  @override
  State<GoogleLoginWidget> createState() => _GoogleLoginWidgetState();
}

class _GoogleLoginWidgetState extends State<GoogleLoginWidget> {
  bool _isLoading = false;

  GoogleSignInAccount? _currentUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: _getGoogleAvatar(),
        ),
        if (_currentUser != null)
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
          await widget.doAppLogin(_currentUser!.email);
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
            child: _isLoading || _currentUser == null
                ? const CircularProgressIndicator()
                : const Text(
                    "Continue",
                  ),
          ),
        ),
      ),
    );
  }

  Widget _getGoogleAvatar() {
    if (_currentUser == null) {
      return _newGoogleSignInButton();
    }
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
          await widget.signOutFromGoogle();
          setState(() {
            _currentUser = null;
          });
        },
        child: const Icon(Icons.clear),
      ),
    );
  }

  Widget _newGoogleSignInButton() {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        setState(() {
          _isLoading = true;
        });
        await signInWithGoogle();
        setState(() {
          _isLoading = false;
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

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await widget.googleSignIn.signIn();
      setState(() {
        _currentUser = googleSignInAccount;
      });
      if (_currentUser != null) {
        await widget.doAppLogin(_currentUser!.email);
      }
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await widget.firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }
}
