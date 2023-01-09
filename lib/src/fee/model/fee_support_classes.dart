import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class FeeTypeTxn {
  int? feeTypeId;
  String? feeType;
  int? feePaidAmount;
  int? transactionId;
  List<CustomFeeTypeTxn>? customFeeTypeTxns;

  List<TermComponent> termComponents;

  FeeTypeTxn(this.feeTypeId, this.feeType, this.feePaidAmount, this.transactionId, this.customFeeTypeTxns, this.termComponents);

  @override
  String toString() {
    return 'FeeTypeTxn{feeTypeId: $feeTypeId, feeType: $feeType, feePaidAmount: $feePaidAmount, transactionId: $transactionId, customFeeTypeTxns: $customFeeTypeTxns, termComponents: $termComponents}';
  }
}

class CustomFeeTypeTxn {
  int? customFeeTypeId;
  String? customFeeType;
  int? feePaidAmount;
  int? transactionId;

  List<TermComponent> termComponents;

  CustomFeeTypeTxn(this.customFeeTypeId, this.customFeeType, this.feePaidAmount, this.transactionId, this.termComponents);
}

enum StatFilterType { daily, monthly, lastNDays }

class DateWiseTxnAmount {
  DateTime dateTime;
  int amount;
  BuildContext context;

  DateWiseTxnAmount(this.dateTime, this.amount, this.context);

  @override
  String toString() {
    return """_DateWiseTxnAmount {"dateTime": "${convertDateTimeToYYYYMMDDFormat(dateTime)}", "amount": ${doubleToStringAsFixedForINR(amount / 100.0)}}""";
  }

  Widget widget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ClayContainer(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          emboss: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "${convertDateTimeToDDMMYYYYFormat(dateTime)}\n",
                  children: [
                    TextSpan(
                      text: "$INR_SYMBOL ${doubleToStringAsFixedForINR(amount / 100.0)} /-",
                      style: const TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                  style: TextStyle(
                    color: clayContainerTextColor(context),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MonthWiseTxnAmount {
  int month;
  int year;
  int amount;
  BuildContext context;

  MonthWiseTxnAmount(this.month, this.year, this.amount, this.context);

  @override
  String toString() {
    return '_MonthWiseTxnAmount{month: $month, year: $year, amount: $amount, context: $context}';
  }

  Widget widget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ClayContainer(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          emboss: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "${MONTHS[month - 1].toLowerCase().capitalize()} - $year\n",
                  children: [
                    TextSpan(
                      text: "$INR_SYMBOL ${doubleToStringAsFixedForINR(amount / 100.0)} /-",
                      style: const TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                  style: TextStyle(
                    color: clayContainerTextColor(context),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
