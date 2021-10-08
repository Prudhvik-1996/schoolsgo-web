extension StringExtension on String {
  String capitalize() {
    if (this == null || this.trim() == '') return '-';
    return "${this[0].toUpperCase()}${this.substring(1)}".trim();
  }

  bool isNumeric() {
    if (this == null) {
      return false;
    }
    return double.tryParse(this) != null;
  }
}
