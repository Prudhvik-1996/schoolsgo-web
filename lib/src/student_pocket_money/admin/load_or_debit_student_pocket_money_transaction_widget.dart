import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_pocket_money/modal/student_pocket_money.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class LoadOrDebitStudentPocketMoneyTransactionWidget extends StatelessWidget {
  const LoadOrDebitStudentPocketMoneyTransactionWidget({
    super.key,
    required this.context,
    required this.adminProfile,
    required this.pocketMoneyTransactionBean,
    required this.deleteAction,
  });

  final BuildContext context;
  final AdminProfile adminProfile;
  final LoadOrDebitStudentPocketMoneyTransactionBean pocketMoneyTransactionBean;
  final Future<void> Function(LoadOrDebitStudentPocketMoneyTransactionBean pocketMoneyTransactionBean)? deleteAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
          : const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
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
        const Text("Parent Name:"),
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
          "Date: ${convertDateToDDMMMYYY(pocketMoneyTransactionBean.transactionDate)}",
          style: const TextStyle(color: Colors.blue),
        ),
        const SizedBox(
          width: 10,
        ),
        if (deleteAction != null)
          GestureDetector(
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
          ),
        const SizedBox(width: 10),
      ],
    );
  }
}
