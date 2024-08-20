import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

enum ModeOfPayment { CASH, PHONEPE, GPAY, PAYTM, NETBANKING, CHEQUE, CARD, OTHER, ACCOUNTTRANSFER }

extension ModeOfPaymentExt on ModeOfPayment {
  String toShortString() {
    return toString().split('.').last;
  }

  String get description {
    switch (this) {
      case ModeOfPayment.CASH:
        return "Cash";
      case ModeOfPayment.PHONEPE:
        return "PhonePe";
      case ModeOfPayment.GPAY:
        return "Google Pay";
      case ModeOfPayment.PAYTM:
        return "PayTM";
      case ModeOfPayment.NETBANKING:
        return "Net Banking";
      case ModeOfPayment.CHEQUE:
        return "Cheque";
      case ModeOfPayment.CARD:
        return "Card";
      case ModeOfPayment.ACCOUNTTRANSFER:
        return "Account Transfer";
      default:
        return "Other";
    }
  }

  static ModeOfPayment fromString(String? val) {
    switch (val) {
      case "CASH":
        return ModeOfPayment.CASH;
      case "PHONEPE":
        return ModeOfPayment.PHONEPE;
      case "GPAY":
        return ModeOfPayment.GPAY;
      case "PAYTM":
        return ModeOfPayment.PAYTM;
      case "NETBANKING":
        return ModeOfPayment.NETBANKING;
      case "CHEQUE":
        return ModeOfPayment.CHEQUE;
      case "CARD":
        return ModeOfPayment.CARD;
      case "ACCOUNTTRANSFER":
        return ModeOfPayment.ACCOUNTTRANSFER;
      default:
        return ModeOfPayment.OTHER;
    }
  }

  static charts.Color getChartColorForModeOfPayment(ModeOfPayment modeOfPayment) {
    switch (modeOfPayment) {
      case ModeOfPayment.CASH:
        return charts.MaterialPalette.blue.shadeDefault;
      case ModeOfPayment.PHONEPE:
        return charts.MaterialPalette.green.shadeDefault;
      case ModeOfPayment.GPAY:
        return charts.MaterialPalette.red.shadeDefault;
      case ModeOfPayment.PAYTM:
        return charts.MaterialPalette.purple.shadeDefault;
      case ModeOfPayment.NETBANKING:
        return charts.MaterialPalette.yellow.shadeDefault;
      case ModeOfPayment.CHEQUE:
        return charts.MaterialPalette.teal.shadeDefault;
      case ModeOfPayment.CARD:
        return charts.MaterialPalette.deepOrange.shadeDefault;
      case ModeOfPayment.ACCOUNTTRANSFER:
        return charts.MaterialPalette.lime.shadeDefault;
      default:
        return charts.MaterialPalette.gray.shadeDefault;
    }
  }

  static Color getColorForModeOfPayment(ModeOfPayment modeOfPayment) {
    switch (modeOfPayment) {
      case ModeOfPayment.CASH:
        return Colors.blue;
      case ModeOfPayment.PHONEPE:
        return Colors.green;
      case ModeOfPayment.GPAY:
        return Colors.red;
      case ModeOfPayment.PAYTM:
        return Colors.purple;
      case ModeOfPayment.NETBANKING:
        return Colors.yellow;
      case ModeOfPayment.CHEQUE:
        return Colors.teal;
      case ModeOfPayment.CARD:
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  static Widget getChartLedgerRow(ModeOfPayment modeOfPayment) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4,2,4,2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            color: getColorForModeOfPayment(modeOfPayment),
            height: 10,
            width: 10,
          ),
          const SizedBox(width: 5),
          Expanded(child: Text(modeOfPayment.description, style: const TextStyle(fontSize: 10),)),
        ],
      ),
    );
  }
}
