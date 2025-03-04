import 'package:collection/collection.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_hovered_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/fee/admin/stats/student_wise_fee_stats.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class StudentRowDataSource extends DataTableSource {
  StudentRowDataSource(
    this.context,
    this.studentWiseFeeStatsMap,
    this.updatedSelectedIndex,
    this.selectedIndex, [
    this.hasRowHeightOverrides = false,
    this.hasZebraStripes = false,
  ]);

  final BuildContext context;
  late List<StudentWiseFeeStatsMap> studentWiseFeeStatsMap;
  final Function updatedSelectedIndex;

  bool hasRowHeightOverrides = false;
  bool hasZebraStripes = true;

  int? selectedIndex;

  @override
  DataRow2 getRow(int index, [Color? color]) {
    assert(index >= 0);
    if (index >= studentWiseFeeStatsMap.length) {
      // Return an empty row for out-of-bounds indices
      return DataRow2.byIndex(
        index: index,
        cells: List.generate(
          studentWiseFeeStatsMap[0].values.keys.length,
          (_) => const DataCell(Text('')),
        ),
      );
    }

    final Map<String, String> studentRowMap = studentWiseFeeStatsMap[index].values;
    StudentProfile? studentProfile = studentWiseFeeStatsMap[index].studentProfile;
    StudentBusFeeBean? studentBusFeeBean = studentWiseFeeStatsMap[index].studentBusFeeBean;

    return DataRow2.byIndex(
      onTap: () => updatedSelectedIndex(index),
      index: index,
      color: selectedIndex == index
          ? MaterialStateProperty.resolveWith(
              (Set states) => Colors.lightBlue,
            )
          : hasZebraStripes
              ? MaterialStateProperty.resolveWith(
                  (Set states) => index % 2 == 0 ? Theme.of(context).highlightColor : null,
                )
              : null,
      specificRowHeight: hasRowHeightOverrides ? 100 : null,
      cells: studentRowMap.keys.mapIndexed(
        (i, key) {
          final value = studentRowMap[key] ?? "-";
          return DataCell(
            Stack(
              children: [
                Container(
                  // color: selectedIndex == index ? Colors.lightBlue : null,
                  alignment: i == 0
                      ? Alignment.center
                      : i == 1
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                  // padding: const EdgeInsets.all(8.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      textAlign: i == 0
                          ? TextAlign.center
                          : i == 1
                              ? TextAlign.start
                              : TextAlign.right,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: selectedIndex == index ? Colors.black : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                if (i == 1)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                      child: Row(
                        children: [
                          const Expanded(child: Text("")),
                          // const SizedBox(width: 2),
                          // accommodationTypeButton(studentProfile),
                          const SizedBox(width: 2),
                          if ((studentBusFeeBean?.fare ?? 0) != 0) busRouteInfoButton(studentBusFeeBean),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  Widget busRouteInfoButton(StudentBusFeeBean? studentBusFeeBean) {
    return Tooltip(
      message: "${studentBusFeeBean?.routeName ?? " - "}\n${studentBusFeeBean?.stopName ?? " - "}",
      child: ClayHoveredWidget(
        depth: 40,
        surfaceColor: Colors.yellow,
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(2),
          width: 15,
          height: 15,
          child: const Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                Icons.directions_bus,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget accommodationTypeButton(StudentProfile? studentProfile) {
    return Tooltip(
      message: studentProfile?.getAccommodationType(),
      child: ClayHoveredWidget(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(2),
          width: 15,
          height: 15,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: studentProfile?.getAccommodationTypeIcon(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  int get rowCount => studentWiseFeeStatsMap.length;

  @override
  bool get isRowCountApproximate => true;

  @override
  int get selectedRowCount => 0;
}
