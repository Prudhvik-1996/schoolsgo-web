import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/widgets/clay_container.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class NewReceiptWidget extends StatefulWidget {
  const NewReceiptWidget({
    Key? key,
    required this.newReceipt,
  }) : super(key: key);

  final NewReceipt newReceipt;

  @override
  State<NewReceiptWidget> createState() => _NewReceiptWidgetState();
}

class _NewReceiptWidgetState extends State<NewReceiptWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
          : const EdgeInsets.all(10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Row(
                children: [
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      "New Receipt",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _deleteReceiptButton(context),
                  const SizedBox(width: 15),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _receiptTextField(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _getDatePicker(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _studentSearchableDropDown(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _sectionSearchableDropDown(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              ...widget.newReceipt.feeToBePaidBeans.map((e) => feeToBePaidWidget(e)).toList(),
              const SizedBox(height: 10),
              if (widget.newReceipt.selectedStudent != null && (widget.newReceipt.totalBusFee ?? 0) != 0) buildBusFeePayableWidget(context),
              if (widget.newReceipt.selectedStudent != null) buildModeOfPayment(context),
            ],
          ),
        ),
      ),
    );
  }

  Container buildModeOfPayment(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Row(
            children: [
              const SizedBox(width: 10),
              const Expanded(child: Text("Mode Of Payment:")),
              const SizedBox(width: 20),
              DropdownButton(
                  value: widget.newReceipt.modeOfPayment,
                  items: ModeOfPayment.values
                      .map((e) => DropdownMenuItem<ModeOfPayment>(
                            value: e,
                            child: Text(e.description),
                            onTap: () {
                              widget.newReceipt.notifyParent(() {
                                widget.newReceipt.modeOfPayment = e;
                              });
                            },
                          ))
                      .toList(),
                  onChanged: (ModeOfPayment? e) {
                    widget.newReceipt.notifyParent(() {
                      widget.newReceipt.modeOfPayment = e ?? ModeOfPayment.CASH;
                    });
                  }),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  Container buildBusFeePayableWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Row(
            children: [
              Checkbox(
                onChanged: (bool? value) {
                  if (value == null) return;
                  if (value) {
                    widget.newReceipt.notifyParent(() {
                      widget.newReceipt.isBusFeeChecked = value;
                      widget.newReceipt.busFeeController.text =
                          doubleToStringAsFixedForINR(((widget.newReceipt.totalBusFee ?? 0) - (widget.newReceipt.busFeePaid ?? 0)) / 100.0);
                    });
                  } else {
                    widget.newReceipt.notifyParent(() {
                      widget.newReceipt.isBusFeeChecked = value;
                      widget.newReceipt.busFeeController.text = "";
                    });
                  }
                },
                value: widget.newReceipt.isBusFeeChecked,
              ),
              const SizedBox(width: 5),
              const SizedBox(width: 15),
              const CustomVerticalDivider(),
              const SizedBox(width: 15),
              const Expanded(
                child: Text("Bus Fee"),
              ),
              const SizedBox(width: 10),
              Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((widget.newReceipt.totalBusFee ?? 0) / 100)} /-"),
              const SizedBox(width: 20),
              _feePayingTextField(),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _feePayingTextField() {
    return SizedBox(
      width: 100,
      height: 40,
      child: InputDecorator(
        isFocused: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          label: Text(
            "$INR_SYMBOL ${doubleToStringAsFixedForINR((widget.newReceipt.busFeePaid ?? 0) / 100)} /-",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        child: TextField(
          enabled: (widget.newReceipt.totalBusFee ?? 0) - (widget.newReceipt.busFeePaid ?? 0) != 0,
          onTap: () {
            widget.newReceipt.busFeeController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: widget.newReceipt.busFeeController.text.length,
            );
          },
          controller: widget.newReceipt.busFeeController,
          keyboardType: TextInputType.number,
          textAlignVertical: TextAlignVertical.center,
          maxLines: 1,
          onChanged: (String e) {
            if (e.isNotEmpty) {
              widget.newReceipt.notifyParent(() {
                widget.newReceipt.isBusFeeChecked = true;
              });
            } else {
              widget.newReceipt.notifyParent(() {
                widget.newReceipt.isBusFeeChecked = false;
              });
            }
          },
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Amount",
          ),
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                if (newValue.text == "") return newValue;
                final text = newValue.text;
                double payingAmount = double.parse(text);
                if (payingAmount * 100 > (widget.newReceipt.totalBusFee ?? 0) - (widget.newReceipt.busFeePaid ?? 0)) {
                  return oldValue;
                }
                return newValue;
              } catch (e) {
                return oldValue;
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget feeToBePaidWidget(FeeToBePaid feeToBePaid) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(""),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                      onTap: () {
                        if (feeToBePaid.isExpanded == null) {
                          setState(() {
                            feeToBePaid.isExpanded = true;
                          });
                          widget.newReceipt.notifyParent(() {});
                        } else if (feeToBePaid.isExpanded!) {
                          setState(() {
                            feeToBePaid.isExpanded = false;
                          });
                          widget.newReceipt.notifyParent(() {});
                        } else {
                          setState(() {
                            feeToBePaid.isExpanded = true;
                          });
                          widget.newReceipt.notifyParent(() {});
                        }
                      },
                      child: (feeToBePaid.isExpanded ?? false) ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down)),
                  const SizedBox(width: 15),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ...(feeToBePaid.feeTypes ?? []).map((e) => e.widget(context)).toList(),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector _deleteReceiptButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showDialog<void>(
          context: widget.newReceipt.context,
          builder: (currentContext) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: const Text("Fee Receipts"),
                content: const Text("Are you sure you want to delete the receipt?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => widget.newReceipt.status = "deleted");
                      widget.newReceipt.notifyParent(() {});
                    },
                    child: const Text("YES"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("NO"),
                  ),
                ],
              );
            });
          },
        );
      },
      child: ClayButton(
        color: clayContainerColor(context),
        borderRadius: 100,
        spread: 2,
        child: const Padding(
          padding: EdgeInsets.all(15),
          child: Center(
            child: Icon(Icons.delete, color: Colors.red),
          ),
        ),
      ),
    );
  }

  SizedBox _receiptTextField() {
    return SizedBox(
      width: 50,
      height: 40,
      child: InputDecorator(
        isFocused: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          label: Text(
            "Receipt",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        child: TextField(
          controller: widget.newReceipt.receiptNumberController,
          keyboardType: TextInputType.number,
          maxLines: 1,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 12),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Receipt No.",
          ),
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                if (newValue.text == "") return newValue;
                final text = newValue.text;
                if (text.isNotEmpty) int.parse(text);
                if (double.parse(text) > 0) {
                  return newValue;
                } else {
                  return oldValue;
                }
              } catch (e) {
                return oldValue;
              }
            }),
          ],
          onChanged: (String e) {
            widget.newReceipt.receiptNumber = int.tryParse(e);
          },
        ),
      ),
    );
  }

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              setState(() => widget.newReceipt.selectedDate = widget.newReceipt.selectedDate.subtract(const Duration(days: 1)));
            },
            child: ClayButton(
              color: clayContainerColor(context),
              height: 20,
              width: 20,
              spread: 1,
              borderRadius: 10,
              depth: 40,
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(Icons.arrow_left),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                DateTime? _newDate = await showDatePicker(
                  context: context,
                  initialDate: widget.newReceipt.selectedDate,
                  firstDate: DateTime(2021),
                  lastDate: DateTime.now(),
                  helpText: "Pick  date to mark attendance",
                );
                setState(() {
                  widget.newReceipt.selectedDate = _newDate ?? widget.newReceipt.selectedDate;
                });
              },
              child: ClayButton(
                color: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                depth: 40,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            convertDateTimeToDDMMYYYYFormat(widget.newReceipt.selectedDate),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () async {
              if (convertDateTimeToDDMMYYYYFormat(widget.newReceipt.selectedDate) == convertDateTimeToDDMMYYYYFormat(DateTime.now())) return;
              setState(() => widget.newReceipt.selectedDate = widget.newReceipt.selectedDate.add(const Duration(days: 1)));
            },
            child: ClayButton(
              color: clayContainerColor(context),
              height: 20,
              width: 20,
              spread: 1,
              borderRadius: 10,
              depth: 40,
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(Icons.arrow_right),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentSearchableDropDown() {
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
          "Student",
          style: TextStyle(color: Colors.grey),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: DropdownSearch<StudentProfile>(
          mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
          selectedItem: widget.newReceipt.selectedStudent,
          items: widget.newReceipt.studentProfiles
              .where((e) => widget.newReceipt.selectedSection == null || widget.newReceipt.selectedSection?.sectionId == e.sectionId)
              .toList(),
          itemAsString: (StudentProfile? student) {
            return student == null
                ? ""
                : [
                      ((student.rollNumber ?? "") == "" ? "" : student.rollNumber! + "."),
                      student.studentFirstName ?? "",
                      student.studentMiddleName ?? "",
                      student.studentLastName ?? ""
                    ].where((e) => e != "").join(" ").trim() +
                    " - ${student.sectionName}";
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, StudentProfile? student) {
            return buildStudentWidget(student ?? StudentProfile());
          },
          onChanged: (StudentProfile? student) {
            setState(() {
              widget.newReceipt.selectedSection = widget.newReceipt.sectionsList.where((e) => e.sectionId == student?.sectionId).firstOrNull;
            });
            widget.newReceipt.updatedSelectedStudent(student, setState);
          },
          showClearButton: false,
          compareFn: (item, selectedItem) => item?.studentId == selectedItem?.studentId,
          dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
          filterFn: (StudentProfile? student, String? key) {
            return ([
                      ((student?.rollNumber ?? "") == "" ? "" : student!.rollNumber! + "."),
                      student?.studentFirstName ?? "",
                      student?.studentMiddleName ?? "",
                      student?.studentLastName ?? ""
                    ].where((e) => e != "").join(" ") +
                    " - ${student?.sectionName ?? ""}")
                .toLowerCase()
                .trim()
                .contains(key!.toLowerCase());
          },
        ),
      ),
    );
  }

  Widget buildStudentWidget(StudentProfile e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: ListTile(
        leading: MediaQuery.of(context).orientation == Orientation.portrait
            ? null
            : Container(
                width: 50,
                padding: const EdgeInsets.all(5),
                child: e.studentPhotoUrl == null
                    ? Image.asset(
                        "assets/images/avatar.png",
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        e.studentPhotoUrl!,
                        fit: BoxFit.contain,
                      ),
              ),
        title: AutoSizeText(
          ((e.rollNumber ?? "") == "" ? "" : e.rollNumber! + ". ") +
              ([e.studentFirstName ?? "", e.studentMiddleName ?? "", e.studentLastName ?? ""].where((e) => e != "").join(" ") +
                      " - ${e.sectionName ?? ""}")
                  .trim(),
          style: const TextStyle(
            fontSize: 14,
          ),
          overflow: TextOverflow.visible,
          maxLines: 3,
          minFontSize: 12,
        ),
      ),
    );
  }

  Widget _sectionSearchableDropDown() {
    return InputDecorator(
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
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: DropdownSearch<Section>(
          mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
          selectedItem: widget.newReceipt.selectedSection,
          items: widget.newReceipt.sectionsList,
          itemAsString: (Section? section) {
            return section == null ? "" : section.sectionName ?? "-";
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, Section? section) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(widget.newReceipt.selectedSection?.sectionName ?? "-"),
            );
          },
          onChanged: (Section? section) {
            setState(() {
              widget.newReceipt.selectedSection = section;
            });
            widget.newReceipt.updatedSelectedStudent(null, setState);
          },
          showClearButton: false,
          compareFn: (item, selectedItem) => item?.sectionId == selectedItem?.sectionId,
          dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
          filterFn: (Section? section, String? key) {
            return (section?.sectionName ?? "").toLowerCase().contains(key!.toLowerCase());
          },
        ),
      ),
    );
  }
}

