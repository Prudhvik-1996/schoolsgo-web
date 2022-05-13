import 'package:flutter/material.dart';

class PieData {
  static List<Data> data = [];
}

class Data {
  final String type;

  final String amount;

  final Color color;

  final double percentage;

  Data({
    required this.type,
    required this.amount,
    required this.color,
    required this.percentage,
  });
}
