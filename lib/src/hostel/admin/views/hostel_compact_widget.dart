import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/hostel/admin/hostel_rooms_screen.dart';
import 'package:schoolsgo_web/src/hostel/model/hostels.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';

class HostelCompactWidget extends StatefulWidget {
  const HostelCompactWidget({
    Key? key,
    required this.adminProfile,
    required this.hostel,
    required this.employees,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final Hostel hostel;
  final List<SchoolWiseEmployeeBean> employees;

  @override
  State<HostelCompactWidget> createState() => _HostelCompactWidgetState();
}

class _HostelCompactWidgetState extends State<HostelCompactWidget> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    setState(() => _isLoading = false);
  }

  SchoolWiseEmployeeBean? get hostelIncharge => widget.employees.where((e) => e.employeeId == widget.hostel.hostelInchargeId).toList().firstOrNull();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return HostelRoomsScreen(
              adminProfile: widget.adminProfile,
              hostel: widget.hostel,
              employees: widget.employees,
            );
          }));
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.hostel.hostelName ?? "-",
                  style: GoogleFonts.archivoBlack(
                    textStyle: TextStyle(
                      fontSize: 36,
                      color: clayContainerTextColor(context),
                    ),
                  ),
                ),
                if (widget.hostel.comment != null) const SizedBox(height: 10),
                if (widget.hostel.comment != null) Text(widget.hostel.comment ?? "-"),
                if (hostelIncharge != null) const SizedBox(height: 10),
                if (hostelIncharge != null) Text(hostelIncharge?.employeeName ?? "-"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Expanded(child: Text("No. of rooms:")),
                    Text("${(widget.hostel.rooms ?? []).length}"),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Expanded(child: Text("No. of beds:")),
                    Text("${(widget.hostel.rooms ?? []).map((e) => (e?.studentBedInfoList ?? []).length).fold(0, (int? a, b) => (a ?? 0) + b)}"),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Expanded(child: Text("No. of students:")),
                    Text(
                        "${(widget.hostel.rooms ?? []).map((e) => (e?.studentBedInfoList ?? []).where((e) => e?.studentId != null).length).fold(0, (int? a, b) => (a ?? 0) + b)}"),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
