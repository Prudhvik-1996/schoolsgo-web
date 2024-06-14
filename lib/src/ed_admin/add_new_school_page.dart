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
    newSchool.academicYearStartDate = "2024-06-01";
    newSchool.academicYearEndDate = "2025-05-01";
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
                textBox(newSchool.cityController, labelText: "City", hintText: "City"),
                textBox(
                  newSchool.detailedAddressController,
                  labelText: "Detailed Address",
                  hintText: "Detailed Address",
                  multiLine: true,
                ),
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
            String schoolName = (school?.schoolName ?? "");
            try {
              String academicStartYear = ((school?.academicYearStartDate) ?? "").split("-")[0];
              String academicEndYear = ((school?.academicYearEndDate) ?? "").split("-")[0];
              return "$schoolName [$academicStartYear - $academicEndYear]";
            } catch (_, e) {
              return schoolName;
            }
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, SchoolInfoBean? school) {
            return Text(school?.schoolName ?? "-");
          },
          onChanged: (SchoolInfoBean? school) {
            setState(() {
              newSchool = CreateOrUpdateSchoolInfoRequest.fromJson(school?.origJson() ?? {});
              if (school == null) return;
              newSchool.agent = widget.userId;
              newSchool.schoolId = null;
              newSchool.academicYearStartDate = "2024-06-01";
              newSchool.academicYearEndDate = "2024-05-01";
              newSchool.linkedSchoolId = school.schoolId;
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
        onTap: () async {
          if (newSchool.academicYearStartDate == null || newSchool.academicYearEndDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Both academic year start date and end date are mandatory fields"),
              ),
            );
            return;
          }
          if ((newSchool.schoolNameController.text) == '') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("School Name is mandatory"),
              ),
            );
            return;
          } else {
            newSchool.schoolName = newSchool.schoolNameController.text;
          }
          if ((newSchool.cityController.text) == '') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("City is mandatory"),
              ),
            );
            return;
          } else {
            newSchool.city = newSchool.cityController.text;
          }
          // if ((newSchool.mailId ?? '') == '') {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text("Mail Id is mandatory"),
          //     ),
          //   );
          //   return;
          // }
          if ((newSchool.mobileController.text) == '') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Mobile is mandatory"),
              ),
            );
            return;
          } else {
            newSchool.mobile = newSchool.mobileController.text;
          }
          setState(() => _isLoading = true);
          CreateOrUpdateSchoolInfoResponse createOrUpdateSchoolInfoResponse = await createOrUpdateSchoolInfo(newSchool);
          if (createOrUpdateSchoolInfoResponse.httpStatus != "OK" || createOrUpdateSchoolInfoResponse.responseStatus != "success") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Something went wrong! Try again later.."),
              ),
            );
          } else {
            Navigator.pop(context);
          }
          setState(() => _isLoading = false);
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
            initialDate: newSchool.academicYearStartDate != null ? convertYYYYMMDDFormatToDateTime(newSchool.academicYearStartDate) : DateTime.now(),
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
            initialDate: newSchool.academicYearEndDate != null
                ? convertYYYYMMDDFormatToDateTime(newSchool.academicYearEndDate)
                : newSchool.academicYearStartDate != null
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
    bool multiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
        ),
        controller: controller,
        maxLines: multiLine ? 5 : 1,
      ),
    );
  }
}
