import 'package:clay_containers/widgets/clay_container.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_information_center/student_base_widget.dart';
import 'package:schoolsgo_web/src/student_information_center/student_information_screen.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentInformationCenterStudentsListScreen extends StatefulWidget {
  const StudentInformationCenterStudentsListScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  static const String routeName = "/student_information_center";

  @override
  State<StudentInformationCenterStudentsListScreen> createState() => _StudentInformationCenterStudentsListScreenState();
}

class _StudentInformationCenterStudentsListScreenState extends State<StudentInformationCenterStudentsListScreen> {
  bool _isLoading = true;

  List<Section> sectionsList = [];
  Section? selectedSection;

  List<StudentProfile> studentsList = [];
  List<StudentProfile> filteredStudentsList = [];

  TextEditingController searchKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentsList = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
    }

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    _filterData();

    setState(() {
      _isLoading = false;
    });
  }

  void _filterData() {
    setState(() {
      _isLoading = true;
    });
    filteredStudentsList = studentsList;
    if (selectedSection == null) {
      filteredStudentsList = filteredStudentsList;
    } else {
      filteredStudentsList = filteredStudentsList.where((e) => e.sectionId == selectedSection?.sectionId).toList();
    }
    if (searchKeyController.text.trim() == "") {
      filteredStudentsList = filteredStudentsList;
    } else {
      filteredStudentsList = studentsList
          .where((e) => "${(e.rollNumber ?? "").toLowerCase()}|${(e.studentFirstName ?? "").toLowerCase()}|${e.sectionName ?? ""}"
              .contains(searchKeyController.text))
          .toList();
    }
    filteredStudentsList.sort((a, b) {
      int sectionComp = (a.sectionId ?? 0).compareTo((b.sectionId ?? 0));
      int rollNumberComp = (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "")) ?? 0);
      return sectionComp == 0 ? rollNumberComp : sectionComp;
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Information Center"),
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 10),
                    Expanded(child: studentSearchFilterWidget()),
                    const SizedBox(width: 10),
                    sectionSearchFilterWidget(),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    controller: ScrollController(),
                    children: filteredStudentsList.map((e) => eachStudentCard(e)).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget studentSearchFilterWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 3 / 5 - 50,
      child: InputDecorator(
        isFocused: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: filteredStudentsList.isNotEmpty ? Colors.blue : Colors.red,
            ),
          ),
          label: Text(
            filteredStudentsList.isNotEmpty ? "Student Name" : "Student not found",
            style: TextStyle(
              color: filteredStudentsList.isNotEmpty ? Colors.blue : Colors.red,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        ),
        child: TextField(
          enabled: true,
          autofocus: true,
          style: const TextStyle(
            fontSize: 12,
          ),
          onTap: () {
            searchKeyController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: searchKeyController.text.length,
            );
          },
          onChanged: (String e) => _filterData(),
          onSubmitted: (String e) => _filterData(),
          controller: searchKeyController,
          keyboardType: TextInputType.text,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Student Name",
            hintStyle: TextStyle(fontSize: 12),
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget sectionSearchFilterWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 2 / 5 - 50,
      child: InputDecorator(
        isFocused: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15, 0, 5, 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          label: Text(
            "Section",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        child: DropdownSearch<Section>(
          mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
          selectedItem: selectedSection,
          items: sectionsList,
          itemAsString: (Section? section) {
            return section == null ? "" : section.sectionName ?? "-";
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, Section? section) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(section?.sectionName ?? "-"),
            );
          },
          onChanged: (Section? section) {
            setState(() {
              selectedSection = section;
            });
            _filterData();
          },
          showClearButton: true,
          compareFn: (item, selectedItem) => item?.sectionId == selectedItem?.sectionId,
          dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
          filterFn: (Section? section, String? key) {
            return (section?.sectionName ?? "").toLowerCase().contains(key!.toLowerCase());
          },
        ),
      ),
    );
  }

  Widget eachStudentCard(StudentProfile studentProfile) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return StudentInformationScreen(
            adminProfile: widget.adminProfile,
            studentProfile: studentProfile,
          );
        }));
      },
        child: StudentBaseWidget(context: context, studentProfile: studentProfile),
    );
  }
}
