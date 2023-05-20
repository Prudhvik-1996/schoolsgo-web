import 'package:flutter/material.dart';

class FlippingTile extends StatefulWidget {
  final Widget frontSideWidget;
  final Widget backSideWidget;
  final Duration duration;

  const FlippingTile({
    Key? key,
    required this.frontSideWidget,
    required this.backSideWidget,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _FlippingTileState createState() => _FlippingTileState();
}

class _FlippingTileState extends State<FlippingTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFlipped = false;

  late Widget flippedBackSideWidget;

  @override
  void initState() {
    super.initState();
    flippedBackSideWidget = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
      child: widget.backSideWidget,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flipTile() {
    if (_isFlipped) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipTile,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateY(_animation.value * 3.14159);
          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _isFlipped ? flippedBackSideWidget : widget.frontSideWidget,
          );
        },
      ),
    );
  }
}
