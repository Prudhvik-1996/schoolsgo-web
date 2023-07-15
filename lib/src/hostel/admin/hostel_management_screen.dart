import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/hostel/admin/views/hostel_compact_widget.dart';
import 'package:schoolsgo_web/src/hostel/model/hostels.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminHostelManagementScreen extends StatefulWidget {
  const AdminHostelManagementScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<AdminHostelManagementScreen> createState() => _AdminHostelManagementScreenState();
}

class _AdminHostelManagementScreenState extends State<AdminHostelManagementScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Hostel> hostels = [];
  List<SchoolWiseEmployeeBean> employees = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetHostelsResponse getHostelsResponse = await getHostels(GetHostelsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getHostelsResponse.httpStatus == "OK" && getHostelsResponse.responseStatus == "success") {
      setState(() {
        hostels = getHostelsResponse.hostelsList!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }
    GetSchoolWiseEmployeesResponse getSchoolWiseEmployeesResponse = await getSchoolWiseEmployees(GetSchoolWiseEmployeesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSchoolWiseEmployeesResponse.httpStatus != "OK" || getSchoolWiseEmployeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        employees = (getSchoolWiseEmployeesResponse.employees ?? []).map((e) => e!).toList();
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Hostel Management"),
        actions: [
          buildRoleButtonForAppBar(context, widget.adminProfile),
        ],
      ),
      drawer: AdminAppDrawer(adminProfile: widget.adminProfile),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : hostels.isEmpty
              ? const Center(child: Text("No hostels registered.."))
              : ListView(
                  children: [...hostels.map((e) => hostelCompactWidget(e))],
                ),
    );
  }

  Widget hostelCompactWidget(Hostel e) {
    return HostelCompactWidget(
      adminProfile: widget.adminProfile,
      hostel: e,
      employees: employees,
    );
  }
}
