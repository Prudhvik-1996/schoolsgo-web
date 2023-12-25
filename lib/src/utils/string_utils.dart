import 'dart:math';

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

  String trimTrailingRegex(String reg) {
    int i = length;
    try {
      while (startsWith(reg, i - reg.length)) {
        i -= reg.length;
      }
      return substring(0, i);
    } catch (e) {
      return reg;
    }
  }

  String getShortenedMessage({int shortLength = 29, bool reduceSpaces = true}) => replaceAll("  ", " ").substring(0, min(shortLength, length)).trim();

  String lastChars({int lastLength = 10}) {
    if (length <= lastLength) return this;
    return substring(length - lastLength);
  }
}
