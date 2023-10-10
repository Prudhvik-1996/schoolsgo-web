import 'package:clay_containers/clay_containers.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
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
  bool _isSectionLoading = false;
  bool _isLoading = true;

  List<Section> sectionsList = [];
  List<Teacher> teachersList = [];

  Section? selectedSection;
  late int selectedAcademicYearId;

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
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sections Info"),
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : ListView(
              children: [
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 3,
                  shrinkWrap: true,
                  childAspectRatio: 1.5,
                  children: sectionsList.map((e) => buildSectionWidget(e)).toList(),
                ),
              ],
            ),
    );
  }

  Widget buildSectionWidget(Section section) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      section.sectionName ?? "-",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (selectedSection == null) editSectionButton(section),
                  if (selectedSection?.sectionId == section.sectionId) saveChangesButton(section),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                thickness: 2,
                color: clayContainerTextColor(context),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(child: Text("Class Teacher")),
                  if (selectedSection == section)
                    DropdownButton<Teacher?>(
                      value: teachersList.where((et) => et.teacherId == section.classTeacherId).firstOrNull,
                      items: teachersList.map((e) => DropdownMenuItem<Teacher>(value: e, child: Text(e.teacherName ?? "-"))).toList(),
                      onChanged: (Teacher? teacher) {
                        setState(() {
                          section.classTeacherId = teacher?.teacherId;
                          section.agent = "${widget.adminProfile.userId}";
                        });
                      },
                    )
                  else
                    Expanded(
                      child: Text(
                        teachersList.where((et) => et.teacherId == section.classTeacherId).firstOrNull?.teacherName ?? "-",
                      ),
                    ),
                ],
              ),
              const Expanded(
                child: Text(""),
              ),
              if (selectedSection == null) const SizedBox(height: 10),
              if (selectedSection == null)
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
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
                      ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ClayButton(
                        depth: 40,
                        surfaceColor: clayContainerColor(context),
                        parentColor: clayContainerColor(context),
                        spread: 1,
                        borderRadius: 5,
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: const Text(
                              "More Info",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector saveChangesButton(Section section) {
    return GestureDetector(
      onTap: () async {
        if (section.classTeacherId == Section.fromJson(section.origJson()).classTeacherId) {
          return;
        }
        setState(() {
          _isSectionLoading = true;
        });
        CreateOrUpdateSectionRequest createOrUpdateSectionRequest = CreateOrUpdateSectionRequest.fromSection(section);
        CreateOrUpdateSectionResponse createOrUpdateSectionResponse = await createOrUpdateSection(createOrUpdateSectionRequest);
        if (createOrUpdateSectionResponse.httpStatus != "OK" || createOrUpdateSectionResponse.responseStatus != "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong! Try again later.."),
            ),
          );
        }
        setState(() {
          _isSectionLoading = false;
          selectedSection = null;
        });
      },
      child: ClayButton(
        depth: 40,
        spread: selectedSection != null && selectedSection!.sectionId == section.sectionId ? 0 : 1,
        surfaceColor: selectedSection != null && selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _isSectionLoading ? const CircularProgressIndicator() : const Icon(Icons.check),
          ),
        ),
      ),
    );
  }

  GestureDetector editSectionButton(Section section) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSection = section;
        });
      },
      child: ClayButton(
        depth: 40,
        spread: selectedSection != null && selectedSection!.sectionId == section.sectionId ? 0 : 1,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}
