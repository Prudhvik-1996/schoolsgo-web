import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClayButton extends StatefulWidget {
  const ClayButton({
    Key? key,
    this.child,
    this.height,
    this.width,
    this.color,
    this.surfaceColor,
    this.parentColor,
    this.spread,
    this.borderRadius,
    this.customBorderRadius,
    this.depth,
    this.doVibrate,
  }) : super(key: key);

  final Widget? child;
  final double? height;
  final double? width;
  final Color? color;
  final Color? surfaceColor;
  final Color? parentColor;
  final double? spread;
  final double? borderRadius;
  final BorderRadius? customBorderRadius;
  final int? depth;
  final bool? doVibrate;

  @override
  _ClayButtonState createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (widget.doVibrate ?? false) HapticFeedback.selectionClick();
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ClayContainer(
          child: widget.child,
          height: widget.height,
          width: widget.width,
          color: widget.color,
          surfaceColor: widget.surfaceColor,
          parentColor: widget.parentColor,
          spread: widget.spread,
          borderRadius: widget.borderRadius,
          customBorderRadius: widget.customBorderRadius,
          depth: widget.depth,
          emboss: _isPressed,
        ),
      ),
    );
  }
}
