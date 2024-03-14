import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_pocket_money/admin/load_or_debit_student_pocket_money_transaction_widget.dart';
import 'package:schoolsgo_web/src/student_pocket_money/modal/student_pocket_money.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class AdminStudentPocketMoneyReceiptsScreen extends StatefulWidget {
  const AdminStudentPocketMoneyReceiptsScreen({
    Key? key,
    required this.adminProfile,
    required this.studentProfiles,
    required this.pocketMoneyTransactions,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<StudentProfile> studentProfiles;
  final List<LoadOrDebitStudentPocketMoneyTransactionBean> pocketMoneyTransactions;

  @override
  State<AdminStudentPocketMoneyReceiptsScreen> createState() => _AdminStudentPocketMoneyReceiptsScreenState();
}

class _AdminStudentPocketMoneyReceiptsScreenState extends State<AdminStudentPocketMoneyReceiptsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool _isEditMode = true;

  List<LoadOrDebitStudentPocketMoneyTransactionBean> pocketMoneyTransactions = [];

  @override
  void initState() {
    super.initState();
    pocketMoneyTransactions = widget.pocketMoneyTransactions;
    populateStudentDetailsInPocketMoneyTransactions();
    _isLoading = false;
  }

  void populateStudentDetailsInPocketMoneyTransactions() {
    for (var eachPocketMoneyTransaction in pocketMoneyTransactions) {
      StudentProfile? studentProfile = widget.studentProfiles.firstWhereOrNull((e) => e.studentId == eachPocketMoneyTransaction.studentId);
      eachPocketMoneyTransaction.gaurdianName = studentProfile?.gaurdianFirstName;
      eachPocketMoneyTransaction.sectionName = studentProfile?.sectionName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Pocket Money"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                ...pocketMoneyTransactions.map(
                  (e) => LoadOrDebitStudentPocketMoneyTransactionWidget(
                    context: context,
                    adminProfile: widget.adminProfile,
                    pocketMoneyTransactionBean: e,
                    deleteAction: _isEditMode ? deletePocketMoneyTransaction : null,
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> deletePocketMoneyTransaction(LoadOrDebitStudentPocketMoneyTransactionBean loadOrDebitStudentPocketMoneyTransactionBean) async {
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text('Are you sure you want to delete the receipt?'),
          content: TextField(
            onChanged: (value) {},
            controller: loadOrDebitStudentPocketMoneyTransactionBean.reasonToDeleteController,
            decoration: InputDecoration(
              hintText: "Reason to delete",
              errorText: loadOrDebitStudentPocketMoneyTransactionBean.reasonToDeleteController.text.trim() == "" ? "Reason cannot be empty!" : "",
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                if (_isLoading) return;
                if (loadOrDebitStudentPocketMoneyTransactionBean.reasonToDeleteController.text.trim() == "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Reason to delete cannot be empty.."),
                    ),
                  );
                  Navigator.pop(context);
                  return;
                }
                Navigator.pop(context);
                setState(() => _isLoading = true);
                DeleteReceiptRequest deleteReceiptRequest = DeleteReceiptRequest(
                  schoolId: widget.adminProfile.schoolId,
                  agentId: widget.adminProfile.userId,
                  masterTransactionId: loadOrDebitStudentPocketMoneyTransactionBean.transactionId,
                  comments: loadOrDebitStudentPocketMoneyTransactionBean.reasonToDeleteController.text.trim(),
                );
                DeleteReceiptResponse deleteReceiptResponse = await deleteReceipt(deleteReceiptRequest);
                if (deleteReceiptResponse.httpStatus != "OK" || deleteReceiptResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Delete Successful.."),
                    ),
                  );
                  Navigator.pop(context);
                }
                setState(() => _isLoading = false);
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                setState(() {
                  loadOrDebitStudentPocketMoneyTransactionBean.reasonToDeleteController.text = "";
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
