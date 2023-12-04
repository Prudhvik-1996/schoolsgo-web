import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/login/generate_new_login_pin_screen.dart';
import 'package:schoolsgo_web/src/model/user_details.dart';
import 'package:schoolsgo_web/src/splash_screen/splash_screen.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colors.dart';

class MobileLoginWidget extends StatefulWidget {
  final FirebaseAuth firebaseAuth;

  const MobileLoginWidget({
    super.key,
    required this.firebaseAuth,
  });

  @override
  State<MobileLoginWidget> createState() => _MobileLoginWidgetState();
}

class _MobileLoginWidgetState extends State<MobileLoginWidget> {
  bool _isLoading = false;
  TextEditingController mobileEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  String mobileErrorText = "";
  bool showPassword = false;

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
                      mobileErrorText = "";
                    });
                  },
                  controller: mobileEditingController,
                  enabled: true,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      try {
                        final text = newValue.text;
                        if (text.length > 10) return oldValue;
                        if (text.isNotEmpty) int.parse(text);
                        return newValue;
                      } catch (e) {
                        return oldValue;
                      }
                    }),
                  ],
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'Mobile Number',
                    hintText: '10 digit Mobile Number',
                    contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  autofocus: true,
                  onChanged: (String e) {
                    setState(() {
                      mobileErrorText = "";
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
                mobileErrorText = "";
              });
            },
            controller: passwordEditingController,
            enabled: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
              TextInputFormatter.withFunction((oldValue, newValue) {
                try {
                  final text = newValue.text;
                  if (text.length > 6) return oldValue;
                  if (text.isNotEmpty) int.parse(text);
                  return newValue;
                } catch (e) {
                  return oldValue;
                }
              }),
            ],
            obscureText: !showPassword,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              labelText: 'Password',
              hintText: 'Password',
              contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
            ),
            style: const TextStyle(
              fontSize: 12,
            ),
            autofocus: true,
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: ListTile(
            leading: Checkbox(
              value: showPassword,
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  setState(() => showPassword = newValue);
                }
              },
            ),
            title: const Text(
              'Show Password',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
        if (mobileErrorText != "")
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
                  mobileErrorText,
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
      ],
    );
  }

  GestureDetector buildRequestLoginOtp(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_isLoading) return;
        setState(() => _isLoading = true);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        UserDetails getUserDetailsRequest = UserDetails(
          mobile: mobileEditingController.text,
        );
        GetUserDetailsResponse getUserDetailsResponse = await getUserDetails(getUserDetailsRequest);
        UserDetails? userDetails = (getUserDetailsResponse.userDetails ?? []).firstOrNull();
        if (getUserDetailsResponse.responseStatus != "success" || getUserDetailsResponse.httpStatus != "OK" || userDetails == null) {
          setState(() => mobileErrorText = "Invalid Credentials");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Credentials"),
            ),
          );
          setState(() => _isLoading = false);
          return;
        } else {
          if (userDetails.password == null) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) {
                return GenerateNewLoginPinScreen(
                  userId: userDetails.userId,
                  studentId: null,
                );
              }),
              (Route<dynamic> route) => false,
            );
          } else {
            if (userDetails.password != passwordEditingController.text) {
              setState(() => mobileErrorText = "Invalid Credentials");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Invalid Credentials"),
                ),
              );
              setState(() => _isLoading = false);
            } else {
              setState(() => _isLoading = true);
              prefs.setString("LOGGED_IN_MOBILE", mobileEditingController.text);
              Navigator.pushNamedAndRemoveUntil(
                context,
                SplashScreen.routeName,
                (route) => false,
              );
              setState(() => _isLoading = false);
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                  ),
                )
              : const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Submit",
                  ),
                ),
        ),
      ),
    );
  }
}
