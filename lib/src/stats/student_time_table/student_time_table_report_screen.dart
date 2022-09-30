import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show AnchorElement;

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/section_wise_time_slots.dart';

class StudentTimeTableReportScreen extends StatefulWidget {
  const StudentTimeTableReportScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<StudentTimeTableReportScreen> createState() => _StudentTimeTableReportScreenState();
}

class _StudentTimeTableReportScreenState extends State<StudentTimeTableReportScreen> {
  bool _isLoading = true;
  bool _isFileDownloading = false;
  late String reportName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    reportName = "StudentTimeTableReport${DateTime.now().millisecondsSinceEpoch}.xlsx";
    setState(() => _isLoading = false);
  }

  Widget _proceedToGenerateSheetButton() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            _isFileDownloading = true;
          });

          List<int> bytes = await getSectionWiseTimeSlotsReport(GetSectionWiseTimeSlotsRequest(
            schoolId: widget.adminProfile.schoolId,
          ));
          AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
            ..setAttribute("download", reportName)
            ..click();
          setState(() {
            reportName = "StudentTimeTableReport${DateTime.now().millisecondsSinceEpoch}.xlsx";
            _isFileDownloading = false;
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Download",
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Time Table"),
        actions: [
          buildRoleButtonForAppBar(context, widget.adminProfile),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : _isFileDownloading
              ? Column(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Center(
                        child: Text("Report download in progress"),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Image.asset(
                        'assets/images/eis_loader.gif',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(reportName),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: _proceedToGenerateSheetButton(),
                ),
    );
  }
}
