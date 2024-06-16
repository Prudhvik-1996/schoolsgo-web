// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/custom_calendar_components/internal_week_view.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';



/// [Widget] to display week view.
class CustomWeekView<T extends Object?> extends StatefulWidget {
  /// Builder to build tile for events.
  final EventTileBuilder<T>? eventTileBuilder;

  /// Header builder for week page header.
  final WeekPageHeaderBuilder? weekPageHeaderBuilder;

  /// Builds custom PressDetector widget
  ///
  /// If null, internal PressDetector will be used to handle onDateLongPress()
  ///
  final DetectorBuilder? weekDetectorBuilder;

  /// This function will generate dateString int the calendar header.
  /// Useful for I18n
  final StringProvider? headerStringBuilder;

  /// This function will generate WeekDayString in the weekday.
  /// Useful for I18n
  final String Function(int)? weekDayStringBuilder;

  /// This function will generate WeekDayDateString in the weekday.
  /// Useful for I18n
  final String Function(int)? weekDayDateStringBuilder;

  /// Called whenever user changes week.
  final CalendarPageChangeCallBack? onPageChange;

  /// Minimum day to display in week view.
  ///
  /// In calendar first date of the week that contains this data will be
  /// minimum date.
  ///
  /// ex, If minDay is 16th March, 2022 then week containing this date will have
  /// dates from 14th to 20th (Monday to Sunday). adn 14th date will
  /// be the actual minimum date.
  final DateTime? minDay;

  /// Maximum day to display in week view.
  ///
  /// In calendar last date of the week that contains this data will be
  /// maximum date.
  ///
  /// ex, If maxDay is 16th March, 2022 then week containing this date will have
  /// dates from 14th to 20th (Monday to Sunday). adn 20th date will
  /// be the actual maximum date.
  final DateTime? maxDay;

  /// Initial week to display in week view.
  final DateTime? initialDay;

  /// Settings for hour indicator settings.
  final HourIndicatorSettings? hourIndicatorSettings;

  /// Settings for live time indicator settings.
  final HourIndicatorSettings? liveTimeIndicatorSettings;

  /// duration for page transition while changing the week.
  final Duration pageTransitionDuration;

  /// Transition curve for transition.
  final Curve pageTransitionCurve;

  /// Controller for Week view thia will refresh view when user adds or removes
  /// event from controller.
  final EventController<T>? controller;

  /// Width of week view. If null provided device width will be considered.
  final double? width;

  /// Height of week day title,
  final double weekTitleHeight;

  /// Builder to build week day.
  final DateWidgetBuilder? weekDayBuilder;

  /// Builder to build week number.
  final WeekNumberBuilder? weekNumberBuilder;

  /// Background color of week view page.
  final Color backgroundColor;

  /// Scroll offset of week view page.
  final double scrollOffset;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onEventTap;

  /// Show weekends or not
  ///
  /// Default value is true.
  ///
  /// If it is false week view will remove weekends from week
  /// even if weekends are added in [weekDays].
  ///
  /// ex, if [showWeekends] is false and [weekDays] are monday, tuesday,
  /// saturday and sunday, only monday and tuesday will be visible in week view.
  final bool showWeekends;

  /// Defines which days should be displayed in one week.
  ///
  /// By default all the days will be visible.
  /// Sequence will be monday to sunday.
  ///
  /// Duplicate values will be removed from list.
  ///
  /// ex, if there are two mondays in list it will display only one.
  final List<WeekDays> weekDays;

  /// This method will be called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  ///
  /// This callback will have a date parameter which
  /// will provide the time span on which user has tapped.
  ///
  /// Ex, User Taps on Date page with date 11/01/2022 and time span is 1PM to 2PM.
  /// then DateTime object will be  DateTime(2022,01,11,1,0)
  final DateTapCallback? onDateTap;

  /// Defines the day from which the week starts.
  ///
  /// Default value is [WeekDays.monday].
  final WeekDays startDay;

  /// Style for WeekView header.
  final HeaderStyle headerStyle;

  /// Option for SafeArea.
  final SafeAreaOption safeAreaOption;

  /// Display full day event builder.
  final FullDayEventBuilder<T>? fullDayEventBuilder;

