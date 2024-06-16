import 'package:flutter/material.dart';

class CustomVerticalDivider extends StatelessWidget {
  const CustomVerticalDivider({
    Key? key,
    this.width,
    this.height,
    this.hasCircularBorder,
    this.color,
    this.child,
  }) : super(key: key);

  final double? width;
  final double? height;
  final bool? hasCircularBorder;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.blue[200],
        borderRadius: hasCircularBorder ?? false
            ? const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              )
            : null,
      ),
      width: width ?? 3,
      height: height,
      child: child ?? const Text(""),
    );
  }
}
