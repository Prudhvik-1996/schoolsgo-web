import 'package:flutter/material.dart';

class AppExpansionTile extends StatefulWidget {
  AppExpansionTile({
    Key? key,
    this.leading,
    this.title,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
    this.allowExpansion = true,
  }) : super(key: key);

  Widget? leading;
  Widget? title;
  ValueChanged<bool>? onExpansionChanged;
  List<Widget>? children;
  Color? backgroundColor;
  Widget? trailing;
  bool? initiallyExpanded;
  bool? allowExpansion;

  @override
  AppExpansionTileState createState() => AppExpansionTileState();
}

class AppExpansionTileState extends State<AppExpansionTile>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  CurvedAnimation? _easeOutAnimation;
  CurvedAnimation? _easeInAnimation;
  ColorTween? _borderColor;
  ColorTween? _headerColor;
  ColorTween? _iconColor;
  ColorTween? _backgroundColor;
  Animation<double>? _iconTurns;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    _easeOutAnimation =
        CurvedAnimation(parent: _controller!, curve: Curves.easeOut);
    _easeInAnimation =
        CurvedAnimation(parent: _controller!, curve: Curves.easeIn);
    _borderColor = ColorTween();
    _headerColor = ColorTween();
    _iconColor = ColorTween();
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5)
        .animate((_isExpanded) ? _easeOutAnimation! : _easeInAnimation!);
    _backgroundColor = ColorTween();

    if (_isExpanded) _controller!.value = 1.0;
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void expand() {
    _setExpanded(true);
  }

  void collapse() {
    _setExpanded(false);
  }

  void toggle() {
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool isExpanded) {
    if (!(widget.allowExpansion ?? false)) {
      return;
    }
    if (_isExpanded != isExpanded) {
      print("hi");
      setState(() {
        _isExpanded = isExpanded;
        if (_isExpanded) {
          _controller!.forward();
        } else {
          _controller!.reverse();
        }
        PageStorage.of(context)?.writeState(context, _isExpanded);
      });
      if (widget.onExpansionChanged != null) {
        print("Hello");
        widget.onExpansionChanged!(_isExpanded);
      }
    }
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final Color titleColor = _headerColor!.evaluate(_easeInAnimation!)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme.merge(
            data: _isExpanded
                ? IconThemeData(
                    color: _iconColor!.evaluate(_easeOutAnimation!)!)
                : IconThemeData(
                    color: _iconColor!.evaluate(_easeInAnimation!)!),
            child: ListTile(
              onTap: toggle,
              leading: widget.leading,
              title: DefaultTextStyle(
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: titleColor),
                child: widget.title!,
              ),
              trailing: widget.trailing == null
                  ? null
                  : RotationTransition(
                      turns: _iconTurns!,
                      child: const Icon(Icons.expand_more),
                    ),
            ),
          ),
          ClipRect(
            child: Align(
              heightFactor: _isExpanded
                  ? _easeOutAnimation!.value
                  : _easeInAnimation!.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _borderColor!.end = theme.dividerColor;
    _headerColor!
      ..begin = theme.textTheme.bodyText1!.color
      ..end = theme.colorScheme.secondary;
    _iconColor!
      ..begin = theme.unselectedWidgetColor
      ..end = theme.colorScheme.secondary;
    _backgroundColor!.end = widget.backgroundColor;

    final bool closed = !_isExpanded && _controller!.isDismissed;
    return AnimatedBuilder(
      animation: _controller!.view,
      builder: _buildChildren,
      child: closed
          ? null
          : Column(children: widget.children!
              // .map(
              //   (e) => InkWell(
              //     onTap: () {
              //       if (_isExpanded)
              //         collapse();
              //       else
              //         expand();
              //     },
              //     child: e,
              //   ),
              // )
              // .toList(),
              ),
    );
  }
}
