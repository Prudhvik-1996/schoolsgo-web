// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class AddNewSchoolPage extends StatefulWidget {
  const AddNewSchoolPage({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  State<AddNewSchoolPage> createState() => _AddNewSchoolPageState();
}

class _AddNewSchoolPageState extends State<AddNewSchoolPage> {
  bool _isLoading = false;
  List<SchoolInfoBean> schoolsList = [];
  late CreateOrUpdateSchoolInfoRequest newSchool;

  @override
  void initState() {
    super.initState();
    newSchool = CreateOrUpdateSchoolInfoRequest(
      agent: widget.userId,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest());
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        schoolsList = (getSchoolsResponse.schoolsInfo ?? []).whereNotNull().toList();
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New School"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    children: [
                      const Text("Prefill from (for new academic year)"),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: schoolSearchableDropDown(),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                textBox(newSchool.schoolNameController, labelText: "School Name", hintText: "School Name"),
                textBox(newSchool.cityController, labelText: "Sity", hintText: "Sity"),
                textBox(newSchool.branchCodeController, labelText: "Branch Code", hintText: "Branch Code"),
                textBox(newSchool.descriptionController, labelText: "Description", hintText: "Description"),
                textBox(newSchool.mailIdController, labelText: "Mail Id", hintText: "Mail Id"),
                textBox(newSchool.mobileController, labelText: "Mobile", hintText: "Mobile"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: academicYearStartDatePicker()),
                      const SizedBox(width: 10),
                      Expanded(child: academicYearEndDatePicker()),
                    ],
                  ),
                ),
                submitButton(),
              ],
            ),
    );
  }

  Widget schoolSearchableDropDown() {
    return InputDecorator(
      isFocused: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        label: Text(
          "School",
          style: TextStyle(color: Colors.grey),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: DropdownSearch<SchoolInfoBean>(
          mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
          selectedItem: schoolsList.firstWhereOrNull((e) => e.schoolId == newSchool.linkedSchoolId),
          items: schoolsList,
          itemAsString: (SchoolInfoBean? school) {
            return school?.schoolName ?? "";
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, SchoolInfoBean? school) {
            return Text(school?.schoolName ?? "-");
          },
          onChanged: (SchoolInfoBean? school) {
            setState(() {
              newSchool.linkedSchoolId = school?.schoolId;
              newSchool.schoolName = school?.schoolName;
              newSchool.schoolNameController.text = school?.schoolName ?? "";
              newSchool.description = school?.description;
              newSchool.descriptionController.text = school?.description ?? "";
              newSchool.mailId = school?.mailId;
              newSchool.mailIdController.text = school?.mailId ?? "";
              newSchool.mobile = school?.mobile;
              newSchool.mobileController.text = school?.mobile ?? "";
              newSchool.description = school?.description;
              newSchool.estdYear = school?.estdYear;
              newSchool.faxNumber = school?.faxNumber;
              newSchool.founder = school?.founder;
              newSchool.mailId = school?.mailId;
              newSchool.mobile = school?.mobile;
              newSchool.schoolDisplayName = school?.schoolDisplayName;
              newSchool.schoolId = school?.schoolId;
              newSchool.schoolName = school?.schoolName;
              newSchool.status = school?.status;
              newSchool.detailedAddress = school?.detailedAddress;
              newSchool.receiptHeader = school?.receiptHeader;
              newSchool.examMemoHeader = school?.examMemoHeader;
              newSchool.linkedSchoolId = school?.linkedSchoolId;
            });
          },
          showClearButton: false,
          compareFn: (item, selectedItem) => item?.schoolId == selectedItem?.schoolId,
          dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
          filterFn: (SchoolInfoBean? school, String? key) {
            return (school?.schoolName ?? "-").toLowerCase().trim().contains(key!.toLowerCase());
          },
        ),
      ),
    );
  }

  Widget submitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: GestureDetector(
        onTap: () {
          //  TODO
        },
        child: ClayButton(
          surfaceColor: Colors.blue,
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.check),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget academicYearStartDatePicker() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: InkWell(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 2 * 365)),
            lastDate: DateTime.now().add(const Duration(days: 2 * 365)),
            helpText: "Select academic year start date",
          );
          if (_newDate == null) return;
          setState(() {
            newSchool.academicYearStartDate = convertDateTimeToYYYYMMDDFormat(_newDate);
            newSchool.academicYearEndDate ??=
                convertDateTimeToYYYYMMDDFormat(convertYYYYMMDDFormatToDateTime(newSchool.academicYearStartDate).add(const Duration(days: 300)));
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 30,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                  ),
                  if (newSchool.academicYearStartDate != null)
                    const SizedBox(
                      width: 15,
                    ),
                  if (newSchool.academicYearStartDate != null)
                    Text(
                      convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(newSchool.academicYearStartDate!)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget academicYearEndDatePicker() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: InkWell(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: newSchool.academicYearStartDate != null
                ? convertYYYYMMDDFormatToDateTime(newSchool.academicYearStartDate).add(const Duration(days: 300))
                : DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 2 * 365)),
            lastDate: DateTime.now().add(const Duration(days: 2 * 365)),
            helpText: "Select academic year end date",
          );
          if (_newDate == null) return;
          setState(() {
            newSchool.academicYearEndDate = convertDateTimeToYYYYMMDDFormat(_newDate);
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 30,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                  ),
                  if (newSchool.academicYearEndDate != null)
                    const SizedBox(
                      width: 15,
                    ),
                  if (newSchool.academicYearEndDate != null)
                    Text(
                      convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(newSchool.academicYearEndDate!)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textBox(
    TextEditingController controller, {
    String? labelText,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
        ),
        controller: controller,
      ),
    );
  }
}
