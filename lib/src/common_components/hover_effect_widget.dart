import 'package:flutter/material.dart';

class OnHoverColorChangeWidget extends StatefulWidget {
  const OnHoverColorChangeWidget({
    Key? key,
    this.child,
    this.hoverColor,
    this.nonHoverColor,
  }) : super(key: key);

  final Widget? child;
  final Color? hoverColor;
  final Color? nonHoverColor;

  @override
  State<OnHoverColorChangeWidget> createState() => _OnHoverColorChangeWidgetState();
}

class _OnHoverColorChangeWidgetState extends State<OnHoverColorChangeWidget> {
  late Color hoverColor;
  late Color nonHoverColor;
  bool? isHovering;

  @override
  void initState() {
    hoverColor = widget.hoverColor ?? Colors.grey.withOpacity(0.2);
    nonHoverColor = widget.nonHoverColor ?? Colors.transparent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (details) => setState(() => isHovering = true),
      onExit: (details) => setState(() => isHovering = false),
      child: Stack(
        children: [
          widget.child ?? Container(),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: (isHovering ?? false) ? hoverColor : nonHoverColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
