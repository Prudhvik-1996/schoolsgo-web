import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  bool _isOtherLoading = true;
  bool _isEditMode = false;

  final ScrollController _controller = ScrollController();

  bool isBasicDetailsExpanded = true;
  bool isParentDetailsExpanded = false;
  bool isNationalityDetailsExpanded = false;
  bool isAddressDetailsExpanded = false;
  bool isPreviousSchoolRecordDetailsExpanded = false;
  bool isCustomDetailsExpanded = false;
  bool isAdditionalMobileDetailsExpanded = false;

  StudentProfile? sibling;

  List<AdditionalMobile> additionalMobileNumbers = [AdditionalMobile("")];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isOtherLoading = false;
    });
    setState(() => _isLoading = false);
  }

  Future<void> saveChanges() async {
    setState(() => _isLoading = true);
    CreateOrUpdateStudentProfileRequest createOrUpdateStudentProfileRequest =
        CreateOrUpdateStudentProfileRequest.fromStudentProfile(widget.adminProfile?.userId, widget.studentProfile);
    CreateOrUpdateStudentProfileResponse createOrUpdateStudentProfileResponse =
        await createOrUpdateStudentProfile(createOrUpdateStudentProfileRequest);
    if (createOrUpdateStudentProfileResponse.httpStatus != "OK" || createOrUpdateStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      setState(() => _isLoading = false);
    } else {
      GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
        schoolId: widget.adminProfile?.schoolId,
        studentId: widget.studentProfile.studentId ?? createOrUpdateStudentProfileResponse.studentId,
      ));
      if (getStudentProfileResponse.httpStatus != "OK" ||
          getStudentProfileResponse.responseStatus != "success" ||
          (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        widget.studentProfile.modifyAsPerJson(
            (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList().firstOrNull?.origJson() ?? {});
      }
      setState(() => _isLoading = false);
    }
    setState(() {
      _isEditMode = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Profile"),
        actions: [
          if (!_isEditMode)
            IconButton(
              onPressed: () {
                setState(() => _isEditMode = true);
              },
              icon: const Icon(Icons.edit),
            ),
          if (_isEditMode)
            IconButton(
              onPressed: () async {
                setState(() {
                  widget.studentProfile.fromControllers();
                });
                if (widget.studentProfile.isModified()) {
                  showDialog(
                    context: _scaffoldKey.currentContext!,
                    builder: (currentContext) {
                      return AlertDialog(
                        title: const Text("Student Profile"),
                        content: const Text("Are you sure you want to save changes?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              saveChanges();
                              // _loadData();
                            },
                            child: const Text("YES"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                widget.studentProfile.modifyAsPerJson(widget.studentProfile.origJson());
                                _isEditMode = false;
                              });
                            },
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() => _isEditMode = true);
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
                      );
                    },
                  );
                }
                setState(() => _isEditMode = false);
              },
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : AbsorbPointer(
              absorbing: _isOtherLoading,
              child: Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: ListView(
                      children: [
                        Scrollbar(
                          thumbVisibility: true,
                          controller: _controller,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _controller,
                            child: Container(
                              margin: MediaQuery.of(context).orientation == Orientation.landscape
                                  ? const EdgeInsets.fromLTRB(50, 8, 50, 8)
                                  : const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  basicDetails(),
                                  const SizedBox(height: 10),
                                  Divider(
                                    thickness: 2,
                                    color: clayContainerTextColor(context),
                                  ),
                                  const SizedBox(height: 10),
                                  parentDetails(),
                                  const SizedBox(height: 10),
                                  nationalityDetails(),
                                  const SizedBox(height: 10),
                                  addressDetails(),
                                  const SizedBox(height: 10),
                                  previousSchoolRecordDetails(),
                                  const SizedBox(height: 10),
                                  identificationMarksDetails(),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isOtherLoading)
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
    );
  }

  Widget detailHeaderWidget(String headerText) {
    return SizedBox(
      width: 200,
      child: Text(
        headerText,
        overflow: TextOverflow.clip,
        maxLines: 2,
      ),
    );
  }

  Widget headerWidget(String headerText) {
    return Text(
      headerText,
      style: GoogleFonts.archivoBlack(
        textStyle: const TextStyle(
          fontSize: 24,
          color: Colors.blue,
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
          headerWidget("Student Details"),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    admissionNumberRow(),
                    const SizedBox(height: 10),
                    rollNumberRow(),
                    const SizedBox(height: 10),
                    sectionRow(),
                  ],
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width >= 600 ? MediaQuery.of(context).size.width - 600 : 10),
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
        detailHeaderWidget("Date of birth"),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: clayContainerTextColor(context)),
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
        detailHeaderWidget("Sex"),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: RadioListTile<String?>(
            value: "male",
            groupValue: widget.studentProfile.sex,
            onChanged: (String? value) {
              setState(() {
                widget.studentProfile.sex = value;
              });
            },
            title: const SizedBox(
              width: 80,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text("Male"),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: RadioListTile<String?>(
            value: "female",
            groupValue: widget.studentProfile.sex,
            onChanged: (String? value) {
              setState(() {
                widget.studentProfile.sex = value;
              });
            },
            title: const SizedBox(
              width: 80,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text("Female"),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Row studentNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Student Name"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode,
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
        detailHeaderWidget("Section"),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: DropdownButton<Section>(
              hint: const Center(child: Text("Select Section")),
              value: widget.sections.where((e) => e.sectionId == widget.studentProfile.sectionId).firstOrNull,
              onChanged: widget.studentProfile.studentId == null
                  ? (Section? section) {
                      setState(() {
                        widget.studentProfile.sectionId = section?.sectionId;
                        widget.studentProfile.sectionName = section?.sectionName;
                      });
                    }
                  : null,
              items: widget.sections
                  .map(
                    (e) => DropdownMenuItem<Section>(
                      value: e,
                      child: SizedBox(
                        width: 75,
                        height: 50,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              e.sectionName ?? "-",
                              textAlign: TextAlign.center,
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
        const SizedBox(width: 10),
      ],
    );
  }

  Row rollNumberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Roll No."),
        const SizedBox(width: 10),
        SizedBox(
          width: 75,
          child: TextFormField(
            enabled: _isEditMode,
            controller: widget.studentProfile.rollNumberController,
            keyboardType: const TextInputType.numberWithOptions(),
            textAlign: TextAlign.left,
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
        detailHeaderWidget("Admission No."),
        const SizedBox(width: 10),
        SizedBox(
          width: 75,
          child: TextFormField(
            enabled: _isEditMode,
            controller: widget.studentProfile.admissionNoController,
            keyboardType: const TextInputType.numberWithOptions(),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget parentDetails() {
    /**
     * Siblings from same school Dropdown
     * Father's Name
     * Father's qualification, occupation, salary
     * Mother's Name
     * Mother's qualification, occupation, salary
     * Auto populate gaurdian name, email, mobile with father's details
     */
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Parent Details"),
          const SizedBox(height: 20),
          selectSiblingWidget(),
          const SizedBox(height: 10),
          ...fatherDetailsRows(),
          const SizedBox(height: 10),
          ...motherDetailsRows(),
          const SizedBox(height: 10),
          ...gaurdianDetailsRows(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              detailHeaderWidget("Additional Mobiles"),
              const SizedBox(width: 10),
              Column(
                children: [
                  ...additionalMobileNumbersRows(),
                  const SizedBox(height: 10),
                  addNewMobileNumberRow(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget addNewMobileNumberRow() {
    return Row(
      children: [
        const SizedBox(width: 110),
        GestureDetector(
          onTap: () {
            setState(() {
              additionalMobileNumbers.add(AdditionalMobile(""));
            });
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            spread: 2,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  Icons.add,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> additionalMobileNumbersRows() {
    return additionalMobileNumbers
        .map((e) => <Widget>[
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      enabled: _isEditMode && (sibling == null || e.controller.text.trim().isEmpty),
                      controller: e.controller,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        additionalMobileNumbers.remove(e);
                      });
                    },
                    child: ClayButton(
                      color: clayContainerColor(context),
                      height: 30,
                      width: 30,
                      borderRadius: 50,
                      spread: 2,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ])
        .expand((i) => i)
        .toList();
  }

  List<Widget> gaurdianDetailsRows() {
    return [
      const SizedBox(height: 10),
      gaurdianNameRow(),
      const SizedBox(height: 10),
      gaurdianEmailAddressRow(),
      const SizedBox(height: 10),
      gaurdianMobile(),
      const SizedBox(height: 10),
    ];
  }

  Widget gaurdianNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Guardian Name"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.gaurdianNameController.text.trim().isEmpty),
            controller: widget.studentProfile.gaurdianNameController,
            keyboardType: TextInputType.name,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget gaurdianEmailAddressRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Guardian Email"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.emailController.text.trim().isEmpty),
            controller: widget.studentProfile.emailController,
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget gaurdianMobile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Guardian Mobile"),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.phoneController.text.trim().isEmpty),
            controller: widget.studentProfile.phoneController,
            keyboardType: TextInputType.phone,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  List<Widget> motherDetailsRows() {
    return [
      const SizedBox(height: 10),
      motherNameRow(),
      const SizedBox(height: 10),
      motherOccupationWidget(),
      const SizedBox(height: 10),
      motherAnnualIncomeWidget(),
      const SizedBox(height: 10),
    ];
  }

  Widget motherAnnualIncomeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Mother Annual Income"),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.motherAnnualIncomeController.text.trim().isEmpty),
            controller: widget.studentProfile.motherAnnualIncomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.left,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')) // Allow numbers with up to 2 decimal places
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget motherOccupationWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Mother Occupation"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.motherOccupationController.text.trim().isEmpty),
            controller: widget.studentProfile.motherOccupationController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget motherNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Mother Name"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.motherNameController.text.trim().isEmpty),
            controller: widget.studentProfile.motherNameController,
            keyboardType: TextInputType.name,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  List<Widget> fatherDetailsRows() {
    return [
      const SizedBox(height: 10),
      fatherNameRow(),
      const SizedBox(height: 10),
      fatherOccupationWidget(),
      const SizedBox(height: 10),
      fatherAnnualIncomeWidget(),
      const SizedBox(height: 10),
    ];
  }

  Widget fatherAnnualIncomeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Father Annual Income"),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.fatherAnnualIncomeController.text.trim().isEmpty),
            controller: widget.studentProfile.fatherAnnualIncomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.left,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')) // Allow numbers with up to 2 decimal places
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget fatherOccupationWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Father Occupation"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.fatherOccupationController.text.trim().isEmpty),
            controller: widget.studentProfile.fatherOccupationController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget fatherNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Father Name"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.fatherNameController.text.trim().isEmpty),
            controller: widget.studentProfile.fatherNameController,
            keyboardType: TextInputType.name,
            textAlign: TextAlign.left,
            onChanged: (String? value) {
              if (widget.studentProfile.gaurdianNameController.text.trim().isNotEmpty) {
                setState(() {
                  widget.studentProfile.gaurdianNameController.text = value ?? "";
                });
              }
            },
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget selectSiblingWidget() {
    // TODO in read mode, show the list of siblings
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: const [
            SizedBox(width: 10),
            Text("Details of sibling already studying in this School"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            SizedBox(
              width: 300,
              child: DropdownSearch<StudentProfile>(
                enabled: true,
                mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
                selectedItem: sibling,
                items: widget.students,
                itemAsString: (StudentProfile? e) {
                  return e == null
                      ? "-"
                      : "${e.rollNumber ?? " - "}. ${e.studentFirstName ?? " - "} [${e.sectionName ?? " - "}] [${e.admissionNo ?? " - "}]";
                },
                showSearchBox: true,
                dropdownBuilder: (BuildContext context, StudentProfile? e) {
                  return Text(e == null
                      ? "-"
                      : "${e.rollNumber ?? " - "}. ${e.studentFirstName ?? " - "} [${e.sectionName ?? " - "}] [${e.admissionNo ?? " - "}]");
                },
                onChanged: (StudentProfile? selectedSibling) {
                  if (_isLoading) return;
                  setState(() {
                    sibling = selectedSibling;
                    widget.studentProfile.fatherNameController.text = selectedSibling?.fatherName?.trim() ?? "";
                    widget.studentProfile.fatherOccupationController.text = selectedSibling?.fatherOccupation?.trim() ?? "";
                    widget.studentProfile.fatherAnnualIncomeController.text = "${selectedSibling?.fatherAnnualIncome ?? ""}".trim();
                    widget.studentProfile.motherNameController.text = selectedSibling?.motherName?.trim() ?? "";
                    widget.studentProfile.motherOccupationController.text = selectedSibling?.motherOccupation?.trim() ?? "";
                    widget.studentProfile.motherAnnualIncomeController.text = "${selectedSibling?.motherAnnualIncome ?? ""}".trim();
                    widget.studentProfile.gaurdianNameController.text = selectedSibling?.gaurdianFirstName?.trim() ?? "";
                    widget.studentProfile.emailController.text = selectedSibling?.gaurdianMailId ?? "";
                    widget.studentProfile.phoneController.text = selectedSibling?.gaurdianMobile ?? "";
                    widget.studentProfile.nationalityController.text = (selectedSibling?.nationality ?? "").trim();
                    widget.studentProfile.religionController.text = (selectedSibling?.religion ?? "").trim();
                    widget.studentProfile.casteController.text = (selectedSibling?.caste ?? "").trim();
                    widget.studentProfile.motherTongueController.text = (selectedSibling?.motherTongue ?? "").trim();
                    widget.studentProfile.category = selectedSibling?.category;
                    widget.studentProfile.gaurdianId = selectedSibling?.gaurdianId;
                  });
                },
                showClearButton: true,
                compareFn: (item, selectedItem) => item?.studentId == selectedItem?.studentId,
                dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
                filterFn: (StudentProfile? e, String? key) {
                  return "${e?.rollNumber ?? " - "}. ${e?.studentFirstName ?? " - "} [${e?.sectionName ?? " - "}] [${e?.admissionNo ?? " - "}]"
                      .toLowerCase()
                      .replaceAll(" ", "")
                      .contains((key ?? "").toLowerCase().trim());
                },
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  Widget nationalityDetails() {
    /**
     * Aadhaar Number
     * Aadhaar scanned copy
     * Nationality
     * Religion
     * Caste
     * Category
     * Mother Tongue
     */
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Nationality Details"),
          const SizedBox(height: 20),
          aadhaarNumberRow(),
          const SizedBox(height: 10),
          aadhaarScannedCopyRow(),
          const SizedBox(height: 10),
          nationalityRow(),
          const SizedBox(height: 10),
          religionRow(),
          const SizedBox(height: 10),
          casteRow(),
          const SizedBox(height: 10),
          categoryRow(),
          const SizedBox(height: 10),
          motherTongueRow(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget motherTongueRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Mother Tongue"),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.motherTongueController.text.trim().isEmpty),
            controller: widget.studentProfile.motherTongueController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget categoryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Category"),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: DropdownButton<String>(
              hint: const Center(child: Text("Select Category")),
              value: CASTE_CATEGORIES.where((e) => e == widget.studentProfile.category).firstOrNull,
              onChanged: (String? category) {
                setState(() {
                  widget.studentProfile.category = category;
                });
              },
              items: CASTE_CATEGORIES
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: SizedBox(
                        width: 75,
                        height: 50,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              e,
                              textAlign: TextAlign.center,
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
        const SizedBox(width: 10),
      ],
    );
  }

  Widget casteRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Caste"),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.casteController.text.trim().isEmpty),
            controller: widget.studentProfile.casteController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget religionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Religion"),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.religionController.text.trim().isEmpty),
            controller: widget.studentProfile.religionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget nationalityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Nationality"),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            enabled: _isEditMode && (sibling == null || widget.studentProfile.nationalityController.text.trim().isEmpty),
            controller: widget.studentProfile.nationalityController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget aadhaarScannedCopyRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Aadhaar Document"),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.upload_file),
          onPressed: () {
            //  TODO
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget aadhaarNumberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Aadhaar Number"),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            enabled: _isEditMode,
            controller: widget.studentProfile.aadhaarNumberController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget addressDetails() {
    /**
     * Address for communication
     * Permanent Address
     */
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Address"),
          const SizedBox(height: 20),
          addressForCommunicationWidget(),
          const SizedBox(height: 10),
          permanentAddressWidget(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget addressForCommunicationWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Address For Communication"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            maxLines: null,
            minLines: 3,
            enabled: _isEditMode && (sibling == null || widget.studentProfile.addressForCommunicationController.text.trim().isEmpty),
            controller: widget.studentProfile.addressForCommunicationController,
            keyboardType: TextInputType.multiline,
            textAlign: TextAlign.left,
            onChanged: (String? value) {
              if ((value ?? "").trim().isNotEmpty) {
                setState(() {
                  widget.studentProfile.permanentAddressController.text = value ?? "";
                });
              }
            },
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget permanentAddressWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Permanent Address"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            maxLines: null,
            minLines: 3,
            enabled: _isEditMode && (sibling == null || widget.studentProfile.permanentAddressController.text.trim().isEmpty),
            controller: widget.studentProfile.permanentAddressController,
            keyboardType: TextInputType.multiline,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget previousSchoolRecordDetails() {
    /**
     * Data Table for PrevSchoolRecord
     */
    List<PreviousSchoolRecord> records = [];
    try {
      final v = jsonDecode(widget.studentProfile.previousSchoolRecords ?? "[]");
      final arr0 = <PreviousSchoolRecord>[];
      v.forEach((v) {
        arr0.add(PreviousSchoolRecord.fromJson(v));
      });
      records = arr0;
    } catch (e) {
      debugPrint("1196: Couldn't parse ${widget.studentProfile.previousSchoolRecords ?? "[]"}\n$e");
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Previous School Records"),
          const SizedBox(height: 20),
          SchoolRecordsTable(records, setPreviousSchoolRecords, _isEditMode),
        ],
      ),
    );
  }

  void setPreviousSchoolRecords(List<PreviousSchoolRecord> previousSchoolRecords) {
    final v = previousSchoolRecords;
    final arr0 = [];
    for (var v in v) {
      arr0.add(v.toJson());
    }
    setState(() => widget.studentProfile.previousSchoolRecords = jsonEncode(arr0));
  }

  Widget identificationMarksDetails() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget("Student Identification Marks"),
          const SizedBox(height: 20),
          identificationMarksRow(),
        ],
      ),
    );
  }

  Widget identificationMarksRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        detailHeaderWidget("Identification Marks"),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: TextFormField(
            enabled: _isEditMode,
            maxLines: null,
            minLines: 3,
            controller: widget.studentProfile.identificationMarksController,
            keyboardType: TextInputType.multiline,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  customDetails() {
    /**
     * key value pairs, value being text field
     */
  }
}

class AdditionalMobile {
  String? mobile;
  TextEditingController controller = TextEditingController();

  AdditionalMobile(this.mobile) {
    controller.text = mobile ?? "";
  }
}

class PreviousSchoolRecord {
  String? schoolName;
  String? yearsOfStudy;
  String? classPassed;

  PreviousSchoolRecord(this.schoolName, this.yearsOfStudy, this.classPassed);

  PreviousSchoolRecord.fromString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    schoolName = json['School Name'];
    yearsOfStudy = json['Years Of Study'];
    classPassed = json['Class Passed'];
  }

  PreviousSchoolRecord.fromJson(Map<String, dynamic> json) {
    schoolName = json['School Name'];
    yearsOfStudy = json['Years Of Study'];
    classPassed = json['Class Passed'];
  }

  Map<String, dynamic> toJson() {
    return {
      'School Name': schoolName,
      'Years Of Study': yearsOfStudy,
      'Class Passed': classPassed,
    };
  }
}

class SchoolRecordsTable extends StatefulWidget {
  const SchoolRecordsTable(this.records, this.setPreviousSchoolRecords, this.isEditMode, {super.key});

  final List<PreviousSchoolRecord> records;
  final Function setPreviousSchoolRecords;
  final bool isEditMode;

  @override
  _SchoolRecordsTableState createState() => _SchoolRecordsTableState();
}

class _SchoolRecordsTableState extends State<SchoolRecordsTable> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void addRecord() {
    setState(() {
      widget.records.add(PreviousSchoolRecord('', '', ''));
    });
    widget.setPreviousSchoolRecords(widget.records);
  }

  void deleteRecord(int index) {
    setState(() {
      widget.records.removeAt(index);
    });
    widget.setPreviousSchoolRecords(widget.records);
  }

  void updateRecord(int index, PreviousSchoolRecord record) {
    setState(() {
      widget.records[index] = record;
    });
    widget.setPreviousSchoolRecords(widget.records);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Scrollbar(
          thumbVisibility: true,
          controller: _controller,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _controller,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('School Name')),
                const DataColumn(label: Text('Years of Study')),
                const DataColumn(label: Text('Class Passed')),
                if (widget.isEditMode) const DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (int index = 0; index < widget.records.length; index++)
                  DataRow(
                    onSelectChanged: null,
                    cells: [
                      DataCell(
                        TextFormField(
                          enabled: widget.isEditMode,
                          initialValue: widget.records[index].schoolName,
                          onChanged: (value) => widget.records[index].schoolName = value,
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          enabled: widget.isEditMode,
                          initialValue: widget.records[index].yearsOfStudy,
                          onChanged: (value) => widget.records[index].yearsOfStudy = value,
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          enabled: widget.isEditMode,
                          initialValue: widget.records[index].classPassed,
                          onChanged: (value) => widget.records[index].classPassed = value,
                        ),
                      ),
                      if (widget.isEditMode)
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteRecord(index),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (widget.isEditMode)
          GestureDetector(
            onTap: addRecord,
            child: ClayButton(
              color: clayContainerColor(context),
              width: 150,
              borderRadius: 10,
              spread: 2,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Add Entry',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
