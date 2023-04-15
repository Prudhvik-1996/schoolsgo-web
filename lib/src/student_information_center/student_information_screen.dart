import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_fee_management_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/basic_fee_stats_widget.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/fee/student/student_fee_screen_v3.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_information_center/modal/month_wise_attendance.dart';
import 'package:schoolsgo_web/src/student_information_center/student_base_widget.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentInformationScreen extends StatefulWidget {
  const StudentInformationScreen({
    Key? key,
    required this.adminProfile,
    required this.studentProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final StudentProfile studentProfile;

  @override
  State<StudentInformationScreen> createState() => _StudentInformationScreenState();
}

class _StudentInformationScreenState extends State<StudentInformationScreen> {
  bool _isLoading = true;
  bool _loadingStudentAttendance = true;
  bool _isAttendanceGraphView = true;

  List<StudentMonthWiseAttendance> studentMonthWiseAttendanceList = [];

  StudentAnnualFeeBean? studentAnnualFeeBean;
  List<StudentFeeReceipt> studentFeeReceipts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadStudentAttendance();
    await _loadFeeData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadStudentAttendance() async {
    setState(() {
      _loadingStudentAttendance = true;
    });
    GetStudentMonthWiseAttendanceResponse getStudentMonthWiseAttendanceResponse = await getStudentMonthWiseAttendance(
        GetStudentMonthWiseAttendanceRequest(studentId: widget.studentProfile.studentId, schoolId: widget.studentProfile.schoolId, isAdminView: "Y"));
    if (getStudentMonthWiseAttendanceResponse.httpStatus != "OK" || getStudentMonthWiseAttendanceResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        studentMonthWiseAttendanceList =
            (getStudentMonthWiseAttendanceResponse.studentMonthWiseAttendanceList ?? []).where((e) => e != null).map((e) => e!).toList();
      });
    }
    setState(() {
      _loadingStudentAttendance = false;
    });
  }

  Future<void> _loadFeeData() async {
    setState(() => _loadingStudentAttendance = true);
    GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = await getStudentWiseAnnualFees(GetStudentWiseAnnualFeesRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
      studentId: widget.studentProfile.studentId,
    ));
    StudentWiseAnnualFeesBean? annualFeesBean = (getStudentWiseAnnualFeesResponse.studentWiseAnnualFeesBeanList ?? []).firstOrNull;
    if (getStudentWiseAnnualFeesResponse.httpStatus != "OK" ||
        getStudentWiseAnnualFeesResponse.responseStatus != "success" ||
        annualFeesBean == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      List<int> feeTypeIds = (annualFeesBean.studentAnnualFeeMapBeanList ?? []).map((e) => e?.feeTypeId ?? 0).toSet().toList();
      List<FeeType> feeTypes = feeTypeIds
          .map((eachFeeTypeId) => FeeType(
                customFeeTypesList: [],
                feeType: (annualFeesBean.studentAnnualFeeMapBeanList ?? []).where((e) => e?.feeTypeId == eachFeeTypeId).firstOrNull?.feeType,
                feeTypeDescription: "",
                feeTypeId: eachFeeTypeId,
                feeTypeStatus: (annualFeesBean.studentAnnualFeeMapBeanList ?? []).where((e) => e?.feeTypeId == eachFeeTypeId).firstOrNull?.status,
                schoolDisplayName: widget.studentProfile.schoolName,
                schoolId: widget.studentProfile.schoolId,
              ))
          .toList();
      for (var eachFeeType in feeTypes) {
        eachFeeType.customFeeTypesList = (annualFeesBean.studentAnnualFeeMapBeanList ?? [])
            .where((e) => e?.feeTypeId == eachFeeType.feeTypeId && e?.customFeeTypeId != null)
            .map((eachCustomFeeType) => CustomFeeType(
                  customFeeType: eachCustomFeeType?.customFeeType,
                  customFeeTypeDescription: "",
                  customFeeTypeId: eachCustomFeeType?.customFeeTypeId,
                  customFeeTypeStatus: eachCustomFeeType?.status,
                  feeType: eachCustomFeeType?.feeType,
                  feeTypeDescription: "",
                  feeTypeId: eachCustomFeeType?.feeTypeId,
                  feeTypeStatus: eachFeeType.feeTypeStatus,
                  schoolDisplayName: widget.studentProfile.schoolName,
                  schoolId: widget.studentProfile.schoolId,
                ))
            .toList();
      }
      setState(() => studentAnnualFeeBean = StudentAnnualFeeBean(
            studentId: annualFeesBean.studentId,
            rollNumber: annualFeesBean.rollNumber,
            studentName: annualFeesBean.studentName,
            totalFee: annualFeesBean.actualFee,
            totalFeePaid: annualFeesBean.feePaid,
            walletBalance: annualFeesBean.studentWalletBalance,
            sectionId: annualFeesBean.sectionId,
            sectionName: annualFeesBean.sectionName,
            studentBusFeeBean: annualFeesBean.studentBusFeeBean,
            studentAnnualFeeTypeBeans: feeTypes
                .map(
                  (eachFeeType) => StudentAnnualFeeTypeBean(
                    feeTypeId: eachFeeType.feeTypeId,
                    feeType: eachFeeType.feeType,
                    studentFeeMapId: (annualFeesBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.studentFeeMapId,
                    sectionFeeMapId: (annualFeesBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.sectionFeeMapId,
                    amount: (annualFeesBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.amount,
                    amountPaid: (annualFeesBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.amountPaid,
                    studentAnnualCustomFeeTypeBeans: (eachFeeType.customFeeTypesList ?? [])
                        .where((eachCustomFeeType) => eachCustomFeeType != null)
                        .map((eachCustomFeeType) => eachCustomFeeType!)
                        .map(
                          (eachCustomFeeType) => StudentAnnualCustomFeeTypeBean(
                            customFeeTypeId: eachCustomFeeType.customFeeTypeId,
                            customFeeType: eachCustomFeeType.customFeeType,
                            studentFeeMapId: (annualFeesBean.studentAnnualFeeMapBeanList ?? [])
                                .map((e) => e!)
                                .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                    eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                    eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                                .firstOrNull
                                ?.studentFeeMapId,
                            sectionFeeMapId: (annualFeesBean.studentAnnualFeeMapBeanList ?? [])
                                .map((e) => e!)
                                .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                    eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                    eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                                .firstOrNull
                                ?.sectionFeeMapId,
                            amount: (annualFeesBean.studentAnnualFeeMapBeanList ?? [])
                                .map((e) => e!)
                                .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                    eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                    eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                                .firstOrNull
                                ?.amount,
                            amountPaid: (annualFeesBean.studentAnnualFeeMapBeanList ?? [])
                                .map((e) => e!)
                                .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                    eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                    eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                                .firstOrNull
                                ?.amountPaid,
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ));

      GetStudentFeeReceiptsResponse studentFeeReceiptsResponse = await getStudentFeeReceipts(GetStudentFeeReceiptsRequest(
        schoolId: widget.studentProfile.schoolId,
        studentIds: [widget.studentProfile.studentId],
      ));
      if (studentFeeReceiptsResponse.httpStatus != "OK" || studentFeeReceiptsResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        setState(() {
          studentFeeReceipts = studentFeeReceiptsResponse.studentFeeReceipts!.map((e) => e!).toList();
          studentFeeReceipts.sort((b, a) {
            int dateCom = convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate));
            return (dateCom == 0) ? (a.receiptNumber ?? 0).compareTo(b.receiptNumber ?? 0) : dateCom;
          });
        });
      }
    }

    setState(() => _loadingStudentAttendance = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentProfile.studentFirstName ?? ""),
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
                StudentBaseWidget(context: context, studentProfile: widget.studentProfile),
                const SizedBox(height: 20),
                studentAttendanceCard(),
                const SizedBox(height: 20),
                studentFeeDetails(),
                const SizedBox(height: 5),
                studentFeeReceiptsButton(),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget studentAttendanceCard() {
    if (_loadingStudentAttendance) {
      return Container(
        padding: MediaQuery.of(context).orientation == Orientation.portrait
            ? const EdgeInsets.all(10)
            : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
        child: ClayContainer(
          emboss: false,
          depth: 15,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                SizedBox(height: 10),
                Center(
                  child: Text(
                    "Attendance",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: ClayContainer(
        emboss: false,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Attendance",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => setState(() => _isAttendanceGraphView = !_isAttendanceGraphView),
                        child: ClayButton(
                          depth: 40,
                          spread: 2,
                          surfaceColor: clayContainerColor(context),
                          parentColor: clayContainerColor(context),
                          borderRadius: 100,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(4),
                            child: !_isAttendanceGraphView
                                ? const Icon(
                                    Icons.auto_graph_sharp,
                                    size: 12,
                                  )
                                : const Icon(
                                    Icons.grid_view_rounded,
                                    size: 12,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "No. of days present: ${doubleToStringAsFixed(studentMonthWiseAttendanceList.map((e) => e.present ?? 0.0).reduce((a, b) => a + b))}",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "No. of days absent: ${doubleToStringAsFixed(studentMonthWiseAttendanceList.map((e) => e.absent ?? 0.0).reduce((a, b) => a + b))}",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Total no.of working days: ${doubleToStringAsFixed(studentMonthWiseAttendanceList.map((e) => (e.present ?? 0.0) + (e.absent ?? 0)).reduce((a, b) => a + b))}",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Attendance Percentage: ${doubleToStringAsFixed(studentMonthWiseAttendanceList.map((e) => e.present ?? 0.0).reduce((a, b) => a + b) * 100.0 / studentMonthWiseAttendanceList.map((e) => (e.present ?? 0.0) + (e.absent ?? 0)).reduce((a, b) => a + b))} %",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ] +
                (_isAttendanceGraphView ? [graphView()] : gridViewWidgets()) +
                <Widget>[
                  const SizedBox(height: 10),
                ],
          ),
        ),
      ),
    );
  }

  Widget graphView() {
    List ranking = studentMonthWiseAttendanceList
        .map((e) => {
              "monthYear": "${MONTHS[(e.month ?? 1) - 1].substring(0, 3).toLowerCase().capitalize()}\n${e.year ?? "-"}",
              "percentage": double.parse(doubleToStringAsFixed((e.present ?? 0.0) * 100.0 / ((e.present ?? 0.0) + (e.absent ?? 0.0))))
            })
        .toList();
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DChartBarCustom(
        loadingDuration: const Duration(milliseconds: 500),
        showLoading: true,
        valueAlign: Alignment.topCenter,
        showDomainLine: true,
        showDomainLabel: true,
        showMeasureLine: true,
        showMeasureLabel: true,
        spaceDomainLabeltoChart: 0,
        spaceMeasureLabeltoChart: 0,
        spaceDomainLinetoChart: 0,
        spaceMeasureLinetoChart: 10,
        spaceBetweenItem: 10,
        radiusBar: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        max: 100,
        listData: List.generate(ranking.length, (index) {
          return DChartBarDataCustom(
            onTap: () {
              debugPrint('${ranking[index]['monthYear']} => ${ranking[index]['percentage']}');
            },
            elevation: 8,
            value: ranking[index]['percentage'].toDouble(),
            label: ranking[index]['monthYear'],
            color: Colors.blue,
            splashColor: Colors.blue,
            showValue: true,
            labelCustom: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                ranking[index]['monthYear'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            valueCustom: const Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 1,
                width: 1,
              ),
            ),
            valueTooltip: '${ranking[index]['percentage']} %',
          );
        }),
      ),
    );
  }

  List<Widget> gridViewWidgets() {
    List<Widget> rows = [];
    double eachTileWidth = (((MediaQuery.of(context).orientation == Orientation.landscape
                    ? (MediaQuery.of(context).size.width / 2)
                    : (MediaQuery.of(context).size.width - 20)) -
                20) /
            3) -
        20;
    double eachTileHeight = 100;
    double totalWidthToFill = (MediaQuery.of(context).orientation == Orientation.landscape
            ? (MediaQuery.of(context).size.width / 2)
            : (MediaQuery.of(context).size.width - 20)) -
        20;
    double remainingWidth = totalWidthToFill;
    Widget marginWidget = const SizedBox(width: 10);
    List<Widget> rowsChildren = [];
    for (var eachMonthWiseBean in studentMonthWiseAttendanceList) {
      if (remainingWidth <= eachTileWidth) {
        remainingWidth = totalWidthToFill;
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [marginWidget] + rowsChildren,
        ));
        rows.add(const SizedBox(height: 10));
        rowsChildren = [];
      }
      rowsChildren.add(monthWiseTile(eachMonthWiseBean, height: eachTileHeight, width: eachTileWidth));
      rowsChildren.add(marginWidget);
      remainingWidth -= eachTileWidth;
    }
    return rows;
  }

  Widget monthWiseTile(StudentMonthWiseAttendance e, {double height = 0, double width = 0}) {
    double percentage = (e.present ?? 0.0) / ((e.present ?? 0.0) + (e.absent ?? 0.0)) * 100.0;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return SizedBox(
        height: height == 0 ? null : height,
        width: width == 0 ? null : width,
        child: ClayContainer(
          emboss: true,
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Center(
            child: RichText(
              text: TextSpan(
                text: "${MONTHS[(e.month ?? 1) - 1].substring(0, 3).toLowerCase().capitalize()} ${e.year ?? "-"}\n",
                style: const TextStyle(
                  color: Colors.blue,
                ),
                children: [
                  TextSpan(
                    text: "Present: ${doubleToStringAsFixed(e.present ?? 0.0)}\n",
                    style: TextStyle(
                      color: percentage >= 75
                          ? Colors.green
                          : percentage >= 65
                          ? Colors.amber
                          : Colors.red,
                    ),
                  ),
                  TextSpan(
                    text: "Total: ${doubleToStringAsFixed((e.present ?? 0.0) + (e.absent ?? 0.0))}",
                    style: TextStyle(
                      color: percentage >= 75
                          ? Colors.green
                          : percentage >= 65
                          ? Colors.amber
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: height == 0 ? null : height,
      width: width == 0 ? null : width,
      child: FlipCard(
        fill: Fill.fillBack,
        direction: FlipDirection.HORIZONTAL,
        side: CardSide.FRONT,
        front: ClayContainer(
          emboss: true,
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Center(
            child: RichText(
              text: TextSpan(
                text: "${MONTHS[(e.month ?? 1) - 1].substring(0, 3).toLowerCase().capitalize()} ${e.year ?? "-"}\n",
                style: const TextStyle(
                  color: Colors.blue,
                ),
                children: [
                  TextSpan(
                    text: doubleToStringAsFixed(percentage) + " %",
                    style: TextStyle(
                      color: percentage >= 75
                          ? Colors.green
                          : percentage >= 65
                              ? Colors.amber
                              : Colors.red,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        back: ClayContainer(
          emboss: true,
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Center(
            child: RichText(
              text: TextSpan(
                text: "${MONTHS[(e.month ?? 1) - 1].substring(0, 3).toLowerCase().capitalize()} ${e.year ?? "-"}\n",
                style: const TextStyle(
                  color: Colors.blue,
                ),
                children: [
                  TextSpan(
                    text: "Present: ${doubleToStringAsFixed(e.present ?? 0.0)}\n",
                    style: TextStyle(
                      color: percentage >= 75
                          ? Colors.green
                          : percentage >= 65
                              ? Colors.amber
                              : Colors.red,
                    ),
                  ),
                  TextSpan(
                    text: "Total: ${doubleToStringAsFixed((e.present ?? 0.0) + (e.absent ?? 0.0))}",
                    style: TextStyle(
                      color: percentage >= 75
                          ? Colors.green
                          : percentage >= 65
                              ? Colors.amber
                              : Colors.red,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        flipOnTouch: true,
      ),
    );
  }

  Widget studentFeeDetails() {
    if (studentAnnualFeeBean == null) return Container();
    return BasicFeeStatsReadWidget(
      studentWiseAnnualFeesBean: studentAnnualFeeBean!,
      context: context,
      alignMargin: true,
      title: "Fee Particulars",
      customMargin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
    );
  }

  Widget studentFeeReceiptsButton() {
    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: GestureDetector(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return StudentFeeScreenV3(
                  studentProfile: widget.studentProfile,
                  adminProfile: widget.adminProfile,
                );
              },
            ),
          ).then((value) => _loadData());
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 5,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              child: const Text(
                "Receipts",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
