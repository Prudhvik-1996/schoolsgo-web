import 'package:flutter/material.dart';

class CustomVerticalDivider extends StatelessWidget {
  const CustomVerticalDivider({
    Key? key,
    this.width,
    this.hasCircularBorder,
  }) : super(key: key);

  final double? width;
  final bool? hasCircularBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[200],
        borderRadius: hasCircularBorder ?? false
            ? const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              )
            : null,
      ),
      width: width ?? 3,
      child: const Text(""),
    );
  }
}
