import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/print_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class ReceiptCopyScreen extends StatefulWidget {
  const ReceiptCopyScreen({
    super.key,
    required this.transactionId,
  });

  final int transactionId;

  @override
  State<ReceiptCopyScreen> createState() => _ReceiptCopyScreenState();
}

class _ReceiptCopyScreenState extends State<ReceiptCopyScreen> {
  bool _isLoading = true;

  late SchoolInfoBean schoolInfoBean;
  StudentFeeReceipt? receiptToPrint;
  late List<StudentProfile> studentProfiles;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetStudentFeeReceiptsResponse studentFeeReceiptsResponse = await getStudentFeeReceipts(GetStudentFeeReceiptsRequest(
      transactionIds: [widget.transactionId],
    ));
    if (studentFeeReceiptsResponse.httpStatus != "OK" || studentFeeReceiptsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        receiptToPrint = studentFeeReceiptsResponse.studentFeeReceipts!.map((e) => e!).toList().firstOrNull;
      });
    }
    if (receiptToPrint == null) {
      setState(() => _isLoading = false);
      return;
    }
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: receiptToPrint?.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      schoolInfoBean = getSchoolsResponse.schoolInfo!;
    }

    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: receiptToPrint?.schoolId,
      studentId: receiptToPrint?.studentId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
    }
    setState(() => _isLoading = false);
    printReceipts(
      context,
      schoolInfoBean,
      [receiptToPrint!],
      studentProfiles,
      false,
      isNewTab: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : receiptToPrint == null
              ? const Center(
                  child: Text(
                    "Inactive receipt, kindly contact admin for more details",
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
    );
  }
}
