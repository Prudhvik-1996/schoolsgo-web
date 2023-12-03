import 'package:clay_containers/widgets/clay_container.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/update_mobile_number_and_password/modal/update_phone_number_and_password.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/school_management/student_card_widget_v2.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentLoginCredentials extends StatefulWidget {
  const StudentLoginCredentials({
    super.key,
    required this.adminProfile,
  });

  final AdminProfile adminProfile;

  @override
  State<StudentLoginCredentials> createState() => _StudentLoginCredentialsState();
}

class _StudentLoginCredentialsState extends State<StudentLoginCredentials> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Section? selectedSection;
  List<Section> sectionsList = [];
  bool _isSectionPickerOpen = false;

  List<StudentProfile> studentsList = [];
  List<StudentProfile> filteredStudentsList = [];
  String? searchingWith;

  final ScrollController dataTableController = ScrollController();
  TextEditingController studentNameSearchController = TextEditingController();
  TextEditingController studentRollNoSearchController = TextEditingController();
  TextEditingController phoneNoSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }
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
      setState(() {
        studentsList = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
        studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      });
      filterStudentsList();
    }
    setState(() => _isLoading = false);
  }

  void filterStudentsList() => setState(() {
        filteredStudentsList = studentsList.where((e) => selectedSection != null ? e.sectionId == selectedSection?.sectionId : true).toList();
        if (studentNameSearchController.text.trim().isNotEmpty) {
          filteredStudentsList = filteredStudentsList.where((student) {
            String searchObject = [
                  ((student.rollNumber ?? "") == "" ? "" : student.rollNumber! + "."),
                  student.studentFirstName ?? "",
                  student.studentMiddleName ?? "",
                  student.studentLastName ?? ""
                ].where((e) => e != "").join(" ").trim() +
                " - ${student.sectionName}";
            return searchObject.toLowerCase().contains(studentNameSearchController.text.trim().toLowerCase());
          }).toList();
        }
        if (studentRollNoSearchController.text.trim().isNotEmpty) {
          filteredStudentsList =
              filteredStudentsList.where((es) => (es.rollNumber ?? "").contains(studentRollNoSearchController.text.trim())).toList();
        }
        if (phoneNoSearchController.text.trim().isNotEmpty) {
          filteredStudentsList = filteredStudentsList.where((es) => (es.gaurdianMobile ?? "").contains(phoneNoSearchController.text.trim())).toList();
        }
      });

  void _downloadReport() {
    setState(() => _isLoading = true);
    // Create an Excel workbook
    var excel = Excel.createExcel();
    var columnCount = 6;

    for (Section eachSection in sectionsList) {
      // Add a sheet to the workbook
      Sheet sheet = excel[eachSection.sectionName ?? "-"];

      List<StudentProfile> sectionWiseStudents = studentsList.where((es) => es.sectionId == eachSection.sectionId).toList();

      int rowIndex = 0;

      // Append the school name
      sheet.appendRow(["${widget.adminProfile.schoolName}"]);
      // Apply formatting to the school name cell
      CellStyle schoolNameStyle = CellStyle(
        bold: true,
        fontSize: 24,
        horizontalAlign: HorizontalAlign.Center,
      );
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = schoolNameStyle;
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: columnCount, rowIndex: 0));
      rowIndex++;

      // Define the headers for the columns
      sheet.appendRow(['Roll No.', 'Admission No.', 'Class', 'Student Name', 'Guardian Name', 'Mobile', 'Password']);
      for (int i = 0; i <= columnCount; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
          backgroundColorHex: 'FF000000',
          fontColorHex: 'FFFFFFFF',
        );
      }
      rowIndex++;

      // Add the data rows to the sheet
      for (StudentProfile eachStudent in sectionWiseStudents) {
        sheet.appendRow([
          eachStudent.rollNumber,
          eachStudent.admissionNo,
          eachStudent.sectionName,
          eachStudent.studentFirstName,
          eachStudent.gaurdianFirstName,
          eachStudent.gaurdianMobile,
          (eachStudent.gaurdianMobile ?? "") == "" ? "-" : eachStudent.password ?? "",
        ]);
        rowIndex++;
      }

      // Deleting default sheet
      if (excel.getDefaultSheet() != null) {
        excel.delete(excel.getDefaultSheet()!);
      }

      sheet.appendRow(["Downloaded: ${convertEpochToDDMMYYYYEEEEHHMMAA(DateTime.now().millisecondsSinceEpoch)}"]);
      CellStyle downloadTimeStyle = CellStyle(
        bold: true,
        fontSize: 9,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
      );
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle = downloadTimeStyle;
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), CellIndex.indexByColumnRow(columnIndex: columnCount, rowIndex: rowIndex));

      // Auto fit the columns
      for (var i = 1; i < sheet.maxCols; i++) {
        sheet.setColAutoFit(i);
      }
    }

    // Generate the Excel file as bytes
    var excelBytes = excel.encode();
    if (excelBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      Uint8List excelUint8List = Uint8List.fromList(excelBytes);

      // Save the Excel file
      FileSaver.instance.saveFile(bytes: excelUint8List, name: 'Student Login Credentials ${widget.adminProfile.schoolName ?? ""}.xlsx');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Login Credentials"),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: () => _downloadReport(),
              icon: const Icon(Icons.download),
            ),
        ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
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
              children: [
                const SizedBox(height: 20),
                _sectionPicker(),
                const SizedBox(height: 20),
                populateDataTableForCreds(selectedSection),
              ],
            ),
    );
  }

  Widget _selectSectionExpanded() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () {
              if (_isLoading) return;
              setState(() {
                _isSectionPickerOpen = !_isSectionPickerOpen;
              });
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                selectedSection == null ? "Select a section" : "Sections:",
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
            shrinkWrap: true,
            children: sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      height: 60,
      child: selectedSection != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_isLoading) return;
                      setState(() {
                        _isSectionPickerOpen = !_isSectionPickerOpen;
                      });
                    },
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName!}",
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  child: const Icon(Icons.close),
                  onTap: () {
                    setState(() {
                      selectedSection = null;
                    });
                    filterStudentsList();
                  },
                ),
                const SizedBox(width: 10),
              ],
            )
          : InkWell(
              onTap: () {
                if (_isLoading) return;
                setState(() {
                  _isSectionPickerOpen = !_isSectionPickerOpen;
                });
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 14, 5, 14),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName!}",
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          if (_isLoading) return;
          setState(() {
            if (selectedSection != null && selectedSection!.sectionId == section.sectionId) {
              selectedSection = null;
            } else {
              selectedSection = section;
            }
            _isSectionPickerOpen = false;
          });
          filterStudentsList();
        },
        child: ClayButton(
          depth: 40,
          color: selectedSection != null && selectedSection!.sectionId == section.sectionId ? Colors.blue[200] : clayContainerColor(context),
          spread: selectedSection != null && selectedSection!.sectionId == section.sectionId! ? 0 : 2,
          borderRadius: 10,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              section.sectionName!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: _isSectionPickerOpen
            ? ClayContainer(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                child: _selectSectionExpanded(),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget populateDataTableForCreds(Section? selectedSection) {
    if (selectedSection == null) return const Center(child: Text("Select a section to continue.."));
    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width - 20,
      child: Scrollbar(
        thumbVisibility: true,
        controller: dataTableController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: dataTableController,
          child: DataTable(
            columns: [
              DataColumn(
                numeric: true,
                label: Row(
                  children: [
                    searchingWith == "Roll No."
                        ? SizedBox(
                            width: 100,
                            child: TextField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Roll No.',
                                hintText: 'Roll No.',
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              controller: studentRollNoSearchController,
                              autofocus: true,
                              onChanged: (_) {
                                filterStudentsList();
                              },
                            ),
                          )
                        : const Text("Roll No."),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        editSearchingWith(searchingWith == "Roll No." ? null : "Roll No.");
                        filterStudentsList();
                      },
                      icon: Icon(
                        searchingWith != "Roll No." ? Icons.search : Icons.close,
                      ),
                    ),
                  ],
                ),
                onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
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
                              onChanged: (_) {
                                filterStudentsList();
                              },
                            ),
                          )
                        : const Text("Student Name"),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        editSearchingWith(searchingWith == "Student Name" ? null : "Student Name");
                        filterStudentsList();
                      },
                      icon: Icon(
                        searchingWith != "Student Name" ? Icons.search : Icons.close,
                      ),
                    ),
                  ],
                ),
                onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
              ),
              DataColumn(
                label: const Text("Parent Name"),
                onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
              ),
              DataColumn(
                numeric: true,
                label: Row(
                  children: [
                    searchingWith == "Phone Number"
                        ? SizedBox(
                            width: 100,
                            child: TextField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Phone Number',
                                hintText: 'Phone Number',
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              controller: phoneNoSearchController,
                              keyboardType: TextInputType.phone,
                              autofocus: true,
                              onChanged: (_) {
                                filterStudentsList();
                              },
                            ),
                          )
                        : const Text("Phone Number"),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        editSearchingWith(searchingWith == "Phone Number" ? null : "Phone Number");
                        filterStudentsList();
                      },
                      icon: Icon(
                        searchingWith != "Phone Number" ? Icons.search : Icons.close,
                      ),
                    ),
                  ],
                ),
                onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
              ),
              const DataColumn(label: Text("Password")),
            ],
            rows: [
              ...filteredStudentsList.where((StudentProfile es) => es.sectionId == selectedSection.sectionId).map(
                    (es) => DataRow(
                      cells: [
                        DataCell(
                          placeholder: true,
                          onTap: () {
                            editStudentDetails(es);
                          },
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(es.rollNumber ?? ""),
                          ),
                        ),
                        DataCell(Text(es.studentFirstName ?? "")),
                        DataCell(Text(es.gaurdianFirstName ?? "")),
                        DataCell(
                          (es.gaurdianMobile ?? "").isEmpty
                              ? const Center(child: Text("-"))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(es.gaurdianMobile ?? ""),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      onPressed: () => launch("tel://${es.gaurdianMobile}"),
                                      icon: const Icon(
                                        Icons.phone,
                                        size: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                        ),
                        resetPinInAlertDialogueButton(es),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  DataCell resetPinInAlertDialogueButton(StudentProfile es) {
    return DataCell(
      onTap: () async {
        if (es.gaurdianId == null || (es.gaurdianMobile ?? "").isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Edit the guardian details first and then edit the password"),
              action: SnackBarAction(
                label: "Edit Guardian Details",
                onPressed: () => editStudentDetails(es),
              ),
            ),
          );
          return;
        }
        await showDialog(
          context: scaffoldKey.currentContext!,
          barrierDismissible: false,
          builder: (currentContext) {
            bool isWaitingOnServer = false;
            return AlertDialog(
              title: const Text("Reset Password"),
              actions: [
                TextButton(
                  onPressed: () async {
                    setState(() => isWaitingOnServer = true);
                    ResetPinRequest resetPinRequest = ResetPinRequest(
                      loginUserId: es.loginId,
                    );
                    ResetPinResponse resetPinResponse = await resetPin(resetPinRequest);
                    if (resetPinResponse.httpStatus != "OK" || resetPinResponse.responseStatus != "success") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Something went wrong! Try again later.."),
                        ),
                      );
                    } else {
                      setState(() => es.password = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Pin reset successful.."),
                        ),
                      );
                    }
                    setState(() => isWaitingOnServer = false);
                    Navigator.pop(context);
                  },
                  child: isWaitingOnServer ? const CircularProgressIndicator() : const Text("YES"),
                ),
                if (!isWaitingOnServer)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No"),
                  ),
              ],
            );
          },
        );
      },
      ClayButton(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: es.password == null ? clayContainerColor(context) : Colors.blue,
        spread: es.password == null ? 0 : 2,
        borderRadius: 10,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Text("Reset PIN"),
        ),
      ),
    );
  }

  DataCell editPinInAlertDialogueButton(StudentProfile es) {
    return DataCell(
      placeholder: true,
      showEditIcon: true,
      onTap: () async {
        if (es.gaurdianId == null || (es.gaurdianMobile ?? "").isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Edit the guardian details first and then edit the password"),
              action: SnackBarAction(
                label: "Edit Guardian Details",
                onPressed: () => editStudentDetails(es),
              ),
            ),
          );
          return;
        }
        await showDialog(
          context: scaffoldKey.currentContext!,
          barrierDismissible: false,
          builder: (currentContext) {
            bool isWaitingOnServer = false;
            return AlertDialog(
              title: const Text("Edit Password"),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return TextFormField(
                    autofocus: true,
                    initialValue: es.password ?? "",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      errorText: (es.password ?? "").isEmpty
                          ? "Password cannot be empty"
                          : (es.password?.length ?? 0) < 6
                              ? "Password must be exactly 6 digits"
                              : "",
                      border: const UnderlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        try {
                          final text = newValue.text;
                          if (text.length > 6) return oldValue;
                          if (text.isNotEmpty) int.parse(text);
                          return newValue;
                        } catch (e) {
                          return oldValue;
                        }
                      }),
                    ],
                    onChanged: (String? newText) => setState(() => es.password = newText),
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if ((es.password ?? "").trim().isEmpty || (es.password?.length ?? 0) < 6) return;
                    setState(() => isWaitingOnServer = true);
                    UpdatePhoneNumberPasswordResponse updatePhoneNumberPasswordResponse =
                        await updatePhoneNumberPassword(UpdatePhoneNumberPasswordRequest(
                      agent: widget.adminProfile.userId,
                      newPassword: es.password,
                      newPhoneNumber: es.gaurdianMobile,
                      oldPhoneNumber: es.gaurdianMobile,
                    ));
                    if (updatePhoneNumberPasswordResponse.httpStatus != "OK" || updatePhoneNumberPasswordResponse.responseStatus != "success") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Something went wrong! Try again later.."),
                        ),
                      );
                    }
                    setState(() => isWaitingOnServer = false);
                    Navigator.pop(context);
                  },
                  child: isWaitingOnServer ? const CircularProgressIndicator() : const Text("YES"),
                ),
                if (!isWaitingOnServer)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No"),
                  ),
              ],
            );
          },
        );
      },
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Text((es.gaurdianMobile ?? "") == "" ? "-" : es.password ?? ""),
      ),
    );
  }

  void editSearchingWith(String? newSearchingWith) => setState(() {
        studentNameSearchController.text = "";
        studentRollNoSearchController.text = "";
        phoneNoSearchController.text = "";
        searchingWith = newSearchingWith;
      });

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        filteredStudentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0)));
      } else {
        filteredStudentsList.sort((a, b) => (int.tryParse(b.rollNumber ?? "") ?? 0).compareTo((int.tryParse(a.rollNumber ?? "") ?? 0)));
      }
    } else if (columnIndex == 1) {
      if (ascending) {
        filteredStudentsList.sort((a, b) => (a.studentFirstName ?? "").compareTo((b.studentFirstName ?? "")));
      } else {
        filteredStudentsList.sort((a, b) => (b.studentFirstName ?? "").compareTo((a.studentFirstName ?? "")));
      }
    } else if (columnIndex == 2) {
      if (ascending) {
        filteredStudentsList.sort((a, b) => (a.gaurdianFirstName ?? "").compareTo((b.gaurdianFirstName ?? "")));
      } else {
        filteredStudentsList.sort((a, b) => (b.gaurdianFirstName ?? "").compareTo((a.gaurdianFirstName ?? "")));
      }
    } else if (columnIndex == 3) {
      if (ascending) {
        filteredStudentsList.sort((a, b) => (a.gaurdianMobile ?? "").compareTo((b.gaurdianMobile ?? "")));
      } else {
        filteredStudentsList.sort((a, b) => (b.gaurdianMobile ?? "").compareTo((a.gaurdianMobile ?? "")));
      }
    }
    setState(() => debugPrint("Sorted based on $columnIndex"));
  }

  void editStudentDetails(StudentProfile es) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return StudentCardWidgetV2(
            studentProfile: es,
            sections: sectionsList,
            adminProfile: widget.adminProfile,
            students: studentsList,
            isEditMode: true,
          );
        },
      ),
    ).then((value) => setState(() => debugPrint("Set the student profile")));
  }
}
