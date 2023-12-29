import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/inventory/admin/admin_inventory_each_date_stats_screen.dart';
import 'package:schoolsgo_web/src/inventory/modal/inventory.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class AdminInventoryStatsScreen extends StatefulWidget {
  const AdminInventoryStatsScreen({
    Key? key,
    required this.adminProfile,
    required this.items,
    required this.purchasedItems,
    required this.consumedItems,
    required this.academicYearStartDate,
    required this.academicYearEndDate,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<InventoryItemBean> items;
  final List<InventoryPurchaseItemBean> purchasedItems;
  final List<InventoryItemConsumptionBean> consumedItems;

  final DateTime academicYearStartDate;
  final DateTime academicYearEndDate;

  @override
  State<AdminInventoryStatsScreen> createState() => _AdminInventoryStatsScreenState();
}

class _AdminInventoryStatsScreenState extends State<AdminInventoryStatsScreen> {
  bool _isLoading = true;

  late DateTime selectedDate;
  late DateTime fromDate;
  late DateTime toDate;

  bool _showOnlyNonZero = true;

  List<DateWiseAmountSpent> dateWiseAmountsSpent = [];
  List<DateWiseAmountSpent> dateWiseAmountsSpentToShow = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fromDate = widget.academicYearStartDate;
    toDate = DateTime.fromMillisecondsSinceEpoch(min(DateTime.now().millisecondsSinceEpoch, widget.academicYearEndDate.millisecondsSinceEpoch));
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    dateWiseAmountsSpent =
        populateDates(widget.academicYearStartDate, widget.academicYearEndDate).reversed.map((e) => DateWiseAmountSpent(e, 0, [])).toList();
    widget.purchasedItems.where((eachItemPurchased) => eachItemPurchased.date != null).forEach((eachItemPurchased) {
      DateTime purchasedDate = convertYYYYMMDDFormatToDateTime(eachItemPurchased.date);
      dateWiseAmountsSpent.firstWhereOrNull((eachDateWiseAmountSpent) => eachDateWiseAmountSpent.date == purchasedDate)?.amount +=
          eachItemPurchased.amount ?? 0;
    });
    widget.consumedItems.where((eachItemConsumed) => eachItemConsumed.date != null).forEach((eachItemConsumed) {
      DateTime consumedDate = convertYYYYMMDDFormatToDateTime(eachItemConsumed.date);
      String description = "${eachItemConsumed.itemName ?? " - "} - ${eachItemConsumed.quantityUsed ?? 0.0} ${eachItemConsumed.unit ?? "Unit"}";
      dateWiseAmountsSpent
          .firstWhereOrNull((eachDateWiseAmountSpent) => eachDateWiseAmountSpent.date == consumedDate)
          ?.consumedItems
          .add(description);
    });
    handleVisibilityOfNonZero();
    setState(() => _isLoading = false);
  }

  void handleVisibilityOfNonZero() {
    if (_showOnlyNonZero) {
      setState(() => dateWiseAmountsSpentToShow = dateWiseAmountsSpent.where((e) => e.amount != 0 || e.consumedItems.isNotEmpty).toList());
    } else {
      setState(() => dateWiseAmountsSpentToShow = dateWiseAmountsSpent.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Stats"),
        actions: [
          const SizedBox(width: 10),
          Tooltip(
            message: _showOnlyNonZero ? "Show all dates" : "Show only dates with POs",
            child: IconButton(
              onPressed: () {
                setState(() {
                  _showOnlyNonZero = !_showOnlyNonZero;
                });
                handleVisibilityOfNonZero();
              },
              icon: Icon(_showOnlyNonZero ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          const SizedBox(width: 10),
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
          : ListView(
              children: [
                summaryWidget(),
                gridWidget(context),
              ],
            ),
    );
  }

  Widget summaryWidget() {
    List<InventoryPurchaseItemBean> purchasedItemsToBeConsidered = widget.purchasedItems
        .where((e) => e.date != null)
        .where((e) =>
            convertYYYYMMDDFormatToDateTime(e.date).millisecondsSinceEpoch >= fromDate.millisecondsSinceEpoch &&
            convertYYYYMMDDFormatToDateTime(e.date).millisecondsSinceEpoch <= toDate.millisecondsSinceEpoch)
        .toList();
    Set<int> uniqueItemIds = purchasedItemsToBeConsidered.map((e) => e.itemId).whereNotNull().toSet();
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.fromLTRB(10, 20, 10, 20)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20),
      child: ClayContainer(
        emboss: true,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Summary",
                  style: GoogleFonts.archivoBlack(
                    textStyle: TextStyle(
                      fontSize: 36,
                      color: clayContainerTextColor(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: datePickerWidget(
                      toolTip: "Pick From Date",
                      dateString: "From Date: ${convertDateTimeToDDMMYYYYFormat(fromDate)}",
                      pickDateAction: () async {
                        DateTime? _newDate = await showDatePicker(
                          context: context,
                          initialDate: fromDate,
                          firstDate: widget.academicYearStartDate,
                          lastDate: toDate,
                          helpText: "Pick from date",
                        );
                        if (_newDate == null || _newDate.millisecondsSinceEpoch == fromDate.millisecondsSinceEpoch) return;
                        setState(() {
                          fromDate = _newDate;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: datePickerWidget(
                      toolTip: "Pick To Date",
                      dateString: "To Date: ${convertDateTimeToDDMMYYYYFormat(toDate)}",
                      pickDateAction: () async {
                        DateTime? _newDate = await showDatePicker(
                          context: context,
                          initialDate: toDate,
                          firstDate: fromDate,
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                          helpText: "Pick to date",
                        );
                        if (_newDate == null || _newDate.millisecondsSinceEpoch == toDate.millisecondsSinceEpoch) return;
                        setState(() {
                          toDate = _newDate;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClayContainer(
                emboss: false,
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 2,
                borderRadius: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      if (uniqueItemIds.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text("No items purchased..")),
                        ),
                      if (uniqueItemIds.isNotEmpty)
                        ...uniqueItemIds.map((eachItemId) {
                          double amount = purchasedItemsToBeConsidered
                              .where((e) => e.itemId == eachItemId)
                              .map((e) => e.amount ?? 0)
                              .fold<double>(0, (sum, amount) => sum + amount);
                          String itemName = widget.items.firstWhereOrNull((eachItem) => eachItem.itemId == eachItemId)?.itemName ?? "-";
                          return Container(
                            margin: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(child: Text(itemName)),
                                Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(amount / 100.0)} /-"),
                              ],
                            ),
                          );
                        }),
                      if (uniqueItemIds.isNotEmpty) const Divider(thickness: 1, color: Colors.grey),
                      if (uniqueItemIds.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              const Expanded(child: Text("Total", style: TextStyle(color: Colors.blue))),
                              Text(
                                "$INR_SYMBOL ${doubleToStringAsFixedForINR(purchasedItemsToBeConsidered.map((e) => e.amount ?? 0).fold(0, (int a, b) => a + b) / 100.0)} /-",
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget datePickerWidget({
    String? toolTip,
    String dateString = "-",
    Future<void> Function()? pickDateAction,
  }) {
    return Tooltip(
      message: toolTip,
      child: GestureDetector(
        onTap: () async {
          if (pickDateAction != null) await pickDateAction();
        },
        child: ClayButton(
          depth: 40,
          spread: 2,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(dateString),
            ),
          ),
        ),
      ),
    );
  }

  Widget gridWidget(BuildContext context) {
    List<DateWiseAmountSpent> selectedDateWiseAmountCollected = dateWiseAmountsSpentToShow
        .where(
            (e) => e.date.millisecondsSinceEpoch >= fromDate.millisecondsSinceEpoch && e.date.millisecondsSinceEpoch <= toDate.millisecondsSinceEpoch)
        .toList();
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 6,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: selectedDateWiseAmountCollected.length,
      itemBuilder: (context, index) {
        final DateTime date = selectedDateWiseAmountCollected[index].date;
        final int amount = selectedDateWiseAmountCollected[index].amount;
        final List<String> consumedItems = selectedDateWiseAmountCollected[index].consumedItems;
        return Tooltip(
          message: consumedItems.isEmpty ? '' : "Consumed:\n" + consumedItems.join("\n"),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AdminInventoryEachDateStatsScreen(
                  adminProfile: widget.adminProfile,
                  items: widget.items,
                  purchasedItems: widget.purchasedItems
                      .where((eachPurchasedItem) => eachPurchasedItem.date != null && convertYYYYMMDDFormatToDateTime(eachPurchasedItem.date) == date)
                      .toList(),
                  consumedItems: widget.consumedItems
                      .where((eachConsumedItem) => eachConsumedItem.date != null && convertYYYYMMDDFormatToDateTime(eachConsumedItem.date) == date)
                      .toList(),
                  selectedDate: date,
                );
              }));
            },
            child: ClayButton(
              depth: 40,
              spread: 2,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              borderRadius: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      color: selectedDate == date ? Colors.blue : Colors.black,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Center(
                        child: Text(
                          convertDateTimeToDDMMYYYYFormat(date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$INR_SYMBOL ${doubleToStringAsFixedForINR(amount / 100.0)}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DateWiseAmountSpent {
  DateTime date;
  int amount;
  List<String> consumedItems;

  DateWiseAmountSpent(
    this.date,
    this.amount,
    this.consumedItems,
  );
}
