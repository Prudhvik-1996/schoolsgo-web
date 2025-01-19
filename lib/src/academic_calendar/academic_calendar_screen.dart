import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schoolsgo_web/src/academic_calendar/modal/academic_calendar.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/custom_calendar_components/calendar_custom_filled_cell.dart';
import 'package:schoolsgo_web/src/common_components/custom_calendar_components/custom_calendar_month_view.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/common_components/local_clean_calender/flutter_clean_calendar.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({
    Key? key,
    this.adminProfile,
    this.teacherProfile,
    this.studentProfile,
    this.otherUserRoleProfile,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final StudentProfile? studentProfile;
  final OtherUserRoleProfile? otherUserRoleProfile;

  static const routeName = "/calendar";

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  int? schoolId;
  late SchoolInfoBean schoolInfo;
  late DateTime startDate;
  late DateTime endDate;

  List<CalenderEvent> calenderEvents = [];
  Map<DateTime, List<CalendarEventData<CalenderEvent>>> calendarEventDataMap = {};
  bool showCalendar = true;
  DateTime _selectedDate = DateTime.now();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final GlobalKey<CalendarState> calenderKey = GlobalKey<CalendarState>();

  List<Section> sectionsList = [];
  List<int> selectedSectionsIdsList = [];

  @override
  void initState() {
    super.initState();
    schoolId =
        widget.adminProfile?.schoolId ?? widget.studentProfile?.schoolId ?? widget.teacherProfile?.schoolId ?? widget.otherUserRoleProfile?.schoolId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      Navigator.pop(context);
      return;
    } else {
      schoolInfo = getSchoolsResponse.schoolInfo!;
      startDate = convertYYYYMMDDFormatToDateTime(schoolInfo.academicYearStartDate);
      endDate = convertYYYYMMDDFormatToDateTime(schoolInfo.academicYearEndDate);
    }
    GetSectionsResponse getSectionsResponse = await getSections(GetSectionsRequest(
      schoolId: schoolId,
    ));
    if (getSectionsResponse.httpStatus != "OK" || getSectionsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      sectionsList = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
      selectedSectionsIdsList = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!.sectionId!).toList();
    }
    GetCalenderEventsResponse getCalenderEventsResponse = await getCalenderEvents(GetCalenderEventsRequest(schoolId: schoolId));
    if (getCalenderEventsResponse.httpStatus != "OK" || getCalenderEventsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        calenderEvents = getCalenderEventsResponse.calenderEventList?.map((e) => e!).toList() ?? [];
        refreshCalendarData();
      });
    }
    setState(() => _isLoading = false);
  }

  void refreshCalendarData() {
    List<CalenderEvent> filteredCalenderEvents = calenderEvents.map((e) => CalenderEvent.fromJson(e.toJson())).toList();
    for (DateTime eachDate = startDate;
        eachDate.millisecondsSinceEpoch <= endDate.millisecondsSinceEpoch;
        eachDate = eachDate.add(const Duration(days: 1))) {
      calendarEventDataMap[eachDate] = [];
    }
    for (CalenderEvent eachEvent in filteredCalenderEvents) {
      DateTime startDate = convertYYYYMMDDFormatToDateTime(eachEvent.startDate);
      DateTime endDate = convertYYYYMMDDFormatToDateTime(eachEvent.endDate);
      for (DateTime eachDate = startDate;
          eachDate.millisecondsSinceEpoch <= endDate.millisecondsSinceEpoch;
          eachDate = eachDate.add(const Duration(days: 1))) {
        calendarEventDataMap[eachDate]?.add(CalendarEventData(
          color: eachEvent.getColor(),
          date: eachDate,
          event: eachEvent,
          title: eachEvent.subject ?? '',
          description: eachEvent.description ?? "-",
        ));
      }
    }
    calendarEventDataMap.forEach((DateTime date, List<CalendarEventData<CalenderEvent>> calendarEventList) {
      calendarEventList.map((e) => e.event).forEach((CalenderEvent? calenderEvent) {
        calenderEvent?.sectionWiseEventBeanList?.removeWhere((es) => !selectedSectionsIdsList.contains(es?.sectionId));
      });
    });
    calendarEventDataMap.forEach((DateTime date, List<CalendarEventData<CalenderEvent>> calendarEventList) {
      calendarEventList.removeWhere((e) => (e.event?.sectionWiseEventBeanList ?? []).isEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Calendar"),
        actions: _isLoading ? [] : commonOptions() + adminOptions(),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : MediaQuery.of(context).orientation == Orientation.portrait
              ? showCalendar
                  ? calendarWidget()
                  : buildEventsList()
              : Row(
                  children: [
                    Expanded(
                      child: buildEventsList(),
                    ),
                    Expanded(
                      child: calendarWidget(),
                    )
                  ],
                ),
    );
  }

  List<Widget> commonOptions() {
    return [
      if (MediaQuery.of(context).orientation == Orientation.portrait) showOrHideCalendarButton(),
    ];
  }

  List<Widget> adminOptions() {
    return widget.adminProfile != null
        ? [
            addOrEditEventButton(
              CalenderEvent(
                color: colorToHexCode(COLORS[Random().nextInt(COLORS.length - 1)]),
                agentId: widget.adminProfile?.userId,
                status: 'active',
                sectionWiseEventBeanList: sectionsList
                    .map((section) => SectionWiseEventBean(
                          sectionId: section.sectionId,
                          sectionName: section.sectionName,
                          status: 'active',
                        ))
                    .toList(),
              ),
            ),
            IconButton(
              onPressed: () async => sectionFilterAlertDialog(),
              icon: const Icon(Icons.filter_alt_sharp),
            ),
          ]
        : [];
  }

  Widget buildEventsList() {
    return Column(
      children: [
        if (selectedSectionsIdsList.length != sectionsList.length && selectedSectionsIdsList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClayContainer(
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              depth: 40,
              emboss: true,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: Text("Events are filtered for the following sections:"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child:
                              Text(sectionsList.where((es) => selectedSectionsIdsList.contains(es.sectionId)).map((e) => e.sectionName).join(", ")),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (calendarEventDataMap.values.map((e) => e.map((e) => e.event?.sectionWiseEventBeanList ?? []).expand((i) => i)).expand((i) => i).isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                "No events found with the applied filters.\nFeel free to add a new event",
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Expanded(
            child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              itemCount: (endDate.difference(startDate).inHours / 24).round(),
              itemBuilder: (context, index) {
                return getDateWiseEventsList(context)[index];
              },
            ),
          ),
      ],
    );
  }

  List<Widget> getDateWiseEventsList(BuildContext context) {
    List<Widget> dateWiseEventsWidgets = [];
    calendarEventDataMap
        .forEach((date, dateWiseEventsList) => dateWiseEventsWidgets.add(buildEachDateWiseEventCardV2(context, date, dateWiseEventsList)));
    return dateWiseEventsWidgets;
  }

  Widget calendarWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CalendarControllerProvider<CalenderEvent>(
            controller: EventController<CalenderEvent>()
              ..addAll(
                calendarEventDataMap.values.expand((i) => i).toList(),
              ),
            child: getMonthView(),
          ),
        ),
      ),
    );
  }

  Widget getMonthView() {
    return CustomMonthView<CalenderEvent>(
      borderColor: Colors.transparent,
      cellAspectRatio: 0.7,
      width: double.infinity,
      minMonth: convertYYYYMMDDFormatToDateTime(schoolInfo.academicYearStartDate),
      maxMonth: convertYYYYMMDDFormatToDateTime(schoolInfo.academicYearEndDate),
      initialMonth: DateTime.now(),
      headerStyle: HeaderStyle(
        leftIcon: Icon(
          Icons.arrow_left,
          color: clayContainerTextColor(context),
        ),
        rightIcon: Icon(
          Icons.arrow_right,
          color: clayContainerTextColor(context),
        ),
        decoration: BoxDecoration(
          color: clayContainerColor(context),
        ),
        headerTextStyle: TextStyle(
          color: clayContainerTextColor(context),
        ),
      ),
      headerStringBuilder: (DateTime headerDate, {DateTime? secondaryDate}) {
        return "${MONTHS[headerDate.month - 1].toLowerCase().capitalize()}, ${headerDate.year}";
      },
      startDay: WeekDays.sunday,
      onCellTap: (List<CalendarEventData<CalenderEvent>> eventData, DateTime date) async {
        setState(() {
          _selectedDate = date;
          showCalendar = false;
        });
        if ((calendarEventDataMap[date]??[]).isNotEmpty) {
          // await Future.delayed(const Duration(seconds: 2));
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            navigateToDate(date);
          });
        }
      },
      cellBuilder: (date, event, isToday, isInMonth) => CustomFilledCell<CalenderEvent>(
        date: date,
        shouldHighlight: convertDateTimeToYYYYMMDDFormat(date) == convertDateTimeToYYYYMMDDFormat(_selectedDate),
        backgroundColor: clayContainerColor(context),
        events: calendarEventDataMap.values
            .expand((i) => i)
            .where((e) => (convertDateTimeToYYYYMMDDFormat(date) == convertDateTimeToYYYYMMDDFormat(e.date)))
            .toList(),
        // onTileTap: (CalendarEventData<CalenderEvent> event, DateTime date) {
        //   onDateSelected(date, event);
        // },
        isInMonth: isInMonth,
        dateStringBuilder: (DateTime date, {DateTime? secondaryDate}) {
          return "${date.day}";
        },
      ),
    );
  }

  void _onDateSelected(DateTime date, CalendarEventData<CalenderEvent> event) {
    setState(() {
      _selectedDate = date;
    });
    showDialog(
      context: scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 2,
            child: buildEachDateWiseEventCardV2(context, date, [event]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // _saveChanges();
                // _loadData();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget calendarWidget2() {
    Map<DateTime, List<CleanCalendarEvent>> eventMap = calendarEventDataMap.map((dateTime, events) => MapEntry(
        dateTime,
        events
            .map((e) => CleanCalendarEvent(
                  e.title,
                  color: e.color,
                  description: e.description,
                  isAllDay: true,
                ))
            .toList()));
    calenderKey.currentState?.reload(eventMap);
    return Calendar(
      key: calenderKey,
      initialDate: _selectedDate,
      startOnMonday: true,
      weekDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      isExpandable: true,
      eventDoneColor: Colors.green,
      selectedColor: Colors.pink,
      todayColor: Colors.blue,
      eventColor: Colors.grey,
      locale: 'en_IN',
      todayButtonText: 'Today',
      isExpanded: true,
      expandableDateFormat: 'EEEE, dd. MMMM yyyy',
      dayOfWeekStyle: TextStyle(color: clayContainerTextColor(context), fontWeight: FontWeight.w800, fontSize: 11),
      onDateSelected: (DateTime? newDate) {
        if (newDate == null) return;
        setState(() => _selectedDate = newDate);
        navigateToDate(newDate);
      },
      onEventSelected: (CleanCalendarEvent? event) {
        if (event == null) return;
      },
      selectedDate: _selectedDate,
      hideTodayIcon: true,
      sideBySide: MediaQuery.of(context).orientation == Orientation.landscape,
      events: eventMap,
    );
  }

  void navigateToDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _itemScrollController.scrollTo(
        index: calendarEventDataMap.keys.toList().indexOf(_selectedDate),
        duration: const Duration(seconds: 1),
        curve: Curves.linear,
      );
    });
  }

  Widget buildEachDateWiseEventCardV2(BuildContext context, DateTime date, List<CalendarEventData<CalenderEvent>> dateWiseEventsList) {
    return Column(
      children: [
        ...dateWiseEventsList.map(
          (e) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () =>
                  setState(() => e.event!.expandedDates.contains(date) ? e.event!.expandedDates.remove(date) : e.event!.expandedDates.add(date)),
              child: ClayButton(
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                borderRadius: 10,
                spread: 2,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomVerticalDivider(
                            color: e.color,
                            width: 50,
                            height: 80,
                            hasCircularBorder: true,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 3),
                                Text(
                                  MONTHS[date.month - 1].substring(0, 3),
                                  style: TextStyle(
                                    color: getTextColorBasedOnBackground(e.color),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "${date.day}",
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: getTextColorBasedOnBackground(e.color),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${date.year}",
                                  style: TextStyle(
                                    color: getTextColorBasedOnBackground(e.color),
                                  ),
                                ),
                                const SizedBox(height: 3),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if ((e.event?.expandedDates ?? []).contains(date))
                                  Text(e.description)
                                else
                                  AutoSizeText(
                                    e.description,
                                    style: const TextStyle(fontSize: 24),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    maxFontSize: 12,
                                  ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (e.event != null && widget.adminProfile != null && selectedSectionsIdsList.length == sectionsList.length)
                            editEventButton(e, context),
                          if (e.event != null && widget.adminProfile != null && selectedSectionsIdsList.length == sectionsList.length)
                            const SizedBox(
                              width: 8,
                            ),
                          if (e.event != null) expandEventWidget(date, e, context),
                          if (e.event != null) const SizedBox(width: 8),
                        ],
                      ),
                      if (((e.event?.expandedDates ?? []).contains(date)))
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((e.event?.sectionWiseEventBeanList ?? []).isNotEmpty) const SizedBox(height: 8),
                            if ((e.event?.sectionWiseEventBeanList ?? []).isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Sections: ${calenderEvents.firstWhere((ece) => ece.eventId == e.event?.eventId).sectionWiseEventBeanList?.where((es) => es?.status == 'active').length == sectionsList.length ? "All" : e.event!.sectionWiseEventBeanList!.where((e) => e?.status == 'active').map((e) => e!.sectionName!).join(", ")}",
                                ),
                              ),
                            if ((e.event?.sectionWiseEventBeanList?.where((es) => es?.status == 'active') ?? []).isNotEmpty)
                              const SizedBox(height: 8),
                            if (e.event?.startDate != null && e.event != null) buildEventDatesWidget(e.event!),
                            if (e.event?.startDate != null && e.event != null) const SizedBox(height: 8),
                            const SizedBox(height: 8),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEventDatesWidget(CalenderEvent e) {
    String startDate = convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(e.startDate));
    String endDate = convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(e.endDate));
    if ((e.startDate) == (e.endDate)) {
      return ClayContainer(
        emboss: true,
        depth: 10,
        color: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(startDate)),
        ),
      );
    } else {
      return Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: ClayContainer(
              emboss: true,
              depth: 10,
              color: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "Start Date:\n$startDate",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_right),
          const SizedBox(width: 8),
          Expanded(
            child: ClayContainer(
              emboss: true,
              depth: 10,
              color: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "End Date:\n$endDate",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      );
    }
  }

  GestureDetector editEventButton(CalendarEventData<CalenderEvent> e, BuildContext context) {
    return GestureDetector(
      onTap: () async => await addEventDialog(e.event!),
      child: ClayButton(
        depth: 15,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 100,
        child: const SizedBox(
          height: 25,
          width: 25,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(Icons.edit),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector expandEventWidget(DateTime date, CalendarEventData<CalenderEvent> e, BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => e.event!.expandedDates.contains(date) ? e.event!.expandedDates.remove(date) : e.event!.expandedDates.add(date)),
      child: ClayButton(
        depth: 15,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 100,
        child: SizedBox(
          height: 25,
          width: 25,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(e.event!.expandedDates.contains(date) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEachDateWiseEventCard(BuildContext context, DateTime date, List<CalendarEventData<CalenderEvent>> dateWiseEventsList) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Text(
                  convertDateTimeToDDMMYYYYFormat(date),
                  style: TextStyle(
                    color: convertDateTimeToDDMMYYYYFormat(date) == convertDateTimeToDDMMYYYYFormat(_selectedDate) ? Colors.blue : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...dateWiseEventsList
                  .map((e) => <Widget>[
                        ClayButton(
                          surfaceColor: clayContainerColor(context),
                          parentColor: clayContainerColor(context),
                          borderRadius: 10,
                          spread: 2,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomVerticalDivider(
                                  color: e.color,
                                  width: 8,
                                  height: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Subject",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        e.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Description",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(e.description),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ])
                  .expand((i) => i),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildEachEventCard(BuildContext context, CalenderEvent e) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 20,
        spread: 2,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomVerticalDivider(
                color: hexCodeToColor(e.color!),
                width: 8,
                height: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Subject",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.subject ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(e.description ?? ""),
                    const SizedBox(height: 8),
                    const Text(
                      "Start Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(e.startDate))),
                    const SizedBox(height: 8),
                    const Text(
                      "End Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(e.endDate))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showOrHideCalendarButton() {
    return IconButton(
      onPressed: () => setState(() => showCalendar = !showCalendar),
      icon: showCalendar ? const Icon(Icons.calendar_today) : const Icon(Icons.calendar_month_sharp),
    );
  }

  Widget addOrEditEventButton(CalenderEvent event) {
    return IconButton(
      onPressed: () async => await addEventDialog(event),
      icon: const Icon(Icons.add),
    );
  }

  Future<void> addEventDialog(CalenderEvent event) async {
    return await showDialog(
      context: scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: Text(event.eventId == null ? "New Event" : "Edit Event"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                child: ListView(
                  children: [
                    eventSubjectTextField(event, setState),
                    eventDescriptionTextField(event, setState),
                    eventDatesButtons(event, setState),
                    eventColorPicker(event, setState),
                    eventSectionPicker(event, setState),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          if (isEventValid(event))
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  Navigator.pop(context);
                                  await saveChanges(event);
                                },
                                child: ClayButton(
                                  surfaceColor: Colors.green,
                                  parentColor: clayContainerColor(context),
                                  borderRadius: 20,
                                  spread: 2,
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.check),
                                        Expanded(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text("Submit"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 30),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                            },
                            child: ClayButton(
                              surfaceColor: Colors.red,
                              parentColor: clayContainerColor(context),
                              borderRadius: 20,
                              spread: 2,
                              child: Container(
                                width: 100,
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.clear),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text("Cancel"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget eventSectionPicker(CalenderEvent event, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              selectSectionExpanded(event, setState),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => selectAllSectionsForAnEvent(setState, event),
                    child: ClayButton(
                      depth: 40,
                      color: clayContainerColor(context),
                      spread: 2,
                      borderRadius: 10,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Select All"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => clearAllSectionsForAnEvent(setState, event),
                    child: ClayButton(
                      depth: 40,
                      color: clayContainerColor(context),
                      spread: 2,
                      borderRadius: 10,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Clear"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clearAllSectionsForAnEvent(StateSetter setState, CalenderEvent event) =>
      setState(() => event.sectionWiseEventBeanList?.forEach((es) => es?.status = 'inactive'));

  void selectAllSectionsForAnEvent(StateSetter setState, CalenderEvent event) =>
      setState(() => event.sectionWiseEventBeanList?.forEach((es) => es?.status = 'active'));

  Widget selectSectionExpanded(CalenderEvent event, StateSetter setState) {
    return SizedBox(
      width: double.infinity,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.25,
        crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 6,
        shrinkWrap: true,
        children: sectionsList.map((e) => buildSectionCheckBox(e, event, setState)).toList(),
      ),
    );
  }

  Widget buildSectionCheckBox(Section section, CalenderEvent event, StateSetter setState) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          if (_isLoading) return;
          onSectionSelectionChangedForAnEvent(event, section, setState);
        },
        child: ClayButton(
          depth: 40,
          color: (event.sectionWiseEventBeanList?.where((e) => e?.status == 'active').map((e) => e?.sectionId) ?? []).contains(section.sectionId)
              ? Colors.blue[200]
              : clayContainerColor(context),
          spread: (event.sectionWiseEventBeanList?.where((e) => e?.status == 'active').map((e) => e?.sectionId) ?? []).contains(section.sectionId)
              ? 0
              : 2,
          borderRadius: 10,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              section.sectionName!,
            ),
          ),
        ),
      ),
    );
  }

  void onSectionSelectionChangedForAnEvent(CalenderEvent event, Section section, StateSetter setState) {
    setState(() {
      SectionWiseEventBean? sectionWiseEventBean = event.sectionWiseEventBeanList?.firstWhere((es) => es?.sectionId == section.sectionId);
      if (sectionWiseEventBean == null) return;
      if (sectionWiseEventBean.status == 'active') {
        sectionWiseEventBean.status = 'inactive';
      } else {
        sectionWiseEventBean.status = 'active';
      }
    });
  }

  Widget eventColorPicker(CalenderEvent event, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: BlockPicker(
          pickerColor: hexCodeToColor(event.color!),
          onColorChanged: (Color color) => setState(() => event.color = colorToHexCode(color)),
          availableColors: COLORS,
        ),
      ),
    );
  }

  Future<void> saveChanges(CalenderEvent event) async {
    setState(() => _isLoading = true);
    CreateOrUpdateCalenderEventsResponse createOrUpdateCalenderEventsResponse =
        await createOrUpdateCalenderEvents(CreateOrUpdateCalenderEventsRequest(
      agentId: widget.adminProfile!.userId,
      schoolId: schoolId,
      calenderEventBeans: [event],
    ));
    if (createOrUpdateCalenderEventsResponse.httpStatus != "OK" || createOrUpdateCalenderEventsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      await _loadData();
    }
    setState(() => _isLoading = false);
  }

  bool isEventValid(CalenderEvent event) =>
      (event.subject?.trim() ?? "").isNotEmpty && (event.startDate?.trim() ?? "").isNotEmpty && (event.endDate?.trim() ?? "").isNotEmpty;

  Widget eventDatesButtons(CalenderEvent event, StateSetter setState) {
    return Row(
      children: [
        Expanded(child: _getStartDatePicker(event, setState)),
        const SizedBox(width: 8),
        Expanded(child: _getEndDatePicker(event, setState)),
      ],
    );
  }

  Widget _getStartDatePicker(CalenderEvent event, StateSetter setState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: event.startDate == null ? DateTime.now() : convertYYYYMMDDFormatToDateTime(event.startDate!),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            helpText: "Pick start date",
          );
          if (_newDate == null || convertDateTimeToYYYYMMDDFormat(_newDate) == event.startDate) return;
          setState(() {
            event.startDate = convertDateTimeToYYYYMMDDFormat(_newDate);
            event.endDate ??= event.startDate;
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                event.startDate == null
                    ? "Start Date:\n-"
                    : "Start Date:\n${convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(event.startDate!))}",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getEndDatePicker(CalenderEvent event, StateSetter setState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: event.endDate == null ? DateTime.now() : convertYYYYMMDDFormatToDateTime(event.endDate!),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            helpText: "Pick end date",
          );
          if (_newDate == null || convertDateTimeToYYYYMMDDFormat(_newDate) == event.endDate) return;
          setState(() {
            event.endDate = convertDateTimeToYYYYMMDDFormat(_newDate);
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                event.endDate == null
                    ? "End Date:\n-"
                    : "End Date:\n${convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(event.endDate!))}",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget eventDescriptionTextField(CalenderEvent event, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        initialValue: event.description ?? '',
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 18, 10, 8),
          hintText: "Description",
          labelText: "Description",
        ),
        onChanged: (String? newText) => setState(() => event.description = newText),
        maxLines: 5,
        style: const TextStyle(
          fontSize: 16,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget eventSubjectTextField(CalenderEvent event, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              initialValue: event.subject ?? '',
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                hintText: "Subject",
                labelText: "Subject",
              ),
              onChanged: (String? newText) => setState(() => event.subject = newText),
              maxLines: null,
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: 8),
          deleteEventButton(event),
        ],
      ),
    );
  }

  GestureDetector deleteEventButton(CalenderEvent event) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        deleteEventAlertDialog(event);
      },
      child: ClayButton(
        depth: 15,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 100,
        child: const SizedBox(
          height: 25,
          width: 25,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deleteEventAlertDialog(CalenderEvent event) async {
    await showDialog(
      context: scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: const Text("Are you sure you want to delete Event"),
          actions: [
            TextButton(
              child: const Text('Proceed to delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                event.status = 'inactive';
                await saveChanges(event);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sectionFilterAlertDialog() async {
    return await showDialog(
      context: scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: const Text("Section Filter"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                child: ListView(
                  children: [
                    selectSectionExpandedForFilter(setState),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => refreshCalendarData());
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget selectSectionExpandedForFilter(StateSetter setState) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 6,
            shrinkWrap: true,
            children: sectionsList.map((e) => buildSectionCheckBoxForFilter(e, setState)).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => selectedSectionsIdsList = sectionsList.map((e) => e.sectionId!).toList()),
                child: ClayButton(
                  depth: 40,
                  color: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Select All"),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => selectedSectionsIdsList = []),
                child: ClayButton(
                  depth: 40,
                  color: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Clear"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSectionCheckBoxForFilter(Section section, StateSetter setState1) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          if (_isLoading) return;
          setState(() {
            setState1(() {
              if (selectedSectionsIdsList.contains(section.sectionId)) {
                selectedSectionsIdsList.remove(section.sectionId);
              } else {
                selectedSectionsIdsList.add(section.sectionId!);
              }
            });
          });
        },
        child: ClayButton(
          depth: 40,
          color: selectedSectionsIdsList.contains(section.sectionId) ? Colors.blue[200] : clayContainerColor(context),
          spread: selectedSectionsIdsList.contains(section.sectionId) ? 0 : 2,
          borderRadius: 10,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              section.sectionName!,
            ),
          ),
        ),
      ),
    );
  }
}
