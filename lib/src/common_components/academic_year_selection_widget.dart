import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/academic_years.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcademicYearDropdown extends StatefulWidget {
  final int? schoolId;

  const AcademicYearDropdown({
    Key? key,
    this.schoolId,
  }) : super(key: key);

  @override
  _AcademicYearDropdownState createState() => _AcademicYearDropdownState();
}

class _AcademicYearDropdownState extends State<AcademicYearDropdown> {
  bool _isLoading = true;
  List<AcademicYearBean> academicYears = [];
  int? selectedAcademicYearId;

  bool shouldShowDropDown = false;

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
    setState(() {
      selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID');
    });

    if (widget.schoolId != null) {
      GetSchoolWiseAcademicYearsResponse response = await getSchoolWiseAcademicYears(
        GetSchoolWiseAcademicYearsRequest(schoolId: widget.schoolId),
      );

      if (response.httpStatus == "OK" && response.responseStatus == "success") {
        setState(() {
          academicYears = response.academicYearBeanList?.whereNotNull().toList() ?? [];
        });

        if (academicYears.isNotEmpty) {
          if (selectedAcademicYearId != null) {
            if (academicYears.any((e) => e.academicYearId == selectedAcademicYearId)) {
              setState(() {
                selectedAcademicYearId = selectedAcademicYearId;
              });
            } else {
              await updateSelectedAcademicYear(academicYears.first.academicYearId!);
            }
          } else {
            await updateSelectedAcademicYear(academicYears.first.academicYearId!);
          }
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> updateSelectedAcademicYear(int academicYearId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('SELECTED_ACADEMIC_YEAR_ID', academicYearId);
    setState(() {
      selectedAcademicYearId = academicYearId;
      shouldShowDropDown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SizedBox(
            width: 50,
            child: CircularProgressIndicator(),
          )
        : !shouldShowDropDown
            ? IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  setState(() {
                    shouldShowDropDown = true;
                  });
                },
              )
            : SizedBox(
                width: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        minLeadingWidth: 10,
                        leading: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () {
                            setState(() {
                              shouldShowDropDown = false;
                            });
                          },
                        ),
                        title: SizedBox(
                          width: 150,
                          child: GestureDetector(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: DropdownButton<AcademicYearBean>(
                              isExpanded: true,
                              underline: Container(),
                              value: academicYears.firstWhereOrNull((e) => e.academicYearId == selectedAcademicYearId),
                              onChanged: (AcademicYearBean? newAcademicYear) async {
                                if (newAcademicYear?.academicYearId != null) {
                                  await updateSelectedAcademicYear(newAcademicYear!.academicYearId!);
                                }
                              },
                              items: academicYears
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(e.formattedString()),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
  }
}
