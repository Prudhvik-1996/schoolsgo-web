import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/model/admin_exams.dart';
import 'package:schoolsgo_web/src/exams/model/constants.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminManageExamsScreen extends StatefulWidget {
  const AdminManageExamsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/manage_exams";

  @override
  _AdminManageExamsScreenState createState() => _AdminManageExamsScreenState();
}

class _AdminManageExamsScreenState extends State<AdminManageExamsScreen> {
  bool _isLoading = true;
  List<AdminExamBean> _exams = [];

  bool _isCreatingNew = false;
  final PageController _createNewPageController = PageController();
  final TextEditingController _examNameEditingController = TextEditingController();

  bool _isSectionPickerOpen = false;
  List<Section> _sectionsList = [];
  List<Section> _selectedSectionsList = [];
  DateTime _selectedStartDate = DateTime.now();

  List<Subject> _subjectsList = [];
  List<DateTimeSubjectMaxMarks> _timeTableList = [];
  DateTimeSubjectMaxMarks _newSlot = DateTimeSubjectMaxMarks();

  List<TeacherDealingSection> _tdsList = [];

  List<AdminExamBean> _internalsForNewExam = [];
  InternalsComputationCode _internalsComputationCodeForNewExam = InternalsComputationCode.A;
  double? _internalsWeightage;
  final TextEditingController _internalsWeightageEditingController = TextEditingController();

  List<MarkingAlgorithmBean> _markingAlgorithms = [];
  MarkingAlgorithmBean? _selectedMarkingAlgorithm;
  MarkingSchemeCode _markingSchemeCode = MarkingSchemeCode.B;
  bool _isGrade = false;
  bool _isGpa = false;
  bool _isMarks = true;

