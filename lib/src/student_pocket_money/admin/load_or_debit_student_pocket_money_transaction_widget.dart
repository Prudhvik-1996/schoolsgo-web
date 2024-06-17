import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_pocket_money/modal/student_pocket_money.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/print_utils.dart';

class LoadOrDebitStudentPocketMoneyTransactionWidget extends StatelessWidget {
  const LoadOrDebitStudentPocketMoneyTransactionWidget({
    super.key,
    required this.context,
    required this.adminProfile,
    required this.pocketMoneyTransactionBean,
    required this.changeLoadingAction,
    required this.deleteAction,
    required this.schoolInfo,
  });

  final BuildContext context;
  final AdminProfile adminProfile;
  final LoadOrDebitStudentPocketMoneyTransactionBean pocketMoneyTransactionBean;
  final Function() changeLoadingAction;
  final Future<void> Function(LoadOrDebitStudentPocketMoneyTransactionBean pocketMoneyTransactionBean)? deleteAction;
  final SchoolInfoBean schoolInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
          : const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        color: pocketMoneyTransactionBean.status == 'active' ? clayContainerColor(context) : Colors.redAccent[100],
        spread: 2,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              dateAndActionsWidget(),
              const SizedBox(height: 20),
              studentDetailsWidget(),
              if (pocketMoneyTransactionBean.gaurdianName != null) const SizedBox(height: 20),
              if (pocketMoneyTransactionBean.gaurdianName != null) parentDetailsWidget(),
              const SizedBox(height: 20),
              amountRowWidget(),
              const SizedBox(height: 20),
              modeOfPaymentWidget(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Row parentDetailsWidget() {
    return Row(
      children: [
        const SizedBox(width: 10),
        const Text("Parent Name: "),
        Expanded(child: Text(pocketMoneyTransactionBean.gaurdianName ?? "-")),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget modeOfPaymentWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 10),
        Expanded(child: Text("Comments: ${pocketMoneyTransactionBean.comment ?? "-"}")),
        const SizedBox(width: 10),
        Text(
          pocketMoneyTransactionBean.modeOfPayment ?? "-",
          style: const TextStyle(
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget amountRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        const Expanded(child: Text("Amount")),
        Text(
          "$INR_SYMBOL ${doubleToStringAsFixedForINR((pocketMoneyTransactionBean.amount ?? 0) / 100.0)} /-",
          style: const TextStyle(
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget studentDetailsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: InputDecorator(
            isFocused: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              label: Text(
                "Student Name",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            child: Center(
              child: Text(
                pocketMoneyTransactionBean.studentName ?? "-",
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: InputDecorator(
            isFocused: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              label: Text(
                "Section",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            child: Center(
              child: Text(
                pocketMoneyTransactionBean.sectionName ?? "-",
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget dateAndActionsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          (MediaQuery.of(context).orientation == Orientation.landscape ? "Date: " : "") +
              convertDateToDDMMMYYY(pocketMoneyTransactionBean.transactionDate),
          style: const TextStyle(color: Colors.blue),
        ),
        const SizedBox(
          width: 10,
        ),
        if (pocketMoneyTransactionBean.status == 'active') printButton(),
        if (pocketMoneyTransactionBean.status == 'active') const SizedBox(width: 10),
        if (deleteAction != null && pocketMoneyTransactionBean.status == 'active') deleteButton(),
        if (deleteAction != null && pocketMoneyTransactionBean.status == 'active') const SizedBox(width: 10),
      ],
    );
  }

  GestureDetector printButton() {
    return GestureDetector(
      onTap: () async {
        makePdf();
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 20,
        width: 20,
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: const Padding(
          padding: EdgeInsets.all(3.0),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                Icons.print,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector deleteButton() {
    return GestureDetector(
      onTap: () async {
        await deleteAction!(pocketMoneyTransactionBean);
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 20,
        width: 20,
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: const Padding(
          padding: EdgeInsets.all(3.0),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> makePdf() async {
    bool isAdminCopySelected = true;
    bool isStudentCopySelected = true;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text('Download receipt'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text("Admin Copy"),
                    selected: isAdminCopySelected,
                    value: isAdminCopySelected,
                    onChanged: (bool value) {
                      setState(() => isAdminCopySelected = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Student Copy"),
                    selected: isStudentCopySelected,
                    value: isStudentCopySelected,
                    onChanged: (bool value) {
                      setState(() => isStudentCopySelected = value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Proceed to print"),
              onPressed: () async {
                if (!isAdminCopySelected && !isStudentCopySelected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("At least one in Admin Copy or Student Copy must be selected"),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 400));
                changeLoadingAction();
                await printReceipts(
                  context,
                  schoolInfo,
                  [
                    StudentFeeReceipt(
                      studentId: pocketMoneyTransactionBean.studentId,
                      studentName: pocketMoneyTransactionBean.studentName,
                      sectionName: pocketMoneyTransactionBean.sectionName,
                      transactionId: pocketMoneyTransactionBean.transactionId,
                      transactionDate: pocketMoneyTransactionBean.transactionDate,
                      feeTypes: [
                        FeeTypeOfReceipt(
                          amountPaidForTheReceipt: pocketMoneyTransactionBean.amount,
                          feeType: "Pocket Money",
                        ),
                      ],
                    ),
                  ],
                  [
                    StudentProfile(
                      studentId: pocketMoneyTransactionBean.studentId,
                      studentFirstName: pocketMoneyTransactionBean.studentName,
                      gaurdianFirstName: pocketMoneyTransactionBean.gaurdianName,
                      rollNumber: pocketMoneyTransactionBean.rollNumber,
                      sectionName: pocketMoneyTransactionBean.sectionName,
                    ),
                  ],
                  false,
                  isAdminCopySelected: true,
                  isStudentCopySelected: true,
                );
                changeLoadingAction();
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
