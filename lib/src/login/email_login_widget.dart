import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/auth.dart';
import 'package:schoolsgo_web/src/model/user_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailLoginWidget extends StatefulWidget {
  final Future<void> Function(String email) doAppLogin;
  final Future<void> Function() signOutFromGoogle;

  const EmailLoginWidget({
    super.key,
    required this.doAppLogin,
    required this.signOutFromGoogle,
  });

  @override
  State<EmailLoginWidget> createState() => _EmailLoginWidgetState();
}

class _EmailLoginWidgetState extends State<EmailLoginWidget> {
  bool _isLoading = false;
  TextEditingController emailEditingController = TextEditingController();
  bool otpToBeEntered = false;
  String otp = "2107";
  String emailErrorText = "";
  bool _isSendingOtp = false;

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
              onChanged: (String value) async {
                if (value.length == 4 && value != otp) {
                  setState(() {
                    emailErrorText = "Invalid OTP";
                  });
                }
                if (value == otp) {
                  setState(() => _isLoading = true);
                  await widget.doAppLogin(emailEditingController.text);
                  setState(() => _isLoading = false);
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
      ],
    );
  }

  GestureDetector buildRequestLoginOtp(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_isLoading || _isSendingOtp) return;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
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
          child: _isSendingOtp || _isLoading
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
