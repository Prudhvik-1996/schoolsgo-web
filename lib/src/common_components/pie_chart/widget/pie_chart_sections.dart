import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/pie_chart/data/pie_data.dart';

List<PieChartSectionData> getSections(int touchedIndex) => PieData.data
    .asMap()
    .map<int, PieChartSectionData>((index, data) {
      final isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 100 : 80;

      final value = PieChartSectionData(
        color: data.color,
        value: data.percentage,
        title: data.amount,
        radius: radius,
        badgeWidget: Text(
          data.type.replaceAll("_", " ") + "\n" + data.amount,
          textAlign: TextAlign.center,
        ),
        badgePositionPercentageOffset: 0.5,
        showTitle: false,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );

      return MapEntry(index, value);
    })
    .values
    .toList();
