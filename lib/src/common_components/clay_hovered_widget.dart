import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';

class ClayHoveredWidget extends StatefulWidget {
  const ClayHoveredWidget({
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
    this.emboss,
    this.unHoverOpacity = 0.3,
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
  final bool? emboss;
  final double unHoverOpacity;

  @override
  State<ClayHoveredWidget> createState() => _ClayHoveredWidgetState();
}

class _ClayHoveredWidgetState extends State<ClayHoveredWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedOpacity(
          opacity: _isHovered ? 1.0 : widget.unHoverOpacity,
          duration: const Duration(milliseconds: 200),
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
            emboss: widget.emboss,
          ),
        ),
      ),
    );
  }
}
