import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';

class ClayPieChart extends StatefulWidget {
  const ClayPieChart({
    Key? key,
    this.child,
    required this.diameter,
    required this.angle,
    required this.highlightColor,
    this.surfaceColor,
    this.parentColor,
    this.spread,
    this.customBorderRadius,
    this.depth,
    this.highlightedText,
  }) : super(key: key);

  final Widget? child;
  final double diameter;
  final double angle;
  final Color highlightColor;
  final Color? surfaceColor;
  final Color? parentColor;
  final double? spread;
  final BorderRadius? customBorderRadius;
  final int? depth;
  final String? highlightedText;

  @override
  _ClayPieChartState createState() => _ClayPieChartState();
}

class _ClayPieChartState extends State<ClayPieChart> {
  late double extraDiameter;

  @override
  void initState() {
    super.initState();
    extraDiameter = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.diameter + 20,
      height: widget.diameter + 20,
      child: Stack(
        children: [
          Center(
            child: FittedBox(
              fit: BoxFit.fill,
              child: ClayContainer(
                width: widget.diameter,
                height: widget.diameter,
                depth: 20,
                parentColor: widget.parentColor,
                surfaceColor: widget.surfaceColor,
                spread: 5,
                borderRadius: widget.diameter,
              ),
            ),
          ),
          Center(
            child: Tooltip(
              message: widget.highlightedText ?? "",
              child: MouseRegion(
                onEnter: (_) {
                  setState(() {
                    extraDiameter = 10;
                  });
                },
                onExit: (_) {
                  setState(() {
                    extraDiameter = 0;
                  });
                },
                cursor: SystemMouseCursors.click,
                child: ClipPath(
                  clipper: SectorClipper(
                    diameter: widget.diameter + extraDiameter,
                    angle: widget.angle,
                    spreadAngle: 0,
                  ),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.highlightColor,
                      ),
                      height: widget.diameter + 20,
                      width: widget.diameter + 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectorClipper extends CustomClipper<Path> {
  SectorClipper({
    required this.diameter,
    required this.angle,
    required this.spreadAngle,
  });

  final double diameter;
  final double angle;
  final double spreadAngle;

  @override
  getClip(Size size) {
    Offset center = Offset((size.width) / 2, (size.height) / 2);
    Rect rect = Rect.fromCircle(center: center, radius: diameter / 2);
    Path path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, pi - (spreadAngle), angle + 2 * (spreadAngle), false)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<dynamic> oldClipper) {
    return true;
  }
}
