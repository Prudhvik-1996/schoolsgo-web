enum StudentStatus {
  active, transferred, suspended, tc_issued, discontinued, long_absent, new_admission;

  String get description {
    switch (this) {
      case StudentStatus.active:
        return "Active";
      case StudentStatus.transferred:
        return "Transferred";
      case StudentStatus.suspended:
        return "Suspended";
      case StudentStatus.tc_issued:
        return "TC Issued";
      case StudentStatus.discontinued:
        return "Discontinued";
      case StudentStatus.long_absent:
        return "Long Absent";
      case StudentStatus.new_admission:
        return "New Admission";
      default:
        return "New Admission";
    }
  }
}
