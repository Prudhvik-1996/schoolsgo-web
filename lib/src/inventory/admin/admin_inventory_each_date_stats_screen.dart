import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/inventory/modal/inventory.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class AdminInventoryEachDateStatsScreen extends StatefulWidget {
  const AdminInventoryEachDateStatsScreen({
    Key? key,
    required this.adminProfile,
    required this.items,
    required this.purchasedItems,
    required this.consumedItems,
    required this.selectedDate,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<InventoryItemBean> items;
  final List<InventoryPurchaseItemBean> purchasedItems;
  final List<InventoryItemConsumptionBean> consumedItems;
  final DateTime selectedDate;

  @override
  State<AdminInventoryEachDateStatsScreen> createState() => _AdminInventoryEachDateStatsScreenState();
}

class _AdminInventoryEachDateStatsScreenState extends State<AdminInventoryEachDateStatsScreen> {
  int selectedIndex = 0;
  ScrollController purchasedItemsHorizontalScrollController = ScrollController();
  ScrollController consumedItemsHorizontalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stats for ${convertDateTimeToDDMMYYYYFormat(widget.selectedDate)}"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: ["Purchased Items", "Consumed Items"]
                  .mapIndexed(
                    (int index, String e) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: index == selectedIndex ? Colors.blue : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: index == selectedIndex ? Colors.blue : Colors.grey,
                        ),
                        child: InkWell(
                          onTap: () => setState(() => selectedIndex = index),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                e,
                                textAlign: TextAlign.center,
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
          Expanded(
            child: selectedIndex == 0 ? purchasedItemsTable() : consumedItemsTable(),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget purchasedItemsTable() {
    if (widget.purchasedItems.isEmpty) return const Center(child: Text("No items purchased on this day.."));
    return ClayTable2DWidget(
      context: context,
      horizontalScrollController: purchasedItemsHorizontalScrollController,
      dataTable: DataTable(
        columns: const [
          DataColumn(label: Text('Item Name')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Unit')),
          DataColumn(label: Text('Amount')),
        ],
        rows: widget.purchasedItems.map((purchasedItem) {
          InventoryItemBean? item = widget.items.firstWhereOrNull((eachItem) => eachItem.itemId == purchasedItem.itemId);
          return DataRow(
            cells: [
              DataCell(Text(purchasedItem.itemName ?? '-')),
              DataCell(Text(purchasedItem.quantity?.toString() ?? '-')),
              DataCell(Text(item?.unit ?? 'Unit')),
              DataCell(
                Text(
                  purchasedItem.amount == 0 ? "-" : "$INR_SYMBOL ${doubleToStringAsFixedForINR((purchasedItem.amount ?? 0) / 100.0)}/-",
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget consumedItemsTable() {
    if (widget.consumedItems.isEmpty) return const Center(child: Text("No items consumed on this day.."));
    return ClayTable2DWidget(
      context: context,
      horizontalScrollController: consumedItemsHorizontalScrollController,
      dataTable: DataTable(
        columns: const [
          DataColumn(label: Text('Item Name')),
          DataColumn(label: Text('Quantity Consumed')),
          DataColumn(label: Text('Unit')),
        ],
        rows: widget.consumedItems.map((consumedItem) {
          InventoryItemBean? item = widget.items.firstWhereOrNull((eachItem) => eachItem.itemId == consumedItem.itemId);
          return DataRow(
            cells: [
              DataCell(Text(consumedItem.itemName ?? '-')),
              DataCell(Text(consumedItem.quantityUsed?.toString() ?? '-')),
              DataCell(Text(item?.unit ?? 'Unit')),
            ],
          );
        }).toList(),
      ),
    );
  }
}
