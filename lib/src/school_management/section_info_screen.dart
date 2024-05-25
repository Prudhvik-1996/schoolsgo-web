// ignore: implementation_imports
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/common_components/hover_effect_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/school_management/sections_reorder_screen.dart';
import 'package:schoolsgo_web/src/teacher_dashboard/class_teacher_section_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SectionInfoScreen extends StatefulWidget {
  const SectionInfoScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<SectionInfoScreen> createState() => _SectionInfoScreenState();
}

class _SectionInfoScreenState extends State<SectionInfoScreen> {
  bool _isLoading = true;

  List<Section> sectionsList = [];
  List<Teacher> teachersList = [];
  List<StudentProfile> studentsList = [];

  Section? selectedSection;
  late int selectedAcademicYearId;

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID')!;
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetTeachersResponse getTeachersResponse = await getTeachers(getTeachersRequest);
    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        teachersList = getTeachersResponse.teachers!;
        teachersList.sort((a, b) => (a.teacherName ?? "-").compareTo((b.teacherName ?? "-")));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      setState(() {
        studentsList = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
        studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    int perRowCount = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sections Info"),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: () => setState(() => _isEditMode = !_isEditMode),
              icon: _isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
            ),
          // if (!_isLoading && !_isEditMode) reorderSectionsButton(),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: sectionsDataTable(),
                // ),
                for (int i = 0; i < sectionsList.length / perRowCount; i = i + 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int j = 0; j < perRowCount; j++)
                        Expanded(
                          child:
                              ((i * perRowCount + j) >= sectionsList.length) ? Container() : sectionCardWidget(sectionsList[(i * perRowCount + j)]),
                        ),
                    ],
                  ), // ...sectionsList.map((e) => sectionCardWidget(e)),
              ],
            ),
    );
  }

  Widget sectionCardWidget(Section section) {
    List<StudentProfile> sectionWiseStudentsList = studentsList.where((es) => es.sectionId == section.sectionId).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              sectionNameWidget(section),
              noOfBoysWidget(sectionWiseStudentsList),
              noOfGirlsWidget(sectionWiseStudentsList),
              totalNoOfStudentsWidget(sectionWiseStudentsList),
            ],
          ),
        ),
      ),
    );
  }

  Widget totalNoOfStudentsWidget(List<StudentProfile> sectionWiseStudentsList) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("Total no. of students:"),
                SizedBox(width: 10),
                Icon(Icons.people_outline_sharp, color: Colors.green),
              ],
            ),
          ),
          Text("${sectionWiseStudentsList.length}")
        ],
      ),
    );
  }

  Widget noOfGirlsWidget(List<StudentProfile> sectionWiseStudentsList) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("No. of girls:"),
                SizedBox(width: 10),
                Icon(Icons.girl_sharp, color: Colors.pink),
              ],
            ),
          ),
          Text("${sectionWiseStudentsList.where((es) => es.sex == 'female').length}")
        ],
      ),
    );
  }

  Padding noOfBoysWidget(List<StudentProfile> sectionWiseStudentsList) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("No. of boys:"),
                SizedBox(width: 10),
                Icon(Icons.boy_sharp, color: Colors.blue),
              ],
            ),
          ),
          Text("${sectionWiseStudentsList.where((es) => es.sex == 'male').length}")
        ],
      ),
    );
  }

  Row sectionNameWidget(Section section) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(4),
            child: ClayContainer(
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              depth: 40,
              emboss: true,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        section.sectionName ?? "-",
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    goToSectionButton(section),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconButton reorderSectionsButton() {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return SectionsReorderScreen(
              adminProfile: widget.adminProfile,
              sections: sectionsList,
              teachers: teachersList,
              students: studentsList,
            );
          },
        ),
      ).then((_) => _loadData()),
      icon: const Icon(Icons.sort),
      tooltip: "Rearrange sections' order",
    );
  }

  Widget sectionsDataTable() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClayContainer(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                headersRow(),
                ...sectionsList.mapIndexed(
                  (index, section) => OnHoverColorChangeWidget(
                    child: sectionRow(section, index),
                    hoverColor: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row sectionRow(Section section, int index) {
    return Row(
      children: [
        tableCell(
          Text("${index + 1}"),
          width: 50,
          alignment: Alignment.centerRight,
        ),
        tableCell(
          Text(section.sectionName ?? "-"),
          width: 150,
        ),
        tableCell(
          _isEditMode
              ? classTeacherPicker(section)
              : Text(teachersList.where((et) => et.teacherId == section.classTeacherId).firstOrNull?.teacherName ?? "-"),
          width: 250,
        ),
        tableCell(
          Text(studentsList.where((es) => es.sectionId == section.sectionId && es.status == 'active').length.toString()),
          width: 70,
          alignment: Alignment.center,
        ),
        tableCell(
          goToSectionButton(section),
          width: 75,
          alignment: Alignment.center,
        ),
      ],
    );
  }

  Row headersRow() {
    return Row(
      children: [
        tableCell(
          const Text('S. No.', style: TextStyle(fontWeight: FontWeight.bold)),
          width: 50,
        ),
        tableCell(
          const Text('Section Name', style: TextStyle(fontWeight: FontWeight.bold)),
          width: 150,
        ),
        tableCell(
          const Text('Class Teacher', style: TextStyle(fontWeight: FontWeight.bold)),
          width: 250,
        ),
        tableCell(
          const Text('Students', style: TextStyle(fontWeight: FontWeight.bold)),
          width: 70,
        ),
        tableCell(
          const Text('More Info', style: TextStyle(fontWeight: FontWeight.bold)),
          width: 75,
        ),
      ],
    );
  }

  Widget tableCell(
    Widget child, {
    double height = 50,
    double width = 150,
    bool emboss = true,
    double margin = 2.0,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Container(
      margin: EdgeInsets.all(margin),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 5,
        depth: 40,
        height: height,
        width: width,
        emboss: emboss,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );
  }

  GestureDetector goToSectionButton(Section section) {
    return GestureDetector(
      onTap: () => goToSectionAction(section),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 100,
          child: const Center(
            child: SizedBox(
              height: 25,
              width: 25,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.exit_to_app),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DropdownButton<Teacher?> classTeacherPicker(Section section) {
    return DropdownButton<Teacher?>(
      isExpanded: true,
      value: teachersList.where((et) => et.teacherId == section.classTeacherId).firstOrNull,
      items: teachersList.map((e) => DropdownMenuItem<Teacher>(value: e, child: Text(e.teacherName ?? "-"))).toList(),
      onChanged: (Teacher? teacher) async {
        setState(() {
          section.classTeacherId = teacher?.teacherId;
          section.agent = "${widget.adminProfile.userId}";
        });
        setState(() => _isLoading = true);
        CreateOrUpdateSectionRequest createOrUpdateSectionRequest = CreateOrUpdateSectionRequest.fromSection(section);
        CreateOrUpdateSectionResponse createOrUpdateSectionResponse = await createOrUpdateSection(createOrUpdateSectionRequest);
        if (createOrUpdateSectionResponse.httpStatus != "OK" || createOrUpdateSectionResponse.responseStatus != "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong! Try again later.."),
            ),
          );
        }
        setState(() => _isLoading = false);
      },
    );
  }

  Future<dynamic> goToSectionAction(Section section) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ClassTeacherSectionScreen(
            adminProfile: widget.adminProfile,
            teacherProfile: null,
            section: section,
            selectedAcademicYearId: selectedAcademicYearId,
          );
        },
      ),
    );
  }
}
