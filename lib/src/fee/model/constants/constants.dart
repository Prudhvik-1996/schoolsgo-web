enum ModeOfPayment { CASH, PHONEPE, GPAY, PAYTM, NETBANKING, CHEQUE }

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
      default:
        return "Invalid Mode Of Payment";
    }
  }
}