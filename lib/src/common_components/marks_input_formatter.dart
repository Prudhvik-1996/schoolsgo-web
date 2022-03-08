import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MarksInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // if (newValue.text == '') {
    //   return newValue;
    // } else if (newValue.text == '-') {
    //   return const TextEditingValue().copyWith(text: "-1");
    // } else if (newValue.text == 'A' || newValue.text == 'a') {
    //   return const TextEditingValue().copyWith(text: "-2");
    // } else if (int.tryParse(newValue.text) != null) {
    //   return const TextEditingValue().copyWith(text: newValue.text);
    // } else {
    //   return const TextEditingValue().copyWith(text: oldValue.text);
    // }
    return newValue;
  }
}