class NewReceipt {
  BuildContext context;
  TextEditingController receiptNumberController = TextEditingController();

  int? receiptNumber;
  DateTime selectedDate;

  List<Section> sectionsList;
  List<StudentProfile> studentProfiles;
  List<StudentFeeDetailsBean> studentFeeDetails;
  List<StudentTermWiseFeeSupportBean> studentTermWiseFeeBeans;
  List<StudentAnnualFeeSupportBean> studentAnnualFeeBeanBeans;

  List<FeeType> feeTypes;

  Section? selectedSection;
  StudentProfile? selectedStudent;

  String status = "active";
  final Function notifyParent;

  List<FeeToBePaid> feeToBePaidBeans = [];
  TextEditingController busFeeController = TextEditingController();
  bool isBusFeeChecked = false;

  int? totalBusFee;
  int? busFeePaid;
  late List<StudentBusFeeLogBean> busFeeBeans;

  ModeOfPayment modeOfPayment = ModeOfPayment.CASH;

  NewReceipt({
    required this.context,
    required this.notifyParent,
    required this.receiptNumber,
    required this.selectedDate,
    required this.sectionsList,
    required this.studentProfiles,
    required this.studentFeeDetails,
    required this.studentTermWiseFeeBeans,
    required this.studentAnnualFeeBeanBeans,
    required this.feeTypes,
    required this.totalBusFee,
    required this.busFeePaid,
    required this.busFeeBeans,
  }) {
    receiptNumberController.text = receiptNumber?.toString() ?? "";
    studentProfiles.sort((a, b) => ((a.sectionId ?? 0)).compareTo((b.sectionId ?? 0)) != 0
        ? ((a.sectionId ?? 0)).compareTo((b.sectionId ?? 0))
        : ((int.tryParse(a.rollNumber ?? "") ?? 0)).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0)) != 0
            ? ((int.tryParse(a.rollNumber ?? "") ?? 0)).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))
            : (((a.studentFirstName ?? ""))).compareTo(((b.studentFirstName ?? ""))));
  }

  void updatedSelectedStudent(StudentProfile? newStudent, Function setState) {
    setState(() {
      selectedStudent = newStudent;
      populateStudentTermWiseFeeDetails(selectedStudentId: newStudent?.studentId);
      feeToBePaidBeans = getFeeToBePaidBeans();
    });
    notifyParent(() {});
  }

  void populateStudentTermWiseFeeDetails({int? selectedStudentId}) {
    if (selectedStudentId == null) return;
    for (var studentTermWiseFeeBean in studentTermWiseFeeBeans.where((e) => e.studentId == selectedStudentId)) {
      var filteredStudentFeeDetailsBeans = studentFeeDetails.where((studentFeeDetailsBean) =>
          studentFeeDetailsBean.studentId == selectedStudentId &&
          (studentFeeDetailsBean.studentWiseFeeTypeDetailsList ?? [])
              .where((studentWiseFeeTypeDetailsBean) =>
                  studentTermWiseFeeBean.studentId == studentWiseFeeTypeDetailsBean?.studentId &&
                  studentTermWiseFeeBean.feeTypeId == studentWiseFeeTypeDetailsBean?.feeTypeId &&
                  (studentTermWiseFeeBean.customFeeTypeId == null ||
                      studentTermWiseFeeBean.customFeeTypeId == studentWiseFeeTypeDetailsBean?.customFeeTypeId))
              .isEmpty);
      for (var studentFeeDetailsBean in filteredStudentFeeDetailsBeans.where((e) => e.studentId == selectedStudentId)) {
        studentFeeDetailsBean.studentWiseFeeTypeDetailsList!.add(StudentWiseFeeTypeDetailsBean(
          studentId: studentTermWiseFeeBean.studentId,
          sectionId: studentTermWiseFeeBean.sectionId,
          schoolId: studentTermWiseFeeBean.schoolId,
          feeTypeId: studentTermWiseFeeBean.feeTypeId,
          feeType: studentTermWiseFeeBean.feeType,
          customFeeTypeId: studentTermWiseFeeBean.customFeeTypeId,
          customFeeType: studentTermWiseFeeBean.customFeeType,
          studentTermWiseFeeTypeDetailsList: [],
        ));
      }
    }
    for (var studentTermWiseFeeBean in studentTermWiseFeeBeans.where((e) => e.studentId == selectedStudentId)) {
      for (var studentFeeDetailsBean
          in studentFeeDetails.where((studentFeeDetailsBean) => (studentTermWiseFeeBean.studentId == studentFeeDetailsBean.studentId))) {
        for (var studentWiseFeeTypeDetailsBean in (studentFeeDetailsBean.studentWiseFeeTypeDetailsList ?? [])) {
          if ((studentWiseFeeTypeDetailsBean?.feeTypeId == studentTermWiseFeeBean.feeTypeId) &&
              (studentTermWiseFeeBean.customFeeTypeId == null ||
                  (studentTermWiseFeeBean.customFeeTypeId == studentWiseFeeTypeDetailsBean?.customFeeTypeId))) {
            studentWiseFeeTypeDetailsBean?.studentTermWiseFeeTypeDetailsList!.add(
              StudentTermWiseFeeTypeDetailsBean(
                studentId: studentTermWiseFeeBean.studentId,
                sectionId: studentTermWiseFeeBean.sectionId,
                schoolId: studentTermWiseFeeBean.schoolId,
                feeTypeId: studentTermWiseFeeBean.feeTypeId,
                customFeeTypeId: studentTermWiseFeeBean.customFeeTypeId,
                termId: studentTermWiseFeeBean.termId,
                termName: studentTermWiseFeeBean.termName,
                termWiseTotalFee: studentTermWiseFeeBean.termWiseAmount,
                termWiseTotalFeePaid: studentTermWiseFeeBean.termWiseAmountPaid,
              ),
            );
          }
        }
      }
    }
    totalBusFee = studentFeeDetails.where((e) => e.studentId == selectedStudentId).map((e) => e.busFee).firstOrNull;
    busFeePaid = studentFeeDetails
        .where((e) => e.studentId == selectedStudentId)
        .map((e) => e.studentFeeTransactionList ?? [])
        .expand((i) => i)
        .map((e) => e?.studentFeeChildTransactionList ?? [])
        .expand((i) => i)
        .where((e) => e?.feeTypeId == null || e?.feeTypeId == -1)
        .firstOrNull
        ?.feePaidAmount;
  }

  Widget widget() {
    return NewReceiptWidget(
      newReceipt: this,
    );
  }

  List<FeeToBePaid> getFeeToBePaidBeans() {
    if (selectedStudent == null) return [];
    StudentFeeDetailsBean? feeDetails = studentFeeDetails.where((e) => e.studentId == selectedStudent?.studentId).firstOrNull;
    if (feeDetails == null) return [];
    List<FeeToBePaid> feeToBePaidBeans = [];
    feeToBePaidBeans.add(FeeToBePaid(
      context,
      notifyParent,
      selectedStudent?.studentId,
      [selectedStudent?.studentFirstName ?? "", selectedStudent?.studentMiddleName ?? "", selectedStudent?.studentLastName ?? ""]
          .where((e) => e != "")
          .join(" "),
      null,
      null,
      null,
    ));

    for (var eachFeeToBePaidBean in feeToBePaidBeans) {
      eachFeeToBePaidBean.feeTypes = feeTypes.map((eachFeeType) {
        return FeeTypeForNewReceipt(
          eachFeeType.feeTypeId,
          eachFeeType.feeType,
          null,
          null,
          (eachFeeType.customFeeTypesList ?? [])
              .where((e) => e != null)
              .map((e) => e!)
              .map((eachCustomFeeType) => CustomFeeTypeForNewReceipt(
                    eachCustomFeeType.feeTypeId,
                    eachCustomFeeType.customFeeTypeId,
                    eachCustomFeeType.customFeeType,
                    null,
                    null,
                    notifyParent,
                  ))
              .toList(),
          notifyParent,
        );
      }).toList();
    }

    for (FeeToBePaid eachFeeToBePaidBean in feeToBePaidBeans) {
      for (FeeTypeForNewReceipt eachFeeTypeFeeToBePaidBean in (eachFeeToBePaidBean.feeTypes ?? [])) {
        if ((eachFeeTypeFeeToBePaidBean.customFeeTypes ?? []).isNotEmpty) {
          for (CustomFeeTypeForNewReceipt eachTermWiseCustomFeeTypeFee in (eachFeeTypeFeeToBePaidBean.customFeeTypes ?? [])) {
            StudentAnnualFeeSupportBean? studentWiseCustomFeeTypeDetails = ((studentAnnualFeeBeanBeans)
                .where((e) =>
                    e.studentId == selectedStudent?.studentId &&
                    e.feeTypeId == eachFeeTypeFeeToBePaidBean.feeTypeId &&
                    e.customFeeTypeId == eachTermWiseCustomFeeTypeFee.customFeeTypeId)
                .firstOrNull);
            eachTermWiseCustomFeeTypeFee.fee = studentWiseCustomFeeTypeDetails?.amount;
            eachTermWiseCustomFeeTypeFee.feePaid = studentWiseCustomFeeTypeDetails?.amountPaid;
          }
        } else {
          StudentAnnualFeeSupportBean? studentWiseFeeTypeDetails = ((studentAnnualFeeBeanBeans)
              .where((e) => e.studentId == selectedStudent?.studentId && e.feeTypeId == eachFeeTypeFeeToBePaidBean.feeTypeId)
              .firstOrNull);
          eachFeeTypeFeeToBePaidBean.fee = studentWiseFeeTypeDetails?.amount;
          eachFeeTypeFeeToBePaidBean.feePaid = studentWiseFeeTypeDetails?.amountPaid;
        }
      }
    }

    for (var eachFeeToBePaidBean in feeToBePaidBeans) {
      eachFeeToBePaidBean.totalFee = (eachFeeToBePaidBean.feeTypes ?? [])
          .map((e) => (e.customFeeTypes ?? []).isEmpty ? e.fee : (e.customFeeTypes ?? []).map((e) => e.fee).reduce((a1, a2) => (a1 ?? 0) + (a2 ?? 0)))
          .reduce((a1, a2) => (a1 ?? 0) + (a2 ?? 0));
      eachFeeToBePaidBean.totalFeesPaid = (eachFeeToBePaidBean.feeTypes ?? [])
          .map((e) =>
              (e.customFeeTypes ?? []).isEmpty ? e.feePaid : (e.customFeeTypes ?? []).map((e) => e.feePaid).reduce((a1, a2) => (a1 ?? 0) + (a2 ?? 0)))
          .reduce((a1, a2) => (a1 ?? 0) + (a2 ?? 0));
    }

    for (FeeToBePaid eachTerm in feeToBePaidBeans) {
      if ((eachTerm.totalFee ?? 0) > (eachTerm.totalFeesPaid ?? 0)) {
        eachTerm.isExpanded = true;
        break;
      }
    }

    return feeToBePaidBeans;
  }

  @override
  String toString() {
    return """{"studentId": ${selectedStudent?.studentId}, "receiptNumber": $receiptNumber, "termWiseFeeToBePaidBeans": $feeToBePaidBeans}""";
  }
}

