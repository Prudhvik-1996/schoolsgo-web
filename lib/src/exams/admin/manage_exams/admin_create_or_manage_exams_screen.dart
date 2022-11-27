import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/decimal_text_input_formatter.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/manage_exams/widgets/date_time_subject_max_marks.dart';
import 'package:schoolsgo_web/src/exams/admin/manage_exams/widgets/section_picker_widget.dart';
import 'package:schoolsgo_web/src/exams/model/admin_exams.dart';
import 'package:schoolsgo_web/src/exams/model/constants.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminCreateOrManageExamsScreen extends StatefulWidget {
  const AdminCreateOrManageExamsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/manage_exams";

  @override
  _AdminCreateOrManageExamsScreenState createState() => _AdminCreateOrManageExamsScreenState();
}

class _AdminCreateOrManageExamsScreenState extends State<AdminCreateOrManageExamsScreen> {
  bool _isLoading = true;

  List<AdminExamBean> allAvailableExams = [];
  late AdminExamBean newExam;
  List<MarkingAlgorithmBean> markingAlgorithms = [];

  List<Section> _sectionsList = [];
  List<Subject> subjectsList = [];
  List<TeacherDealingSection> tdsList = [];

  bool isCreateNew = true;
  final PageController _createNewPageController = PageController();

  List<Section> selectedSectionsList = [];

  List<DateTimeSubjectMaxMarks> dateTimeSubjectMaxMarks = [];
  DateTimeSubjectMaxMarks newSlot = DateTimeSubjectMaxMarks();

  List<AdminExamBean> internals = [];
  AdminExamBean? newInternal;
  TextEditingController weightageEditingController = TextEditingController();

  InternalsComputationCode internalsComputationCodeForNewExam = InternalsComputationCode.A;
  MarkingAlgorithmBean? selectedMarkingAlgorithm;
  MarkingSchemeCode newMarkingSchemeCode = MarkingSchemeCode.B;

