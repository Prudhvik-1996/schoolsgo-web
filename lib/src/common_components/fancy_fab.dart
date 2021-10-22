import 'package:flutter/material.dart';

class ExpandableFab extends StatefulWidget {
  final String tooltip;
  final List<FloatingActionButton> expandedWidgets;

  const ExpandableFab({
    Key? key,
    required this.tooltip,
    required this.expandedWidgets,
  }) : super(key: key);

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  late AnimationController _animationController;
  late Animation<Color?> _buttonColor;
  late Animation<double> _animateIcon;
  late Animation<double> _translateButton;
  final Curve _curve = Curves.easeOut;
  final double _fabHeight = 56.0;

  @override
  initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(
        () {
          setState(() {});
        },
      );
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.grey,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.00,
          1.00,
          curve: Curves.linear,
        ),
      ),
    );
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          0.75,
          curve: _curve,
        ),
      ),
    );
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggle() {
    return FloatingActionButton(
      backgroundColor: _buttonColor.value,
      onPressed: animate,
      tooltip: 'Toggle',
      child: const Icon(
        Icons.settings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: widget.expandedWidgets
                .asMap()
                .map(
                  (index, e) => MapEntry<int, Widget>(
                    index,
                    Transform(
                      transform: Matrix4.translationValues(
                        _translateButton.value *
                            (widget.expandedWidgets.length - index),
                        0.0,
                        0.0,
                      ),
                      child: e,
                    ),
                  ),
                )
                .values
                .toList() +
            [toggle()],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: widget.expandedWidgets
                .asMap()
                .map(
                  (index, e) => MapEntry<int, Widget>(
                    index,
                    Transform(
                      transform: Matrix4.translationValues(
                        0.0,
                        _translateButton.value *
                            (widget.expandedWidgets.length - index),
                        0.0,
                      ),
                      child: e,
                    ),
                  ),
                )
                .values
                .toList() +
            [toggle()],
      );
    }
  }
}
