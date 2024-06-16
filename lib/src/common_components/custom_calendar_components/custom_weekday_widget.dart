// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';

class CustomWeekDayTile extends StatelessWidget {
  /// Index of week day.
  final int dayIndex;

  /// display week day
  final String Function(int)? weekDayStringBuilder;

  /// Background color of single week day tile.
  final Color backgroundColor;

  /// Should display border or not.
  final bool displayBorder;

  /// Style for week day string.
  final TextStyle? textStyle;

  /// Title for week day in month view.
  const CustomWeekDayTile({
    Key? key,
    required this.dayIndex,
    this.backgroundColor = Colors.white,
    this.displayBorder = true,
    this.textStyle,
    this.weekDayStringBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            weekDayStringBuilder?.call(dayIndex) ?? ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dayIndex],
            style: textStyle ??
                TextStyle(
                  fontSize: 12,
                  color: clayContainerTextColor(context),
                ),
          ),
        ),
      ),
    );
  }
}
