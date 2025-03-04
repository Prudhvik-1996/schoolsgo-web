import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/inventory/admin/admin_inventory_stats_screen.dart';
import 'package:schoolsgo_web/src/inventory/modal/inventory.dart';
import 'package:schoolsgo_web/src/model/academic_years.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:substring_highlight/substring_highlight.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({
    Key? key,
    required this.adminProfile,
    required this.isHostel,
    this.otherUserRoleProfile,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final OtherUserRoleProfile? otherUserRoleProfile;
  final bool isHostel;

  static const String routeName = "/inventory";

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool _isEditMode = false;

  late DateTime academicYearStartDate;
  late DateTime academicYearEndDate;

  late SchoolInfoBean schoolInfo;
  List<InventoryItemBean> inventoryItemBeans = [];
  List<InventoryItemConsumptionBean> inventoryItemConsumptionBeans = [];
  List<InventoryPoBean> inventoryPoBeans = [];
  List<InventoryLogBean> inventoryLogBeans = [];
  int widgetToDisplayIndex = 0;
  List<String> widgetsToDisplay = ["Stock", "Purchase Order", "Consumption", "Log"];

  ScrollController stockHorizontalScrollController = ScrollController();
  ScrollController consumptionHorizontalScrollController = ScrollController();
  ScrollController logHorizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherUserRoleProfile?.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      schoolInfo = getSchoolsResponse.schoolInfo!;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID');
    GetSchoolWiseAcademicYearsResponse response = await getSchoolWiseAcademicYears(
      GetSchoolWiseAcademicYearsRequest(
        schoolId: widget.adminProfile?.schoolId ?? widget.otherUserRoleProfile?.schoolId,
      ),
    );
    List<AcademicYearBean> academicYears = response.academicYearBeanList?.whereNotNull().toList() ?? [];
    if (academicYears.isNotEmpty) {
      if (selectedAcademicYearId != null) {
        if (academicYears.any((e) => e.academicYearId == selectedAcademicYearId)) {
          academicYearStartDate =
              convertYYYYMMDDFormatToDateTime(academicYears.where((e) => e.academicYearId == selectedAcademicYearId).first.academicYearStartDate);
          academicYearEndDate =
              convertYYYYMMDDFormatToDateTime(academicYears.where((e) => e.academicYearId == selectedAcademicYearId).first.academicYearEndDate);
        } else {
          academicYearStartDate = convertYYYYMMDDFormatToDateTime(academicYears.last.academicYearStartDate);
          academicYearEndDate = convertYYYYMMDDFormatToDateTime(academicYears.last.academicYearEndDate);
        }
      } else {
        academicYearStartDate = convertYYYYMMDDFormatToDateTime(academicYears.last.academicYearStartDate);
        academicYearEndDate = convertYYYYMMDDFormatToDateTime(academicYears.last.academicYearEndDate);
      }
    }
    await _loadInventoryItems();
    await _loadInventoryConsumption();
    await _loadInventoryPos();
    await _loadInventoryLogs();
    setState(() => _isLoading = false);
  }

  Future<void> _loadInventoryPos() async {
    GetInventoryPoResponse getInventoryPoResponse = await getInventoryPo(GetInventoryPoRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherUserRoleProfile?.schoolId,
      isHostel: widget.isHostel ? "Y" : "N",
    ));
    if (getInventoryPoResponse.httpStatus != "OK" ||
        getInventoryPoResponse.responseStatus != "success" ||
        getInventoryPoResponse.inventoryPoBeans == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      inventoryPoBeans = getInventoryPoResponse.inventoryPoBeans?.whereNotNull().toList() ?? [];
    }
  }

  Future<void> _loadInventoryLogs() async {
    GetInventoryLogResponse getInventoryLogResponse = await getInventoryLog(GetInventoryLogRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherUserRoleProfile?.schoolId,
      isHostel: widget.isHostel ? "Y" : "N",
    ));
    if (getInventoryLogResponse.httpStatus != "OK" ||
        getInventoryLogResponse.responseStatus != "success" ||
        getInventoryLogResponse.inventoryLogBeans == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      inventoryLogBeans = getInventoryLogResponse.inventoryLogBeans?.whereNotNull().toList() ?? [];
    }
  }

  Future<void> _loadInventoryConsumption() async {
    GetInventoryItemsConsumptionResponse getInventoryItemsConsumptionResponse =
        await getInventoryItemsConsumption(GetInventoryItemsConsumptionRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherUserRoleProfile?.schoolId,
      isHostel: widget.isHostel ? "Y" : "N",
    ));
    if (getInventoryItemsConsumptionResponse.httpStatus != "OK" ||
        getInventoryItemsConsumptionResponse.responseStatus != "success" ||
        getInventoryItemsConsumptionResponse.inventoryItemConsumptionBeans == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      inventoryItemConsumptionBeans = getInventoryItemsConsumptionResponse.inventoryItemConsumptionBeans?.whereNotNull().toList() ?? [];
    }
  }

  Future<void> _loadInventoryItems() async {
    GetInventoryItemsResponse getInventoryItemsResponse = await getInventoryItems(GetInventoryItemsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherUserRoleProfile?.schoolId,
      isHostel: widget.isHostel ? "Y" : "N",
    ));
    if (getInventoryItemsResponse.httpStatus != "OK" ||
        getInventoryItemsResponse.responseStatus != "success" ||
        getInventoryItemsResponse.inventoryItemBeans == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      inventoryItemBeans = getInventoryItemsResponse.inventoryItemBeans?.whereNotNull().toList() ?? [];
    }
  }

  void handleMoreOptions(String value) {
    switch (value) {
      case "Date Wise Stats":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AdminInventoryStatsScreen(
                adminProfile: widget.adminProfile!,
                items: inventoryItemBeans,
                purchasedItems: inventoryPoBeans.map((e) => e.inventoryPurchaseItemsForStats).expand((i) => i).toList(),
                consumedItems: inventoryItemConsumptionBeans,
                academicYearStartDate: academicYearStartDate,
                academicYearEndDate: academicYearEndDate,
              );
            },
          ),
        );
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Inventory"),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: _isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditMode = !_isEditMode),
            ),
          if (!_isLoading && !_isEditMode && widget.adminProfile != null)
            PopupMenuButton<String>(
              onSelected: handleMoreOptions,
              itemBuilder: (BuildContext context) {
                return {'Date Wise Stats'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: widgetsToDisplay
                        .mapIndexed(
                          (int index, String e) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: index == widgetToDisplayIndex ? Colors.blue : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: index == widgetToDisplayIndex ? Colors.blue : Colors.grey,
                              ),
                              child: InkWell(
                                onTap: () => setState(() => widgetToDisplayIndex = index),
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
                Expanded(child: widgetToDisplay(widgetToDisplayIndex)),
                const SizedBox(height: 10),
              ],
            ),
      floatingActionButton: _isLoading || !_isEditMode ? null : fabToDisplay(widgetToDisplayIndex),
    );
  }

  Widget? fabToDisplay(int widgetToDisplayIndex) {
    switch (widgetToDisplayIndex) {
      case 0:
        return createOrUpdateItemButton(
          InventoryItemBean()
            ..isHostel = widget.isHostel ? "Y" : "N"
            ..status = "active"
            ..agent = widget.adminProfile?.userId ?? widget.otherUserRoleProfile?.userId,
          const Icon(Icons.add, size: 12),
          "Add Item",
        );
      case 1:
        return createOrUpdatePoButton(
          InventoryPoBean()
            ..status = "active"
            ..modeOfPayment = ModeOfPayment.CASH.name
            ..transactionDate = convertDateTimeToYYYYMMDDFormat(DateTime.now()),
          const Icon(Icons.add, size: 12),
          "Add Purchase Order",
        );
      case 2:
        return createOrUpdateItemConsumptionButton(
          InventoryItemConsumptionBean()
            ..agent = widget.adminProfile?.userId ?? widget.otherUserRoleProfile?.userId
            ..status = "active",
          const Icon(Icons.add, size: 12),
          "Enter Consumption",
        );
      default:
        return null;
    }
  }

  Widget widgetToDisplay(int widgetToDisplayIndex) {
    switch (widgetToDisplayIndex) {
      case 0:
        return stocksWidget();
      case 1:
        return purchaseOrdersWidget();
      case 2:
        return consumptionWidget();
      case 3:
        return logWidget();
      default:
        return const Center(child: Text("Invalid choice"));
    }
  }

  Widget stocksWidget() {
    if (inventoryItemBeans.isEmpty) return const Center(child: Text("No items in your inventory.."));
    return ClayTable2DWidget(
      context: context,
      horizontalScrollController: stockHorizontalScrollController,
      dataTable: DataTable(
        columns: [
          const DataColumn(label: Text('Item Name')),
          const DataColumn(label: Text('Unit')),
          const DataColumn(label: Text('Quantity Left')),
          if (_isEditMode) const DataColumn(label: Text('Actions')),
        ],
        rows: inventoryItemBeans
            .map(
              (item) => DataRow(
                cells: [
                  DataCell(Text(item.itemName ?? '')),
                  DataCell(Text(item.unit ?? '')),
                  DataCell(Text(item.availableStock?.toString() ?? '')),
                  if (_isEditMode)
                    DataCell(
                      createOrUpdateItemButton(item, const Icon(Icons.edit, size: 12), "Edit"),
                    ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget createOrUpdateItemButton(InventoryItemBean item, Icon buttonIcon, String buttonText) {
    return ElevatedButton(
      onPressed: () async {
        await showDialog(
          barrierDismissible: false,
          context: _scaffoldKey.currentContext!,
          builder: (currentContext) {
            return AlertDialog(
              title: Text("${item.itemId == null ? "Create" : "Update"} Inventory Item"),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    width: getAlertBoxWidth(context),
                    height: getAlertBoxHeight(context),
                    child: ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item.itemName ?? "",
                                onChanged: (String e) => setState(() => item.itemName = e),
                                decoration: InputDecoration(
                                  labelText: 'Item Name',
                                  hintText: 'Name of the item',
                                  errorText: itemNameErrorText(item),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue: item.unit ?? "",
                                onChanged: (String e) => setState(() => item.unit = e),
                                decoration: const InputDecoration(
                                  labelText: 'Unit',
                                  hintText: 'KG, Box, Unit, etc,.',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (itemNameErrorText(item) != null) return;
                    Navigator.pop(context);
                    await createOrUpdateInventoryItemAction(item);
                  },
                  child: const Text("Proceed to save"),
                ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buttonIcon,
          const SizedBox(width: 10),
          Text(buttonText),
        ],
      ),
    );
  }

  String? itemNameErrorText(InventoryItemBean itemToEdit) =>
      inventoryItemBeans.where((e) => e.itemName?.trim().toLowerCase() == itemToEdit.itemName?.trim().toLowerCase()).isNotEmpty
          ? "Item already exists"
          : null;

  Future<void> createOrUpdateInventoryItemAction(InventoryItemBean item) async {
    setState(() => _isLoading = true);
    CreateOrUpdateInventoryItemsResponse createOrUpdateInventoryItemsResponse =
        await createOrUpdateInventoryItems(CreateOrUpdateInventoryItemsRequest(
      agentId: widget.adminProfile?.userId ?? widget.otherUserRoleProfile?.userId,
      schoolId: widget.adminProfile?.schoolId ?? widget.otherUserRoleProfile?.schoolId,
      inventoryItemBeans: [item],
    ));
    if (createOrUpdateInventoryItemsResponse.httpStatus != "OK" || createOrUpdateInventoryItemsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      await _loadInventoryItems();
      await _loadInventoryLogs();
    }
    setState(() => _isLoading = false);
  }

  Widget purchaseOrdersWidget() {
    if (inventoryPoBeans.isEmpty) return const Center(child: Text("No Purchase Orders yet.."));
    return Container(
      margin: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...inventoryPoBeans.mapIndexed(
              (int index, InventoryPoBean poBean) => Container(
                margin: const EdgeInsets.all(8),
                width: getAlertBoxWidth(context),
                child: ClayContainer(
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 1,
                  borderRadius: 10,
                  depth: 40,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(poBean.transactionDate)),
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (_isEditMode)
                              createOrUpdatePoButton(
                                poBean,
                                const Icon(
                                  Icons.edit,
                                  size: 12,
                                ),
                                "Edit",
                              ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        if (_isEditMode) const SizedBox(height: 10),
                        SizedBox(
                          width: getAlertBoxWidth(context) + 20,
                          child: Scrollbar(
                            thumbVisibility: true,
                            thickness: 8.0,
                            controller: poBean.horizontalScrollController,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: poBean.horizontalScrollController,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Item Name')),
                                  DataColumn(label: Text('Quantity')),
                                  DataColumn(label: Text('Unit')),
                                  DataColumn(label: Text('Amount')),
                                ],
                                rows: (poBean.inventoryPurchaseItemBeans ?? []).whereNotNull().map(
                                  (InventoryPurchaseItemBean purchaseItem) {
                                    InventoryItemBean? item = getInventoryItemForPurchaseItem(purchaseItem);
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(purchaseItem.itemName ?? '')),
                                        DataCell(Text(purchaseItem.quantity?.toString() ?? '-')),
                                        DataCell(Text(item?.unit ?? '-')),
                                        DataCell(Text(purchaseItem.amount == 0
                                            ? "-"
                                            : "$INR_SYMBOL ${doubleToStringAsFixedForINR((purchaseItem.amount ?? 0) / 100.0)}/-")),
                                      ],
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Text("Comments"),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  poBean.description ?? "-",
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  poBean.modeOfPayment ?? "CASH",
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                              Text(
                                "$INR_SYMBOL ${doubleToStringAsFixedForINR((poBean.computeTotal) / 100.0)}/-",
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createOrUpdatePoButton(InventoryPoBean poBean, Icon buttonIcon, String buttonText, {Color color = Colors.blue}) {
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => color)),
      onPressed: () async {
        await showDialog(
          barrierDismissible: false,
          context: _scaffoldKey.currentContext!,
          builder: (currentContext) {
            return AlertDialog(
              title: Text("${poBean.poId == null ? "Create" : "Update"} Purchase Order"),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  ScrollController horizontalScrollController = ScrollController();
                  poBean.inventoryPurchaseItemBeans ??= [];
                  return SizedBox(
                    width: getAlertBoxWidth(context),
                    height: getAlertBoxHeight(context),
                    child: ListView(
                      children: [
                        SizedBox(
                          width: getAlertBoxWidth(context) + 20,
                          child: Scrollbar(
                            thumbVisibility: true,
                            thickness: 8.0,
                            controller: horizontalScrollController,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: horizontalScrollController,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Item Name')),
                                  DataColumn(label: Text('Quantity')),
                                  DataColumn(label: Text('Unit')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: (poBean.inventoryPurchaseItemBeans ?? []).whereNotNull().where((e) => e.status != "inactive").map(
                                  (InventoryPurchaseItemBean purchaseItem) {
                                    return DataRow(
                                      cells: [
                                        DataCell(purchaseItem.itemId == null
                                            ? buildItemNamePickerForPO(poBean, purchaseItem, setState)
                                            : Text(purchaseItem.itemName ?? "-")),
                                        DataCell(
                                          TextFormField(
                                            onTap: () => itemNotPickedError(purchaseItem, context),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                              TextInputFormatter.withFunction((oldValue, newValue) {
                                                try {
                                                  if (purchaseItem.itemId == null) return oldValue;
                                                  final text = newValue.text;
                                                  if (text.isNotEmpty) double.parse(text);
                                                  return newValue;
                                                } on Exception catch (_, e) {
                                                  debugPrintStack(stackTrace: e);
                                                }
                                                return oldValue;
                                              }),
                                            ],
                                            onChanged: (String e) {
                                              if (purchaseItem.itemId == null) return;
                                              setState(() {
                                                purchaseItem.quantity = double.tryParse(e);
                                              });
                                            },
                                            controller: purchaseItem.quantityController,
                                            decoration: const InputDecoration(
                                              hintText: '100',
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(getInventoryItemForPurchaseItem(purchaseItem)?.unit ?? '-')),
                                        DataCell(
                                          TextFormField(
                                            onTap: () => itemNotPickedError(purchaseItem, context),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                              TextInputFormatter.withFunction((oldValue, newValue) {
                                                try {
                                                  if (purchaseItem.itemId == null) return oldValue;
                                                  final text = newValue.text;
                                                  if (text.isNotEmpty) double.parse(text);
                                                  return newValue;
                                                } on Exception catch (_, e) {
                                                  debugPrintStack(stackTrace: e);
                                                }
                                                return oldValue;
                                              }),
                                            ],
                                            onChanged: (String e) {
                                              if (purchaseItem.itemId == null) return;
                                              setState(() {
                                                purchaseItem.amount = ((double.tryParse(e) ?? 0) * 100).toInt();
                                              });
                                            },
                                            controller: purchaseItem.amountController,
                                            decoration: const InputDecoration(
                                              hintText: '100',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 12,
                                            ),
                                            onPressed: () {
                                              if (poBean.poId == null || purchaseItem.itemId == null) {
                                                setState(() => poBean.inventoryPurchaseItemBeans?.remove(purchaseItem));
                                              } else {
                                                setState(() => purchaseItem.status = "inactive");
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                        ),
                        if (!isPoNotFilledCompletely(poBean)) const SizedBox(height: 10),
                        if (!isPoNotFilledCompletely(poBean))
                          Row(
                            children: [
                              const Expanded(child: Text("")),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() => poBean.inventoryPurchaseItemBeans?.add(
                                        InventoryPurchaseItemBean()
                                          ..agent = widget.adminProfile?.userId ?? widget.otherUserRoleProfile?.userId
                                          ..status = "active",
                                      ));
                                },
                                child: const Text("Add Purchase item"),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Total",
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              Text(
                                "$INR_SYMBOL ${doubleToStringAsFixedForINR(poBean.computeTotal / 100.0)} /-",
                                style: const TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isPoNewAndEmpty(poBean) && !isPoNotFilledCompletely(poBean))
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              onChanged: (String e) {
                                setState(() {
                                  poBean.description = e;
                                });
                              },
                              controller: poBean.descriptionController,
                              decoration: const InputDecoration(
                                hintText: 'Comments',
                                labelText: 'Comments',
                              ),
                            ),
                          ),
                        if (isPoNewAndEmpty(poBean) && !isPoNotFilledCompletely(poBean)) const SizedBox(height: 10),
                        if (isPoNewAndEmpty(poBean) && !isPoNotFilledCompletely(poBean))
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  DateTime? _newDate = await showDatePicker(
                                    context: context,
                                    initialDate: convertYYYYMMDDFormatToDateTime(poBean.transactionDate),
                                    firstDate: academicYearStartDate,
                                    lastDate: DateTime.now(),
                                    helpText: "Select a date",
                                  );
                                  if (_newDate == null) return;
                                  setState(() {
                                    poBean.transactionDate = convertDateTimeToYYYYMMDDFormat(_newDate);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(poBean.transactionDate))),
                                  ),
                                ),
                              ),
                              DropdownButton(
                                value: poBean.modeOfPayment,
                                items: ModeOfPayment.values
                                    .map((e) => e.name)
                                    .map(
                                      (e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                        onTap: () {
                                          setState(() => poBean.modeOfPayment = e);
                                        },
                                      ),
                                    )
                                    .toList(),
                                onChanged: (String? e) {
                                  setState(() => poBean.modeOfPayment = e ?? ModeOfPayment.CASH.name);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (isPoNotFilledCompletely(poBean)) return;
                    Navigator.pop(context);
                    await createOrUpdateInventoryPoAction(poBean);
                  },
                  child: const Text("Proceed to save"),
                ),
                if (poBean.poId != null)
                  TextButton(
                    onPressed: () async {
                      if (isPoNotFilledCompletely(poBean)) return;
                      Navigator.pop(context);
                      setState(() {
                        poBean.status = "inactive";
                      });
                      await createOrUpdateInventoryPoAction(poBean);
                    },
                    child: const Text("Delete Purchase Order"),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => poBean.fromJson(poBean.origJson()));
                  },
                  child: const Text("No"),
                ),
              ],
            );
          },
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buttonIcon,
          const SizedBox(width: 10),
          Text(buttonText),
        ],
      ),
    );
  }

  bool isPoNewAndEmpty(InventoryPoBean poBean) => poBean.poId == null
      ? (poBean.inventoryPurchaseItemBeans ?? []).where((e) => e?.status != "inactive").isNotEmpty
      : (poBean.inventoryPurchaseItemBeans ?? []).isNotEmpty;

  bool isPoNotFilledCompletely(InventoryPoBean poBean) =>
      (poBean.inventoryPurchaseItemBeans ?? []).where((e) => e?.status != "inactive").map((e) => e?.isFilledCompletely).contains(false);

  void itemNotPickedError(InventoryPurchaseItemBean purchaseItem, BuildContext context) {
    if (purchaseItem.itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pick an item to continue.."),
        ),
      );
    }
  }

  double getAlertBoxHeight(BuildContext context, {double scaleFactor = 2}) => MediaQuery.of(context).size.height / scaleFactor;

  double getAlertBoxWidth(BuildContext context, {double scaleFactor = 2}) => max(500, MediaQuery.of(context).size.width / scaleFactor);

  InventoryItemBean? getInventoryItemForPurchaseItem(InventoryPurchaseItemBean purchaseItem) =>
      inventoryItemBeans.firstWhereOrNull((e) => e.itemId == purchaseItem.itemId);

  Widget buildItemNamePickerForPO(InventoryPoBean poBean, InventoryPurchaseItemBean purchaseItem, StateSetter setState) {
    return EasyAutocomplete(
      autofocus: true,
      controller: TextEditingController(),
      suggestions: inventoryItemBeans
          .where((eachItem) => !(poBean.inventoryPurchaseItemBeans ?? []).map((e) => e?.itemId).contains(eachItem.itemId))
          .map((e) => e.itemName)
          .whereNotNull()
          .toList(),
      decoration: const InputDecoration(
        hintText: 'Item',
      ),
      suggestionBuilder: (data) {
        return Container(
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.all(5),
          child: SubstringHighlight(
            text: data,
            term: purchaseItem.itemNameController.text,
            textStyleHighlight: TextStyle(
              fontWeight: FontWeight.bold,
              color: clayContainerTextColor(context),
            ),
            textStyle: TextStyle(
              color: clayContainerTextColor(context),
            ),
          ),
        );
      },
      onChanged: (String value) {
        InventoryItemBean? newItem = inventoryItemBeans.firstWhereOrNull((e) => e.itemName == value);
        if (newItem == null) return;
        setState(() {
          purchaseItem.itemName = value;
          purchaseItem.itemId = newItem.itemId;
        });
      },
    );
  }

  Future<void> createOrUpdateInventoryPoAction(InventoryPoBean po) async {
    setState(() => _isLoading = true);
    CreateOrUpdateInventoryPoResponse createOrUpdateInventoryPoResponse = await createOrUpdateInventoryPo(CreateOrUpdateInventoryPoRequest(
      agentId: widget.adminProfile?.userId ?? widget.otherUserRoleProfile?.userId,
      schoolId: widget.adminProfile?.schoolId ?? widget.otherUserRoleProfile?.schoolId,
      isHostel: widget.isHostel ? "Y" : "N",
      transactionId: po.transactionId,
      status: po.status,
      amount: po.computeTotal,
      description: po.description,
      inventoryPurchaseItemBeans: po.inventoryPurchaseItemBeans,
      mediaType: po.mediaType,
      mediaUrl: po.mediaUrl,
      mediaUrlId: po.mediaUrlId,
      modeOfPayment: po.modeOfPayment,
      poId: po.poId,
      transactionDate: po.transactionDate,
    ));
    if (createOrUpdateInventoryPoResponse.httpStatus != "OK" || createOrUpdateInventoryPoResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      await _loadInventoryItems();
      await _loadInventoryPos();
    }
    setState(() => _isLoading = false);
  }

  Widget consumptionWidget() {
    if (inventoryItemBeans.isEmpty) return const Center(child: Text("No items in your inventory.."));
    if (inventoryItemConsumptionBeans.isEmpty) return const Center(child: Text("No items consumed yet.."));
    return ClayTable2DWidget(
      context: context,
      horizontalScrollController: consumptionHorizontalScrollController,
      dataTable: DataTable(
        columns: [
          const DataColumn(label: Text('Item Name')),
          const DataColumn(label: Text('Date')),
          const DataColumn(label: Text('Quantity Used')),
          const DataColumn(label: Text('Unit')),
          if (_isEditMode) const DataColumn(label: Text('Actions')),
        ],
        rows: inventoryItemConsumptionBeans
            .map(
              (consumedItem) => DataRow(
                cells: [
                  DataCell(Text(consumedItem.itemName ?? '')),
                  DataCell(Text(convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(consumedItem.date)))),
                  DataCell(Text("${consumedItem.quantityUsed}")),
                  DataCell(Text(consumedItem.unit ?? '')),
                  if (_isEditMode)
                    DataCell(
                      Row(
                        children: [
                          createOrUpdateItemConsumptionButton(consumedItem, const Icon(Icons.edit, size: 12), "Edit"),
                          const SizedBox(width: 10),
                          createOrUpdateItemConsumptionButton(consumedItem, const Icon(Icons.delete, size: 12, color: Colors.white), "Delete",
                              color: Colors.red),
                        ],
                      ),
                    ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget createOrUpdateItemConsumptionButton(InventoryItemConsumptionBean consumedItem, Icon buttonIcon, String buttonText,
      {Color color = Colors.blue}) {
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => color)),
      onPressed: () async {
        await showDialog(
          barrierDismissible: false,
          context: _scaffoldKey.currentContext!,
          builder: (currentContext) {
            if (buttonText == "Delete") {
              return deleteConsumptionAlertDialog(consumedItem);
            }
            return createOrUpdateConsumptionAlertDialog(consumedItem);
          },
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buttonIcon,
          const SizedBox(width: 10),
          Text(buttonText),
        ],
      ),
    );
  }

  Widget createOrUpdateConsumptionAlertDialog(InventoryItemConsumptionBean consumedItem) {
    return AlertDialog(
      title: Text("${consumedItem.itemId == null ? "Create" : "Update"} Item Consumption"),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          InventoryItemBean? item = inventoryItemBeans.firstWhereOrNull((e) => e.itemId == consumedItem.itemId);
          return SizedBox(
            width: getAlertBoxWidth(context),
            height: getAlertBoxHeight(context),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: consumedItem.itemId == null
                          ? buildItemNamePickerForConsumption(consumedItem, setState)
                          : Text(consumedItem.itemName ?? "-"),
                    ),
                    const SizedBox(width: 10),
                    Text(" x ${item?.unit ?? "-"} "),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: "${consumedItem.quantityUsed ?? ""}",
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            try {
                              if (consumedItem.itemId == null) return oldValue;
                              final text = newValue.text;
                              if (text.isNotEmpty) double.parse(text);
                              if (consumedItem.doNotLetQuantityExceedStock && (int.tryParse(newValue.text) ?? 0) > (item?.availableStock ?? 0)) {
                                return oldValue;
                              }
                              return newValue;
                            } on Exception catch (_, e) {
                              debugPrintStack(stackTrace: e);
                            }
                            return oldValue;
                          }),
                        ],
                        onChanged: (String e) => setState(() => consumedItem.quantityUsed = double.tryParse(e)),
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          hintText: '10',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(child: Text("Date")),
                    InkWell(
                      onTap: () async {
                        DateTime? _newDate = await showDatePicker(
                          context: context,
                          initialDate: convertYYYYMMDDFormatToDateTime(consumedItem.date),
                          firstDate: academicYearStartDate,
                          lastDate: DateTime.now(),
                          helpText: "Select a date",
                        );
                        if (_newDate == null) return;
                        setState(() => consumedItem.date = convertDateTimeToYYYYMMDDFormat(_newDate));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(consumedItem.date))),
                        ),
                      ),
                    ),
                  ],
                ),
                if (item != null) const SizedBox(height: 10),
                if (item != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [const Expanded(child: Text("Available stock:")), Text(item.availableStock?.toString() ?? "-")],
                  ),
                if (item != null) const SizedBox(height: 20),
                if (item != null)
                  Row(
                    children: [
                      Checkbox(
                        value: consumedItem.doNotLetQuantityExceedStock,
                        onChanged: (bool? newValue) => setState(() => consumedItem.doNotLetQuantityExceedStock = newValue ?? false),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text("Do not let the quantity exceed the available stock"),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            if (consumedItem.itemId == null || (consumedItem.quantityUsed ?? 0) == 0) return;
            createOrUpdateInventoryItemsConsumptionAction(consumedItem);
          },
          child: const Text("Proceed to save"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("No"),
        ),
      ],
    );
  }

  Widget buildItemNamePickerForConsumption(InventoryItemConsumptionBean itemConsumptionBean, StateSetter setState) {
    return EasyAutocomplete(
      autofocus: true,
      controller: TextEditingController(),
      suggestions:
          inventoryItemBeans.where((eachItem) => itemConsumptionBean.itemId != eachItem.itemId).map((e) => e.itemName).whereNotNull().toList(),
      decoration: const InputDecoration(
        hintText: 'Item',
      ),
      suggestionBuilder: (data) {
        return Container(
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.all(5),
          child: SubstringHighlight(
            text: data,
            term: itemConsumptionBean.itemNameController.text,
            textStyleHighlight: TextStyle(
              fontWeight: FontWeight.bold,
              color: clayContainerTextColor(context),
            ),
            textStyle: TextStyle(
              color: clayContainerTextColor(context),
            ),
          ),
        );
      },
      onChanged: (String value) {
        InventoryItemBean? newItem = inventoryItemBeans.firstWhereOrNull((e) => e.itemName == value);
        if (newItem == null) return;
        setState(() {
          itemConsumptionBean.itemName = value;
          itemConsumptionBean.itemId = newItem.itemId;
        });
      },
    );
  }

  Future<void> createOrUpdateInventoryItemsConsumptionAction(InventoryItemConsumptionBean consumedItem) async {
    setState(() => _isLoading = true);
    CreateOrUpdateInventoryItemsConsumptionResponse createOrUpdateInventoryItemsConsumptionResponse =
        await createOrUpdateInventoryItemsConsumption(CreateOrUpdateInventoryItemsConsumptionRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherUserRoleProfile?.schoolId,
      agentId: widget.adminProfile?.userId ?? widget.otherUserRoleProfile?.userId,
      inventoryItemConsumptionBeans: [consumedItem],
    ));
    if (createOrUpdateInventoryItemsConsumptionResponse.httpStatus != "OK" ||
        createOrUpdateInventoryItemsConsumptionResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      await _loadInventoryItems();
      await _loadInventoryConsumption();
    }
    setState(() => _isLoading = false);
  }

  Widget deleteConsumptionAlertDialog(InventoryItemConsumptionBean consumedItem) {
    return AlertDialog(
      title: Text("Delete Item Consumption for ${consumedItem.itemName}"),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            if (consumedItem.itemId == null || (consumedItem.quantityUsed ?? 0) == 0) return;
            consumedItem.status = "inactive";
            createOrUpdateInventoryItemsConsumptionAction(consumedItem);
          },
          child: const Text("Proceed to save"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("No"),
        ),
      ],
    );
  }

  Widget logWidget() {
    if (inventoryItemBeans.isEmpty) return const Center(child: Text("No items in your inventory.."));
    if (inventoryLogBeans.isEmpty) return const Center(child: Text("No items recorded yet.."));
    return ClayTable2DWidget(
      context: context,
      horizontalScrollController: logHorizontalScrollController,
      dataTable: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Item Name')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Unit')),
          DataColumn(label: Text('')),
        ],
        rows: inventoryLogBeans
            .map(
              (item) => DataRow(
                cells: [
                  DataCell(Text(item.date == null ? "-" : convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(item.date)))),
                  DataCell(Text(item.itemName ?? '')),
                  DataCell(Text("${item.quantity ?? "-"}")),
                  DataCell(Text(item.unit ?? '-')),
                  DataCell(
                    item.logType == "LOADED"
                        ? const Icon(
                            Icons.arrow_drop_up,
                            size: 16,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: Colors.red,
                          ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
