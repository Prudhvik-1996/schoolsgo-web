import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/ed_admin/add_new_school_page.dart';

class AddNewSchoolButton extends StatefulWidget {
  const AddNewSchoolButton({
    super.key,
    required this.userId,
    required this.reload,
  });

  final int? userId;
  final Function reload;

  @override
  State<AddNewSchoolButton> createState() => _AddNewSchoolButtonState();
}

class _AddNewSchoolButtonState extends State<AddNewSchoolButton> {
  @override
  Widget build(BuildContext context) {
    return isEdAdmin() ? addNewSchoolFab() : const SizedBox();
  }

  bool isEdAdmin() => [127, 128].contains(widget.userId);

  Widget addNewSchoolFab() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AddNewSchoolPage(
              userId: widget.userId!,
            );
          })).then((value) => widget.reload());
        },
        child: ClayButton(
          surfaceColor: Colors.blue,
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.add),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Add"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
