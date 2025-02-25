import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as user_details;
import 'package:schoolsgo_web/src/model/user_details.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/splash_screen/splash_screen.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerateNewFourDigitPinScreen extends StatefulWidget {
  const GenerateNewFourDigitPinScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<GenerateNewFourDigitPinScreen> createState() => _GenerateNewFourDigitPinScreenState();
}

class _GenerateNewFourDigitPinScreenState extends State<GenerateNewFourDigitPinScreen> {
  bool _isLoading = false;
  String newPin = "";
  String confirmNewPin = "";
  bool showNewPin = false;
  TextEditingController newPinController = TextEditingController();
  bool showConfirmPin = false;
  TextEditingController newConfirmPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Update Four Digit Pin"),
      ),
      body: _isLoading ? const EpsilonDiaryLoadingWidget() : signUpPin(),
    );
  }

  Widget signUpPin() {
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
          setState(() {
            _isLoading = true;
          });
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("PIN reset successful.."),
              ),
            );
          }
        }
        setState(() {
          _isLoading = false;
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
}
