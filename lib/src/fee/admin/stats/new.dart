import 'package:collection/collection.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';

class StudentRowDataSource extends DataTableSource {
  StudentRowDataSource(
    this.context,
    this.studentRowValues, [
    this.hasRowHeightOverrides = false,
    this.hasZebraStripes = false,
  ]);

  final BuildContext context;
  late List<Map<String, String>> studentRowValues;

  // Override height values for certain rows
  bool hasRowHeightOverrides = false;

  // Color each Row by index's parity
  bool hasZebraStripes = true;

  @override
  DataRow2 getRow(int index, [Color? color]) {
    assert(index >= 0);
    if (index >= studentRowValues.length) throw 'index > _desserts.length';
    final Map<String, String> studentRowMap = studentRowValues[index];
    return DataRow2.byIndex(
      index: index,
      color: hasZebraStripes ? MaterialStateProperty.resolveWith((Set states) => index % 2 == 0 ? Theme.of(context).highlightColor : null) : null,
      specificRowHeight: hasRowHeightOverrides ? 100 : null,
      cells: [
        ...studentRowMap.keys.mapIndexed(
          (i, e) {
            return DataCell(
              i == 1
                  ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(studentRowMap[e] ?? "-")),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(studentRowMap[e] ?? "-"),
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }

  @override
  int get rowCount => studentRowValues.length;

  @override
  bool get isRowCountApproximate => true;

  @override
  int get selectedRowCount => 0;
}
