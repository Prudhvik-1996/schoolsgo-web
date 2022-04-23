import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/admin_dashboard/admin_dashboard.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/auth.dart';
import 'package:schoolsgo_web/src/model/user_details.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as userDetails;
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/splash_screen/splash_screen.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MegaAdminHomePage extends StatefulWidget {
  MegaAdminHomePage({
    Key? key,
    required this.megaAdminProfiles,
    required this.franchiseName,
  }) : super(key: key);

  static const String routeName = 'mega_admin';
  List<MegaAdminProfile> megaAdminProfiles;
  String? franchiseName;

  @override
  _MegaAdminHomePageState createState() => _MegaAdminHomePageState();
}

class _MegaAdminHomePageState extends State<MegaAdminHomePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Epsilon Diary"),
        actions: [
          InkWell(
            onTap: () {
              showDialog(
                context: _scaffoldKey.currentContext!,
                builder: (dialogueContext) {
                  return AlertDialog(
                    title: const Text('Epsilon Diary'),
                    content: const Text("Are you sure you want to logout?"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Yes"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.remove('USER_FOUR_DIGIT_PIN');
                          await prefs.remove('IS_USER_LOGGED_IN');
                          await prefs.remove('LOGGED_IN_USER_ID');
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            SplashScreen.routeName,
                            (route) => route.isFirst,
                            arguments: true,
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("No"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              child: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
          : canGoToDashBoard
              ? ListView(
                  children: widget.megaAdminProfiles
                      .map(
                        (MegaAdminProfile eachMegaAdminProfile) => buildMegaAdminButton(context, eachMegaAdminProfile),
                      )
                      .toList(),
                )
              : goToSignUpPage
                  ? signUpPin()
                  : pinScreen(),
    );
  }

  Container buildMegaAdminButton(BuildContext context, MegaAdminProfile eachMegaAdminProfile) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: InkWell(
        onTap: () {
          AdminProfile adminProfile = AdminProfile(
            schoolId: eachMegaAdminProfile.schoolId,
            schoolName: eachMegaAdminProfile.schoolName,
            userId: eachMegaAdminProfile.userId,
            firstName: eachMegaAdminProfile.userName,
            mailId: eachMegaAdminProfile.mailId,
            schoolPhotoUrl: eachMegaAdminProfile.schoolPhotoUrl,
            isMegaAdmin: true,
          );
          Navigator.pushNamed(
            context,
            AdminDashboard.routeName,
            arguments: adminProfile,
          );
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            // child: Text("Student: ${e.studentFirstName}"),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        eachMegaAdminProfile.schoolName ?? "-",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).dialogBackgroundColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 50,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            (eachMegaAdminProfile.city ?? "-").capitalize(),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadPrefs() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userDetails.GetUserDetailsResponse getUserDetailsResponse = await getUserDetails(
      userDetails.UserDetails(
        userId: widget.megaAdminProfiles.first.userId,
      ),
    );
    if (getUserDetailsResponse.userDetails!.first.fourDigitPin != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('USER_FOUR_DIGIT_PIN', getUserDetailsResponse.userDetails!.first.fourDigitPin!);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('USER_FOUR_DIGIT_PIN');
    }
    setState(() {
      fourDigitPin = prefs.getString('USER_FOUR_DIGIT_PIN');
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
    });
    GenerateOtpRequest generateOtpRequest = GenerateOtpRequest(
      userId: widget.megaAdminProfiles.first.userId,
      channel: "WEB",
      deviceName: "-",
      otpType: "SIGNUP",
      requestedEmail: widget.megaAdminProfiles.first.mailId,
    );
    GenerateOtpResponse generateOtpResponse = await generateOtp(generateOtpRequest);
    if (generateOtpResponse.httpStatus != "OK" || generateOtpResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        otp = generateOtpResponse.otpBean?.otpValue;
      });
      SendEmailRequest sendEmailRequest = SendEmailRequest(
        content: EmailContent(
          subject: "OTP for authenticating Set/Reset pin request",
          body: "OTP to authenticate your request for set/reset pin is $otp",
          html: true,
        ),
        recieverEmailIds: [
          widget.megaAdminProfiles.first.mailId,
        ],
      );
      SendEmailResponse sendEmailResponse = await sendEmail(sendEmailRequest);
      if (sendEmailResponse.httpStatus != "OK" || sendEmailResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  String? fourDigitPin;
  bool canGoToDashBoard = false;
  bool goToSignUpPage = false;
  bool isOtpValidated = false;
  String? otp;
  String userOtp = "";
  TextEditingController otpController = TextEditingController();

  TextEditingController pinController = TextEditingController();
  TextEditingController newPinController = TextEditingController();
  TextEditingController newConfirmPinController = TextEditingController();

  String pin = "";
  bool showPin = false;
  String newPin = "";
  String confirmNewPin = "";
  bool showNewPin = false;
  bool showConfirmPin = false;

  List<Widget> commonWidgets() {
    return [
      Container(
        margin: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                (widget.megaAdminProfiles.first.userName ?? "-").trim(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(10),
              child: const SizedBox(
                width: 50,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Mega Admin"),
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(widget.megaAdminProfiles.first.franchiseName ?? "-"),
            ),
          ],
        ),
      ),
    ];
  }

  Widget pinScreen() {
    if (fourDigitPin == null) {
      setState(() {
        goToSignUpPage = true;
      });
      _sendOtp();
    }
    return Center(
      child: Container(
        margin: MediaQuery.of(context).orientation == Orientation.portrait
            ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
            : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
        child: ClayContainer(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          child: Container(
            margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...commonWidgets(),
                Container(
                  margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                  child: pinTextField(),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Expanded(
                        child: Text(""),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            goToSignUpPage = true;
                          });
                          _sendOtp();
                        },
                        child: const Text(
                          "Forgot pin",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPointerDownForPin(PointerDownEvent event) {
    setState(() {
      showPin = true;
    });
  }

  void _onPointerUpForPin(PointerUpEvent event) {
    setState(() {
      showPin = false;
    });
  }

  String? get _errorTextToLogin {
    if (pin.length == 4 && pin != fourDigitPin) {
      return "Invalid PIN";
    }
    return null;
  }

  TextField pinTextField() {
    return TextField(
      obscureText: !showPin,
      controller: pinController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        suffix: Listener(
          onPointerDown: _onPointerDownForPin,
          onPointerUp: _onPointerUpForPin,
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Icon(Icons.remove_red_eye),
          ),
        ),
        label: const Text(
          'PIN',
          textAlign: TextAlign.end,
        ),
        hintText: '4-digit PIN',
        errorText: _errorTextToLogin,
        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.length > 4) return oldValue;
            if (text.isNotEmpty) int.parse(text);
            return newValue;
          } catch (e) {}
          return oldValue;
        }),
      ],
      onChanged: (String e) {
        setState(() {
          pin = e;
        });
        if (e == fourDigitPin) {
          setState(() {
            canGoToDashBoard = true;
          });
        }
      },
      style: const TextStyle(
        fontSize: 12,
      ),
      autofocus: true,
    );
  }

  Widget signUpPin() {
    if (!isOtpValidated) {
      return otpScreen();
    }
    return Center(
      child: Container(
        margin: MediaQuery.of(context).orientation == Orientation.portrait
            ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
            : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
        child: ClayContainer(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          child: Container(
            margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...commonWidgets(),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                  child: newPinTextField(),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                  child: newConfirmPinTextField(),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget otpScreen() {
    return Center(
      child: Container(
        margin: MediaQuery.of(context).orientation == Orientation.portrait
            ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
            : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
        child: ClayContainer(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          child: Container(
            margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...commonWidgets(),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      "An OTP has been sent to your registered Email Id, ${widget.megaAdminProfiles.first.mailId}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(50, 15, 50, 15),
                  child: otpTextField(),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPointerDownForConfirmNewPin(PointerDownEvent event) {
    setState(() {
      showConfirmPin = true;
    });
  }

  void _onPointerUpForConfirmNewPin(PointerUpEvent event) {
    setState(() {
      showConfirmPin = false;
    });
  }

  TextField newConfirmPinTextField() {
    return TextField(
      obscureText: !showConfirmPin,
      controller: newConfirmPinController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        suffix: Listener(
          onPointerDown: _onPointerDownForConfirmNewPin,
          onPointerUp: _onPointerUpForConfirmNewPin,
          child: const Icon(Icons.remove_red_eye),
        ),
        label: const Text(
          'Confirm PIN',
          textAlign: TextAlign.end,
        ),
        errorText: errorTextForNewPin,
        hintText: '4-digit PIN',
        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.length > 4) return oldValue;
            if (text.isNotEmpty) int.parse(text);
            return newValue;
          } catch (e) {}
          return oldValue;
        }),
      ],
      onChanged: (String e) async {
        setState(() {
          confirmNewPin = newConfirmPinController.text;
        });
        if (e == newPin && e.length == 4) {
          UpdateUserFourDigitPinResponse updateUserFourDigitPinResponse = await updateUserFourDigitPin(UpdateUserFourDigitPinRequest(
            agent: widget.megaAdminProfiles.first.userId,
            userId: widget.megaAdminProfiles.first.userId,
            newFourDigitPin: e,
          ));
          if (updateUserFourDigitPinResponse.httpStatus != "OK" || updateUserFourDigitPinResponse.responseStatus != "success") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Something went wrong! Try again later.."),
              ),
            );
          } else {
            _loadPrefs();
            setState(() {
              canGoToDashBoard = true;
            });
          }
        }
      },
      style: const TextStyle(
        fontSize: 12,
      ),
      autofocus: true,
    );
  }

  void _onPointerDownForNewPin(PointerDownEvent event) {
    setState(() {
      showNewPin = true;
    });
  }

  void _onPointerUpForNewPin(PointerUpEvent event) {
    setState(() {
      showNewPin = false;
    });
  }

  TextField newPinTextField() {
    return TextField(
      obscureText: !showNewPin,
      controller: newPinController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        suffix: Listener(
          onPointerDown: _onPointerDownForNewPin,
          onPointerUp: _onPointerUpForNewPin,
          child: const Icon(Icons.remove_red_eye),
        ),
        label: const Text(
          'PIN',
          textAlign: TextAlign.end,
        ),
        hintText: '4-digit PIN',
        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.length > 4) return oldValue;
            if (text.isNotEmpty) int.parse(text);
            return newValue;
          } catch (e) {}
          return oldValue;
        }),
      ],
      onChanged: (String e) {
        setState(() {
          newPin = newPinController.text;
        });
      },
      style: const TextStyle(
        fontSize: 12,
      ),
      autofocus: true,
    );
  }

  String? get errorTextForNewPin {
    if (newPin.length < 4) return "PIN should be 4 digits";
    if (confirmNewPin.length == 4 && newPin.length == 4 && newPin != confirmNewPin) return "Pins do not match";
    if (confirmNewPin.length != 4) return "Pin should be exactly 4 digits";
    return null;
  }

  String? get _errorTextToOtpValidate {
    if (userOtp.length == 4 && userOtp != otp) {
      return "Invalid OTP";
    }
    return null;
  }

  TextField otpTextField() {
    return TextField(
      controller: otpController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        errorText: _errorTextToOtpValidate,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        label: const Text(
          'OTP',
          textAlign: TextAlign.end,
        ),
        hintText: 'OTP',
        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.length > 4) return oldValue;
            if (text.isNotEmpty) int.parse(text);
            return newValue;
          } catch (e) {}
          return oldValue;
        }),
      ],
      onChanged: (String e) {
        setState(() {
          userOtp = e;
        });
        if (userOtp == otp) {
          setState(() {
            isOtpValidated = true;
          });
        }
      },
      style: const TextStyle(
        fontSize: 12,
      ),
      autofocus: true,
    );
  }
}
