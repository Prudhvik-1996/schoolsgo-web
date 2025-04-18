import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';
import 'package:schoolsgo_web/src/admin_dashboard/admin_stats_widget.dart';
import 'package:schoolsgo_web/src/admin_dashboard/modal/stats.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/dashboard_widgets.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/auth.dart';
import 'package:schoolsgo_web/src/model/user_details.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as userDetails;
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/splash_screen/splash_screen.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/admin_dashboard";

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int? totalAcademicFee;
  int? totalAcademicFeeCollected;
  int? totalBusFee;
  int? totalBusFeeCollected;
  int? totalFeeCollectedForTheDay;
  int? totalNoOfStudents;
  int? totalNoOfStudentsMarkedForAttendance;
  int? totalNoOfStudentsPresent;
  int? totalNoOfEmployees;
  int? totalNoOfEmployeesMarkedForAttendance;
  int? totalNoOfEmployeesPresent;
  int? totalExpensesForTheDay;

  bool showStats = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      restorationId: 'AdminDashBoard',
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          // AcademicYearDropdown(schoolId: widget.adminProfile.schoolId),
          buildRoleButtonForAppBar(context, widget.adminProfile),
          if (canGoToDashBoard)
            InkWell(
              onTap: () {
                setState(() => showStats = !showStats);
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Icon(
                  showStats ? Icons.info_sharp : Icons.info_outline,
                  color: Colors.white,
                ),
              ),
            ),
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
                          await prefs.clear();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            SplashScreen.routeName,
                            (route) => route.isFirst,
                            arguments: true,
                          );
                          await Restart.restartApp(webOrigin: null);
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
      drawer: canGoToDashBoard
          ? AdminAppDrawer(
              adminProfile: widget.adminProfile,
            )
          : const DefaultAppDrawer(),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : canGoToDashBoard
              ? buildOldDashBoardView()
              : goToSignUpPage
                  ? signUpPin()
                  : pinScreen(),
    );
  }

  ListView buildOldDashBoardView() {
    int count = MediaQuery.of(context).orientation == Orientation.landscape ? 5 : 3;
    double mainMargin = MediaQuery.of(context).orientation == Orientation.landscape ? 20 : 10;
    return ListView(
      physics: const BouncingScrollPhysics(),
      controller: ScrollController(),
      children: [
        EisStandardHeader(
          title: Text(
            "Admin Dashboard",
            style: GoogleFonts.archivoBlack(
              textStyle: TextStyle(
                fontSize: 36,
                color: isDarkTheme(context) ? clayContainerTextColor(context) : Colors.white54,
              ),
            ),
          ),
        ),
        if (showStats && !_isLoading)
          AdminStatsWidget(
            context: context,
            totalAcademicFee: totalAcademicFee,
            totalAcademicFeeCollected: totalAcademicFeeCollected,
            totalBusFee: totalBusFee,
            totalBusFeeCollected: totalBusFeeCollected,
            totalFeeCollectedForTheDay: totalFeeCollectedForTheDay,
            totalNoOfStudents: totalNoOfStudents,
            totalNoOfStudentsMarkedForAttendance: totalNoOfStudentsMarkedForAttendance,
            totalNoOfStudentsPresent: totalNoOfStudentsPresent,
            totalNoOfEmployees: totalNoOfEmployees,
            totalNoOfEmployeesMarkedForAttendance: totalNoOfEmployeesMarkedForAttendance,
            totalNoOfEmployeesPresent: totalNoOfEmployeesPresent,
            totalExpensesForTheDay: totalExpensesForTheDay,
            adminProfile: widget.adminProfile,
          ),
        Container(
          margin: EdgeInsets.fromLTRB(mainMargin, 20, mainMargin, mainMargin),
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(1.5),
            crossAxisCount: count,
            childAspectRatio: 1,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
            physics: const NeverScrollableScrollPhysics(),
            children: adminDashBoardWidgets(widget.adminProfile)
                .map(
                  (e) => GestureDetector(
                    onTap: () {
                      debugPrint("Entering ${e.routeName}");
                      Navigator.pushNamed(
                        context,
                        e.routeName!,
                        arguments: e.argument as AdminProfile,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: EdgeInsets.all(MediaQuery.of(context).orientation == Orientation.landscape ? 7.0 : 0.0),
                      child: ClayButton(
                        depth: 40,
                        surfaceColor: clayContainerColor(context),
                        parentColor: clayContainerColor(context),
                        spread: 1,
                        borderRadius: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 50,
                                width: 50,
                                padding: const EdgeInsets.all(5),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Center(
                                    child: e.image,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 20,
                                padding: EdgeInsets.all(MediaQuery.of(context).orientation == Orientation.landscape ? 5 : 2),
                                width: double.infinity,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text("${e.title}"),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ), //new Cards()
                )
                .toList(),
            shrinkWrap: true,
          ),
        ),
      ],
    );
  }

  Future<void> _loadPrefs() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userDetails.GetUserDetailsResponse getUserDetailsResponse = await getUserDetails(
      userDetails.UserDetails(
        userId: widget.adminProfile.userId,
      ),
    );
    if (getUserDetailsResponse.userDetails!.first.fourDigitPin != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('USER_FOUR_DIGIT_PIN', getUserDetailsResponse.userDetails!.first.fourDigitPin!);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('USER_FOUR_DIGIT_PIN');
    }
    if (getUserDetailsResponse.userDetails!.first.mailId == null) {
      goToDashboardAction();
    }
    fourDigitPin = prefs.getString('USER_FOUR_DIGIT_PIN');
    if (fourDigitPin == null) {
      canGoToDashBoard = true;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> goToDashboardAction() async {
    setState(() => _isLoading = true);
    GetSchoolWiseStatsResponse statsResponse = await getSchoolWiseStats(GetSchoolWiseStatsRequest(
      schoolId: widget.adminProfile.schoolId,
      date: convertDateTimeToYYYYMMDDFormat(null),
    ));
    if (statsResponse.httpStatus != "OK" || statsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong while loading today's stats! Try again later.."),
        ),
      );
    } else {
      setState(() {
        totalAcademicFee = statsResponse.totalAcademicFee;
        totalAcademicFeeCollected = statsResponse.totalAcademicFeeCollected;
        totalBusFee = statsResponse.totalBusFee;
        totalBusFeeCollected = statsResponse.totalBusFeeCollected;
        totalFeeCollectedForTheDay = statsResponse.totalFeeCollectedForTheDay;
        totalNoOfStudents = statsResponse.totalNoOfStudents;
        totalNoOfStudentsMarkedForAttendance = statsResponse.totalNoOfStudentsMarkedForAttendance;
        totalNoOfStudentsPresent = statsResponse.totalNoOfStudentsPresent;
        totalNoOfEmployees = statsResponse.totalNoOfEmployees;
        totalNoOfEmployeesPresent = statsResponse.totalNoOfEmployeesPresent;
        totalNoOfEmployeesMarkedForAttendance = statsResponse.totalNoOfEmployeesMarkedForAttendance;
        totalExpensesForTheDay = statsResponse.totalExpensesForTheDay;
      });
    }
    setState(() => _isLoading = false);
    setState(() => canGoToDashBoard = true);
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
    });
    GenerateOtpRequest generateOtpRequest = GenerateOtpRequest(
      userId: widget.adminProfile.userId,
      channel: "WEB",
      deviceName: "-",
      otpType: "ADMIN_ACCESS",
      requestedEmail: widget.adminProfile.mailId,
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
        recipient: widget.adminProfile.mailId,
        subject: "OTP for authenticating Set/Reset pin request",
        msgBody: "OTP to authenticate your request for set/reset pin is $otp",
      );
      String sendEmailResponse = await sendEmail(sendEmailRequest);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sendEmailResponse),
        ),
      );
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

  List<Widget> commonWidgets() {
    return [
      Container(
        margin: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                ((widget.adminProfile.firstName ?? "" ' ') + (widget.adminProfile.middleName ?? "" ' ') + (widget.adminProfile.lastName ?? "" ' '))
                    .split(" ")
                    .where((i) => i != "")
                    .join(" "),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
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
                  child: Text("Admin"),
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
              child: Text(widget.adminProfile.schoolName ?? "-"),
            ),
          ],
        ),
      ),
    ];
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
      keyboardType: TextInputType.number,
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
          } catch (e) {
            return oldValue;
          }
        }),
      ],
      onChanged: (String e) {
        setState(() {
          pin = e;
        });
        if (e == fourDigitPin) {
          setState(() {
            goToDashboardAction();
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
                      "An OTP has been sent to your registered Email Id, ${widget.adminProfile.mailId}",
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
      keyboardType: TextInputType.number,
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
          } catch (e) {
            return oldValue;
          }
        }),
      ],
      onChanged: (String e) async {
        setState(() {
          confirmNewPin = newConfirmPinController.text;
        });
        if (e == newPin && e.length == 4) {
          UpdateUserFourDigitPinResponse updateUserFourDigitPinResponse = await updateUserFourDigitPin(UpdateUserFourDigitPinRequest(
            agent: widget.adminProfile.userId,
            userId: widget.adminProfile.userId,
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
              goToDashboardAction();
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
      keyboardType: TextInputType.number,
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
          } catch (e) {
            return oldValue;
          }
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
          } catch (e) {
            return oldValue;
          }
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