  AdminExamBean? _selectedExamBean;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      newExam = AdminExamBean(
        schoolId: widget.adminProfile.schoolId,
        agent: widget.adminProfile.userId,
        status: "active",
        examType: "TERM",
      );
    });

    GetAdminExamsResponse getAdminExamsResponse = await getAdminExams(GetAdminExamsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getAdminExamsResponse.httpStatus != "OK" || getAdminExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        allAvailableExams = getAdminExamsResponse.adminExamBeanList!.map((e) => e!).toList();
      });
    }

    GetMarkingAlgorithmsResponse getMarkingAlgorithmsResponse = await getMarkingAlgorithms(
      GetMarkingAlgorithmsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getMarkingAlgorithmsResponse.httpStatus == "OK" && getMarkingAlgorithmsResponse.responseStatus == "success") {
      setState(() {
        markingAlgorithms = getMarkingAlgorithmsResponse.markingAlgorithmBeanList!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }

    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }

    GetSubjectsResponse getSubjectsResponse = await getSubjects(
      GetSubjectsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSubjectsResponse.httpStatus == "OK" && getSubjectsResponse.responseStatus == "success") {
      setState(() {
        subjectsList = getSubjectsResponse.subjects!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
      status: "active",
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
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
        title: const Text("Manage Exams"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : isCreateNew
              ? PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _createNewPageController,
                  children: [
                    _firstScreen(),
                    _secondScreen(),
                  ],
                )
              : Stack(
                  children: [
                    _getAllExamsLandscapeScreen(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: allAvailableExams.map((e) => e.isEditMode).contains(true) || widget.adminProfile.isMegaAdmin
                          ? Container()
                          : Container(
                              margin: const EdgeInsets.all(15),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isCreateNew = true;
                                  });
                                },
                                child: ClayButton(
                                  depth: 40,
                                  surfaceColor: clayContainerColor(context),
                                  parentColor: clayContainerColor(context),
                                  spread: 1,
                                  borderRadius: 100,
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    child: const Icon(Icons.add),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _firstScreen() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        child: Column(
          children: [
            _newExamHeaderRow(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _examNameTextBox(),
                  MultipleSectionPickerWidget(
                    selectedSectionsList: selectedSectionsList,
                    availableSections: _sectionsList,
                  ),
                  _pickExamStartDate(),
                  _getExamTimeTable(),
                  _addInternals(),
                  if (internals.length > 1) _internalsComputationCode(),
                  _chooseMarkingAlgorithmAndScheme(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _proceedToNextScreenButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _newExamHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Center(
            child: Text(
              "Create New Exam",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: closeNewExamsButton(),
        ),
      ],
    );
  }

  GestureDetector closeNewExamsButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isCreateNew = false;
        });
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: const Icon(Icons.close),
        ),
      ),
    );
  }

  Container _examNameTextBox() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: newExam.examNameEditingController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Exam Name',
          hintText: 'Exam',
        ),
        onChanged: (String newExamName) {
          setState(() {
            newExam.examName = newExamName;
          });
        },
      ),
    );
  }

  Widget _pickExamStartDate() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              DateTime? _newDate = await showDatePicker(
                context: context,
                initialDate: convertYYYYMMDDFormatToDateTime(newExam.examStartDate),
                firstDate: DateTime(2021),
                lastDate: DateTime(2031),
                helpText: "Pick exam start date",
              );
              if (_newDate == null || _newDate == convertYYYYMMDDFormatToDateTime(newExam.examStartDate)) return;
              setState(() {
                newExam.examStartDate = convertDateTimeToYYYYMMDDFormat(_newDate);
              });
            },
            child: ClayButton(
              depth: 20,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 2,
              borderRadius: 10,
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Text(
                  "Exam Start Date: " + convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(newExam.examStartDate)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _proceedToNextScreenButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () {
          if (newExam.examName == null || newExam.examName!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please enter exam name to proceed.."),
              ),
            );
            return;
          }
          if (dateTimeSubjectMaxMarks.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please fill in the exam time slots to proceed.."),
              ),
            );
            return;
          }
          if (internals.isNotEmpty && weightageEditingController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please fill in Internals Weightage to proceed.."),
              ),
            );
            return;
          }
          setState(() {
            newExam = AdminExamBean(
              status: "active",
              schoolId: widget.adminProfile.schoolId,
              agent: widget.adminProfile.userId,
              examName: newExam.examName,
              examId: null,
              examStartDate: convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(newExam.examStartDate)),
              examType: "TERM",
              examSectionMapBeanList: selectedSectionsList
                  .map(
                    (Section section) => ExamSectionMapBean(
                      examId: null,
                      examSectionMapId: null,
                      markingAlgorithmId: selectedMarkingAlgorithm == null ? null : selectedMarkingAlgorithm!.markingAlgorithmId,
                      markingAlgorithmName: selectedMarkingAlgorithm == null ? null : selectedMarkingAlgorithm!.algorithmName,
                      sectionId: section.sectionId,
                      sectionName: section.sectionName,
                      markingSchemeCode: newMarkingSchemeCode.toShortString(),
                      status: "active",
                      examTdsMapBeanList: tdsList
                          .where((e) => e.sectionId == section.sectionId)
                          .map((TeacherDealingSection tds) {
                            if (dateTimeSubjectMaxMarks.map((e) => e.subject!.subjectId).contains((tds.subjectId))) {
                              List<DateTimeSubjectMaxMarks> slots =
                                  dateTimeSubjectMaxMarks.where((e) => e.subject!.subjectId == tds.subjectId).toList();
                              return slots
                                  .map((slot) => ExamTdsMapBean(
                                        examTdsMapId: null,
                                        examId: null,
                                        examName: newExam.examName,
                                        sectionId: section.sectionId,
                                        sectionName: section.sectionName,
                                        maxMarks: tds.subjectId == slot.subject!.subjectId ? slot.maxMarks!.toInt() : null,
                                        subjectId: tds.subjectId,
                                        subjectName: tds.subjectName,
                                        examTdsDate: tds.subjectId == slot.subject!.subjectId ? convertDateTimeToYYYYMMDDFormat(slot.date) : null,
                                        startTime: tds.subjectId == slot.subject!.subjectId ? timeOfDayToHHMMSS(slot.startTime!) : null,
                                        endTime: tds.subjectId == slot.subject!.subjectId ? timeOfDayToHHMMSS(slot.endTime!) : null,
                                        internalsComputationCode: internalsComputationCodeForNewExam.toShortString(),
                                        tdsId: tds.tdsId,
                                        teacherId: tds.teacherId,
                                        teacherName: tds.teacherName,
                                        status: "active",
                                        internalsWeightage: internals.isNotEmpty ? double.parse(weightageEditingController.text) : null,
                                        internalExamTdsMapBeanList: internals
                                            .map((AdminExamBean eachAdminExamBean) => allAvailableExams
                                                .where((AdminExamBean eachExam) => eachExam.examId == eachAdminExamBean.examId)
                                                .map((AdminExamBean eachExam) => eachExam.examSectionMapBeanList ?? [])
                                                .expand((List<ExamSectionMapBean?> eachList) => eachList)
                                                .where((ExamSectionMapBean? eachExamSectionMapBean) =>
                                                    eachExamSectionMapBean != null && eachExamSectionMapBean.sectionId == section.sectionId)
                                                .where((ExamSectionMapBean? eachExamSectionMapBean) => eachExamSectionMapBean != null)
                                                .map((ExamSectionMapBean? eachExamSectionMapBean) => eachExamSectionMapBean!)
                                                .map((ExamSectionMapBean e) => e.examTdsMapBeanList ?? [])
                                                .map((List<ExamTdsMapBean?>? eachExamTdsMapBeanList) => eachExamTdsMapBeanList ?? [])
                                                .expand((i) => i)
                                                .where((ExamTdsMapBean? eachExamTdsMapBean) => eachExamTdsMapBean != null)
                                                .map((ExamTdsMapBean? eachExamTdsMapBean) => eachExamTdsMapBean!)
                                                .where((ExamTdsMapBean eachInternalTdsMapBean) => eachInternalTdsMapBean.tdsId == tds.tdsId)
                                                .map((ExamTdsMapBean eachInternalTdsMapBean) => InternalExamTdsMapBean(
                                                      internalExamId: eachInternalTdsMapBean.examId,
                                                      internalExamMapTdsId: eachInternalTdsMapBean.examTdsMapId,
                                                      internalNumber: internals.indexOf(eachAdminExamBean) + 1,
                                                      teacherName: eachInternalTdsMapBean.teacherName,
                                                      teacherId: eachInternalTdsMapBean.teacherId,
                                                      tdsId: eachInternalTdsMapBean.tdsId,
                                                      status: "active",
                                                      startTime: eachInternalTdsMapBean.startTime,
                                                      endTime: eachInternalTdsMapBean.endTime,
                                                      examTdsDate: eachInternalTdsMapBean.examTdsDate,
                                                      subjectId: eachInternalTdsMapBean.subjectId,
                                                      subjectName: eachInternalTdsMapBean.subjectName,
                                                      sectionId: eachInternalTdsMapBean.sectionId,
                                                      sectionName: eachInternalTdsMapBean.sectionName,
                                                      examName: eachAdminExamBean.examName,
                                                      maxMarks: eachInternalTdsMapBean.maxMarks,
                                                      examId: null,
                                                      internalExamName: eachInternalTdsMapBean.examName,
                                                      examTdsMapId: null,
                                                    ))
                                                .toList())
                                            .expand((List<InternalExamTdsMapBean> i) => i)
                                            .toList(),
                                      ))
                                  .toList();
                            } else {
                              return [
                                ExamTdsMapBean(
                                  examTdsMapId: null,
                                  examId: null,
                                  examName: newExam.examName,
                                  sectionId: section.sectionId,
                                  sectionName: section.sectionName,
                                  maxMarks: null,
                                  subjectId: tds.subjectId,
                                  subjectName: tds.subjectName,
                                  examTdsDate: null,
                                  startTime: null,
                                  endTime: null,
                                  internalsComputationCode: internalsComputationCodeForNewExam.toShortString(),
                                  tdsId: tds.tdsId,
                                  teacherId: tds.teacherId,
                                  teacherName: tds.teacherName,
                                  status: "active",
                                  internalExamTdsMapBeanList: [],
                                )
                              ];
                            }
                          })
                          .expand((i) => i)
                          .toList(),
                    ),
                  )
                  .toList(),
            );
          });
          _createNewPageController.nextPage(
            duration: const Duration(
              milliseconds: 1000,
            ),
            curve: Curves.easeIn,
          );
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: Colors.blue.shade300,
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text("Continue"),
                      Icon(Icons.arrow_forward_ios_rounded),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _getExamTimeTable() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
              _getTableHeaderRow(),
              for (DateTimeSubjectMaxMarks slot in dateTimeSubjectMaxMarks) _getSlotReadModeWidget(slot),
            ] +
            [
              _getNewSlotWidget(),
            ],
      ),
    );
  }

  Row _getTableHeaderRow() {
    return Row(
      children: const [
        Expanded(
          flex: 3,
          child: Center(
            child: Text("Date"),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text("Start Time"),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text("End Time"),
          ),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: Text("Subject"),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text("Max Marks"),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Text(""),
          ),
        ),
      ],
    );
  }

  Widget _getSlotReadModeWidget(DateTimeSubjectMaxMarks slot) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  slot.date != null ? convertDateTimeToDDMMYYYYFormat(slot.date!) : "-",
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  slot.startTime == null ? "-" : timeOfDayToString(slot.startTime!),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  slot.endTime == null ? "-" : timeOfDayToString(slot.endTime!),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  slot.subject!.subjectName ?? "-",
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  slot.maxMarks!.toString(),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              setState(() {
                dateTimeSubjectMaxMarks.remove(
                  slot,
                );
              });
            },
            child: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getNewSlotWidget() {
    DateTime defaultSlotDate = convertYYYYMMDDFormatToDateTime(newExam.examStartDate);
    if (dateTimeSubjectMaxMarks.map((e) => e.date).where((e) => e != null).isNotEmpty) {
      List<DateTime> x = dateTimeSubjectMaxMarks.map((e) => e.date!).toSet().toList();
      defaultSlotDate = x.reversed.first;
    }
    List<Subject> _availableSubjectsList =
        subjectsList.where((e) => !dateTimeSubjectMaxMarks.map((e) => e.subject!.subjectId).contains(e.subjectId)).toList();
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _slotDatePicker(
            defaultSlotDate,
          ),
        ),
        Expanded(
          flex: 2,
          child: _slotStartTimePicker(),
        ),
        Expanded(
          flex: 2,
          child: _slotEndTimePicker(),
        ),
        Expanded(
          flex: 3,
          child: _slotSubjectPicker(
            _availableSubjectsList,
          ),
        ),
        Expanded(
          flex: 2,
          child: _slotMaxMarksEditor(),
        ),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              _addNewDateTimeSubjectMaxMarks(defaultSlotDate);
            },
            child: const Icon(
              Icons.add_circle_outline,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  void _addNewDateTimeSubjectMaxMarks(DateTime defaultSlotDate) {
    if (newSlot.startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Start Time is a mandatory field.."),
        ),
      );
      return;
    }
    if (newSlot.endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("End Time is a mandatory field.."),
        ),
      );
      return;
    }
    if (newSlot.subject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Subject is a mandatory field.."),
        ),
      );
      return;
    }
    if (newSlot.maxMarks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Max marks is a mandatory field.."),
        ),
      );
      return;
    }
    setState(() {
      newSlot.date ??= defaultSlotDate;
      dateTimeSubjectMaxMarks.add(
        newSlot,
      );
      newSlot = DateTimeSubjectMaxMarks();
      dateTimeSubjectMaxMarks.sort();
    });
  }

  Widget _slotDatePicker(
    DateTime defaultSlotDate,
  ) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: newSlot.date ?? defaultSlotDate,
            firstDate: DateTime(2021),
            lastDate: DateTime(2031),
            helpText: "Pick exam date",
          );
          if (_newDate == null || _newDate == newSlot.date) return;
          setState(() {
            newSlot.date = _newDate;
          });
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  convertDateTimeToDDMMYYYYFormat(newSlot.date ?? defaultSlotDate),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slotStartTimePicker() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          TimeOfDay? _startTimePicker = await showTimePicker(
            context: context,
            initialTime: newSlot.startTime ?? const TimeOfDay(hour: 0, minute: 0),
          );
          if (_startTimePicker == null) return;
          setState(() {
            newSlot.startTime = _startTimePicker;
          });
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  newSlot.startTime == null ? "-" : timeOfDayToString(newSlot.startTime!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slotEndTimePicker() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          if (newSlot.startTime == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("First pick start time to proceed.."),
              ),
            );
            return;
          }
          TimeOfDay? _endTimePicker = await showTimePicker(
            context: context,
            initialTime: newSlot.endTime ?? newSlot.startTime ?? const TimeOfDay(hour: 0, minute: 0),
          );
          if (_endTimePicker == null) return;
          if ((_endTimePicker.hour * 60 * 60 + _endTimePicker.minute * 60) < (newSlot.startTime!.hour * 60 * 60 + newSlot.startTime!.minute * 60)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("End time must be greater than start time.."),
              ),
            );
            return;
          }
          setState(() {
            newSlot.endTime = _endTimePicker;
          });
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  newSlot.endTime == null ? "-" : timeOfDayToString(newSlot.endTime!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slotSubjectPicker(
    List<Subject> availableSubjectsList,
  ) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: DropdownButton<Subject>(
          isExpanded: true,
          underline: Container(),
          items: availableSubjectsList
              .map(
                (Subject e) => DropdownMenuItem(
                  value: e,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        (e.subjectName ?? "-").capitalize(),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
          value: newSlot.subject,
          onChanged: (Subject? newValue) {
            setState(() {
              newSlot.subject = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _slotMaxMarksEditor() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Center(
          child: TextField(
            controller: newSlot.maxMarksController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            textAlign: TextAlign.center,
            onChanged: (String e) {
              setState(() {
                newSlot.maxMarks = double.tryParse(e) ?? 0.0;
              });
            },
            style: const TextStyle(
              fontSize: 12,
            ),
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ),
    );
  }

  Widget _addInternals() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: internals.map((AdminExamBean e) => _internalsRow(e)).toList() + [_newInternalsRow()],
          ),
        ),
        if (internals.isNotEmpty)
          Expanded(
            child: _inputInternalsWeightage(),
          ),
      ]),
    );
  }

  Widget _internalsRow(AdminExamBean eachInternal) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: ClayContainer(
              depth: 40,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Text('Internal ${internals.indexOf(eachInternal) + 1}: ' + (eachInternal.examName ?? "").capitalize()),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              internals.remove(eachInternal);
            });
          },
          child: Container(
            margin: const EdgeInsets.all(20),
            child: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _newInternalsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: ClayContainer(
              depth: 40,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              child: DropdownButton<AdminExamBean>(
                isExpanded: true,
                underline: Container(),
                items: allAvailableExams
                    .where((eachExam) => !internals.map((e) => e.examId).contains(eachExam.examId))
                    .map(
                      (AdminExamBean e) => DropdownMenuItem(
                        value: e,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              (e.examName ?? "-").capitalize(),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                value: newInternal,
                onChanged: (AdminExamBean? newValue) {
                  setState(() {
                    newInternal = newValue;
                  });
                },
                hint: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: const Text('Choose Internal Exam'),
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (newInternal == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Select an internal to add.."),
                ),
              );
            }
            setState(() {
              internals.add(newInternal!);
              newInternal = null;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(20),
            child: const Icon(
              Icons.add_circle_outline,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputInternalsWeightage() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(5),
          child: Center(
            child: TextField(
              controller: weightageEditingController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                label: Text('Weightage (%)'),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              ),
              inputFormatters: <TextInputFormatter>[DecimalTextInputFormatter(decimalRange: 2)],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ),
      ),
    );
  }

  Widget _internalsComputationCode() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile(
              title: const Text("Compute average of above internals in the final score"),
              value: InternalsComputationCode.A,
              groupValue: internalsComputationCodeForNewExam,
              onChanged: (InternalsComputationCode? value) {
                setState(() {
                  internalsComputationCodeForNewExam = value!;
                });
              },
            ),
          ),
          Expanded(
            child: RadioListTile(
              title: const Text("Compute best of above internals in the final score"),
              value: InternalsComputationCode.B,
              groupValue: internalsComputationCodeForNewExam,
              onChanged: (InternalsComputationCode? value) {
                setState(() {
                  internalsComputationCodeForNewExam = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chooseMarkingAlgorithmAndScheme() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: ClayContainer(
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: DropdownButton<MarkingAlgorithmBean>(
                    isExpanded: true,
                    underline: Container(),
                    items: markingAlgorithms
                        .map(
                          (MarkingAlgorithmBean e) => DropdownMenuItem(
                            value: e,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  (e.algorithmName ?? "-").capitalize(),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    value: selectedMarkingAlgorithm,
                    hint: const Text("Choose Marking Algorithm"),
                    onChanged: (MarkingAlgorithmBean? newValue) {
                      setState(() {
                        selectedMarkingAlgorithm = newValue;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            child: const Icon(Icons.clear),
            onTap: () {
              setState(() {
                selectedMarkingAlgorithm = null;
              });
            },
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: ClayContainer(
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    children: [
                      const Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Choose default marking scheme",
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _markingSchemeButton("Marks"),
                          ),
                          Expanded(
                            child: _markingSchemeButton("Grade"),
                          ),
                          Expanded(
                            child: _markingSchemeButton("GPA"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _markingSchemeButton(String type) {
    Color color = clayContainerColor(context);
    bool isMarksForNewExam = newMarkingSchemeCode.value[0] == "T";
    bool isGradeForNewExam = newMarkingSchemeCode.value[1] == "T";
    bool isGpaForNewExam = newMarkingSchemeCode.value[2] == "T";
    if ((type == "Marks" && isMarksForNewExam) || (type == "Grade" && isGradeForNewExam) || (type == "GPA" && isGpaForNewExam)) {
      color = Colors.blue.shade300;
    }
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          switch (type) {
            case "Marks":
              setState(() {
                isMarksForNewExam = !isMarksForNewExam;
              });
              break;
            case "Grade":
              if (selectedMarkingAlgorithm == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select a marking algorithm to opt in for Grades"),
                  ),
                );
                return;
              }
              setState(() {
                isGradeForNewExam = !isGradeForNewExam;
              });
              break;
            case "GPA":
              if (selectedMarkingAlgorithm == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select a marking algorithm to opt in for GPA"),
                  ),
                );
                return;
              }
              setState(() {
                isGpaForNewExam = !isGpaForNewExam;
              });
              break;
          }
          setState(() {
            newMarkingSchemeCode = fromMarkingSchemeCodeBooleans(isMarksForNewExam, isGradeForNewExam, isGpaForNewExam);
          });
        },
        child: Center(
          child: ClayButton(
            depth: 40,
            surfaceColor: color,
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 100,
            child: Container(
              margin: const EdgeInsets.all(5),
              child: Center(
                child: MediaQuery.of(context).orientation == Orientation.landscape
                    ? Text(type)
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(type),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _secondScreen() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _examNameTextBox(),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: closeNewExamsButton(),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  for (ExamSectionMapBean eachSectionMapBean in (newExam.examSectionMapBeanList ?? [])
                      .where((e) => e != null)
                      .map((e) => e!)
                      .where((e) => (e.examTdsMapBeanList ?? []).isNotEmpty))
                    _buildSectionWiseExamBeans(eachSectionMapBean),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: goToPreviousPageButton(),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: buildCreateNewExamsButton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWiseExamBeans(ExamSectionMapBean examSectionMapBean) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(8),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "${examSectionMapBean.sectionName}",
                        style: const TextStyle(
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _markingAlgorithmsAndSchemeForSection(examSectionMapBean),
                      ],
                    ),
                  )
                ],
              ),
              for (TeacherDealingSection eachTds in examSectionMapBean.examId == null
                  ? tdsList.where((eachTds) => eachTds.sectionId == examSectionMapBean.sectionId)
                  : (examSectionMapBean.examTdsMapBeanList ?? []).map((e) => e!).map((e) => TeacherDealingSection(
                        teacherName: e.teacherName,
                        teacherId: e.teacherId,
                        tdsId: e.tdsId,
                        sectionName: e.subjectName,
                        sectionId: e.sectionId,
                        subjectName: e.subjectName,
                        subjectId: e.subjectId,
                      )))
                _buildTdsWiseExamWidget(eachTds, examSectionMapBean),
            ],
          ),
        ),
      ),
    );
  }

  Widget _markingAlgorithmsAndSchemeForSection(ExamSectionMapBean examSectionMapBean) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Column(
        children: [
          chooseMarkingAlgorithmForSection(examSectionMapBean),
          chooseGradingSchemeForSection(examSectionMapBean),
        ],
      ),
    );
  }

  Container chooseGradingSchemeForSection(ExamSectionMapBean examSectionMapBean) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Choose default marking scheme",
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _markingSchemeButtonForSection(examSectionMapBean, "Marks"),
              ),
              Expanded(
                child: _markingSchemeButtonForSection(examSectionMapBean, "Grade"),
              ),
              Expanded(
                child: _markingSchemeButtonForSection(examSectionMapBean, "GPA"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _markingSchemeButtonForSection(ExamSectionMapBean examSectionMapBean, String type, {bool disabled = false}) {
    Color color = clayContainerColor(context);
    MarkingSchemeCode? x = fromMarkingSchemeCodeString(examSectionMapBean.markingSchemeCode ?? "-");
    bool _isMarksForBean = x == null ? false : x.value[0] == "T";
    bool _isGradeForBean = x == null ? false : x.value[1] == "T";
    bool _isGpaForBean = x == null ? false : x.value[2] == "T";
    if ((type == "Marks" && _isMarksForBean) || (type == "Grade" && _isGradeForBean) || (type == "GPA" && _isGpaForBean)) {
      color = Colors.blue.shade300;
    }
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          if (disabled) return;
          switch (type) {
            case "Marks":
              _isMarksForBean = !_isMarksForBean;
              break;
            case "Grade":
              if (examSectionMapBean.markingAlgorithmId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select a marking algorithm to opt in for Grades"),
                  ),
                );
                return;
              }
              _isGradeForBean = !_isGradeForBean;
              break;
            case "GPA":
              if (examSectionMapBean.markingAlgorithmId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select a marking algorithm to opt in for GPA"),
                  ),
                );
                return;
              }
              _isGpaForBean = !_isGpaForBean;
              break;
          }
          setState(() {
            examSectionMapBean.markingSchemeCode = fromMarkingSchemeCodeBooleans(_isMarksForBean, _isGradeForBean, _isGpaForBean).toShortString();
          });
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: color,
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 100,
          child: Container(
            width: 15,
            margin: const EdgeInsets.all(5),
            child: Center(
              child: MediaQuery.of(context).orientation == Orientation.landscape
                  ? Text(type)
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(type),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Container chooseMarkingAlgorithmForSection(ExamSectionMapBean examSectionMapBean) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: DropdownButton<MarkingAlgorithmBean>(
              isExpanded: true,
              underline: Container(),
              items: markingAlgorithms
                  .map(
                    (MarkingAlgorithmBean e) => DropdownMenuItem(
                      value: e,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            (e.algorithmName ?? "-").capitalize(),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              value: markingAlgorithms
                      .where((eachMarkingAlgorithm) => examSectionMapBean.markingAlgorithmId == eachMarkingAlgorithm.markingAlgorithmId)
                      .isNotEmpty
                  ? markingAlgorithms
                      .where((eachMarkingAlgorithm) => examSectionMapBean.markingAlgorithmId == eachMarkingAlgorithm.markingAlgorithmId)
                      .first
                  : null,
              hint: const Text("Choose Marking Algorithm"),
              onChanged: (MarkingAlgorithmBean? newValue) {
                setState(() {
                  examSectionMapBean.markingAlgorithmId = newValue?.markingAlgorithmId;
                  examSectionMapBean.markingAlgorithmName = newValue?.algorithmName;
                  examSectionMapBean.markingAlgorithmRangeBeanList = newValue?.markingAlgorithmRangeBeanList ?? [];
                  examSectionMapBean.markingSchemeCode = MarkingSchemeCode.B.toShortString();
                });
              },
            ),
          ),
          InkWell(
            child: const Icon(Icons.clear),
            onTap: () {
              setState(() {
                examSectionMapBean.markingAlgorithmId = null;
                examSectionMapBean.markingAlgorithmName = null;
                examSectionMapBean.markingAlgorithmRangeBeanList = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTdsWiseExamWidget(TeacherDealingSection eachTds, ExamSectionMapBean examSectionMapBean) {
    ExamTdsMapBean? examTdsMapBean = (examSectionMapBean.examTdsMapBeanList ?? []).map((e) => e?.tdsId).contains(eachTds.tdsId)
        ? (examSectionMapBean.examTdsMapBeanList ?? []).where((e) => e != null && e.tdsId == eachTds.tdsId).first
        : null;
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        (eachTds.subjectName ?? "-").capitalize(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _slotDatePickerForTds(examTdsMapBean!),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _slotMaxMarksEditorForTds(examTdsMapBean),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        (eachTds.teacherName ?? "-").capitalize(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: _slotStartTimePickerForTds(examTdsMapBean),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: _slotEndTimePickerForTds(examTdsMapBean),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              _addInternalsForTds(examTdsMapBean),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addInternalsForTds(ExamTdsMapBean examTdsMapBean) {
    List<Widget> _widgets = [];
    for (InternalExamTdsMapBean eachInternalExamTdsMapBean
        in (examTdsMapBean.internalExamTdsMapBeanList ?? []).where((e) => e != null).map((e) => e!)) {
      _widgets.add(
        Container(
          margin: const EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Internal ${eachInternalExamTdsMapBean.internalNumber}',
                        border: InputBorder.none,
                      ),
                      child: Text(eachInternalExamTdsMapBean.internalExamName ?? "-"),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    (examTdsMapBean.internalExamTdsMapBeanList ?? []).remove(eachInternalExamTdsMapBean);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    }
    List<InternalExamTdsMapBean> _internalTdsMapBeans = allAvailableExams
        .where((e) => e.examId != examTdsMapBean.examId)
        .map((e) => e.examSectionMapBeanList)
        .where((List<ExamSectionMapBean?>? e) => e != null)
        .map((List<ExamSectionMapBean?>? e) => e!)
        .expand((List<ExamSectionMapBean?> i) => i)
        .where((ExamSectionMapBean? e) => e != null)
        .map((ExamSectionMapBean? e) => e!)
        .map((ExamSectionMapBean e) => e.examTdsMapBeanList)
        .where((List<ExamTdsMapBean?>? e) => e != null)
        .map((List<ExamTdsMapBean?>? e) => e!)
        .expand((List<ExamTdsMapBean?> i) => i)
        .where((ExamTdsMapBean? e) => e != null)
        .map((ExamTdsMapBean? e) => e!)
        .where((ExamTdsMapBean e) => e.tdsId == examTdsMapBean.tdsId)
        .map((ExamTdsMapBean e) => InternalExamTdsMapBean(
              maxMarks: e.maxMarks,
              examId: examTdsMapBean.examId,
              internalExamName: e.examName,
              examTdsMapId: examTdsMapBean.examTdsMapId,
              examName: examTdsMapBean.examName,
              sectionName: e.sectionName,
              sectionId: e.sectionId,
              subjectName: e.subjectName,
              subjectId: e.subjectId,
              examTdsDate: e.examTdsDate,
              endTime: e.endTime,
              startTime: e.startTime,
              status: null,
              tdsId: e.tdsId,
              teacherId: e.teacherId,
              teacherName: e.teacherName,
              internalExamId: e.examId,
              internalExamMapTdsId: e.examTdsMapId,
              internalNumber: null,
            ))
        .toList();
    _widgets.add(Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<InternalExamTdsMapBean>(
              isExpanded: true,
              underline: Container(),
              items: _internalTdsMapBeans
                  .map(
                    (InternalExamTdsMapBean e) => DropdownMenuItem(
                      value: e,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            (e.internalExamName ?? "-").capitalize(),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              hint: const Text("Choose internal Exam"),
              onChanged: (InternalExamTdsMapBean? newValue) {
                if (newValue == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Can't add an internal without selecting one.."),
                    ),
                  );
                  return;
                }
                if ((examTdsMapBean.internalExamTdsMapBeanList ?? []).map((e) => e!.internalExamId).contains(newValue.internalExamId)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("This exam has already been added.."),
                    ),
                  );
                  return;
                }
                setState(() {
                  examTdsMapBean.internalExamTdsMapBeanList ??= [];
                  newValue.internalNumber = (examTdsMapBean.internalExamTdsMapBeanList ?? []).length + 1;
                  examTdsMapBean.internalExamTdsMapBeanList!.add(newValue);
                });
              },
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(5),
              child: const Icon(Icons.add_circle_outline, color: Colors.green),
            ),
          ),
        ],
      ),
    ));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 2,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _widgets,
          ),
        ),
        if (_widgets.length > 1)
          const SizedBox(
            width: 15,
          ),
        if (_widgets.length > 1)
          Expanded(
            child: _inputInternalsWeightageForExamTds(examTdsMapBean),
          )
      ],
    );
  }

  Widget _inputInternalsWeightageForExamTds(ExamTdsMapBean examTdsMapBean) {
    return ClayContainer(
      depth: 40,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: TextField(
        controller: examTdsMapBean.internalsWeightageEditingController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          label: Text('Weightage (%)'),
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
        ),
        inputFormatters: <TextInputFormatter>[DecimalTextInputFormatter(decimalRange: 2)],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Widget _slotDatePickerForTds(ExamTdsMapBean examTdsMapBean) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: examTdsMapBean.examTdsDate == null ? DateTime.now() : convertYYYYMMDDFormatToDateTime(examTdsMapBean.examTdsDate!),
            firstDate: DateTime(2021),
            lastDate: DateTime(2031),
            helpText: "${(examTdsMapBean.subjectName ?? "").capitalize()}-${(examTdsMapBean.sectionName ?? "").capitalize()}",
          );
          if (_newDate == null || (examTdsMapBean.examTdsDate != null && _newDate == convertYYYYMMDDFormatToDateTime(examTdsMapBean.examTdsDate!))) {
            return;
          }
          setState(() {
            examTdsMapBean.examTdsDate = convertDateTimeToYYYYMMDDFormat(_newDate);
          });
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                examTdsMapBean.examTdsDate ?? "-",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slotStartTimePickerForTds(ExamTdsMapBean examTdsMapBean) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          TimeOfDay? _startTimePicker = await showTimePicker(
            context: context,
            initialTime: examTdsMapBean.startTime == null ? const TimeOfDay(hour: 0, minute: 0) : formatHHMMSSToTimeOfDay(examTdsMapBean.startTime!),
            helpText: "${(examTdsMapBean.subjectName ?? "").capitalize()}-${(examTdsMapBean.sectionName ?? "").capitalize()}",
          );
          if (_startTimePicker == null) return;
          setState(() {
            examTdsMapBean.startTime = timeOfDayToHHMMSS(_startTimePicker);
          });
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Start Time',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                examTdsMapBean.startTime == null ? "-" : timeOfDayToString(formatHHMMSSToTimeOfDay(examTdsMapBean.startTime!)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slotEndTimePickerForTds(ExamTdsMapBean examTdsMapBean) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          TimeOfDay? _endTimePicker = await showTimePicker(
            context: context,
            initialTime: examTdsMapBean.endTime == null ? const TimeOfDay(hour: 0, minute: 0) : formatHHMMSSToTimeOfDay(examTdsMapBean.endTime!),
            helpText: "${(examTdsMapBean.subjectName ?? "").capitalize()}-${(examTdsMapBean.sectionName ?? "").capitalize()}",
          );
          if (_endTimePicker == null) return;
          setState(() {
            examTdsMapBean.endTime = timeOfDayToHHMMSS(_endTimePicker);
          });
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'End Time',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                examTdsMapBean.endTime == null ? "-" : timeOfDayToString(formatHHMMSSToTimeOfDay(examTdsMapBean.endTime!)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slotMaxMarksEditorForTds(ExamTdsMapBean examTdsMapBean) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: examTdsMapBean.maxMarksEditingController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Max marks',
          hintText: 'Marks',
        ),
        onChanged: (String e) {
          setState(() {
            examTdsMapBean.maxMarks = int.tryParse(e) ?? 0;
          });
        },
        style: const TextStyle(
          fontSize: 12,
        ),
        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }

  Widget goToPreviousPageButton() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          _createNewPageController.previousPage(
            duration: const Duration(
              milliseconds: 1000,
            ),
            curve: Curves.easeIn,
          );
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: Colors.blue.shade300,
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_back_ios_rounded),
                Text("Go back"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCreateNewExamsButton() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () async {
          setState(() {
            _isLoading = true;
          });
          CreateOrUpdateExamResponse createOrUpdateExamResponse = await createOrUpdateExam(newExam);
          if (createOrUpdateExamResponse.httpStatus != "OK" || createOrUpdateExamResponse.responseStatus != "success") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Something went wrong! Try again later.."),
              ),
            );
          }
          _loadData();
          setState(() {
            _isLoading = false;
          });
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: Colors.blue.shade300,
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: const Text("Submit"),
          ),
        ),
      ),
    );
  }

  Widget _getAllExamsLandscapeScreen() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildAllExams(),
          ),
          Expanded(
            flex: 5,
            child: _selectedExamBean == null ? Container() : _buildEachExamDetails(_selectedExamBean!),
          ),
        ],
      ),
    );
  }

  Widget _buildAllExams() {
    return ListView(
      controller: ScrollController(),
      children: allAvailableExams.map((e) => _buildEachExamButton(e)).toList(),
    );
  }

  Widget _buildEachExamButton(AdminExamBean eachExam) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () {
          setState(() {
            if (_selectedExamBean == eachExam) {
              _selectedExamBean = null;
            } else {
              _selectedExamBean = eachExam;
            }
          });
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: _selectedExamBean == eachExam ? Colors.blue.shade300 : clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        eachExam.examName ?? "-",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      convertDateToDDMMMYYYEEEE(eachExam.examStartDate),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEachExamDetails(AdminExamBean _selectedExamBean) {
    return !widget.adminProfile.isMegaAdmin && _selectedExamBean.isEditMode
        ? _buildEditableAdminExamBeanWidget(_selectedExamBean)
        : _buildReadableAdminExamBeanWidget(_selectedExamBean);
  }

  Container _buildEditableAdminExamBeanWidget(AdminExamBean examBean) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 40,
        color: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildExamNameTextBoxForAdminExamWidget(examBean),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: _closeButtonForAdminExamWidget(examBean),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  for (ExamSectionMapBean eachSectionMapBean in (examBean.examSectionMapBeanList ?? [])
                      .where((e) => e != null)
                      .map((e) => e!)
                      .where((e) => (e.examTdsMapBeanList ?? []).isNotEmpty))
                    _buildSectionWiseExamBeans(eachSectionMapBean),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: _buildUpdateExamButton(examBean),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateExamButton(AdminExamBean eachExamBean) {
    return InkWell(
      onTap: () async {
        setState(() {
          _isLoading = true;
        });
        CreateOrUpdateExamResponse createOrUpdateExamResponse = await createOrUpdateExam(eachExamBean);
        if (createOrUpdateExamResponse.httpStatus != "OK" || createOrUpdateExamResponse.responseStatus != "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong! Try again later.."),
            ),
          );
        } else {
          _loadData();
        }
        setState(() {
          _isLoading = false;
        });
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: Colors.blue.shade300,
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: const Text("Submit"),
        ),
      ),
    );
  }

  Container _buildExamNameTextBoxForAdminExamWidget(AdminExamBean examBean) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: examBean.examNameEditingController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Exam Name',
          hintText: 'Exam',
        ),
        onChanged: (String newText) {
          setState(() {
            examBean.examName = newText;
          });
        },
      ),
    );
  }

  GestureDetector _closeButtonForAdminExamWidget(AdminExamBean examBean) {
    return GestureDetector(
      onTap: () {
        setState(() {
          examBean.isEditMode = false;
        });
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: const Icon(Icons.close),
        ),
      ),
    );
  }

  Container _buildReadableAdminExamBeanWidget(AdminExamBean _selectedExamBean) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Sections: " + _selectedExamBean.examSectionMapBeanList!.map((e) => e!.sectionName!).toList().join(", "),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  controller: ScrollController(),
                  children: _selectedExamBean.examSectionMapBeanList!
                      .map(
                        (e) => _buildSectionWiseTdsMapWidget(_selectedExamBean, e!),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildSectionWiseTdsMapWidget(AdminExamBean examBean, ExamSectionMapBean eachSectionWiseTdsMapBean) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(eachSectionWiseTdsMapBean.sectionName ?? "-"),
                          _buildMarkingSchemeWidgetForSectionWiseTdsMapBean(eachSectionWiseTdsMapBean),
                        ],
                      ),
                    ),
                  ),
                  widget.adminProfile.isMegaAdmin
                      ? Container()
                      : InkWell(
                          onTap: () {
                            setState(() {
                              examBean.isEditMode = true;
                            });
                          },
                          child: ClayButton(
                            depth: 40,
                            surfaceColor: clayContainerColor(context),
                            parentColor: clayContainerColor(context),
                            spread: 1,
                            borderRadius: 100,
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              child: const Icon(Icons.edit),
                            ),
                          ),
                        ),
                ],
              ),
              for (ExamTdsMapBean eachExamTdsBean in (eachSectionWiseTdsMapBean.examTdsMapBeanList ?? []).map((e) => e!))
                _buildEachExamTdsDetails(eachExamTdsBean),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkingSchemeWidgetForSectionWiseTdsMapBean(ExamSectionMapBean eachSectionWiseTdsMapBean) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Marking Algorithm: ${eachSectionWiseTdsMapBean.markingAlgorithmName ?? "-"}"),
              const SizedBox(
                height: 10,
              ),
              ClayContainer(
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Expanded(
                            child: Text("Results are shown in"),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: _markingSchemeButtonForSection(eachSectionWiseTdsMapBean, "Marks", disabled: true),
                          ),
                          Expanded(
                            child: _markingSchemeButtonForSection(eachSectionWiseTdsMapBean, "Grade", disabled: true),
                          ),
                          Expanded(
                            child: _markingSchemeButtonForSection(eachSectionWiseTdsMapBean, "GPA", disabled: true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEachExamTdsDetails(ExamTdsMapBean eachExamTdsMapBean) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: AnimatedSize(
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 500),
          child: eachExamTdsMapBean.isExpanded
              ? Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExamTdsMapBeanCollapsedWidget(eachExamTdsMapBean),
                      _buildExamTdsMapInternalsWidget(eachExamTdsMapBean),
                    ],
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(15),
                  child: _buildExamTdsMapBeanCollapsedWidget(eachExamTdsMapBean),
                ),
        ),
      ),
    );
  }

  Widget _buildExamTdsMapBeanCollapsedWidget(ExamTdsMapBean eachExamTdsMapBean) {
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(eachExamTdsMapBean.examTdsDate ?? "-"),
          ),
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text((eachExamTdsMapBean.startTime == null ? "-" : formatHHMMSStoHHMMA(eachExamTdsMapBean.startTime!)) +
                "-" +
                (eachExamTdsMapBean.endTime == null ? "-" : formatHHMMSStoHHMMA(eachExamTdsMapBean.endTime!))),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Center(child: Text((eachExamTdsMapBean.subjectName ?? "-").capitalize()))),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Center(child: Text((eachExamTdsMapBean.teacherName ?? "-").capitalize()))),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              eachExamTdsMapBean.isExpanded = !eachExamTdsMapBean.isExpanded;
            });
          },
          child: !eachExamTdsMapBean.isExpanded ? const Icon(Icons.expand_more_rounded) : const Icon(Icons.expand_less_rounded),
        ),
      ],
    );
  }

  Widget _buildExamTdsMapInternalsWidget(ExamTdsMapBean eachExamTdsMapBean) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Internals"),
          if ((eachExamTdsMapBean.internalExamTdsMapBeanList ?? []).isEmpty)
            Container(
              margin: const EdgeInsets.all(15),
              child: const Text("No Internals added for this exam"),
            ),
          for (InternalExamTdsMapBean eachInternalTdsMapBean in (eachExamTdsMapBean.internalExamTdsMapBeanList ?? []).map((e) => e!))
            _buildEachInternalTdsMapBeanWidget(eachInternalTdsMapBean),
          if ((eachExamTdsMapBean.internalExamTdsMapBeanList ?? []).isNotEmpty)
            Container(
              margin: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Marks from internals are computed using ${fromInternalsComputationCodeString(eachExamTdsMapBean.internalsComputationCode ?? "-")?.description ?? "-"}",
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEachInternalTdsMapBeanWidget(InternalExamTdsMapBean eachInternalTdsMapBean) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Row(
        children: [
          Text(
            "Internal ${eachInternalTdsMapBean.internalNumber ?? ""}",
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(eachInternalTdsMapBean.internalExamName ?? "-"),
            ),
          ),
        ],
      ),
    );
  }
}
