import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_pocket_money/admin/load_or_debit_student_pocket_money_transaction_widget.dart';
import 'package:schoolsgo_web/src/student_pocket_money/modal/student_pocket_money.dart';

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
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
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

  Future<void> deletePocketMoneyTransaction(LoadOrDebitStudentPocketMoneyTransactionBean loadOrDebitStudentPocketMoneyTransactionBean) async {}
}
