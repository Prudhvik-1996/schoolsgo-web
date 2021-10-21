import 'dart:math' as math;

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final Widget? collapsedTitle;
  final Widget? backgroundWidget;
  final Color? backgroundColor;
  final double? expandedHeight;
  const CustomAppBar({
    Key? key,
    @required this.collapsedTitle,
    @required this.backgroundWidget,
    @required this.backgroundColor,
    @required this.expandedHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: true,
      pinned: true,
      elevation: 50,
      backgroundColor: backgroundColor,
      leading: Container(),
      flexibleSpace: LayoutBuilder(
        builder: (context, c) {
          final FlexibleSpaceBarSettings? settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
          final deltaExtent = settings!.maxExtent - settings!.minExtent;
          final t = (1.0 -
                  (settings.currentExtent - settings.minExtent) / deltaExtent)
              .clamp(0.0, 1.0);
          final fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
          const fadeEnd = 1.0;
          final opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);

          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 45, 0, 10),
                child: Opacity(
                  opacity: 1 - opacity,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: collapsedTitle,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 45, 0, 0),
                child: Opacity(
                  opacity: opacity,
                  child: backgroundWidget,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
