import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class EmployeeCardViewWidget extends StatefulWidget {
  const EmployeeCardViewWidget({
    Key? key,
    required this.adminProfile,
    required this.employeeProfile,
    required this.isEmployeeSelected,
    required this.onEmployeeSelected,
    this.onEditSelected,
    this.isEditEnabled = false,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final SchoolWiseEmployeeBean employeeProfile;

  final bool isEmployeeSelected;
  final Function onEmployeeSelected;

  final Function? onEditSelected;
  final bool isEditEnabled;

  @override
  State<EmployeeCardViewWidget> createState() => _EmployeeCardViewWidgetState();
}

class _EmployeeCardViewWidgetState extends State<EmployeeCardViewWidget> {
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
                style: TextStyle(
                  fontSize: 24,
                  color: widget.isEditEnabled && widget.employeeProfile.hasAdminRole ? Colors.red : Colors.blue,
                ),
              ),
            ),
            if (widget.isEditEnabled) const SizedBox(width: 10),
            if (widget.isEditEnabled)
              GestureDetector(
                onTap: () => widget.onEditSelected == null ? {} : widget.onEditSelected!(widget.employeeProfile),
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
                        child: Icon(Icons.edit),
                      ),
                    ),
                  ),
                ),
              ),
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
                  Text((widget.employeeProfile.roles ?? []).isEmpty
                      ? "Role: -"
                      : ((widget.employeeProfile.roles ?? []).length == 1 ? "Role: " : "Roles: ") +
                          (widget.employeeProfile.roles ?? []).map((e) => e?.replaceAll("_", " ").toLowerCase().capitalize()).join(", ")),
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
                      style: TextStyle(
                        color: widget.isEditEnabled && widget.employeeProfile.hasAdminRole ? Colors.red : Colors.blue,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text((widget.employeeProfile.roles ?? []).isEmpty
                        ? "Role: -"
                        : ((widget.employeeProfile.roles ?? []).length == 1 ? "Role: " : "Roles: ") +
                            (widget.employeeProfile.roles ?? []).map((e) => e?.replaceAll("_", " ").toLowerCase().capitalize()).join(", ")),
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
