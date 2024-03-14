import 'package:charts_flutter/flutter.dart' as charts;
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/feedback/model/admin_feedback.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class AdminFeedbackViewScreen extends StatefulWidget {
  const AdminFeedbackViewScreen({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/feedback";

  @override
  State<AdminFeedbackViewScreen> createState() => _AdminFeedbackViewScreenState();
}

class _AdminFeedbackViewScreenState extends State<AdminFeedbackViewScreen> {
  bool _isLoading = true;

  List<TeacherDealingSection> tdsList = [];
  List<Teacher> teachersList = [];
  Teacher? selectedTeacher;
  Teacher? expandedTeacher;

  List<FeedbackPlotBean> allTdsWiseFeedbackPlotBeans = [];
  List<FeedbackPlotBean> allTeacherWiseFeedbackPlotBeans = [];
  Map<int, List<DateWiseFeedbackBean>> allTeachersFeedbackPlotPoints = {};

  bool _isSectionPickerOpen = false;
  Section? _selectedSection;
  List<Section> sectionsList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }
    GetTeachersResponse getTeachersResponse = await getTeachers(
      GetTeachersRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }
    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        teachersList = getTeachersResponse.teachers!;
      });
    }
    GetStudentToTeacherFeedbackAdminViewResponse getStudentToTeacherFeedbackAdminViewResponse =
        await getStudentToTeacherFeedbackAdminView(GetStudentToTeacherFeedbackAdminViewRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getStudentToTeacherFeedbackAdminViewResponse.httpStatus != "OK" || getStudentToTeacherFeedbackAdminViewResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        allTdsWiseFeedbackPlotBeans = getStudentToTeacherFeedbackAdminViewResponse.allTdsWiseFeedbackPlotBeans!.map((e) => e!).toList();
        allTeacherWiseFeedbackPlotBeans = getStudentToTeacherFeedbackAdminViewResponse.allTeacherWiseFeedbackPlotBeans!.map((e) => e!).toList();
        for (DateWiseFeedbackBean eachFeedbackPlotBean
            in allTdsWiseFeedbackPlotBeans.map((e) => (e.dateWiseFeedbackBeans ?? []).map((e) => e!).toList()).expand((i) => i)) {
          if (eachFeedbackPlotBean.teacherId == null) continue;
          allTeachersFeedbackPlotPoints[eachFeedbackPlotBean.teacherId!] ??= [];
          allTeachersFeedbackPlotPoints[eachFeedbackPlotBean.teacherId]?.add(eachFeedbackPlotBean);
        }
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.adminProfile,
          ),
        ],
      ),
      drawer: AdminAppDrawer(adminProfile: widget.adminProfile),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).orientation == Orientation.landscape
                          ? MediaQuery.of(context).size.width / 2
                          : MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.all(20),
                      child: _isSectionPickerOpen
                          ? _sectionPicker()
                          : MediaQuery.of(context).orientation == Orientation.landscape
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: _sectionPicker(),
                                    ),
                                    Expanded(
                                      child: searchableDropdownButtonForTeacher(),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: _sectionPicker()),
                                      ],
                                    ),
                                    searchableDropdownButtonForTeacher(),
                                  ],
                                ),
                    ),
                  ] +
                  (_selectedSection != null
                      ? [eachSectionFeedbackWidget(_selectedSection!)]
                      : (selectedTeacher != null
                          ? [eachTeacherFeedbackWidget(selectedTeacher!)]
                          : teachersList.map((eachTeacher) => eachTeacherFeedbackWidget(eachTeacher)).toList())),
            ),
    );
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(20),
        child: _isSectionPickerOpen
            ? ClayContainer(
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 2,
                borderRadius: 10,
                child: _selectSectionExpanded(),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget _buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.vibrate();
          if (_isLoading) return;
          setState(() {
            if (_selectedSection != null && _selectedSection!.sectionId == section.sectionId) {
              _selectedSection = null;
            } else {
              _selectedSection = section;
            }
            selectedTeacher = null;
            _isSectionPickerOpen = false;
          });
        },
        child: ClayButton(
          depth: 40,
          spread: _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? 0 : 2,
          surfaceColor:
              _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
          parentColor: clayContainerColor(context),
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

  Widget _selectSectionExpanded() {
    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.vibrate();
              if (_isLoading) return;
              setState(() {
                _isSectionPickerOpen = !_isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName}",
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: const Icon(Icons.expand_less),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
            shrinkWrap: true,
            children: sectionsList.map((e) => _buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.vibrate();
        setState(() {
          _isSectionPickerOpen = !_isSectionPickerOpen;
        });
      },
      child: ClayButton(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        height: 60,
        width: 60,
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 15, 5, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    _selectedSection == null ? "Select a section" : "Sections: ${_selectedSection!.sectionName}",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchableDropdownButtonForTeacher() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
          child: DropdownSearch<Teacher>(
            mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
            selectedItem: selectedTeacher == null ? null : teachersList.where((e) => e.teacherId == selectedTeacher?.teacherId).firstOrNull,
            items: teachersList,
            itemAsString: (Teacher? teacher) {
              return teacher == null ? "" : teacher.teacherName ?? "";
            },
            showSearchBox: true,
            dropdownBuilder: (BuildContext context, Teacher? teacher) {
              return buildTeacherWidget(teacher ?? Teacher());
            },
            onChanged: (Teacher? teacher) {
              setState(() {
                selectedTeacher = teacher;
                _selectedSection = null;
              });
            },
            showClearButton: true,
            compareFn: (item, selectedItem) => item?.teacherId == selectedItem?.teacherId,
            dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
            filterFn: (Teacher? teacher, String? key) {
              return teacher!.teacherName!.toLowerCase().contains(key!.toLowerCase());
            },
          ),
        ),
      ),
    );
  }

  Widget buildTeacherWidget(Teacher e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: ListTile(
        leading: Container(
          width: 50,
          padding: const EdgeInsets.all(5),
          child: e.teacherPhotoUrl == null
              ? Image.asset(
                  "assets/images/avatar.png",
                  fit: BoxFit.contain,
                )
              : Image.network(
                  e.teacherPhotoUrl!,
                  fit: BoxFit.contain,
                ),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            e.teacherName ?? "Select a Teacher",
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget eachSectionFeedbackWidget(Section selectedSection) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: true,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              selectedSection.sectionName ?? " - ",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ...tdsList
                .where((eachTds) => eachTds.sectionId == selectedSection.sectionId)
                .map((eachTds) => eachTdsWiseFeedbackWidget(eachTds))
                .toList(),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget eachTeacherFeedbackWidget(Teacher eachTeacher) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: buildTeacherBasicRatingWidget(eachTeacher),
            ),
            const SizedBox(
              height: 20,
            ),
            if (_selectedSection == null &&
                selectedTeacher != null &&
                allTeacherWiseFeedbackPlotBeans
                    .where((eachTeacherWiseFeedbackPlot) => eachTeacherWiseFeedbackPlot.teacherId == selectedTeacher!.teacherId)
                    .isNotEmpty)
              eachFeedbackGraph(allTeacherWiseFeedbackPlotBeans
                  .where((eachTeacherWiseFeedbackPlot) => eachTeacherWiseFeedbackPlot.teacherId == selectedTeacher!.teacherId)
                  .first),
            if (_selectedSection == null &&
                selectedTeacher != null &&
                allTeacherWiseFeedbackPlotBeans
                    .where((eachTeacherWiseFeedbackPlot) => eachTeacherWiseFeedbackPlot.teacherId == selectedTeacher!.teacherId)
                    .isNotEmpty)
              const SizedBox(
                height: 20,
              ),
            for (TeacherDealingSection eachTds in tdsList
                .where((eachTds) =>
                    (selectedTeacher != null && selectedTeacher!.teacherId == eachTeacher.teacherId && eachTds.teacherId == eachTeacher.teacherId) ||
                    (expandedTeacher != null && expandedTeacher!.teacherId == eachTeacher.teacherId && eachTds.teacherId == eachTeacher.teacherId))
                .toList()) ...[
              eachTdsWiseFeedbackWidget(eachTds),
              const SizedBox(
                height: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildTeacherBasicRatingWidget(Teacher eachTeacher) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (expandedTeacher != null && expandedTeacher!.teacherId == eachTeacher.teacherId) {
            expandedTeacher = null;
          } else {
            expandedTeacher = eachTeacher;
          }
        });
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              eachTeacher.teacherName ?? "-",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "Cumulative\nAverage\nRating\n${doubleToStringAsFixed(allTdsWiseFeedbackPlotBeans.where((e) => e.teacherId == eachTeacher.teacherId).firstOrNull?.cumulativeAverageRating ?? 0.0)}",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget eachTdsWiseFeedbackWidget(TeacherDealingSection eachTds) {
    if (eachTds.status != "active" && allTdsWiseFeedbackPlotBeans.where((e) => e.tdsId == eachTds.tdsId).isEmpty) {
      return Container();
    }
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: ClayContainer(
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              depth: 40,
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text("Subject: ${eachTds.subjectName}"),
                    const SizedBox(
                      height: 10,
                    ),
                    if (_selectedSection == null) Text("Section: ${eachTds.sectionName}"),
                    if (_selectedSection != null) Text("Section: ${eachTds.teacherName}"),
                    const SizedBox(
                      height: 10,
                    ),
                    allTdsWiseFeedbackPlotBeans.where((e) => e.tdsId == eachTds.tdsId).isEmpty
                        ? const Center(child: Text("No feedback given so far.."))
                        : eachFeedbackGraph(allTdsWiseFeedbackPlotBeans.where((e) => e.tdsId == eachTds.tdsId).first),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget eachFeedbackGraph(FeedbackPlotBean plot) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          height: 200,
          width: 1.5 * 35 * (plot.dateWiseFeedbackBeans ?? []).map((e) => e!).toList().length,
          child: charts.BarChart(
            [
              charts.Series<DateWiseFeedbackBean, String>(
                id: 'feedback',
                colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                domainFn: (DateWiseFeedbackBean plotPoint, _) => convertDateToDDMMMYYYY(plotPoint.date),
                measureFn: (DateWiseFeedbackBean plotPoint, _) => plotPoint.avgRating ?? 0.0,
                data: (plot.dateWiseFeedbackBeans ?? []).map((e) => e!).toList(),
                strokeWidthPxFn: (DateWiseFeedbackBean plotPoint, _) => 1.0,
                labelAccessorFn: (DateWiseFeedbackBean plotPoint, _) => "${plotPoint.noOfStudents ?? 0}",
                insideLabelStyleAccessorFn: (DateWiseFeedbackBean plotPoint, _) => charts.TextStyleSpec(
                  color: charts.MaterialPalette.yellow.shadeDefault.darker,
                ),
                outsideLabelStyleAccessorFn: (DateWiseFeedbackBean plotPoint, _) => charts.TextStyleSpec(
                  color: charts.MaterialPalette.red.shadeDefault.darker,
                ),
              )
            ],
            animate: true,
            animationDuration: const Duration(milliseconds: 1000),
            barRendererDecorator: charts.BarLabelDecorator<String>(),
            primaryMeasureAxis: charts.NumericAxisSpec(
              showAxisLine: true,
              renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: 10,
                  color: isDarkTheme(context) ? charts.MaterialPalette.white : charts.MaterialPalette.black,
                ),
                minimumPaddingBetweenLabelsPx: 10,
                axisLineStyle: const charts.LineStyleSpec(thickness: 1),
                lineStyle: charts.LineStyleSpec(
                  thickness: 0,
                  color: charts.MaterialPalette.gray.shadeDefault,
                  dashPattern: const [1, 0, 1],
                ),
              ),
              tickProviderSpec: const charts.StaticNumericTickProviderSpec(
                [
                  charts.TickSpec(5.0),
                  charts.TickSpec(4.0),
                  charts.TickSpec(3.0),
                  charts.TickSpec(2.0),
                  charts.TickSpec(1.0),
                  charts.TickSpec(0.0),
                ],
              ),
            ),
            domainAxis: charts.OrdinalAxisSpec(
              showAxisLine: true,
              renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: 10,
                  color: isDarkTheme(context) ? charts.MaterialPalette.white : charts.MaterialPalette.black,
                ),
                axisLineStyle: const charts.LineStyleSpec(thickness: 1),
                lineStyle: const charts.LineStyleSpec(
                  thickness: 0,
                  color: charts.MaterialPalette.transparent,
                  dashPattern: [1, 0],
                ),
              ),
            ),
            defaultRenderer: charts.BarRendererConfig(
              maxBarWidthPx: 50,
              cornerStrategy: const charts.ConstCornerStrategy(3),
              fillPattern: charts.FillPatternType.solid,
              barRendererDecorator: charts.BarLabelDecorator(
                labelPosition: charts.BarLabelPosition.outside,
                labelAnchor: charts.BarLabelAnchor.end,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