class FeeToBePaid {
  BuildContext context;
  Function notifyParent;
  int? studentId;
  String? studentName;
  int? totalFee;
  int? totalFeesPaid;

  List<FeeTypeForNewReceipt>? feeTypes;

  bool? isExpanded;

  FeeToBePaid(
    this.context,
    this.notifyParent,
    this.studentId,
    this.studentName,
    this.totalFee,
    this.totalFeesPaid,
    this.feeTypes,
  );

  @override
  String toString() {
    return '{studentId: $studentId, studentName: $studentName, termWiseTotalFee: $totalFee, termWiseTotalFeesPaid: $totalFeesPaid, termWiseFeeTypes: $feeTypes}';
  }
}

class FeeTypeForNewReceipt {
  int? feeTypeId;
  String? feeType;
  int? fee;
  int? feePaid;
  List<CustomFeeTypeForNewReceipt>? customFeeTypes;
  Function notifyParent;

  FeeTypeForNewReceipt(
    this.feeTypeId,
    this.feeType,
    this.fee,
    this.feePaid,
    this.customFeeTypes,
    this.notifyParent,
  );

  TextEditingController feePayingController = TextEditingController();
  bool isChecked = false;

  Widget widget(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            (customFeeTypes ?? []).isEmpty
                ? Checkbox(
                    onChanged: (bool? value) {
                      if (value == null) return;
                      if (value) {
                        notifyParent(() {
                          isChecked = value;
                          feePayingController.text = doubleToStringAsFixedForINR(((fee ?? 0) - (feePaid ?? 0)) / 100.0);
                        });
                      } else {
                        notifyParent(() {
                          isChecked = value;
                          feePayingController.text = "";
                        });
                      }
                    },
                    value: isChecked,
                  )
                : Container(),
            (customFeeTypes ?? []).isEmpty ? const SizedBox(width: 10) : Container(),
            Expanded(
              child: Text(feeType ?? "-"),
            ),
            const SizedBox(width: 10),
            (customFeeTypes ?? []).isEmpty
                ? Text(
                    "$INR_SYMBOL ${doubleToStringAsFixedForINR((fee ?? 0) / 100)} /-",
                  )
                : Container(),
            const SizedBox(width: 20),
            (customFeeTypes ?? []).isEmpty ? _feePayingTextField(context) : Container(),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ...(customFeeTypes ?? []).map((e) => e.widget(context)).toList(),
      ],
    );
  }

  SizedBox _feePayingTextField(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 40,
      child: InputDecorator(
        isFocused: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          label: Text(
            "$INR_SYMBOL ${doubleToStringAsFixedForINR((feePaid ?? 0) / 100)} /-",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        child: TextField(
          enabled: (fee ?? 0) - (feePaid ?? 0) != 0,
          onTap: () {
            feePayingController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: feePayingController.text.length,
            );
          },
          controller: feePayingController,
          keyboardType: TextInputType.number,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Amount",
          ),
          onChanged: (String e) {
            if (e.isNotEmpty) {
              notifyParent(() {
                isChecked = true;
              });
            } else {
              notifyParent(() {
                isChecked = false;
              });
            }
          },
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                if (newValue.text == "") return newValue;
                final text = newValue.text;
                double payingAmount = double.parse(text);
                if (payingAmount * 100 > (fee ?? 0) - (feePaid ?? 0)) {
                  return oldValue;
                }
                return newValue;
              } catch (e) {
                return oldValue;
              }
            }),
          ],
        ),
      ),
    );
  }

  @override
  String toString() {
    if ((customFeeTypes ?? []).isEmpty && feePayingController.text.trim().isNotEmpty && feePayingController.text.trim() != "0") {
      return """{"feeTypeId": $feeTypeId, "feeType": "$feeType", "customFeeTypeId": null, "customFeeType": null, "feePaying": ${feePayingController.text}}""";
    }
    if ((customFeeTypes ?? []).isNotEmpty) {
      return customFeeTypes?.map((e) => e.toString()).join(",") ?? "";
    }
    // return '_TermWiseFeeType{termId: $termId, feeTypeId: $feeTypeId, feeType: $feeType, termWiseFee: $termWiseFee, termWiseFeePaid: $termWiseFeePaid, termWiseCustomFeeTypes: $termWiseCustomFeeTypes, feePayingController: $feePayingController}';
    return "";
  }
}

