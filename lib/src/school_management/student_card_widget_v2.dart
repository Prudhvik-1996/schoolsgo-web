import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class StudentCardWidgetV2 extends StatefulWidget {
  const StudentCardWidgetV2({
    Key? key,
    required this.studentProfile,
    required this.students,
    required this.sections,
    required this.adminProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;
  final List<StudentProfile> students;
  final List<Section> sections;
  final AdminProfile? adminProfile;

  @override
  State<StudentCardWidgetV2> createState() => _StudentCardWidgetV2State();
}

class _StudentCardWidgetV2State extends State<StudentCardWidgetV2> {
  bool _isLoading = true;
  bool _isEditMode = false;

  bool isBasicDetailsExpanded = true;
  bool isParentDetailsExpanded = false;
  bool isNationalityDetailsExpanded = false;
  bool isAddressDetailsExpanded = false;
  bool isPreviousSchoolRecordDetailsExpanded = false;
  bool isCustomDetailsExpanded = false;
  bool isAdditionalMobileDetailsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Bio"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: Stack(
            children: [
              ListView(
                children: [
                  basicDetails(),
                ],
              ),
              if (_isLoading)
                Center(
                  child: Image.asset(
                    'assets/images/eis_loader.gif',
                    height: 500,
                    width: 500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget basicDetails() {
    /**
     * Admission No.
     * Section
     * Student Name
     * Student Sex
     * Student DOB
     */
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  children: [
                    admissionNumberRow(),
                    sectionRow(),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              studentPhotoWidget(),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 10),
          studentNameRow(),
          const SizedBox(height: 10),
          studentSexRow(),
          const SizedBox(height: 10),
          studentDobRow(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Row studentDobRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        const Text("Date Of Birth"),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(),
              ),
            ),
            child: GestureDetector(
              onTap: () async {
                if (_isEditMode) return;
                DateTime? _newDate = await showDatePicker(
                  context: context,
                  initialDate: convertYYYYMMDDFormatToDateTime(widget.studentProfile.studentDob),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  helpText: "Pick Student Date Of Birth",
                );
                setState(() {
                  widget.studentProfile.studentDob = convertDateTimeToYYYYMMDDFormat(_newDate);
                });
              },
              child: Text(
                widget.studentProfile.studentDob == null
                    ? "-"
                    : convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(widget.studentProfile.studentDob)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Row studentSexRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        const Expanded(child: Text("Sex")),
        const SizedBox(width: 10),
        Expanded(
          child: RadioListTile<String?>(
            value: "male",
            groupValue: widget.studentProfile.sex,
            onChanged: (String? value) {
              setState(() {
                widget.studentProfile.sex = value;
              });
            },
            title: const Text("Male"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RadioListTile<String?>(
            value: "female",
            groupValue: widget.studentProfile.sex,
            onChanged: (String? value) {
              setState(() {
                widget.studentProfile.sex = value;
              });
            },
            title: const Text("Female"),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Row studentNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 10),
        const Text("Student Name"),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: widget.studentProfile.studentNameController,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Container studentPhotoWidget() {
    return Container(
      height: 100,
      width: 80,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: widget.studentProfile.studentPhotoUrl == null
          ? const FittedBox(fit: BoxFit.scaleDown, child: Text("Student\nPhoto"))
          : Image.network(
              widget.studentProfile.studentPhotoUrl!,
              fit: BoxFit.scaleDown,
            ),
    );
  }

  Row sectionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        const Text("Section"),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            width: 100,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: DropdownButton<Section>(
                hint: const Center(child: Text("Select Section")),
                value: widget.sections.where((e) => e.sectionId == widget.studentProfile.sectionId).firstOrNull,
                onChanged: (Section? section) {
                  setState(() {
                    widget.studentProfile.sectionId = section?.sectionId;
                    widget.studentProfile.sectionName = section?.sectionName;
                  });
                },
                items: widget.sections
                    .map(
                      (e) => DropdownMenuItem<Section>(
                        value: e,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 40,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                e.sectionName ?? "-",
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Row admissionNumberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        const Text("Admission No."),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: widget.studentProfile.admissionNoController,
            keyboardType: const TextInputType.numberWithOptions(),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  parentDetails() {
    /**
     * Siblings from same school Dropdown
     * Father's Name
     * Mother's Name
     * Auto populate gaurdian name, email, mobile with father's details
     * Father's qualification, occupation, salary
     * Mother's qualification, occupation, salary
     */
  }

  nationalityDetails() {
    /**
     * Aadhaar Number
     * Aadhaar scanned copy
     * Nationality
     * Religion
     * Caste
     * Category
     * Mother Tongue
     */
  }

  addressDetails() {
    /**
     * Address for communication
     * Permanent Address
     */
  }

  previousSchoolRecordDetails() {
    /**
     * Data Table for PrevSchoolRecord
     */
  }

  customDetails() {
    /**
     * key value pairs, value being text field
     */
  }

  additionalMobileDetails() {
    /**
     * Addable list for additional mobiles
     */
  }
}
