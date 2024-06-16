import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class CustomFilledCell<T extends Object?> extends StatelessWidget {
  /// Date of current cell.
  final DateTime date;

  /// List of events on for current date.
  final List<CalendarEventData<T>> events;

  /// defines date string for current cell.
  final StringProvider? dateStringBuilder;

  /// Defines if cell should be highlighted or not.
  /// If true it will display date title in a circle.
  final bool shouldHighlight;

  /// Defines background color of cell.
  final Color backgroundColor;

  /// Defines highlight color.
  final Color highlightColor;

  /// Called when user taps on any event tile.
  final TileTapCallback<T>? onTileTap;

  /// defines that [date] is in current month or not.
  final bool isInMonth;

  /// defines radius of highlighted date.
  final double highlightRadius;

  /// color of highlighted cell title
  final Color highlightedTitleColor;

  /// This class will defines how cell will be displayed.
  /// This widget will display all the events as tile below date title.
  const CustomFilledCell({
    Key? key,
    required this.date,
    required this.events,
    this.isInMonth = false,
    this.shouldHighlight = false,
    this.backgroundColor = Colors.blue,
    this.highlightColor = Colors.blue,
    this.onTileTap,
    this.highlightRadius = 11,
    this.highlightedTitleColor = Colors.white,
    this.dateStringBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 5.0,
        ),
        CircleAvatar(
          radius: highlightRadius,
          backgroundColor: shouldHighlight ? highlightColor : Colors.transparent,
          child: Text(
            dateStringBuilder?.call(date) ?? "${date.day}",
            style: TextStyle(
              color: shouldHighlight
                  ? highlightedTitleColor
                  : isInMonth
                      ? clayContainerTextColor(context)
                      : clayContainerTextColor(context).withOpacity(0.4),
              decoration: convertDateTimeToYYYYMMDDFormat(date) == convertDateTimeToYYYYMMDDFormat(DateTime.now()) ? TextDecoration.underline : null,
              fontSize: 12,
            ),
          ),
        ),
        if (events.isNotEmpty)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 5.0),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    events.length,
                    (index) => GestureDetector(
                      onTap: () => onTileTap?.call(events[index], events[index].date),
                      child: Container(
                        decoration: BoxDecoration(
                          color: events[index].color,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
                        padding: const EdgeInsets.all(2.0),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                events[index].title,
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                                style: events[0].titleStyle ??
                                    TextStyle(
                                      color: events[index].color.accent,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
