import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentCardWidget extends StatefulWidget {
  const StudentCardWidget({
    Key? key,
    required this.studentProfile,
    required this.adminProfile,
    required this.isStudentSelected,
    required this.onStudentSelected,
    required this.isEditMode,
    required this.onEditSelected,
  }) : super(key: key);

  final StudentProfile studentProfile;
  final AdminProfile adminProfile;

  final bool isStudentSelected;
  final Function onStudentSelected;

  final bool isEditMode;
  final Function onEditSelected;

  @override
  State<StudentCardWidget> createState() => _StudentCardWidgetState();
}

class _StudentCardWidgetState extends State<StudentCardWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return widget.isEditMode
        ? buildEditableExpandedCard()
        : widget.isStudentSelected
            ? buildExpandedCard()
            : buildCompactCard();
  }

  Widget buildExpandedCard() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: ClayContainer(
        emboss: true,
        depth: 15,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ((widget.studentProfile.studentFirstName == null ? "" : (widget.studentProfile.studentFirstName ?? "").capitalize() + " ") +
                          (widget.studentProfile.studentMiddleName == null
                              ? ""
                              : (widget.studentProfile.studentMiddleName ?? "").capitalize() + " ") +
                          (widget.studentProfile.studentLastName == null ? "" : (widget.studentProfile.studentLastName ?? "").capitalize() + " ")),
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => widget.onEditSelected(widget.isEditMode ? null : widget.studentProfile.studentId),
                    child: ClayButton(
                      depth: 15,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 2,
                      borderRadius: 100,
                      child: SizedBox(
                        height: 25,
                        width: 25,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: widget.isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => widget.onStudentSelected(null),
                    child: ClayButton(
                      depth: 15,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 2,
                      borderRadius: 100,
                      child: const SizedBox(
                        height: 25,
                        width: 25,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Icon(Icons.keyboard_arrow_up),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text("Roll No.: ${widget.studentProfile.rollNumber ?? "-"}"),
                        const SizedBox(height: 10),
                        Text(
                          "Section Name: ${widget.studentProfile.sectionName ?? "-"}",
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Parent Name: ${((widget.studentProfile.gaurdianFirstName == null ? "" : (widget.studentProfile.gaurdianFirstName ?? "").capitalize() + " ") + (widget.studentProfile.gaurdianMiddleName == null ? "" : (widget.studentProfile.gaurdianMiddleName ?? "").capitalize() + " ") + (widget.studentProfile.gaurdianLastName == null ? "" : (widget.studentProfile.gaurdianLastName ?? "").capitalize() + " "))}",
                        ),
                        const SizedBox(height: 10),
                        Text("Email: ${widget.studentProfile.gaurdianMailId ?? "-"}"),
                        const SizedBox(height: 10),
                        Text("Mobile: ${widget.studentProfile.gaurdianMobile ?? widget.studentProfile.studentMobile ?? "-"}"),
                        const SizedBox(height: 10),
                        Text("Alternate Mobile: ${widget.studentProfile.gaurdianMobile ?? widget.studentProfile.studentMobile ?? "-"}"),
                        const SizedBox(height: 10),
                        Text("Login Id: ${widget.studentProfile.loginId ?? "-"}"),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 75,
                    height: 75,
                    child: widget.studentProfile.studentPhotoUrl == null
                        ? Image.asset(
                            "assets/images/avatar.png",
                            fit: BoxFit.contain,
                          )
                        : Image.network(
                            widget.studentProfile.studentPhotoUrl!,
                            fit: BoxFit.contain,
                          ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditableExpandedCard() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: ClayContainer(
        emboss: true,
        depth: 15,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: InputDecorator(
                      isFocused: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        label: Text(
                          "Student Name",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      child: TextField(
                        controller: widget.studentProfile.studentNameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Student Name",
                        ),
                        keyboardType: TextInputType.text,
                        autofocus: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => widget.onEditSelected(widget.isEditMode ? null : widget.studentProfile.studentId),
                    child: ClayButton(
                      depth: 15,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 2,
                      borderRadius: 100,
                      child: SizedBox(
                        height: 25,
                        width: 25,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: widget.isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: InputDecorator(
                                isFocused: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  label: Text(
                                    "Roll No.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                child: TextField(
                                  controller: widget.studentProfile.rollNumberController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Roll No.",
                                  ),
                                  keyboardType: TextInputType.text,
                                  autofocus: true,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                            MediaQuery.of(context).orientation == Orientation.landscape ? const SizedBox(width: 100) :  const SizedBox(width: 10),
                            Text(
                              "Section Name: ${widget.studentProfile.sectionName ?? "-"}",
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 20),
                        InputDecorator(
                          isFocused: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            label: Text(
                              "Parent Name",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          child: TextField(
                            controller: widget.studentProfile.gaurdianNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Parent Name",
                            ),
                            keyboardType: TextInputType.text,
                            autofocus: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        InputDecorator(
                          isFocused: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            label: Text(
                              "Email Id",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          child: TextField(
                            controller: widget.studentProfile.emailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email Id",
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autofocus: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        InputDecorator(
                          isFocused: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            label: Text(
                              "Mobile",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          child: TextField(
                            controller: widget.studentProfile.phoneController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Mobile",
                            ),
                            keyboardType: TextInputType.text,
                            autofocus: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        InputDecorator(
                          isFocused: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            label: Text(
                              "Alternate Mobile",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          child: TextField(
                            controller: widget.studentProfile.alternatePhoneController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Alternate Mobile",
                            ),
                            keyboardType: TextInputType.text,
                            autofocus: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("Login Id: ${widget.studentProfile.loginId ?? "-"}"),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 75,
                    height: 75,
                    child: widget.studentProfile.studentPhotoUrl == null
                        ? Image.asset(
                            "assets/images/avatar.png",
                            fit: BoxFit.contain,
                          )
                        : Image.network(
                            widget.studentProfile.studentPhotoUrl!,
                            fit: BoxFit.contain,
                          ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCompactCard() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: GestureDetector(
        onTap: () => widget.onStudentSelected(widget.studentProfile.studentId),
        child: ClayButton(
          depth: 15,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                Text("${widget.studentProfile.rollNumber ?? " - "}."),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ((widget.studentProfile.studentFirstName == null ? "" : (widget.studentProfile.studentFirstName ?? "").capitalize() + " ") +
                        (widget.studentProfile.studentMiddleName == null ? "" : (widget.studentProfile.studentMiddleName ?? "").capitalize() + " ") +
                        (widget.studentProfile.studentLastName == null ? "" : (widget.studentProfile.studentLastName ?? "").capitalize() + " ")),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: widget.studentProfile.studentPhotoUrl == null
                          ? Image.asset(
                              "assets/images/avatar.png",
                              fit: BoxFit.contain,
                            )
                          : Image.network(
                              widget.studentProfile.studentPhotoUrl!,
                              fit: BoxFit.contain,
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.studentProfile.sectionName ?? "-"),
                  ],
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => widget.onStudentSelected(widget.studentProfile.studentId),
                  child: ClayButton(
                    depth: 15,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 2,
                    borderRadius: 100,
                    child: const SizedBox(
                      height: 25,
                      width: 25,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
