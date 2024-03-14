import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/feedback/model/feedback.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class StudentFeedbackScreen extends StatefulWidget {
  const StudentFeedbackScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/feedback";

  @override
  _StudentFeedbackScreenState createState() => _StudentFeedbackScreenState();
}

class _StudentFeedbackScreenState extends State<StudentFeedbackScreen> {
  bool _isLoading = true;

  List<TeacherDealingSection> _tdsList = [];
  List<StudentToTeacherFeedback> _feedbackBeans = [];

  bool _isEditMode = false;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {
      _isEditMode = false;
      _isLoading = true;
      _feedbackBeans = [];
    });

    // Get all TDS
    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(
      GetTeacherDealingSectionsRequest(
        schoolId: widget.studentProfile.schoolId,
        sectionId: widget.studentProfile.sectionId,
        status: "active",
      ),
    );
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections ?? [];
      });
    }

    // Get all teachers feedback
    GetStudentToTeacherFeedbackResponse getStudentToTeacherFeedbackResponse = await getStudentToTeacherFeedback(
      GetStudentToTeacherFeedbackRequest(
        schoolId: widget.studentProfile.schoolId,
        adminView: false,
        sectionId: widget.studentProfile.sectionId,
        studentId: widget.studentProfile.studentId,
      ),
    );
    List<StudentToTeacherFeedback> allFeedbackBeans = [];
    if (getStudentToTeacherFeedbackResponse.httpStatus == "OK" && getStudentToTeacherFeedbackResponse.responseStatus == "success") {
      setState(() {
        allFeedbackBeans = getStudentToTeacherFeedbackResponse.feedbackBeans?.map((e) => e!).where((e) => e.feedbackId != null).toList() ?? [];
      });

      for (var eachTds in _tdsList) {
        List<double> ratingsList = allFeedbackBeans.where((e) => e.tdsId == eachTds.tdsId).map((e) => e.rating ?? 0).toList()..add(0);
        double averageRating = (ratingsList.reduce((a, b) => a + b) / ratingsList.length);
        setState(() {
          _feedbackBeans.add(StudentToTeacherFeedback(
            studentId: widget.studentProfile.studentId,
            sectionId: widget.studentProfile.sectionId,
            teacherId: eachTds.teacherId,
            schoolId: widget.studentProfile.schoolId,
            tdsId: eachTds.tdsId,
            subjectId: eachTds.subjectId,
            averageRating: averageRating,
            rating: allFeedbackBeans.where((e) => e.tdsId == eachTds.tdsId).firstOrNull?.rating,
            lastUpdated: allFeedbackBeans.where((e) => e.tdsId == eachTds.tdsId).firstOrNull?.lastUpdated,
            subjectName: eachTds.subjectName,
            teacherName: eachTds.teacherName,
            sectionName: eachTds.sectionName,
            schoolName: widget.studentProfile.schoolName,
            studentName: ((widget.studentProfile.studentFirstName == null ? "" : (widget.studentProfile.studentFirstName ?? "") + " ") +
                    (widget.studentProfile.studentMiddleName == null ? "" : (widget.studentProfile.studentMiddleName ?? "") + " ") +
                    (widget.studentProfile.studentLastName == null ? "" : (widget.studentProfile.studentLastName ?? "") + " "))
                .trim(),
          ));
        });
      }
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
          buildRoleButtonForAppBar(context, widget.studentProfile),
        ],
      ),
      drawer: StudentAppDrawer(
        studentProfile: widget.studentProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children:
                  // <Widget>[
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.end,
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         children: [
                  //           buildEditButton(context),
                  //         ],
                  //       )
                  //     ] +
                  _feedbackBeans
                          .map(
                            (eachFeedbackBean) => Container(
                              margin: MediaQuery.of(context).orientation == Orientation.portrait
                                  ? const EdgeInsets.fromLTRB(25, 15, 25, 15)
                                  : const EdgeInsets.fromLTRB(150, 15, 150, 15),
                              child: ClayContainer(
                                depth: 40,
                                color: clayContainerColor(context),
                                spread: 2,
                                borderRadius: 10,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.all(15),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Teacher: ${(eachFeedbackBean.teacherName ?? "").capitalize()}",
                                                ),
                                                Text(
                                                  "Subject: ${(eachFeedbackBean.subjectName ?? "").capitalize()}",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Center(
                                            child: !_isEditMode ? buildRatingIndicator(eachFeedbackBean) : buildRatingBar(eachFeedbackBean),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!_isEditMode)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                                              child: Text(
                                                "Last Updated: ${eachFeedbackBean.lastUpdated == null ? "-" : convertEpochToDDMMYYYYHHMMAA(eachFeedbackBean.lastUpdated!)}",
                                                textAlign: TextAlign.end,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList() +
                      [
                        Container(
                          height: 150,
                        )
                      ],
            ),
      floatingActionButton: _isLoading ? Container() : buildEditButton(context),
    );
  }

  Widget buildRatingBar(StudentToTeacherFeedback eachFeedbackBean) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: RatingBar.builder(
        initialRating: (eachFeedbackBean.rating ?? 0).toDouble(),
        minRating: 0,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemPadding: const EdgeInsets.symmetric(horizontal: 2.5),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber.shade400,
        ),
        glow: true,
        glowColor: Colors.yellow,
        itemSize: 25,
        onRatingUpdate: (rating) {
          debugPrint("199: TDS Id: ${eachFeedbackBean.tdsId} - New rating: $rating");
          if (StudentToTeacherFeedback.fromJson(eachFeedbackBean.origJson()).rating != rating.toInt()) {
            setState(() {
              eachFeedbackBean.rating = rating;
              eachFeedbackBean.isEdited = true;
            });
          }
        },
      ),
    );
  }

  Widget buildRatingIndicator(StudentToTeacherFeedback eachFeedbackBean) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: "Rating: ${eachFeedbackBean.rating ?? 0}",
        child: RatingBarIndicator(
          rating: (eachFeedbackBean.rating ?? 0).toDouble(),
          direction: Axis.horizontal,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(
            horizontal: 2.5,
          ),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber.shade400,
          ),
          unratedColor: Colors.grey,
          itemSize: 25,
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_feedbackBeans.where((e) => e.isEdited).isEmpty) return;
    CreateOrUpdateStudentToTeacherFeedbackRequest createOrUpdateStudentToTeacherFeedbackRequest = CreateOrUpdateStudentToTeacherFeedbackRequest(
      schoolId: widget.studentProfile.studentId,
      feedbackBeans: _feedbackBeans.where((e) => e.isEdited).toList(),
    );
    CreateOrUpdateStudentToTeacherFeedbackResponse createOrUpdateStudentToTeacherFeedbackResponse =
        await createOrUpdateStudentToTeacherFeedback(createOrUpdateStudentToTeacherFeedbackRequest);
    if (createOrUpdateStudentToTeacherFeedbackResponse.httpStatus == "OK" &&
        createOrUpdateStudentToTeacherFeedbackResponse.responseStatus == "success") {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Updated feedback!"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Please try again later.."),
        ),
      );
    }
  }

  Container buildEditButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.vibrate();
          if (_isEditMode) {
            // showAlert();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Feedback'),
                  content: const Text("Are you sure to submit your feedback?"),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("YES"),
                      onPressed: () async {
                        HapticFeedback.vibrate();
                        Navigator.of(context).pop();
                        _saveChanges();
                      },
                    ),
                    TextButton(
                      child: const Text("NO"),
                      onPressed: () async {
                        HapticFeedback.vibrate();
                        Navigator.of(context).pop();
                        _loadData();
                      },
                    ),
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () async {
                        HapticFeedback.vibrate();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            setState(() {
              _isEditMode = true;
            });
          }
        },
        child: ClayButton(
          depth: 80,
          surfaceColor: _isEditMode ? Colors.green : Colors.blue,
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 50,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            child: _isEditMode
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }
}
