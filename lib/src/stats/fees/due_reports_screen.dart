import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class DueReportsScreen extends StatefulWidget {
  const DueReportsScreen({
    super.key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.defaultSelectedSection,
  });

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final Section? defaultSelectedSection;

  @override
  State<DueReportsScreen> createState() => _DueReportsScreenState();
}

class _DueReportsScreenState extends State<DueReportsScreen> {
  bool _isLoading = true;
  bool showPreviousTransactions = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SchoolInfoBean schoolInfoBean;
  List<Section> sectionsList = [];
  List<Section> selectedSectionsList = [];
  List<StudentProfile> studentProfiles = [];
  List<StudentProfile> selectedStudentProfiles = [];
  List<FeeType> feeTypes = [];

  Uint8List? pdfInBytes;

  List<StudentWiseAnnualFeesBean> studentWiseAnnualFeesBeanList = [];

  ScrollController controller = ScrollController();
  ScrollController verticalScrollController = ScrollController();
  ScrollController horizontalScrollController = ScrollController();

  String? searchingWith;
  TextEditingController studentNameSearchController = TextEditingController();

  bool isSummary = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      schoolInfoBean = getSchoolsResponse.schoolInfo!;
    }
    GetSectionsResponse getSectionsResponse = await getSections(GetSectionsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      sectionId: widget.defaultSelectedSection?.sectionId,
    ));
    if (getSectionsResponse.httpStatus != "OK" || getSectionsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      sectionsList = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
      selectedSectionsList.addAll(sectionsList);
    }
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      sectionId: widget.defaultSelectedSection?.sectionId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
    }
    GetFeeTypesResponse getFeeTypesResponse = await getFeeTypes(GetFeeTypesRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    ));
    if (getFeeTypesResponse.httpStatus != "OK" || getFeeTypesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
    }
    GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = await getStudentWiseAnnualFees(GetStudentWiseAnnualFeesRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      sectionIds: widget.defaultSelectedSection == null ? sectionsList.map((e) => e.sectionId).toList() : [widget.defaultSelectedSection?.sectionId],
    ));
    if (getStudentWiseAnnualFeesResponse.httpStatus != "OK" || getStudentWiseAnnualFeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentWiseAnnualFeesBeanList = getStudentWiseAnnualFeesResponse.studentWiseAnnualFeesBeanList!.map((e) => e!).toList();
      setState(() {
        for (StudentWiseAnnualFeesBean e in studentWiseAnnualFeesBeanList) {
          int actualFee = 0;
          int feePaid = 0;
          for (StudentAnnualFeeMapBean? ef in (e.studentAnnualFeeMapBeanList ?? [])) {
            actualFee += ef?.amount ?? 0;
            feePaid += ef?.amountPaid ?? 0;
          }
          actualFee += e.studentBusFeeBean?.fare ?? 0;
          feePaid += e.studentBusFeeBean?.feePaid ?? 0;
          e.actualFee = actualFee;
          e.feePaid = feePaid;
        }
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("Detailed Fee Reports"),
          actions: [
            Tooltip(
              message: isSummary ? "Show Details" : "Show Summary",
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isSummary = !isSummary;
                  });
                },
                icon: isSummary ? const Icon(Icons.info_outline) : const Icon(Icons.info),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const EpsilonDiaryLoadingWidget()
            : AdaptiveScrollbar(
                controller: verticalScrollController,
                child: AdaptiveScrollbar(
                  controller: horizontalScrollController,
                  position: ScrollbarPosition.bottom,
                  underColor: Colors.blueGrey.withOpacity(0.3),
                  sliderDefaultColor: Colors.grey.withOpacity(0.7),
                  sliderActiveColor: Colors.grey,
                  child: SingleChildScrollView(
                    controller: verticalScrollController,
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      controller: horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: [
                            DataColumn(
                              label: Row(
                                children: [
                                  const Text(
                                    "Section",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  if (widget.defaultSelectedSection == null)
                                    PopupMenuButton<Section>(
                                      onSelected: (Section section) {
                                        setState(() {
                                          if (selectedSectionsList.contains(section)) {
                                            selectedSectionsList.remove(section);
                                          } else {
                                            selectedSectionsList.add(section);
                                          }
                                        });
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return sectionsList.map((e) {
                                          return CheckedPopupMenuItem<Section>(
                                            value: e,
                                            checked: selectedSectionsList.contains(e),
                                            child: Text(e.sectionName ?? " - "),
                                          );
                                        }).toList();
                                      },
                                    ),
                                ],
                              ),
                            ),
                            const DataColumn(
                              numeric: true,
                              label: Center(
                                child: Text(
                                  "Roll No.",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Row(
                                children: [
                                  searchingWith == "Student Name"
                                      ? SizedBox(
                                          width: 100,
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(),
                                              labelText: 'Student Name',
                                              hintText: 'Student Name',
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.blue),
                                              ),
                                              contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            controller: studentNameSearchController,
                                            autofocus: true,
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        )
                                      : const Text(
                                          "Student Name",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    onPressed: () {
                                      editSearchingWith(searchingWith == "Student Name" ? null : "Student Name");
                                    },
                                    icon: Icon(
                                      searchingWith != "Student Name" ? Icons.search : Icons.close,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const DataColumn(
                              label: Center(
                                child: Text(
                                  "Phone",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                            if (!isSummary)
                              ...feeTypes
                                  .map((ef) => (ef.customFeeTypesList ?? []).isEmpty
                                      ? [
                                          DataColumn(
                                            numeric: true,
                                            label: Center(
                                              child: Text(
                                                "${ef.feeType}",
                                                style: const TextStyle(color: Colors.blue),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        ]
                                      : (ef.customFeeTypesList ?? [])
                                          .map((ecf) => DataColumn(
                                                numeric: true,
                                                label: Center(
                                                  child: Text(
                                                    "${ecf?.feeType}\n${ecf?.customFeeType}",
                                                    style: const TextStyle(color: Colors.blue),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ))
                                          .toList())
                                  .expand((i) => i)
                                  .toList(),
                            if (!isSummary)
                              const DataColumn(
                                label: Center(
                                  child: Text(
                                    "Bus Fee",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            const DataColumn(
                              label: Center(
                                child: Text(
                                  "Total Due",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                          ],
                          rows: filteredStudents.map((e) {
                            StudentProfile? eachStudent = studentProfiles.where((es) => es.studentId == e.studentId).firstOrNull;
                            String? mobile = ((eachStudent?.gaurdianMobile?.trim().isEmpty ?? true ? null : eachStudent?.gaurdianMobile?.trim()) ??
                                ((eachStudent?.studentMobile?.trim().isEmpty ?? true ? null : eachStudent?.studentMobile?.trim())) ??
                                ((eachStudent?.alternateMobile?.trim().isEmpty ?? true ? null : eachStudent?.alternateMobile?.trim())));
                            return DataRow(
                              cells: [
                                DataCell(Text(e.sectionName ?? " - ")),
                                DataCell(Text(e.rollNumber ?? " - ")),
                                DataCell(Text(e.studentName ?? " - ")),
                                DataCell(
                                  Row(
                                    children: [
                                      Text(mobile ?? " - "),
                                      if (mobile != null)
                                        IconButton(
                                          onPressed: () => launch("tel://$mobile"),
                                          icon: const Icon(Icons.phone),
                                        ),
                                    ],
                                  ),
                                ),
                                if (!isSummary)
                                  ...feeTypes
                                      .map((ef) {
                                        if ((ef.customFeeTypesList ?? []).isEmpty) {
                                          var studentWiseFeeTypeDetailsBean = e.studentAnnualFeeMapBeanList
                                              ?.where((esafmb) => esafmb?.feeTypeId == ef.feeTypeId && esafmb?.customFeeTypeId == null)
                                              .firstOrNull;
                                          int due = (studentWiseFeeTypeDetailsBean?.amount ?? 0) - (studentWiseFeeTypeDetailsBean?.amountPaid ?? 0);
                                          if (due != 0) {
                                            return [DataCell(Text(doubleToStringAsFixedForINR(due / 100, decimalPlaces: 2)))];
                                          }
                                          return [const DataCell(Text("-"))];
                                        } else {
                                          return (ef.customFeeTypesList ?? []).map((ecf) {
                                            var studentWiseFeeTypeDetailsBean = e.studentAnnualFeeMapBeanList
                                                ?.where(
                                                    (esafmb) => esafmb?.feeTypeId == ef.feeTypeId && esafmb?.customFeeTypeId == ecf?.customFeeTypeId)
                                                .firstOrNull;
                                            int due = (studentWiseFeeTypeDetailsBean?.amount ?? 0) - (studentWiseFeeTypeDetailsBean?.amountPaid ?? 0);
                                            if (due != 0) {
                                              return DataCell(Text(doubleToStringAsFixedForINR(due / 100, decimalPlaces: 2)));
                                            }
                                            return const DataCell(Text("-"));
                                          }).toList();
                                        }
                                      })
                                      .expand((i) => i)
                                      .toList(),
                                if (!isSummary)
                                  DataCell(Text(
                                    doubleToStringAsFixedForINR(((e.studentBusFeeBean?.fare ?? 0) - (e.studentBusFeeBean?.feePaid ?? 0)) / 100),
                                  )),
                                DataCell(Text(doubleToStringAsFixedForINR(((e.actualFee ?? 0) - (e.feePaid ?? 0)) / 100))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  List<StudentWiseAnnualFeesBean> get filteredStudents {
    return studentWiseAnnualFeesBeanList
        .where((es) => selectedSectionsList.map((e) => e.sectionId).contains(es.sectionId))
        .where((es) => (es.studentName ?? "").toLowerCase().trim().contains(studentNameSearchController.text.toLowerCase().trim()))
        .sorted((a, b) => (a.sectionId ?? 0).compareTo(b.sectionId ?? 0) != 0
            ? (a.sectionId ?? 0).compareTo(b.sectionId ?? 0)
            : (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
  }

  void editSearchingWith(String? newSearchingWith) => setState(() {
        studentNameSearchController.text = "";
        searchingWith = newSearchingWith;
      });
}