  AdminExamBean _newExamBean = AdminExamBean();
  AdminExamBean? _selectedExamBean;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _newSlot = DateTimeSubjectMaxMarks(date: _selectedStartDate);
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
        _exams = getAdminExamsResponse.adminExamBeanList!.map((e) => e!).toList();
      });
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
        _subjectsList = getSubjectsResponse.subjects!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }

    GetMarkingAlgorithmsResponse getMarkingAlgorithmsResponse = await getMarkingAlgorithms(
      GetMarkingAlgorithmsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getMarkingAlgorithmsResponse.httpStatus == "OK" && getMarkingAlgorithmsResponse.responseStatus == "success") {
      setState(() {
        _markingAlgorithms = getMarkingAlgorithmsResponse.markingAlgorithmBeanList!.map((e) => e!).toList();
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
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
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
        child: Image.asset('assets/images/eis_loader.gif',
          height: 500,
          width: 500,),
      )
          : _isCreatingNew
          ? createNewExamsWidget()
          : Stack(
        children: [
          _getAllExamsLandscapeScreen(),
          Align(
            alignment: Alignment.bottomRight,
            child: _exams.map((e) => e.isEditMode).contains(true) ? Container() : Container(
              margin: const EdgeInsets.all(15),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isCreatingNew = true;
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
      children: _exams.map((e) => _buildEachExamButton(e)).toList(),
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
    return _selectedExamBean.isEditMode ? _buildEditableAdminExamBeanWidget(_selectedExamBean) :
    _buildReadableAdminExamBeanWidget(_selectedExamBean);
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
                    child: Text("Sections: " + _selectedExamBean.examSectionMapBeanList!.map((e) => e!.sectionName!).toList().join(", "),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  controller: ScrollController(),
                  children: _selectedExamBean.examSectionMapBeanList!.map((e) =>
                      _buildSectionWiseTdsMapWidget(_selectedExamBean, e!),).toList(),
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
                  InkWell(
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
              const SizedBox(height: 10,),
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
          duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
          child: eachExamTdsMapBean.isExpanded ? Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExamTdsMapBeanCollapsedWidget(eachExamTdsMapBean),
                _buildExamTdsMapInternalsWidget(eachExamTdsMapBean),
              ],
            ),
          ) : Container(
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
            child: Text((eachExamTdsMapBean.startTime == null ? "-" : formatHHMMSStoHHMMA(eachExamTdsMapBean.startTime!)) + "-" +
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
              child: const Text ("No Internals added for this exam"),
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
                      "Marks from internals are computed using ${fromInternalsComputationCodeString(
                          eachExamTdsMapBean.internalsComputationCode ?? "-")
                          ?.description ?? "-"}",
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _inputInternalsWeightageForExamTds(ExamTdsMapBean examTdsMapBean) {
    return Container(
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: InputDecorator(
          isFocused: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: "Internals weightage",
            focusColor: Colors.blue,
          ),
          child: TextField(
            autofocus: true,
            keyboardType: TextInputType.text,
            controller: examTdsMapBean.internalsWeightageEditingController,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: (String e) {
              setState(() {
                examTdsMapBean.internalsWeightage = double.tryParse(e);
              });
            },
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
            ],
            textAlign: TextAlign.center,
          ),
        ),),
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

  Widget createNewExamsWidget() {
    return Stack(
      children: [
        PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _createNewPageController,
          children: [
            _firstPageInCreateNewExam(),
            _secondPageInCreateNewExam(),
          ],
        ),
      ],
    );
  }

  Container _firstPageInCreateNewExam() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
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
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _examNameTextBox(),
                  _sectionPicker(),
                  _pickExamStartDate(),
                  _createExamsTimeTable(),
                  _addInternals(),
                  if (_internalsForNewExam.length > 1) _internalsComputationCode(),
                  _markingAlgorithmsAndScheme(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: goToNextPageButton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _secondPageInCreateNewExam() {
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
                  for (ExamSectionMapBean eachSectionMapBean in (_newExamBean.examSectionMapBeanList ?? [])
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
                  child: _buildCreateNewExamsButton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _buildEditableAdminExamBeanWidget(AdminExamBean examBean) {
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
        // CreateOrUpdateExamResponse createOrUpdateExamResponse = await createOrUpdateExam(_newExamBean);
        // if (createOrUpdateExamResponse.httpStatus != "OK" || createOrUpdateExamResponse.responseStatus != "success") {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text("Something went wrong! Try again later.."),
        //     ),
        //   );
        // } else {
        //   _loadData();
        // }
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

  Widget _buildCreateNewExamsButton() {
    return InkWell(
      onTap: () async {
        setState(() {
          _isLoading = true;
        });
        CreateOrUpdateExamResponse createOrUpdateExamResponse = await createOrUpdateExam(_newExamBean);
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
              for (TeacherDealingSection eachTds in examSectionMapBean.examId == null ? _tdsList.where((eachTds) =>
              eachTds.sectionId == examSectionMapBean.sectionId) : (examSectionMapBean.examTdsMapBeanList ?? []).map((e) => e!).map((e) =>
                  TeacherDealingSection(
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

  Widget _buildTdsWiseExamWidget(TeacherDealingSection eachTds, ExamSectionMapBean examSectionMapBean) {
    ExamTdsMapBean? examTdsMapBean = (examSectionMapBean.examTdsMapBeanList ?? []).map((e) => e?.tdsId).contains(eachTds.tdsId)
        ? (examSectionMapBean.examTdsMapBeanList ?? [])
        .where((e) => e != null && e.tdsId == eachTds.tdsId)
        .first
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
    for (InternalExamTdsMapBean eachInternalExamTdsMapBean in (examTdsMapBean.internalExamTdsMapBeanList ?? []).where((e) => e != null).map((
        e) => e!)) {
      _widgets.add(Row(
        children: [
          Expanded(
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Internal ${eachInternalExamTdsMapBean.internalNumber}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                  eachInternalExamTdsMapBean.examName ?? "-"
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
      ),);
    }
    List<InternalExamTdsMapBean> _internalTdsMapBeans = _exams.where((e) => e.examId != examTdsMapBean.examId).map((e) => e.examSectionMapBeanList)
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
        .map((ExamTdsMapBean e) =>
        InternalExamTdsMapBean(
          maxMarks: e.maxMarks,
          examId: examTdsMapBean.examId,
          internalExamName: examTdsMapBean.examName,
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
        .toList()
    ;
    _widgets.add(
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Internal',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: DropdownButton<InternalExamTdsMapBean>(
            isExpanded: true,
            underline: Container(),
            items: _internalTdsMapBeans
                .map(
                  (InternalExamTdsMapBean e) =>
                  DropdownMenuItem(
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
              if ((examTdsMapBean.internalExamTdsMapBeanList ?? []).contains(newValue)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("This exam has already been added.."),
                  ),
                );
                return;
              }
              setState(() {
                examTdsMapBean.internalExamTdsMapBeanList ??= [];
                examTdsMapBean.internalExamTdsMapBeanList!.add(newValue);
              });
            },
          ),
        )
    );
    return
      Row(
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
          if (_widgets.length > 2)
            Expanded(
              flex: 1,
              child: _inputInternalsWeightageForExamTds(examTdsMapBean),
            )
        ],
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
          if (_newDate == null || (examTdsMapBean.examTdsDate != null && _newDate == convertYYYYMMDDFormatToDateTime(examTdsMapBean.examTdsDate!)))
            return;
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

  Container _examNameTextBox() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: _examNameEditingController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Exam Name',
          hintText: 'Exam',
        ),
      ),
    );
  }

  Widget _createExamsTimeTable() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          Row(
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
          ),
          for (DateTimeSubjectMaxMarks slot in _timeTableList) _timeTableRow(slot)
        ] +
            [_newTimeTableRow()],
      ),
    );
  }

  Widget _timeTableRow(DateTimeSubjectMaxMarks existingSlot) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _slotDatePicker(existingSlot),
        ),
        Expanded(
          flex: 2,
          child: _slotStartTimePicker(existingSlot),
        ),
        Expanded(
          flex: 2,
          child: _slotEndTimePicker(existingSlot),
        ),
        Expanded(
          flex: 3,
          child: _slotSubjectPicker(existingSlot),
        ),
        Expanded(
          flex: 2,
          child: _slotMaxMarksEditor(existingSlot),
        ),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              setState(() {
                _timeTableList.remove(
                  existingSlot,
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

  Widget _newTimeTableRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _slotDatePicker(_newSlot),
        ),
        Expanded(
          flex: 2,
          child: _slotStartTimePicker(_newSlot),
        ),
        Expanded(
          flex: 2,
          child: _slotEndTimePicker(_newSlot),
        ),
        Expanded(
          flex: 3,
          child: _slotSubjectPicker(_newSlot),
        ),
        Expanded(
          flex: 2,
          child: _slotMaxMarksEditor(_newSlot),
        ),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              if (_newSlot.date == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select date to add.."),
                  ),
                );
                return;
              }
              if (_newSlot.startTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select start time to add.."),
                  ),
                );
                return;
              }
              if (_newSlot.endTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select end time to add.."),
                  ),
                );
                return;
              }
              if (_newSlot.subject == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select subject to add.."),
                  ),
                );
                return;
              }
              if (_newSlot.maxMarks == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Enter max marks to add.."),
                  ),
                );
                return;
              }
              setState(() {
                _timeTableList.add(_newSlot);
              });
              setState(() {
                _newSlot = DateTimeSubjectMaxMarks();
                _newSlot.date = _timeTableList.last.date;
                _newSlot.startTime = _timeTableList.last.endTime;
                _newSlot.maxMarks = _timeTableList.last.maxMarks;
                _newSlot.maxMarksController.text = "${_timeTableList.last.maxMarks}";
              });
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

  Widget _slotDatePicker(DateTimeSubjectMaxMarks slot) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: slot.date ?? _selectedStartDate,
            firstDate: DateTime(2021),
            lastDate: DateTime(2031),
            helpText: "Pick exam date",
          );
          if (_newDate == null || _newDate == slot.date) return;
          setState(() {
            slot.date = _newDate;
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
                convertDateTimeToDDMMYYYYFormat(slot.date ?? _selectedStartDate),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slotStartTimePicker(DateTimeSubjectMaxMarks slot) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          TimeOfDay? _startTimePicker = await showTimePicker(
            context: context,
            initialTime: slot.startTime ?? const TimeOfDay(hour: 0, minute: 0),
          );
          if (_startTimePicker == null) return;
          setState(() {
            slot.startTime = _startTimePicker;
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
                slot.startTime == null ? "-" : timeOfDayToString(slot.startTime!),
              ),
            ),
          ),),
      ),
    );
  }

  Widget _slotEndTimePicker(DateTimeSubjectMaxMarks slot) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          TimeOfDay? _endTimePicker = await showTimePicker(
            context: context,
            initialTime: slot.endTime ?? slot.startTime ?? const TimeOfDay(hour: 0, minute: 0),
          );
          if (_endTimePicker == null) return;
          setState(() {
            slot.endTime = _endTimePicker;
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
                slot.endTime == null ? "-" : timeOfDayToString(slot.endTime!),
              ),
            ),
          ),),
      ),
    );
  }

  Widget _slotSubjectPicker(DateTimeSubjectMaxMarks slot) {
    List<Subject> _subjects = slot.subject == null ? _subjectsList.where((eachSubject) =>
    !_timeTableList.map((eachSlot) =>
    eachSlot.subject!.subjectId).contains(eachSubject.subjectId)).toList() : _subjectsList;
    return Container(
      margin: const EdgeInsets.all(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Subject',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: DropdownButton<Subject>(
          isExpanded: true,
          underline: Container(),
          items: _subjects
              .map(
                (Subject e) =>
                DropdownMenuItem(
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
          value: slot.subject,
          onChanged: (Subject? newValue) {
            setState(() {
              slot.subject = newValue;
            });
          },
        ),),
    );
  }

  Widget _slotMaxMarksEditor(DateTimeSubjectMaxMarks slot) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: slot.maxMarksController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Max marks',
          hintText: 'Marks',
        ),
        onChanged: (String e) {
          setState(() {
            slot.maxMarks = double.tryParse(e) ?? 0.0;
          });
        },
        style: const TextStyle(
          fontSize: 12,
        ),
        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }

  GestureDetector goToNextPageButton() {
    return GestureDetector(
      onTap: () {
        if (_examNameEditingController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please enter exam name to proceed.."),
            ),
          );
          return;
        }
        if (_timeTableList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please fill in the exam time slots to proceed.."),
            ),
          );
          return;
        }
        if (_internalsForNewExam.length > 1 && _internalsWeightage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please fill in internalsWeightage to proceed.."),
            ),
          );
          return;
        }
        setState(() {
          _newExamBean = AdminExamBean(
            status: "active",
            schoolId: widget.adminProfile.schoolId,
            agent: widget.adminProfile.userId,
            examName: _examNameEditingController.text,
            examId: null,
            examStartDate: convertDateTimeToYYYYMMDDFormat(_selectedStartDate),
            examType: "TERM",
            examSectionMapBeanList: _selectedSectionsList
                .map(
                  (Section section) =>
                  ExamSectionMapBean(
                    examId: null,
                    examSectionMapId: null,
                    markingAlgorithmId: _selectedMarkingAlgorithm == null ? null : _selectedMarkingAlgorithm!.markingAlgorithmId,
                    markingAlgorithmName: _selectedMarkingAlgorithm == null ? null : _selectedMarkingAlgorithm!.algorithmName,
                    sectionId: section.sectionId,
                    sectionName: section.sectionName,
                    markingSchemeCode: _markingSchemeCode.toShortString(),
                    status: "active",
                    examTdsMapBeanList: _tdsList.where((e) => e.sectionId == section.sectionId)
                        .map((TeacherDealingSection tds) {
                      if (_timeTableList.map((e) => e.subject!.subjectId).contains((tds.subjectId))) {
                        List<DateTimeSubjectMaxMarks> slots = _timeTableList.where((e) => e.subject!.subjectId == tds.subjectId).toList();
                        return slots.map((slot) =>
                            ExamTdsMapBean(
                              examTdsMapId: null,
                              examId: null,
                              examName: _examNameEditingController.text,
                              sectionId: section.sectionId,
                              sectionName: section.sectionName,
                              maxMarks: tds.subjectId == slot.subject!.subjectId ? slot.maxMarks!.toInt() : null,
                              subjectId: tds.subjectId,
                              subjectName: tds.subjectName,
                              examTdsDate: tds.subjectId == slot.subject!.subjectId ? convertDateTimeToYYYYMMDDFormat(slot.date) : null,
                              startTime: tds.subjectId == slot.subject!.subjectId ? timeOfDayToHHMMSS(slot.startTime!) : null,
                              endTime: tds.subjectId == slot.subject!.subjectId ? timeOfDayToHHMMSS(slot.endTime!) : null,
                              internalsComputationCode: _internalsComputationCodeForNewExam.toShortString(),
                              tdsId: tds.tdsId,
                              teacherId: tds.teacherId,
                              teacherName: tds.teacherName,
                              status: "active",
                              internalsWeightage: _internalsWeightage,
                              internalExamTdsMapBeanList: _internalsForNewExam
                                  .map((AdminExamBean eachAdminExamBean) =>
                                  _exams
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
                                      .map((ExamTdsMapBean eachInternalTdsMapBean) =>
                                      InternalExamTdsMapBean(
                                        internalExamId: eachInternalTdsMapBean.examId,
                                        internalExamMapTdsId: eachInternalTdsMapBean.examTdsMapId,
                                        internalNumber: _internalsForNewExam.indexOf(eachAdminExamBean) + 1,
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
                            )).toList();
                      } else {
                        return [ExamTdsMapBean(
                          examTdsMapId: null,
                          examId: null,
                          examName: _examNameEditingController.text,
                          sectionId: section.sectionId,
                          sectionName: section.sectionName,
                          maxMarks: null,
                          subjectId: tds.subjectId,
                          subjectName: tds.subjectName,
                          examTdsDate: null,
                          startTime: null,
                          endTime: null,
                          internalsComputationCode: _internalsComputationCodeForNewExam.toShortString(),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text("Continue"),
              Icon(Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector closeNewExamsButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCreatingNew = false;
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

  GestureDetector goToPreviousPageButton() {
    return GestureDetector(
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
    );
  }

  Widget _pickExamStartDate() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Row(
        children: [
          const Text("Exam start date: "),
          Container(
            margin: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () async {
                DateTime? _newDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedStartDate,
                  firstDate: DateTime(2021),
                  lastDate: DateTime(2031),
                  helpText: "Pick exam start date",
                );
                if (_newDate == null || _newDate == _selectedStartDate) return;
                setState(() {
                  _selectedStartDate = _newDate;
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
                    convertDateTimeToDDMMYYYYFormat(_selectedStartDate),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: _isSectionPickerOpen
            ? Container(
          margin: const EdgeInsets.all(10),
          child: ClayContainer(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 2,
            borderRadius: 10,
            child: _selectSectionExpanded(),
          ),
        )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.vibrate();
          if (_isLoading) return;
          setState(() {
            if (_selectedSectionsList.contains(section)) {
              _selectedSectionsList.remove(section);
            } else {
              _selectedSectionsList.add(section);
            }
          });
          // _applyFilters();
        },
        child: ClayButton(
          depth: 40,
          spread: _selectedSectionsList.contains(section) ? 0 : 2,
          surfaceColor: _selectedSectionsList.contains(section) ? Colors.blue.shade300 : clayContainerColor(context),
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
          InkWell(
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
                      _selectedSectionsList.isEmpty ? "Select a section" : "Sections: ${_selectedSectionsList.map((e) => e.sectionName).join(", ")}",
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
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery
                .of(context)
                .size
                .width ~/ 125,
            shrinkWrap: true,
            children: _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSectionsList = _sectionsList.map((e) => e).toList();
                    });
                  },
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 25,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: const Text("Select All"),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSectionsList = [];
                    });
                  },
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 25,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: const Text("Clear"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          HapticFeedback.vibrate();
          if (_isLoading) return;
          setState(() {
            _isSectionPickerOpen = !_isSectionPickerOpen;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    _selectedSectionsList.isEmpty ? "Select a section" : "Sections: ${_selectedSectionsList.map((e) => e.sectionName).join(", ")}",
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

  Widget _addInternals() {
    return Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: _internalsForNewExam.map((e) => _internalsRow(e)).toList()
                  + [_newInternalsRow(null)],
            ),
          ),
          if (_internalsForNewExam.length > 1)
            Expanded(
              child: _inputInternalsWeightage(),
            ),
        ]
    );
  }

  Widget _inputInternalsWeightage() {
    return Container(
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: InputDecorator(
          isFocused: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: "Internals weightage",
            focusColor: Colors.blue,
          ),
          child: TextField(
            autofocus: true,
            keyboardType: TextInputType.text,
            controller: _internalsWeightageEditingController,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: (String e) {
              setState(() {
                _internalsWeightage = double.tryParse(e);
              });
            },
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
            ],
            textAlign: TextAlign.center,
          ),
        ),),
    );
  }

  Widget _newInternalsRow(AdminExamBean? exam) {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 5, 20, 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<AdminExamBean>(
                isExpanded: true,
                underline: Container(),
                items: _exams
                    .where((eachExamBean) => !_internalsForNewExam.map((e) => e.examId).contains(eachExamBean.examId))
                    .map(
                      (AdminExamBean e) =>
                      DropdownMenuItem(
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
                value: exam,
                hint: const Text("Choose internal Exam"),
                onChanged: (AdminExamBean? newValue) {
                  if (newValue == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Can't add an internal without selecting one.."),
                      ),
                    );
                    return;
                  }
                  if (_internalsForNewExam.contains(newValue)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("This exam has already been added.."),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _internalsForNewExam.add(newValue);
                  });
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (exam == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Can't add an internal without selecting one.."),
                  ),
                );
                return;
              }
              if (_internalsForNewExam.contains(exam)) {
                _internalsForNewExam.remove(exam);
              } else {
                _internalsForNewExam.add(exam);
              }
            },
            child: Container(
              margin: const EdgeInsets.all(15),
              child: exam != null && _internalsForNewExam.contains(exam)
                  ? const Icon(
                Icons.delete,
                color: Colors.red,
              )
                  : const Icon(
                Icons.add_circle_outline,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _internalsRow(AdminExamBean exam) {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 5, 20, 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    (exam.examName ?? "-").capitalize(),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _internalsForNewExam.remove(exam);
              });
            },
            child: Container(
              margin: const EdgeInsets.all(15),
              child: const Icon(
                Icons.clear_rounded,
              ),
            ),
          ),
        ],
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
              groupValue: _internalsComputationCodeForNewExam,
              onChanged: (InternalsComputationCode? value) {
                setState(() {
                  _internalsComputationCodeForNewExam = value!;
                });
              },
            ),
          ),
          Expanded(
            child: RadioListTile(
              title: const Text("Compute best of above internals in the final score"),
              value: InternalsComputationCode.B,
              groupValue: _internalsComputationCodeForNewExam,
              onChanged: (InternalsComputationCode? value) {
                setState(() {
                  _internalsComputationCodeForNewExam = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _markingAlgorithmsAndScheme() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<MarkingAlgorithmBean>(
                isExpanded: true,
                underline: Container(),
                items: _markingAlgorithms
                    .map(
                      (MarkingAlgorithmBean e) =>
                      DropdownMenuItem(
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
                value: _selectedMarkingAlgorithm,
                hint: const Text("Choose Marking Algorithm"),
                onChanged: (MarkingAlgorithmBean? newValue) {
                  setState(() {
                    _selectedMarkingAlgorithm = newValue;
                  });
                },
              ),
            ),
          ),
          InkWell(
            child: const Icon(Icons.clear),
            onTap: () {
              setState(() {
                _selectedMarkingAlgorithm = null;
              });
            },
          ),
          Expanded(
            flex: 1,
            child: Container(
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
        ],
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
              items: _markingAlgorithms
                  .map(
                    (MarkingAlgorithmBean e) =>
                    DropdownMenuItem(
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
              value: _markingAlgorithms
                  .where((eachMarkingAlgorithm) => examSectionMapBean.markingAlgorithmId == eachMarkingAlgorithm.markingAlgorithmId)
                  .isNotEmpty
                  ? _markingAlgorithms
                  .where((eachMarkingAlgorithm) => examSectionMapBean.markingAlgorithmId == eachMarkingAlgorithm.markingAlgorithmId)
                  .first
                  : null,
              hint: const Text("Choose Marking Algorithm"),
              onChanged: (MarkingAlgorithmBean? newValue) {
                setState(() {
                  examSectionMapBean.markingAlgorithmId = newValue?.markingAlgorithmId;
                  examSectionMapBean.markingAlgorithmName = newValue?.algorithmName;
                  examSectionMapBean.markingAlgorithmRangeBeanList = newValue?.markingAlgorithmRangeBeanList ?? [];
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

  Widget _markingSchemeButton(String type) {
    Color color = clayContainerColor(context);
    if ((type == "Marks" && _isMarks) || (type == "Grade" && _isGrade) || (type == "GPA" && _isGpa)) {
      color = Colors.blue.shade300;
    }
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          switch (type) {
            case "Marks":
              setState(() {
                _isMarks = !_isMarks;
              });
              break;
            case "Grade":
              if (_selectedMarkingAlgorithm == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select a marking algorithm to opt in for Grades"),
                  ),
                );
                return;
              }
              setState(() {
                _isGrade = !_isGrade;
              });
              break;
            case "GPA":
              if (_selectedMarkingAlgorithm == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select a marking algorithm to opt in for GPA"),
                  ),
                );
                return;
              }
              setState(() {
                _isGpa = !_isGpa;
              });
              break;
          }
          _reloadSchemeCode();
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
                child: MediaQuery
                    .of(context)
                    .orientation == Orientation.landscape
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
              setState(() {
                examSectionMapBean.markingSchemeCode = _reloadSchemeCodeForSection(examSectionMapBean, type);
              });
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
              setState(() {
                _isGrade = !_isGrade;
              });
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
              setState(() {
                _isGpa = !_isGpa;
              });
              break;
          }
          _reloadSchemeCodeForSection(examSectionMapBean, type);
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
              child: MediaQuery
                  .of(context)
                  .orientation == Orientation.landscape
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

  _reloadSchemeCode() {
    setState(() {
      _markingSchemeCode = fromMarkingSchemeCodeBooleans(_isMarks, _isGrade, _isGpa);
    });
  }

  _reloadSchemeCodeForSection(ExamSectionMapBean examSectionMapBean, String type) {
    MarkingSchemeCode originalCode = MarkingSchemeCode.values.firstWhere((e) => e.toString() == examSectionMapBean.markingSchemeCode);
    bool _isMarksForSection = originalCode.value[0] == "T";
    bool _isGradeForSection = originalCode.value[1] == "T";
    bool _isGpaForSection = originalCode.value[2] == "T";

    switch (type) {
      case "Marks":
        _isMarksForSection = !_isMarksForSection;
        break;
      case "Grade":
        _isGradeForSection = !_isGradeForSection;
        break;
      case "GPA":
        _isGpaForSection = !_isGpaForSection;
        break;
    }

    setState(() {
      examSectionMapBean.markingSchemeCode = fromMarkingSchemeCodeBooleans(_isMarksForSection, _isGradeForSection, _isGpaForSection).toString();
    });
  }
}

class DateTimeSubjectMaxMarks {
  DateTime? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Subject? subject;
  double? maxMarks;

  TextEditingController maxMarksController = TextEditingController();

  DateTimeSubjectMaxMarks({
    this.date,
    this.startTime,
    this.endTime,
    this.subject,
    this.maxMarks,
  });

  @override
  String toString() {
    return "DateTimeSubjectMaxMarks: {date: $date, startTime: $startTime, endTime: $endTime, subject: $subject, maxMarks: $maxMarks}";
  }
}