  /// Main widget for week view.
  const CustomWeekView({
    Key? key,
    this.controller,
    this.eventTileBuilder,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.ease,
    this.width,
    this.minDay,
    this.maxDay,
    this.initialDay,
    this.hourIndicatorSettings,
    this.liveTimeIndicatorSettings,
    this.onPageChange,
    this.weekPageHeaderBuilder,
    this.weekTitleHeight = 50,
    this.weekDayBuilder,
    this.weekNumberBuilder,
    this.backgroundColor = Colors.white,
    this.scrollOffset = 0.0,
    this.onEventTap,
    this.onDateLongPress,
    this.onDateTap,
    this.weekDays = WeekDays.values,
    this.showWeekends = true,
    this.startDay = WeekDays.monday,
    this.weekDetectorBuilder,
    this.headerStringBuilder,
    this.weekDayStringBuilder,
    this.weekDayDateStringBuilder,
    this.headerStyle = const HeaderStyle(),
    this.safeAreaOption = const SafeAreaOption(),
    this.fullDayEventBuilder,
  })  :
        assert(width == null || width > 0,
        "Calendar width must be greater than 0."),
        assert(
        weekDetectorBuilder == null || onDateLongPress == null,
        """If you use [weekPressDetectorBuilder] 
          do not provide [onDateLongPress]""",
        ),
        super(key: key);

  @override
  CustomWeekViewState<T> createState() => CustomWeekViewState<T>();
}

class CustomWeekViewState<T extends Object?> extends State<CustomWeekView<T>> {
  late double _width;
  late double _height;
  late double _timeLineWidth;
  late DateTime _currentStartDate;
  late DateTime _currentEndDate;
  late DateTime _maxDate;
  late DateTime _minDate;
  late DateTime _currentWeek;
  late int _totalWeeks;
  late int _currentIndex;

  late PageController _pageController;

  late EventTileBuilder<T> _eventTileBuilder;
  late WeekPageHeaderBuilder _weekHeaderBuilder;
  late DateWidgetBuilder _weekDayBuilder;
  late WeekNumberBuilder _weekNumberBuilder;
  late DetectorBuilder _weekDetectorBuilder;

  late double _weekTitleWidth;
  late int _totalDaysInWeek;

  late VoidCallback _reloadCallback;

  EventController<T>? _controller;

  late ScrollController _scrollController;

  ScrollController get scrollController => _scrollController;

  late List<WeekDays> _weekDays;

  @override
  void initState() {
    super.initState();

    _width = widget.width!;
    _weekHeaderBuilder =
        widget.weekPageHeaderBuilder ?? _defaultWeekPageHeaderBuilder;
    _reloadCallback = _reload;

    _setWeekDays();
    _setDateRange();

    _currentWeek = (widget.initialDay ?? DateTime.now()).withoutTime;

    _regulateCurrentDate();

    _scrollController =
        ScrollController(initialScrollOffset: widget.scrollOffset);
    _pageController = PageController(initialPage: _currentIndex);

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (_controller != newController) {
      _controller = newController;

      _controller!
      // Removes existing callback.
        ..removeListener(_reloadCallback)

      // Reloads the view if there is any change in controller or
      // user adds new events.
        ..addListener(_reloadCallback);
    }

  }