class CustomFeeTypeForNewReceipt {
  int? feeTypeId;
  int? customFeeTypeId;
  String? customFeeType;
  int? fee;
  int? feePaid;
  Function notifyParent;

  CustomFeeTypeForNewReceipt(
    this.feeTypeId,
    this.customFeeTypeId,
    this.customFeeType,
    this.fee,
    this.feePaid,
    this.notifyParent,
  );

  TextEditingController feePayingController = TextEditingController();
  bool isChecked = false;

  Widget widget(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              onChanged: (bool? value) {
                if (value == null) return;
                if (value) {
                  notifyParent(() {
                    isChecked = value;
                    feePayingController.text = doubleToStringAsFixedForINR(((fee ?? 0) - (feePaid ?? 0)) / 100.0);
                  });
                } else {
                  notifyParent(() {
                    isChecked = value;
                    feePayingController.text = "";
                  });
                }
              },
              value: isChecked,
            ),
            const SizedBox(width: 5),
            const SizedBox(width: 15),
            const CustomVerticalDivider(),
            const SizedBox(width: 15),
            Expanded(
              child: Text(customFeeType ?? "-"),
            ),
            const SizedBox(width: 10),
            Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((fee ?? 0) / 100)} /-"),
            const SizedBox(width: 20),
            _feePayingTextField(context),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  SizedBox _feePayingTextField(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 40,
      child: InputDecorator(
        isFocused: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          label: Text(
            "$INR_SYMBOL ${doubleToStringAsFixedForINR((feePaid ?? 0) / 100)} /-",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        child: TextField(
          enabled: (fee ?? 0) - (feePaid ?? 0) != 0,
          onTap: () {
            feePayingController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: feePayingController.text.length,
            );
          },
          controller: feePayingController,
          keyboardType: TextInputType.number,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Amount",
          ),
          textAlign: TextAlign.center,
          onChanged: (String e) {
            if (e.isNotEmpty) {
              notifyParent(() {
                isChecked = true;
              });
            } else {
              notifyParent(() {
                isChecked = false;
              });
            }
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                if (newValue.text == "") return newValue;
                final text = newValue.text;
                double payingAmount = double.parse(text);
                if (payingAmount * 100 > (fee ?? 0) - (feePaid ?? 0)) {
                  return oldValue;
                }
                return newValue;
              } catch (e) {
                return oldValue;
              }
            }),
          ],
        ),
      ),
    );
  }

  @override
  String toString() {
    if (feePayingController.text.trim().isNotEmpty && feePayingController.text.trim() != "0") {
      return """{"feeTypeId": $feeTypeId, "feeType": null, "customFeeTypeId": $customFeeTypeId, "customFeeType": "$customFeeType", "feePaying": ${feePayingController.text}}""";
    }
    // return '_TermWiseCustomFeeType{termId: $termId, feeTypeId: $feeTypeId, customFeeTypeId: $customFeeTypeId, customFeeType: $customFeeType, termWiseFee: $termWiseFee, termWiseFeePaid: $termWiseFeePaid, feePayingController: $feePayingController}';
    return "";
  }
}

