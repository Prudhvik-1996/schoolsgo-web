import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/publish_results/admin_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/admin/publish_results/admin_exam_marks_v2_screen.dart';
import 'package:schoolsgo_web/src/exams/model/admin_exams.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class AdminPublishResultsScreen extends StatefulWidget {
  const AdminPublishResultsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/publish_results";

  @override
  _AdminPublishResultsScreenState createState() => _AdminPublishResultsScreenState();
}

class _AdminPublishResultsScreenState extends State<AdminPublishResultsScreen> {
  bool _isLoading = true;
  List<AdminExamBean> _exams = [];
  List<AdminExamBean> _filteredExams = [];

  bool _isSectionPickerOpen = false;
  List<Section> _sectionsList = [];
  Section? _selectedSection;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
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

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publish Results"),
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
          : Container(
              margin: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  _sectionPicker(),
                  for (AdminExamBean examBean in _filteredExams) _examWidget(examBean),
                ],
              ),
            ),
    );
  }

  Widget _examWidget(AdminExamBean examBean) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: InkWell(
        onTap: () {
          if ((examBean.examSectionMapBeanList ?? [])
              .map((ExamSectionMapBean? e) => e!)
              .where((ExamSectionMapBean eachSectionMapBean) => eachSectionMapBean.sectionId == _selectedSection?.sectionId)
              .map((ExamSectionMapBean eachSectionMapBean) => eachSectionMapBean.examTdsMapBeanList ?? [])
              .expand((List<ExamTdsMapBean?> i) => i)
              .map((ExamTdsMapBean? examTdsMapBean) => examTdsMapBean!)
              .where((ExamTdsMapBean examTdsMapBean) => examTdsMapBean.sectionId == _selectedSection?.sectionId)
              .map((e) => e.internalsComputationCode)
              .toList()
              .contains("S")) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AdminMarksV2Screen(
                adminProfile: widget.adminProfile,
                examBean: examBean,
                section: _selectedSection!,
                subjectId: null,
                teacherId: null,
              );
            }));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AdminExamMarksScreen(
                adminProfile: widget.adminProfile,
                examBean: examBean,
                section: _selectedSection!,
                subjectId: null,
                teacherId: null,
              );
            }));
          }
        },
        child: ClayButton(
          depth: 40,
          spread: 2,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        examBean.examName ?? "-",
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
                    Expanded(
                      child: Text(
                        convertDateToDDMMMYYYEEEE(examBean.examStartDate),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 9,
                        ),
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
            if (_selectedSection != null && _selectedSection!.sectionId == section.sectionId) {
              _selectedSection = null;
            } else {
              _selectedSection = section;
            }
            _filteredExams = _exams
                .where((eachExam) => (eachExam.examSectionMapBeanList ?? [])
                    .map((ExamSectionMapBean? e) => e!)
                    .where((ExamSectionMapBean eachSectionMapBean) =>
                        _selectedSection != null && eachSectionMapBean.sectionId == _selectedSection!.sectionId)
                    .isNotEmpty)
                .toList();
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
            children: _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
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
}