  @override
  void didUpdateWidget(CustomWeekView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller.
    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (newController != _controller) {
      _controller?.removeListener(_reloadCallback);
      _controller = newController;
      _controller?.addListener(_reloadCallback);
    }

    _setWeekDays();

    // Update date range.
    if (widget.minDay != oldWidget.minDay ||
        widget.maxDay != oldWidget.maxDay) {
      _setDateRange();
      _regulateCurrentDate();

      _pageController.jumpToPage(_currentIndex);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_reloadCallback);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaWrapper(
      option: widget.safeAreaOption,
      child: SizedBox(
        width: _width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _weekHeaderBuilder(_currentStartDate, _currentEndDate),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(color: widget.backgroundColor),
                child: SizedBox(
                  height: _height,
                  width: _width,
                  child: PageView.builder(
                    itemCount: _totalWeeks,
                    controller: _pageController,
                    onPageChanged: _onPageChange,
                    itemBuilder: (_, index) {
                      final dates = DateTime(_minDate.year, _minDate.month,
                          _minDate.day + (index * DateTime.daysPerWeek))
                          .datesOfWeek(start: widget.startDay);

                      return CustomInternalWeekViewPage<T>(
                          height: _height,
                          width: _width,
                          weekTitleWidth: _weekTitleWidth,
                          weekTitleHeight: widget.weekTitleHeight,
                          weekDayBuilder: _weekDayBuilder,
                          weekNumberBuilder: _weekNumberBuilder,
                          weekDetectorBuilder: _weekDetectorBuilder,
                          onTileTap: widget.onEventTap,
                          onDateLongPress: widget.onDateLongPress,
                          onDateTap: widget.onDateTap,
                          eventTileBuilder: _eventTileBuilder,
                          dates: dates,
                          verticalLineOffset: 0,
                          showVerticalLine: true,
                          controller: controller,
                          scrollController: _scrollController,
                          weekDays: _weekDays,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns [EventController] associated with this Widget.
  ///
  /// This will throw [AssertionError] if controller is called before its
  /// initialization is complete.
  EventController<T> get controller {
    if (_controller == null) {
      throw "EventController is not initialized yet.";
    }

    return _controller!;
  }

  /// Reloads page.
  void _reload() {
    if (mounted) {
      setState(() {});
    }
  }

  void _setWeekDays() {
    _weekDays = widget.weekDays.toSet().toList();

    if (!widget.showWeekends) {
      _weekDays
        ..remove(WeekDays.saturday)
        ..remove(WeekDays.sunday);
    }

    assert(
    _weekDays.isNotEmpty,
    "weekDays can not be empty.\n"
        "Make sure you are providing weekdays in initialization of "
        "WeekView. or showWeekends is true if you are providing only "
        "saturday or sunday in weekDays.");
    _totalDaysInWeek = _weekDays.length;
  }

  Widget _defaultFullDayEventBuilder(
      List<CalendarEventData<T>> events, DateTime dateTime) {
    return FullDayEventView(
      events: events,
      boxConstraints: BoxConstraints(maxHeight: 65),
      date: dateTime,
    );
  }

  /// Sets the current date of this month.
  ///
  /// This method is used in initState and onUpdateWidget methods to
  /// regulate current date in Month view.
  ///
  /// If maximum and minimum dates are change then first call _setDateRange
  /// and then _regulateCurrentDate method.
  ///
  void _regulateCurrentDate() {
    if (_currentWeek.isBefore(_minDate)) {
      _currentWeek = _minDate;
    } else if (_currentWeek.isAfter(_maxDate)) {
      _currentWeek = _maxDate;
    }

    _currentStartDate = _currentWeek.firstDayOfWeek(start: widget.startDay);
    _currentEndDate = _currentWeek.lastDayOfWeek(start: widget.startDay);
    _currentIndex =
        _minDate.getWeekDifference(_currentEndDate, start: widget.startDay);
  }

  /// Sets the minimum and maximum dates for current view.
  void _setDateRange() {
    _minDate = (widget.minDay ?? CalendarConstants.epochDate)
        .firstDayOfWeek(start: widget.startDay)
        .withoutTime;

    _maxDate = (widget.maxDay ?? CalendarConstants.maxDate)
        .lastDayOfWeek(start: widget.startDay)
        .withoutTime;

    assert(
    _minDate.isBefore(_maxDate),
    "Minimum date must be less than maximum date.\n"
        "Provided minimum date: $_minDate, maximum date: $_maxDate",
    );

    _totalWeeks =
        _minDate.getWeekDifference(_maxDate, start: widget.startDay) + 1;
  }

  /// Default press detector builder. This builder will be used if
  /// [widget.weekDetectorBuilder] is null.
  ///
  Widget _defaultPressDetectorBuilder({
    required DateTime date,
    required double height,
    required double width,
    required double heightPerMinute,
    required MinuteSlotSize minuteSlotSize,
  }) {
    final heightPerSlot = minuteSlotSize.minutes * heightPerMinute;
    final slots = (24 * 60) ~/ minuteSlotSize.minutes;

    return Container(
      height: height,
      width: width,
      child: Stack(
        children: [
          for (int i = 0; i < slots; i++)
            Positioned(
              top: heightPerSlot * i,
              left: 0,
              right: 0,
              bottom: height - (heightPerSlot * (i + 1)),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress: () => widget.onDateLongPress?.call(
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    0,
                    minuteSlotSize.minutes * i,
                  ),
                ),
                onTap: () => widget.onDateTap?.call(
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    0,
                    minuteSlotSize.minutes * i,
                  ),
                ),
                child: SizedBox(width: width, height: heightPerSlot),
              ),
            ),
        ],
      ),
    );
  }

  /// Default builder for week line.
  Widget _defaultWeekDayBuilder(DateTime date) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.weekDayStringBuilder?.call(date.weekday - 1) ??
              WEEKS[date.weekday - 1]),
          Text(widget.weekDayDateStringBuilder?.call(date.day) ??
              date.day.toString()),
        ],
      ),
    );
  }

  /// Called when user change page using any gesture or inbuilt functions.
  void _onPageChange(int index) {
    if (mounted) {
      setState(() {
        _currentStartDate = DateTime(
          _currentStartDate.year,
          _currentStartDate.month,
          _currentStartDate.day + (index - _currentIndex) * 7,
        );
        _currentEndDate = _currentStartDate.add(Duration(days: 6));
        _currentIndex = index;
      });
    }
    widget.onPageChange?.call(_currentStartDate, _currentIndex);
  }

  /// Animate to next page
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  void nextPage({Duration? duration, Curve? curve}) {
    _pageController.nextPage(
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// Animate to previous page
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  void previousPage({Duration? duration, Curve? curve}) {
    _pageController.previousPage(
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// Jumps to page number [page]
  ///
  ///
  void jumpToPage(int page) => _pageController.jumpToPage(page);

  /// Animate to page number [page].
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  Future<void> animateToPage(int page,
      {Duration? duration, Curve? curve}) async {
    await _pageController.animateToPage(page,
        duration: duration ?? widget.pageTransitionDuration,
        curve: curve ?? widget.pageTransitionCurve);
  }

  /// Returns current page number.
  int get currentPage => _currentIndex;

  /// Jumps to page which gives day calendar for [week]
  void jumpToWeek(DateTime week) {
    if (week.isBefore(_minDate) || week.isAfter(_maxDate)) {
      throw "Invalid date selected.";
    }
    _pageController
        .jumpToPage(_minDate.getWeekDifference(week, start: widget.startDay));
  }

  /// Animate to page which gives day calendar for [week].
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [CustomWeekView.pageTransitionDuration] and [CustomWeekView.pageTransitionCurve]
  /// respectively.
  Future<void> animateToWeek(DateTime week,
      {Duration? duration, Curve? curve}) async {
    if (week.isBefore(_minDate) || week.isAfter(_maxDate)) {
      throw "Invalid date selected.";
    }
    await _pageController.animateToPage(
      _minDate.getWeekDifference(week, start: widget.startDay),
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// Returns the current visible week's first date.
  DateTime get currentDate => DateTime(
      _currentStartDate.year, _currentStartDate.month, _currentStartDate.day);

  /// Animate to specific scroll controller offset
  void animateTo(
      double offset, {
        Duration duration = const Duration(milliseconds: 200),
        Curve curve = Curves.linear,
      }) {
    _scrollController.animateTo(
      offset,
      duration: duration,
      curve: curve,
    );
  }

  /// check if any dates contains current date or not.
  /// Returns true if it does else false.
  bool _showLiveTimeIndicator(List<DateTime> dates) =>
      dates.any((date) => date.compareWithoutTime(DateTime.now()));

  /// Default view header builder. This builder will be used if
  /// [widget.dayTitleBuilder] is null.
  Widget _defaultWeekPageHeaderBuilder(DateTime startDate, DateTime endDate) {
    return WeekPageHeader(
      startDate: _currentStartDate,
      endDate: _currentEndDate,
      onNextDay: nextPage,
      onPreviousDay: previousPage,
      onTitleTapped: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: startDate,
          firstDate: _minDate,
          lastDate: _maxDate,
        );

        if (selectedDate == null) return;
        jumpToWeek(selectedDate);
      },
      headerStringBuilder: widget.headerStringBuilder,
      headerStyle: widget.headerStyle,
    );
  }
}
