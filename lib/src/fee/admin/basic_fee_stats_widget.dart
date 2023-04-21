import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_fee_management_screen.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class BasicFeeStatsReadWidget extends StatelessWidget {
  const BasicFeeStatsReadWidget({
    Key? key,
    required this.studentWiseAnnualFeesBean,
    required this.context,
    required this.alignMargin,
    this.title,
    this.customMargin,
  }) : super(key: key);

  final StudentAnnualFeeBean studentWiseAnnualFeesBean;
  final BuildContext context;
  final bool alignMargin;
  final String? title;
  final EdgeInsets? customMargin;

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    rows.add(
      Row(
        children: [
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(
              title ?? "${studentWiseAnnualFeesBean.rollNumber ?? "-"}. ${studentWiseAnnualFeesBean.studentName}",
              style: TextStyle(
                color: title == null ? null : Colors.blue,
                fontSize: title == null ? 18 : 24,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            child: Text(
              title != null ? "" : (studentWiseAnnualFeesBean.sectionName ?? "-"),
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    );
    rows.add(
      const SizedBox(
        height: 15,
      ),
    );
    List<Widget> feeStats = [];
    for (StudentAnnualFeeTypeBean eachStudentAnnualFeeTypeBean in (studentWiseAnnualFeesBean.studentAnnualFeeTypeBeans ?? [])) {
      feeStats.add(
        Row(
          children: [
            Expanded(
              child: Text(eachStudentAnnualFeeTypeBean.feeType ?? "-"),
            ),
            eachStudentAnnualFeeTypeBean.amount == null
                ? Container()
                : eachStudentAnnualFeeTypeBean.amount == null || eachStudentAnnualFeeTypeBean.amount == 0
                    ? Container()
                    : Text("$INR_SYMBOL ${(eachStudentAnnualFeeTypeBean.amount! / 100).toString()}"),
          ],
        ),
      );
      feeStats.add(
        const SizedBox(
          height: 15,
        ),
      );
      for (StudentAnnualCustomFeeTypeBean eachStudentAnnualCustomFeeTypeBean
          in (eachStudentAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? [])) {
        feeStats.add(
          Row(
            children: [
              const CustomVerticalDivider(),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(eachStudentAnnualCustomFeeTypeBean.customFeeType ?? "-"),
              ),
              eachStudentAnnualCustomFeeTypeBean.amount == null
                  ? Container()
                  : eachStudentAnnualCustomFeeTypeBean.amount == null || eachStudentAnnualCustomFeeTypeBean.amount == 0
                      ? Container()
                      : Text("$INR_SYMBOL ${(eachStudentAnnualCustomFeeTypeBean.amount! / 100).toString()}"),
            ],
          ),
        );
        feeStats.add(
          const SizedBox(
            height: 15,
          ),
        );
      }
    }

    if (studentWiseAnnualFeesBean.studentBusFeeBean != null) {
      feeStats.add(Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Bus Fee"),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text('Bus Fee for ${studentWiseAnnualFeesBean.studentBusFeeBean?.studentName ?? "-"}'),
                          content: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: ListView(
                              children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      child: Row(
                                        children: const [
                                          Expanded(
                                            child: AutoSizeText(
                                              "Route",
                                              maxLines: 2,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: Text(
                                              "Stop",
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text("Valid From"),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text("Valid Through"),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              "Fare",
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ] +
                                  (studentWiseAnnualFeesBean.studentBusFeeBean?.studentBusFeeLogBeans ?? [])
                                      .map(
                                        (e) => Container(
                                          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  e?.routeName ?? "-",
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  e?.stopName ?? "-",
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: AutoSizeText(
                                                  convertDateToDDMMMYYYEEEE(e?.validFrom),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: AutoSizeText(
                                                  convertDateToDDMMMYYYEEEE(e?.validThrough),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "$INR_SYMBOL ${e?.fare == null ? "-" : doubleToStringAsFixed(e!.fare! / 100)}",
                                                  textAlign: TextAlign.end,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Icon(
                    Icons.warning,
                    color: Colors.orange,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
          Text(
            studentWiseAnnualFeesBean.studentBusFeeBean?.fare == null
                ? "-"
                : INR_SYMBOL + " " + doubleToStringAsFixed(studentWiseAnnualFeesBean.studentBusFeeBean!.fare! / 100),
          ),
        ],
      ));
      feeStats.add(
        const SizedBox(
          height: 15,
        ),
      );
    }

    feeStats.add(
      const Divider(
        thickness: 1,
      ),
    );

    feeStats.add(
      const SizedBox(
        height: 7.5,
      ),
    );

    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text("Total:"),
          ),
          Text(
            studentWiseAnnualFeesBean.totalFee == null ? "-" : "$INR_SYMBOL ${((studentWiseAnnualFeesBean.totalFee ?? 0) / 100).toString()}",
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text("Total Fee Paid:"),
          ),
          Text(
            studentWiseAnnualFeesBean.totalFeePaid == null ? "-" : "$INR_SYMBOL ${((studentWiseAnnualFeesBean.totalFeePaid ?? 0) / 100).toString()}",
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text(
              "Fee to be paid:",
            ),
          ),
          Text(
            "$INR_SYMBOL ${(((studentWiseAnnualFeesBean.totalFee ?? 0) - (studentWiseAnnualFeesBean.totalFeePaid ?? 0)) / 100).toString()}",
            textAlign: TextAlign.end,
            style: TextStyle(
              color:
                  ((studentWiseAnnualFeesBean.totalFee ?? 0) - (studentWiseAnnualFeesBean.totalFeePaid ?? 0)) == 0 ? null : const Color(0xffff5733),
            ),
          ),
        ],
      ),
    );

    return Container(
      margin: customMargin ??
          (alignMargin
              ? MediaQuery.of(context).orientation == Orientation.portrait
                  ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
                  : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
              : const EdgeInsets.fromLTRB(25, 10, 25, 10)),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: rows +
                [
                  Container(
                    margin: const EdgeInsets.all(4),
                    child: ClayContainer(
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 10,
                      depth: 40,
                      emboss: true,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: feeStats,
                        ),
                      ),
                    ),
                  ),
                ],
          ),
        ),
      ),
    );
  }
}
