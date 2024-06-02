// ignore: implementation_imports
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/school_management/subjects_reorder_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectInfoScreen extends StatefulWidget {
  const SubjectInfoScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<SubjectInfoScreen> createState() => _SubjectInfoScreenState();
}

class _SubjectInfoScreenState extends State<SubjectInfoScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<Subject> subjectsList = [];
  List<Teacher> teachersList = [];

  Subject? selectedSubject;
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
    int perRowCount = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 1;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Subjects Info"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: subjectsDataTable(),
                // ),
                for (int i = 0; i < subjectsList.length / perRowCount; i = i + 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int j = 0; j < perRowCount; j++)
                        Expanded(
                          child:
                              ((i * perRowCount + j) >= subjectsList.length) ? Container() : subjectCardWidget(subjectsList[(i * perRowCount + j)]),
                        ),
                    ],
                  ), // ...subjectsList.map((e) => subjectCardWidget(e)),
                const SizedBox(height: 200),
              ],
            ),
      floatingActionButton: _isLoading
          ? null
          : _isEditMode
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    doneEditingButton(),
                    addNewSubjectButton(),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reorderSubjectsButton(),
                    editSubjectsButton(),
                  ],
                ),
    );
  }

  Widget doneEditingButton() {
    return fab(
      const Icon(Icons.check),
      "Done",
      () => setState(() => _isEditMode = !_isEditMode),
      color: Colors.green,
    );
  }

  Widget addNewSubjectButton() {
    return fab(
      const Icon(Icons.add),
      "Add",
      () async {
        String? newTopic = "";
        await showDialog(
          context: scaffoldKey.currentContext!,
          builder: (currentContext) {
            return AlertDialog(
              title: const Text("New Subject"),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 2,
                    child: TextFormField(
                      initialValue: newTopic,
                      decoration: InputDecoration(
                        errorText: (newTopic ?? "").isEmpty ? "Subject Name cannot be empty" : "",
                        border: const UnderlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      ),
                      onChanged: (String? newText) => setState(() => newTopic = newText),
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if ((newTopic?.trim() ?? "").isEmpty) return;
                    Navigator.pop(context);
                    setState(() {
                      _isLoading = true;
                    });
                    CreateOrUpdateSubjectResponse createOrUpdateSubjectResponse = await createOrUpdateSubject(CreateOrUpdateSubjectRequest(
                      schoolId: widget.adminProfile.schoolId,
                      agent: widget.adminProfile.userId?.toString(),
                      subjectName: newTopic,
                      seqOrder: subjectsList.length + 1,
                    ));
                    if (createOrUpdateSubjectResponse.httpStatus != "OK" || createOrUpdateSubjectResponse.responseStatus != "success") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Something went wrong! Try again later.."),
                        ),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      return;
                    }
                    setState(() {
                      _isLoading = false;
                    });
                    await _loadData();
                  },
                  child: const Text("Add"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
      color: Colors.blue,
    );
  }

  Widget editSubjectsButton() {
    return fab(
      const Icon(Icons.edit),
      "Edit",
      () => setState(() => _isEditMode = !_isEditMode),
      color: Colors.blue,
    );
  }

  Widget reorderSubjectsButton() {
    return fab(
      const Icon(Icons.reorder_sharp),
      "Reorder",
      () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return SubjectsReorderScreen(
              adminProfile: widget.adminProfile,
              subjects: subjectsList,
              teachers: teachersList,
            );
          },
        ),
      ).then((_) => _loadData()),
      color: Colors.amber,
    );
  }

  Widget fab(Icon icon, String text, Function() action, {Function()? postAction, Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await action();
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (postAction != null) {
              await postAction();
            }
          });
        },
        child: ClayButton(
          surfaceColor: color ?? clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget subjectCardWidget(Subject subject) {
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
              subjectNameWidget(subject),
            ],
          ),
        ),
      ),
    );
  }

  Row subjectNameWidget(Subject subject) {
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
                        subject.subjectName ?? "-",
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    // goToSubjectButton(subject),
                    // const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector goToSubjectButton(Subject subject) {
    return GestureDetector(
      onTap: () => goToSubjectAction(subject),
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

  goToSubjectAction(Subject subject) {
    // return Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) {
    //       return ClassTeacherSubjectScreen(
    //         adminProfile: widget.adminProfile,
    //         teacherProfile: null,
    //         subject: subject,
    //         selectedAcademicYearId: selectedAcademicYearId,
    //       );
    //     },
    //   ),
    // );
    debugPrint("Go to subject ${subject.subjectName}");
  }
}
