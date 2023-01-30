import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/diary/model/diary.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentDiaryScreen extends StatefulWidget {
  const StudentDiaryScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/diary";

  @override
  _StudentDiaryScreenState createState() => _StudentDiaryScreenState();
}

class _StudentDiaryScreenState extends State<StudentDiaryScreen> {
  bool _isLoading = true;

  DateTime _selectedDate = DateTime.now();

  List<DiaryEntry> _diaryList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await _loadDiary();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadDiary() async {
    setState(() {
      _isLoading = true;
    });

    GetStudentDiaryResponse getDiaryResponse = await getDiary(
      GetDiaryRequest(
        schoolId: widget.studentProfile.schoolId,
        sectionId: widget.studentProfile.sectionId,
        studentId: widget.studentProfile.studentId,
        date: convertDateTimeToYYYYMMDDFormat(_selectedDate),
      ),
    );
    if (getDiaryResponse.httpStatus == "OK" && getDiaryResponse.responseStatus == "success") {
      setState(() {
        _diaryList = (getDiaryResponse.diaryEntries ?? []).where((e) => e != null).map((e) => e!).toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.vibrate();
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 364)),
            lastDate: DateTime.now(),
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setState(() {
            _selectedDate = _newDate;
          });
          _loadDiary();
        },
        child: ClayButton(
          depth: 40,
          parentColor: clayContainerColor(context),
          surfaceColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          height: 60,
          width: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    convertDateTimeToDDMMYYYYFormat(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getLeftArrow() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Tooltip(
        message: "Previous Day",
        child: GestureDetector(
          onTap: () {
            if (_selectedDate.millisecondsSinceEpoch == DateTime.now().subtract(const Duration(days: 364)).millisecondsSinceEpoch) return;
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
            });
            _loadDiary();
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            surfaceColor: clayContainerColor(context),
            child: const Icon(Icons.arrow_left),
          ),
        ),
      ),
    );
  }

  Widget _getRightArrow() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Tooltip(
        message: "Next Day",
        child: GestureDetector(
          onTap: () {
            if (convertDateTimeToYYYYMMDDFormat(_selectedDate) == convertDateTimeToYYYYMMDDFormat(null)) return;
            setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
            });
            _loadDiary();
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            surfaceColor: clayContainerColor(context),
            child: const Icon(Icons.arrow_right),
          ),
        ),
      ),
    );
  }

  Container _getDiaryWidget(DiaryEntry diary) {
    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
          : const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildSectionNameWidget(diary),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildSubjectNameWidget(diary),
                  ),
                  Expanded(
                    child: buildTeacherNameWidget(diary),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: buildAssignmentWidget(diary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAssignmentWidget(DiaryEntry diary) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Text(
            diary.assignment ?? "-",
            textAlign: diary.assignment == null ? TextAlign.center : TextAlign.start,
          ),
        ),
      ),
    );
  }

  Container buildSubjectNameWidget(DiaryEntry diary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text("Subject: ${diary.subjectName!.capitalize()}"),
    );
  }

  Container buildTeacherNameWidget(DiaryEntry diary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text("Teacher: ${diary.teacherFirstName!.capitalize()}"),
    );
  }

  Container buildSectionNameWidget(DiaryEntry diary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text(
        "Section: ${diary.sectionName}",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diary"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.studentProfile,
          ),
        ],
      ),
      drawer: StudentAppDrawer(
        studentProfile: widget.studentProfile,
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
              children: <Widget>[
                Container(
                  padding: MediaQuery.of(context).orientation == Orientation.landscape
                      ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
                      : const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      _getLeftArrow(),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(child: _getDatePicker()),
                      const SizedBox(
                        width: 10,
                      ),
                      _getRightArrow(),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                for (DiaryEntry eachDiary in _diaryList) _getDiaryWidget(eachDiary),
              ],
            ),
    );
  }
}
