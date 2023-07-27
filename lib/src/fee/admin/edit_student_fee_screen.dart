import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class EditStudentFeeScreen extends StatefulWidget {
  const EditStudentFeeScreen({
    Key? key,
    required this.adminProfile,
    required this.studentWiseAnnualFeesBean,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final StudentAnnualFeeBean studentWiseAnnualFeesBean;

  @override
  State<EditStudentFeeScreen> createState() => _EditStudentFeeScreenState();
}

class _EditStudentFeeScreenState extends State<EditStudentFeeScreen> {
  bool _isLoading = true;
  late StudentAnnualFeeBean studentWiseAnnualFeesBean;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    studentWiseAnnualFeesBean = widget.studentWiseAnnualFeesBean;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    CreateOrUpdateStudentAnnualFeeMapRequest createOrUpdateStudentAnnualFeeMapRequest = CreateOrUpdateStudentAnnualFeeMapRequest(
      schoolId: widget.adminProfile.schoolId,
      agent: widget.adminProfile.userId,
      studentAnnualFeeMapBeanList: [widget.studentWiseAnnualFeesBean]
              .map((e) => e.studentAnnualFeeTypeBeans ?? [])
              .expand((i) => i)
              .where((e) => (e.studentAnnualCustomFeeTypeBeans ?? []).isEmpty)
              .map((e) => StudentAnnualFeeMapUpdateBean(
                    schoolId: widget.adminProfile.schoolId,
                    studentId: widget.studentWiseAnnualFeesBean.studentId,
                    amount: e.amount,
                    discount: e.discount,
                    comments: e.comments,
                    sectionFeeMapId: e.sectionFeeMapId,
                    studentFeeMapId: e.studentFeeMapId,
                  ))
              .toList() +
          [widget.studentWiseAnnualFeesBean]
              .map((e) => e.studentAnnualFeeTypeBeans ?? [])
              .expand((i) => i)
              .map((e) => e.studentAnnualCustomFeeTypeBeans ?? [])
              .expand((i) => i)
              .map((e) => StudentAnnualFeeMapUpdateBean(
                    schoolId: widget.adminProfile.schoolId,
                    studentId: widget.studentWiseAnnualFeesBean.studentId,
                    amount: e.amount,
                    discount: e.discount,
                    comments: e.comments,
                    sectionFeeMapId: e.sectionFeeMapId,
                    studentFeeMapId: e.studentFeeMapId,
                  ))
              .toList(),
      studentRouteStopFares: [widget.studentWiseAnnualFeesBean]
          .where((e) =>
                  e.studentBusFeeBean != null &&
                  e.studentId == widget.studentWiseAnnualFeesBean.studentId &&
                  (int.tryParse(e.studentBusFeeBean!.fareController.text)) != null
              // && (e.studentBusFeeBean!.fare ?? 0) != int.tryParse(e.studentBusFeeBean!.fareController.text)
              )
          .map((e) => StudentStopFare(
                studentId: widget.studentWiseAnnualFeesBean.studentId,
                fare: int.parse(e.studentBusFeeBean!.fareController.text) * 100,
              ))
          .toList(),
    );
    CreateOrUpdateStudentAnnualFeeMapResponse createOrUpdateStudentAnnualFeeMapResponse =
        await createOrUpdateStudentAnnualFeeMap(createOrUpdateStudentAnnualFeeMapRequest);
    if (createOrUpdateStudentAnnualFeeMapResponse.httpStatus == "OK" && createOrUpdateStudentAnnualFeeMapResponse.responseStatus == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Changes updated successfully"),
        ),
      );
      // await _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong, Please try again later.."),
        ),
      );
    }
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.studentWiseAnnualFeesBean.sectionName} - ${widget.studentWiseAnnualFeesBean.rollNumber ?? "-"} - ${widget.studentWiseAnnualFeesBean.studentName}"),
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
                feeTable(),
                const SizedBox(height: 250),
              ],
            ),
      floatingActionButton: _isLoading
          ? null
          : fab(
              const Icon(Icons.check),
              "Submit",
              () async => await _saveChanges(),
              color: Colors.green,
            ),
    );
  }

  Widget fab(Icon icon, String text, Function() action, {Function()? postAction, Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await action();
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (postAction != null) {
              await postAction();
            }
          });
        },
        child: ClayButton(
          surfaceColor: color ?? clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget feeTable() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(15),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _controller,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _controller,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Fee Type")),
                DataColumn(label: Text("Custom Fee Type")),
                DataColumn(label: Text("Fee")),
                DataColumn(label: Text("Discount")),
                DataColumn(label: Text("Amount Payable")),
                DataColumn(label: Text("Comments")),
              ],
              rows: [
                ...feeTypeRows(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> feeTypeRows() {
    List<DataRow> rows = [];
    for (StudentAnnualFeeTypeBean eachFeeType in studentWiseAnnualFeesBean.studentAnnualFeeTypeBeans ?? []) {
      if ((eachFeeType.studentAnnualCustomFeeTypeBeans ?? []).isEmpty) {
        setState(() => eachFeeType.actualAmount = (eachFeeType.amount ?? 0) + (eachFeeType.discount ?? 0));
        rows.add(
          DataRow(
            cells: [
              DataCell(Text(eachFeeType.feeType ?? "-")),
              const DataCell(Text("-")),
              DataCell(feeTypeAmountWidget(eachFeeType)),
              DataCell(feeTypeDiscountWidget(eachFeeType)),
              DataCell(Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeType.amount ?? 0) / 100)}")),
              DataCell(feeTypeCommentsWidget(eachFeeType)),
            ],
          ),
        );
      } else {
        for (StudentAnnualCustomFeeTypeBean eachCustomFeeTypeBean in (eachFeeType.studentAnnualCustomFeeTypeBeans ?? [])) {
          setState(() => eachCustomFeeTypeBean.actualAmount = (eachCustomFeeTypeBean.amount ?? 0) + (eachCustomFeeTypeBean.discount ?? 0));
          rows.add(
            DataRow(
              cells: [
                DataCell(Text(eachFeeType.feeType ?? "-")),
                DataCell(Text(eachCustomFeeTypeBean.customFeeType ?? "-")),
                DataCell(customFeeTypeAmountWidget(eachCustomFeeTypeBean)),
                DataCell(customFeeTypeDiscountWidget(eachCustomFeeTypeBean)),
                DataCell(Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachCustomFeeTypeBean.amount ?? 0) / 100)}")),
                DataCell(customFeeTypeCommentsWidget(eachCustomFeeTypeBean)),
              ],
            ),
          );
        }
      }
    }
    // if (studentWiseAnnualFeesBean.studentBusFeeBean != null && (studentWiseAnnualFeesBean.studentBusFeeBean?.fare) != null)
    rows.add(
      busFeeDataRow(),
    );
    return rows;
  }

  DataRow busFeeDataRow() {
    return DataRow(
      cells: [
        const DataCell(Text("Bus Fee")),
        DataCell(
          Text(
            "${studentWiseAnnualFeesBean.studentBusFeeBean?.stopName ?? " - "}\n${studentWiseAnnualFeesBean.studentBusFeeBean?.routeName ?? " - "}",
          ),
        ),
        DataCell(
          TextFormField(
            controller: studentWiseAnnualFeesBean.studentBusFeeBean!.fareController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
            ),
            maxLines: 1,
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.start,
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                try {
                  final text = newValue.text;
                  if (text.isNotEmpty) double.parse(text);
                  return newValue;
                } catch (e) {
                  debugPrintStack();
                }
                return oldValue;
              }),
            ],
          ),
        ),
        const DataCell(Text("-")),
        const DataCell(Text("-")),
        const DataCell(Text("-")),
      ],
    );
  }

  Widget feeTypeCommentsWidget(StudentAnnualFeeTypeBean eachFeeType) => TextFormField(
        initialValue: eachFeeType.comments ?? "-",
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
        ),
        onChanged: (String? newText) => setState(() => eachFeeType.comments = newText),
        maxLines: null,
        style: const TextStyle(
          fontSize: 16,
        ),
        textAlign: TextAlign.start,
      );

  Widget customFeeTypeCommentsWidget(StudentAnnualCustomFeeTypeBean eachCustomFeeType) => TextFormField(
        initialValue: eachCustomFeeType.comments ?? "-",
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
        ),
        onChanged: (String? newText) => setState(() => eachCustomFeeType.comments = newText),
        maxLines: null,
        style: const TextStyle(
          fontSize: 16,
        ),
        textAlign: TextAlign.start,
      );

  Widget feeTypeDiscountWidget(StudentAnnualFeeTypeBean eachFeeType) {
    // return Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeType.discount ?? 0) / 100)}");
    return TextFormField(
      initialValue: "${((eachFeeType.discount ?? 0) / 100)}",
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      onChanged: (String? newText) => setState(() {
        eachFeeType.discount = (int.tryParse(newText ?? "0") ?? 0) * 100;
        eachFeeType.amount = (eachFeeType.actualAmount ?? 0) - (eachFeeType.discount ?? 0);
      }),
      maxLines: 1,
      style: const TextStyle(
        fontSize: 16,
      ),
      textAlign: TextAlign.start,
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) double.parse(text);
            // TODO if this newValue is > actual amount => do not allow
            return newValue;
          } catch (e) {
            debugPrintStack();
          }
          return oldValue;
        }),
      ],
    );
  }

  Widget feeTypeAmountWidget(StudentAnnualFeeTypeBean eachFeeType) {
    // return Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(((eachFeeType.amount ?? 0) + (eachFeeType.discount ?? 0)) / 100)}");
    return TextFormField(
      initialValue: "${((eachFeeType.actualAmount ?? 0) / 100)}",
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      onChanged: (String? newText) => setState(() {
        eachFeeType.actualAmount = (int.tryParse(newText ?? "0") ?? 0) * 100;
        eachFeeType.amount = (eachFeeType.actualAmount ?? 0) - (eachFeeType.discount ?? 0);
      }),
      maxLines: 1,
      style: const TextStyle(
        fontSize: 16,
      ),
      textAlign: TextAlign.start,
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) double.parse(text);
            return newValue;
          } catch (e) {
            debugPrintStack();
          }
          return oldValue;
        }),
      ],
    );
  }

  Widget customFeeTypeDiscountWidget(StudentAnnualCustomFeeTypeBean eachCustomFeeType) {
    // return Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachCustomFeeType.discount ?? 0) / 100)}");
    return TextFormField(
      initialValue: "${((eachCustomFeeType.discount ?? 0) / 100)}",
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      onChanged: (String? newText) => setState(() {
        eachCustomFeeType.discount = (int.tryParse(newText ?? "0") ?? 0) * 100;
        eachCustomFeeType.amount = (eachCustomFeeType.actualAmount ?? 0) - (eachCustomFeeType.discount ?? 0);
      }),
      maxLines: 1,
      style: const TextStyle(
        fontSize: 16,
      ),
      textAlign: TextAlign.start,
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) double.parse(text);
            return newValue;
          } catch (e) {
            debugPrintStack();
          }
          return oldValue;
        }),
      ],
    );
  }

  Widget customFeeTypeAmountWidget(StudentAnnualCustomFeeTypeBean eachCustomFeeType) {
    // return Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(((eachCustomFeeType.amount ?? 0) + (eachCustomFeeType.discount ?? 0)) / 100)}");
    return TextFormField(
      initialValue: "${((eachCustomFeeType.actualAmount ?? 0) / 100)}",
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      onChanged: (String? newText) => setState(() {
        eachCustomFeeType.actualAmount = (int.tryParse(newText ?? "0") ?? 0) * 100;
        eachCustomFeeType.amount = (eachCustomFeeType.actualAmount ?? 0) - (eachCustomFeeType.discount ?? 0);
      }),
      maxLines: 1,
      style: const TextStyle(
        fontSize: 16,
      ),
      textAlign: TextAlign.start,
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) double.parse(text);
            return newValue;
          } catch (e) {
            debugPrintStack();
          }
          return oldValue;
        }),
      ],
    );
  }
}
