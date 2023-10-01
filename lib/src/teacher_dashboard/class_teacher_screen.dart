import 'package:clay_containers/widgets/clay_text.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/teacher_dashboard/class_teacher_section_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassTeacherScreen extends StatefulWidget {
  const ClassTeacherScreen({
    super.key,
    required this.teacherProfile,
  });

  final TeacherProfile teacherProfile;

  static const routeName = "/class_teacher";

  @override
  State<ClassTeacherScreen> createState() => _ClassTeacherScreenState();
}

class _ClassTeacherScreenState extends State<ClassTeacherScreen> {
  bool _isLoading = true;

  late int selectedAcademicYearId;
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID')!;
    GetSectionsResponse getSectionsResponse = await getSections(GetSectionsRequest(
      schoolId: widget.teacherProfile.schoolId,
    ));
    if (getSectionsResponse.httpStatus != "OK" || getSectionsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      sectionsList = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _getClassOption(String title, String? description, StatefulWidget nextWidget) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return nextWidget;
        }));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(10), // margin: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: const Icon(
                    Icons.adjust,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: <Widget>[
                      Text(
                        description ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      drawer: TeacherAppDrawer(
        teacherProfile: widget.teacherProfile,
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
                EisStandardHeader(
                  title: ClayText(
                    "Class Teacher",
                    size: 32,
                    textColor: Colors.blueGrey,
                    spread: 2,
                  ),
                ),
                ...sectionsList.where((es) => (widget.teacherProfile.classTeacherFor ?? []).contains(es.sectionId)).map(
                      (es) => _getClassOption(
                        es.sectionName ?? " - ",
                        null,
                        ClassTeacherSectionScreen(
                          teacherProfile: widget.teacherProfile,
                          section: es,
                          selectedAcademicYearId: selectedAcademicYearId,
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}
