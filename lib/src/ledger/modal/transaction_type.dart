import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

enum TransactionType {
  FEE,
  ADMIN_EXPENSE,
  SALARIES,
  INVENTORY,
  HOSTEL_INVENTORY,
  STUDENT_POCKET_MONEY,
  LOAD_EXPENSE_POCKET,
  DEBIT_EXPENSE_POCKET
}

extension TransactionTypeExt on TransactionType {
  String toShortString() {
    return toString().split('.').last;
  }

  String get description {
    switch (this) {
      case TransactionType.FEE:
        return "Fee";
      case TransactionType.ADMIN_EXPENSE:
        return "Admin Expense";
      case TransactionType.SALARIES:
        return "Salaries";
      case TransactionType.INVENTORY:
        return "Inventory";
      case TransactionType.HOSTEL_INVENTORY:
        return "Hostel Inventory";
      case TransactionType.STUDENT_POCKET_MONEY:
        return "Student Pocket Money";
      case TransactionType.LOAD_EXPENSE_POCKET:
        return "Load Employee Wallet";
      case TransactionType.DEBIT_EXPENSE_POCKET:
        return "Debit Employee Wallet";
      default:
        return "Other";
    }
  }

  static TransactionType fromString(String? val) {
    switch (val) {
      case "FEE":
        return TransactionType.FEE;
      case "ADMIN_EXPENSE":
        return TransactionType.ADMIN_EXPENSE;
      case "SALARIES":
        return TransactionType.SALARIES;
      case "INVENTORY":
        return TransactionType.INVENTORY;
      case "HOSTEL_INVENTORY":
        return TransactionType.HOSTEL_INVENTORY;
      case "STUDENT_POCKET_MONEY":
        return TransactionType.STUDENT_POCKET_MONEY;
      case "LOAD_EXPENSE_POCKET":
        return TransactionType.LOAD_EXPENSE_POCKET;
      case "DEBIT_EXPENSE_POCKET":
        return TransactionType.DEBIT_EXPENSE_POCKET;
      default:
        return TransactionType.FEE; // Defaulting to "FEE"
    }
  }

  static charts.Color getChartColorForTransactionType(TransactionType transactionType) {
    switch (transactionType) {
      case TransactionType.FEE:
        return charts.MaterialPalette.blue.shadeDefault;
      case TransactionType.ADMIN_EXPENSE:
        return charts.MaterialPalette.green.shadeDefault;
      case TransactionType.SALARIES:
        return charts.MaterialPalette.red.shadeDefault;
      case TransactionType.INVENTORY:
        return charts.MaterialPalette.purple.shadeDefault;
      case TransactionType.HOSTEL_INVENTORY:
        return charts.MaterialPalette.yellow.shadeDefault;
      case TransactionType.STUDENT_POCKET_MONEY:
        return charts.MaterialPalette.teal.shadeDefault;
      case TransactionType.LOAD_EXPENSE_POCKET:
        return charts.MaterialPalette.deepOrange.shadeDefault;
      case TransactionType.DEBIT_EXPENSE_POCKET:
        return charts.MaterialPalette.lime.shadeDefault;
      default:
        return charts.MaterialPalette.gray.shadeDefault;
    }
  }

  static Color getColorForTransactionType(TransactionType transactionType) {
    switch (transactionType) {
      case TransactionType.FEE:
        return Colors.blue;
      case TransactionType.ADMIN_EXPENSE:
        return Colors.green;
      case TransactionType.SALARIES:
        return Colors.red;
      case TransactionType.INVENTORY:
        return Colors.purple;
      case TransactionType.HOSTEL_INVENTORY:
        return Colors.yellow;
      case TransactionType.STUDENT_POCKET_MONEY:
        return Colors.teal;
      case TransactionType.LOAD_EXPENSE_POCKET:
        return Colors.deepOrange;
      case TransactionType.DEBIT_EXPENSE_POCKET:
        return Colors.lime;
      default:
        return Colors.grey;
    }
  }

  static Widget getChartLedgerRow(TransactionType transactionType) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            color: getColorForTransactionType(transactionType),
            height: 10,
            width: 10,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              transactionType.description,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