Future<NewReceipt> getNewReceipt(
  BuildContext context,
  Function notifyParent,
  DateTime selectedDate,
  List<Section> sectionsList,
  List<StudentProfile> studentProfiles,
  List<StudentFeeDetailsBean> studentFeeDetails,
  List<StudentTermWiseFeeSupportBean> studentTermWiseFeeBeans,
  List<StudentAnnualFeeSupportBean> studentAnnualFeeBeanBeans,
  List<FeeType> feeTypes,
  int? totalBusFee,
  int? busFeePaid,
  List<StudentBusFeeLogBean> busFeeBeans,
  int schoolId,
) async {
  // receiptNumberController.text = receiptNumber?.toString() ?? "";
  studentProfiles.sort((a, b) => ((a.sectionId ?? 0)).compareTo((b.sectionId ?? 0)) != 0
      ? ((a.sectionId ?? 0)).compareTo((b.sectionId ?? 0))
      : ((int.tryParse(a.rollNumber ?? "") ?? 0)).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0)) != 0
          ? ((int.tryParse(a.rollNumber ?? "") ?? 0)).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))
          : (((a.studentFirstName ?? ""))).compareTo(((b.studentFirstName ?? ""))));
  int receiptNumber = await loadLatestReceiptNumber(schoolId);
  return NewReceipt(
    context: context,
    notifyParent: notifyParent,
    receiptNumber: receiptNumber,
    selectedDate: selectedDate,
    sectionsList: sectionsList,
    studentProfiles: studentProfiles,
    studentFeeDetails: studentFeeDetails,
    studentTermWiseFeeBeans: studentTermWiseFeeBeans,
    studentAnnualFeeBeanBeans: studentAnnualFeeBeanBeans,
    feeTypes: feeTypes,
    totalBusFee: totalBusFee,
    busFeePaid: busFeePaid,
    busFeeBeans: busFeeBeans,
  );
}

Future<int> loadLatestReceiptNumber(int schoolId) async {
  int? receiptNumber = -1; // TODO
  return receiptNumber;
}
