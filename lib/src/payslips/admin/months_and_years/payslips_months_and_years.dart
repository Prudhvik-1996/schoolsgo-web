import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/payslips/admin/months_and_years/payslips_of_given_month_screen.dart';
import 'package:schoolsgo_web/src/payslips/modal/payslips.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class PayslipsMonthsAndYearsScreen extends StatefulWidget {
  const PayslipsMonthsAndYearsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<PayslipsMonthsAndYearsScreen> createState() => _PayslipsMonthsAndYearsScreenState();
}

class _PayslipsMonthsAndYearsScreenState extends State<PayslipsMonthsAndYearsScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;

  List<MonthAndYearForSchoolBean> monthsAndYears = [];
  late MonthAndYearForSchoolBean newMonthAndYearForSchool;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedMonthIndex = DateTime.now().month - 1;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetMonthsAndYearsForSchoolsResponse getMonthsAndYearsForSchoolsResponse = await getMonthsAndYearsForSchools(GetMonthsAndYearsForSchoolsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getMonthsAndYearsForSchoolsResponse.httpStatus != "OK" || getMonthsAndYearsForSchoolsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        monthsAndYears = (getMonthsAndYearsForSchoolsResponse.monthAndYearForSchoolBeans ?? []).map((e) => e!).toList();
      });
    }
    newMonthAndYearForSchool = MonthAndYearForSchoolBean(
      schoolId: widget.adminProfile.schoolId,
      agent: widget.adminProfile.userId,
      status: "active",
    );
    refreshNewBean(newMonthAndYearForSchool, selectedMonthIndex, selectedYear, daysInMonth(DateTime(selectedYear, selectedMonthIndex + 1, 1)));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Month wise payslips"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : monthsAndYears.isEmpty
              ? const Center(
                  child: Text(
                    "Add month and year..",
                  ),
                )
              : ListView(
                  children: monthsAndYears.map((e) => _isEditMode ? buildMonthAndYearEditableWidget(e) : buildMonthAndYearWidget(e)).toList(),
                ),
      floatingActionButton: !_isEditMode
          ? _buildEditButton()
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAddNewButton(),
                const SizedBox(
                  height: 25,
                ),
                _buildEditButton(),
              ],
            ),
    );
  }

  GestureDetector _buildEditButton() {
    return GestureDetector(
      onTap: () {
        MonthAndYearForSchoolBean? editing = monthsAndYears.where((e) => e.isEditMode).firstOrNull;
        if (editing == null) {
          setState(() {
            _isEditMode = !_isEditMode;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Save changes for ${editing.month} - ${editing.year} to continue.."),
            ),
          );
          return;
        }
      },
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        height: 50,
        width: 50,
        borderRadius: 50,
        spread: 1,
        child: !_isEditMode ? const Icon(Icons.edit) : const Icon(Icons.done),
      ),
    );
  }

  GestureDetector _buildAddNewButton() {
    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: _scaffoldKey.currentContext!,
          barrierDismissible: true, // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('New Month and Year'),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return ClayContainer(
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 10,
                    depth: 40,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                            ),
                            const SizedBox(
                              width: 25,
                            ),
                            SizedBox(
                              width: 150,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: MONTHS[selectedMonthIndex],
                                items: MONTHS
                                    .map(
                                      (e) => DropdownMenuItem(
                                        child: Text(e),
                                        value: e,
                                      ),
                                    )
                                    .toList(),
                                onChanged: (String? e) {
                                  if (e == null) return;
                                  setState(() {
                                    selectedMonthIndex = MONTHS.indexOf(e.toUpperCase());
                                    refreshNewBean(newMonthAndYearForSchool, selectedMonthIndex, selectedYear,
                                        daysInMonth(DateTime(selectedYear, selectedMonthIndex + 1, 1)));
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 100,
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedYear,
                                items: [for (var i = DateTime.now().year - 5; i <= DateTime.now().year + 5; i++) i]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        child: Text("$e"),
                                        value: e,
                                      ),
                                    )
                                    .toList(),
                                onChanged: (int? e) {
                                  if (e == null) return;
                                  setState(() {
                                    selectedYear = e;
                                    refreshNewBean(newMonthAndYearForSchool, selectedMonthIndex, selectedYear,
                                        daysInMonth(DateTime(selectedYear, selectedMonthIndex + 1, 1)));
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 50,
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: newMonthAndYearForSchool.noOfWorkingDays,
                                items: [for (var i = 1; i <= daysInMonth(DateTime(selectedYear, selectedMonthIndex + 1, 1)); i++) i]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        child: Text("$e"),
                                        value: e,
                                      ),
                                    )
                                    .toList(),
                                onChanged: (int? e) {
                                  if (e == null) return;
                                  setState(() {
                                    refreshNewBean(newMonthAndYearForSchool, selectedMonthIndex, selectedYear, e);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Proceed'),
                  onPressed: () {
                    if (monthsAndYears
                        .where((e) => e.month == newMonthAndYearForSchool.month && e.year == newMonthAndYearForSchool.year)
                        .isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${newMonthAndYearForSchool.month} - ${newMonthAndYearForSchool.year} is already created.."),
                        ),
                      );
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    _saveChanges();
                  },
                ),
              ],
            );
          },
        );
        setState(() {});
      },
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        height: 50,
        width: 50,
        borderRadius: 50,
        spread: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });
    CreateMonthsAndYearsForSchoolsResponse createMonthsAndYearsForSchoolsResponse =
        await createOrUpdateMonthAndYearForSchool(newMonthAndYearForSchool);
    if (createMonthsAndYearsForSchoolsResponse.httpStatus != 'OK' || createMonthsAndYearsForSchoolsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong..\nPlease try later.."),
        ),
      );
    } else {
      setState(() {
        monthsAndYears.add(newMonthAndYearForSchool);
        newMonthAndYearForSchool = MonthAndYearForSchoolBean(
          schoolId: widget.adminProfile.schoolId,
          agent: widget.adminProfile.userId,
          status: "active",
        );
        refreshNewBean(newMonthAndYearForSchool, selectedMonthIndex, selectedYear, daysInMonth(DateTime(selectedYear, selectedMonthIndex + 1, 1)));
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void refreshNewBean(MonthAndYearForSchoolBean newMonthAndYearForSchool, int selectedMonthIndex, int selectedYear, int noOfWorkingDays) {
    newMonthAndYearForSchool.month = MONTHS[selectedMonthIndex];
    newMonthAndYearForSchool.year = selectedYear;
    newMonthAndYearForSchool.noOfWorkingDays = noOfWorkingDays;
  }

  Widget buildMonthAndYearWidget(MonthAndYearForSchoolBean monthAndYearForSchoolBean) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: GestureDetector(
        onTap: () {
          // PayslipsOfGivenMonthScreen
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PayslipsOfGivenMonthScreen(
              adminProfile: widget.adminProfile,
              monthAndYearForSchoolBean: monthAndYearForSchoolBean,
            );
          }));
        },
        child: ClayButton(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          child: Container(
            margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    monthAndYearForSchoolBean.month!.toLowerCase().capitalize() + " - " + "${monthAndYearForSchoolBean.year!}",
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "${monthAndYearForSchoolBean.noOfWorkingDays!}",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMonthAndYearEditableWidget(MonthAndYearForSchoolBean monthAndYearForSchoolBean) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  monthAndYearForSchoolBean.month!.toLowerCase().capitalize() + " - " + "${monthAndYearForSchoolBean.year!}",
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              monthAndYearForSchoolBean.isEditMode
                  ? SizedBox(
                      width: 50,
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: monthAndYearForSchoolBean.noOfWorkingDays,
                        items: [for (var i = 1; i <= daysInMonth(DateTime(selectedYear, selectedMonthIndex + 1, 1)); i++) i]
                            .map(
                              (e) => DropdownMenuItem(
                                child: Text("$e"),
                                value: e,
                              ),
                            )
                            .toList(),
                        onChanged: (int? e) {
                          if (e == null) return;
                          setState(() {
                            monthAndYearForSchoolBean.noOfWorkingDays = e;
                          });
                        },
                      ),
                    )
                  : Text(
                      "${monthAndYearForSchoolBean.noOfWorkingDays!}",
                    ),
              const SizedBox(
                width: 25,
              ),
              GestureDetector(
                onTap: () async {
                  if (monthAndYearForSchoolBean.isEditMode) {
                    setState(() {
                      _isLoading = true;
                    });
                    if (monthAndYearForSchoolBean.noOfWorkingDays !=
                        MonthAndYearForSchoolBean.fromJson(monthAndYearForSchoolBean.origJson()).noOfWorkingDays) {
                      CreateMonthsAndYearsForSchoolsResponse createMonthsAndYearsForSchoolsResponse =
                          await createOrUpdateMonthAndYearForSchool(monthAndYearForSchoolBean);
                      if (createMonthsAndYearsForSchoolsResponse.httpStatus != 'OK' ||
                          createMonthsAndYearsForSchoolsResponse.responseStatus != "success") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Something went wrong..\nPlease try later.."),
                          ),
                        );
                      }
                    }
                    setState(() {
                      _isLoading = false;
                      monthAndYearForSchoolBean.isEditMode = false;
                    });
                  } else {
                    MonthAndYearForSchoolBean? editing = monthsAndYears.where((e) => e.isEditMode).firstOrNull;
                    if (editing != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Save changes for ${editing.month} - ${editing.year} to continue.."),
                        ),
                      );
                      return;
                    } else {
                      setState(() {
                        monthAndYearForSchoolBean.isEditMode = true;
                      });
                    }
                  }
                },
                child: ClayButton(
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  height: 50,
                  width: 50,
                  borderRadius: 50,
                  spread: 1,
                  child: !monthAndYearForSchoolBean.isEditMode ? const Icon(Icons.edit) : const Icon(Icons.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
