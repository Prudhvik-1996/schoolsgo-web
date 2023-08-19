import 'package:flutter/material.dart';

class UpdatePhoneNumberAndPasswordWidget extends StatefulWidget {
  const UpdatePhoneNumberAndPasswordWidget({
    super.key,
    required this.userId,
    required this.mobileNumber,
    required this.password,
  });

  final int? userId;
  final String? mobileNumber;
  final String? password;

  @override
  State<UpdatePhoneNumberAndPasswordWidget> createState() => _UpdatePhoneNumberAndPasswordWidgetState();
}

class _UpdatePhoneNumberAndPasswordWidgetState extends State<UpdatePhoneNumberAndPasswordWidget> {
  bool showPassword = false;

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text("Password: ${showPassword ? widget.password : List.generate(widget.password?.length ?? 0, (index) => "*").join("")}"),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () => setState(() => showPassword = !showPassword),
          icon: const Icon(Icons.remove_red_eye_outlined),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () {
            //  TODO
          },
          icon: const Icon(Icons.edit),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
