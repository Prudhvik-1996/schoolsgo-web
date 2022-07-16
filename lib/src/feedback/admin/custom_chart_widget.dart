import 'dart:math';

import 'package:flutter/material.dart';

class CustomChartWidget extends StatelessWidget {
  const CustomChartWidget({
    Key? key,
    required this.xSteps,
    required this.ySteps,
    required this.points,
  }) : super(key: key);

  final List<String> xSteps;
  final List<String> ySteps;

  final List<Point> points;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red),
      ),
      height: ySteps.length * 10 + 10,
      width: min(MediaQuery.of(context).size.width - 100, xSteps.length * 10),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            height: ySteps.length * 10,
            width: 0.1,
            //  TODO wrap in stack and mark Y-Axis
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: xSteps.map((e) => Text(e)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Point {
  int x;
  double y;

  Point({required this.x, required this.y});
}
