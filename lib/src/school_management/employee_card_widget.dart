import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class EmployeeCardWidget extends StatefulWidget {
  const EmployeeCardWidget({
    Key? key,
    required this.adminProfile,
    required this.employeeProfile,
    required this.isEmployeeSelected,
    required this.onEmployeeSelected,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final SchoolWiseEmployeeBean employeeProfile;

  final bool isEmployeeSelected;
  final Function onEmployeeSelected;

  @override
  State<EmployeeCardWidget> createState() => _EmployeeCardWidgetState();
}

class _EmployeeCardWidgetState extends State<EmployeeCardWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: AbsorbPointer(
        absorbing: _isLoading,
        child: ClayContainer(
          emboss: widget.isEmployeeSelected,
          depth: 15,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: widget.isEmployeeSelected ? employeeExpandedWidget() : employeeCompactWidget(),
          ),
        ),
      ),
    );
  }

  Widget employeeExpandedWidget() {
    return Column(
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
                widget.employeeProfile.employeeName ?? "-",
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                ),
              ),
            ),
            // const SizedBox(width: 10),
            // GestureDetector(
            //   onTap: () => widget.onEditSelected(widget.isEditMode ? null : widget.studentProfile.studentId),
            //   child: ClayButton(
            //     depth: 15,
            //     surfaceColor: clayContainerColor(context),
            //     parentColor: clayContainerColor(context),
            //     spread: 2,
            //     borderRadius: 100,
            //     child: SizedBox(
            //       height: 25,
            //       width: 25,
            //       child: Padding(
            //         padding: const EdgeInsets.all(4),
            //         child: FittedBox(
            //           fit: BoxFit.scaleDown,
            //           child: widget.isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => widget.onEmployeeSelected(null),
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
                  Text((widget.employeeProfile.roles ?? []).isEmpty ? "Role: -" : ((widget.employeeProfile.roles ?? []).length == 1 ? "Role: " : "Roles: ") + (widget.employeeProfile.roles ?? []).map((e) => e?.replaceAll("_", " ").toLowerCase().capitalize()).join(", ")),
                  const SizedBox(height: 10),
                  Text("Email: ${widget.employeeProfile.emailId ?? "-"}"),
                  const SizedBox(height: 10),
                  Text("Mobile: ${widget.employeeProfile.mobile ?? "-"}"),
                  const SizedBox(height: 10),
                  Text("Alternate Mobile: ${widget.employeeProfile.alternateMobile ?? "-"}"),
                  const SizedBox(height: 10),
                  Text("Login Id: ${widget.employeeProfile.loginId ?? "-"}"),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 75,
              height: 75,
              child: widget.employeeProfile.photoUrl == null
                  ? Image.asset(
                "assets/images/avatar.png",
                fit: BoxFit.contain,
              )
                  : Image.network(
                widget.employeeProfile.photoUrl!,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  Widget employeeCompactWidget() {
    return GestureDetector(
      onTap: () => widget.onEmployeeSelected(widget.employeeProfile.employeeId),
      child: Center(
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
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
                    Text(
                      widget.employeeProfile.employeeName?.capitalize() ?? "-",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text((widget.employeeProfile.roles ?? []).isEmpty ? "Role: -" : ((widget.employeeProfile.roles ?? []).length == 1 ? "Role: " : "Roles: ") + (widget.employeeProfile.roles ?? []).map((e) => e?.replaceAll("_", " ").toLowerCase().capitalize()).join(", ")),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 40,
                height: 40,
                child: widget.employeeProfile.photoUrl == null
                    ? Image.asset(
                        "assets/images/avatar.png",
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        widget.employeeProfile.photoUrl!,
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => widget.onEmployeeSelected(widget.employeeProfile.employeeId),
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
    );
  }
}
