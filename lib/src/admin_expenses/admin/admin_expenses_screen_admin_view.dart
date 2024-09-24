import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/admin_expenses_creation_in_bulk.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/date_wise_admin_expenses_stats_screen.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/admin_expenses.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/pocket_balances.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/common_components/media_loading_widget.dart';
import 'package:schoolsgo_web/src/common_components/search_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:substring_highlight/substring_highlight.dart';

class AdminExpenseScreenAdminView extends StatefulWidget {
  const AdminExpenseScreenAdminView({
    Key? key,
    this.adminProfile,
    this.receptionistProfile,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final OtherUserRoleProfile? receptionistProfile;

  @override
  State<AdminExpenseScreenAdminView> createState() => _AdminExpenseScreenAdminViewState();
}

class _AdminExpenseScreenAdminViewState extends State<AdminExpenseScreenAdminView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool isSearchBarSelected = false;

  List<AdminExpenseBean> adminExpenses = [];
  List<AdminExpenseBean> filteredAdminExpenses = [];
  late PocketBalanceBean pocketBalanceBean;
  bool isEditMode = false;
  bool isAddNew = false;
  late AdminExpenseBean newAdminExpenseBean;

  String? _reportDownloadStatus;
  final ItemScrollController _itemScrollController = ItemScrollController();
  double headerHeight = 200;
  Set<String> uniqueExpenseTypes = {};

  String? _uploadingFile;
  double? _fileUploadProgress;
  String? reportName;

  late int newVoucherNumber;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      isAddNew = false;
    });
    newVoucherNumber = await getNewVoucherNumber();
    newAdminExpenseBean = AdminExpenseBean(
      franchiseId: widget.adminProfile?.franchiseId,
      schoolId: widget.adminProfile?.schoolId ?? widget.receptionistProfile?.schoolId,
      agent: widget.adminProfile?.userId ?? widget.receptionistProfile?.userId,
      adminId: widget.adminProfile?.userId ?? widget.receptionistProfile?.userId,
      adminName: widget.adminProfile?.firstName ?? widget.receptionistProfile?.userName,
      adminPhotoUrl: widget.adminProfile?.adminPhotoUrl,
      transactionTime: null,
      adminExpenseReceiptsList: [],
      receiptId: newVoucherNumber,
      status: "active",
    )..isEditMode = true;
    GetAdminExpensesResponse getAdminExpensesResponse = await getAdminExpenses(GetAdminExpensesRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.receptionistProfile?.schoolId,
      franchiseId: widget.adminProfile?.franchiseId,
      agent: widget.receptionistProfile?.userId,
    ));
    if (getAdminExpensesResponse.httpStatus != "OK" || getAdminExpensesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      adminExpenses = getAdminExpensesResponse.adminExpenseBeanList!.map((e) => e!).toList();
      filteredAdminExpenses = getAdminExpensesResponse.adminExpenseBeanList!.map((e) => e!).toList()
        ..sort((b, a) {
          DateTime aDateTime = DateTime.fromMillisecondsSinceEpoch(a.transactionTime!);
          DateTime bDateTime = DateTime.fromMillisecondsSinceEpoch(b.transactionTime!);
          if (convertDateTimeToDDMMYYYYFormat(aDateTime) == convertDateTimeToDDMMYYYYFormat(bDateTime)) {
            return (a.receiptId ?? 0).compareTo(a.receiptId ?? 0);
          }
          if (a.transactionTime != null && b.transactionTime != null) {
            return a.transactionTime!.compareTo(b.transactionTime!);
          }
          if (a.adminExpenseId != null && b.adminExpenseId != null) {
            return a.adminExpenseId!.compareTo(b.adminExpenseId!);
          }
          return 0;
        });
      uniqueExpenseTypes = filteredAdminExpenses.map((e) => e.expenseType ?? "-").where((e) => e != "-").toList().toSet();
    }
    GetPocketBalancesResponse getPocketBalancesResponse = await getPocketBalances(GetPocketBalancesRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.receptionistProfile?.schoolId,
      employeeId: widget.adminProfile?.userId ?? widget.receptionistProfile?.userId,
    ));
    if (getPocketBalancesResponse.httpStatus != "OK" || getPocketBalancesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      pocketBalanceBean = getPocketBalancesResponse.pocketBalanceBeanList?.firstOrNull ??
          PocketBalanceBean(
            employeeId: widget.adminProfile?.userId ?? widget.receptionistProfile?.userId,
            schoolId: widget.adminProfile?.schoolId ?? widget.receptionistProfile?.schoolId,
            employeeName: widget.adminProfile?.firstName ?? widget.receptionistProfile?.userName,
            balanceAmount: 0,
            lastTransactionDate: null,
          );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void isSearchButtonSelected(bool isSelected) {
    setState(() {
      isSearchBarSelected = isSelected;
    });
  }

  Future<int> getNewVoucherNumber() async {
    return await HttpUtils.getNewVoucherNumber(widget.adminProfile?.schoolId ?? widget.receptionistProfile?.schoolId ?? -1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Admin Expenses"),
        actions: [
          if (!isSearchBarSelected)
            SearchWidget(
              isSearchBarSelectedByDefault: false,
              onComplete: scrollToIndex,
              receiptNumbers: filteredAdminExpenses.map((e) => "${e.receiptId ?? ""}").toList(),
              isSearchButtonSelected: isSearchButtonSelected,
              searchType: "Voucher",
            ),
          if (widget.adminProfile != null)
            PopupMenuButton<String>(
              onSelected: (String choice) async => await handleMoreOptions(choice),
              itemBuilder: (BuildContext context) {
                return {
                  if (!isEditMode && filteredAdminExpenses.isNotEmpty) 'Download Report',
                  if (widget.adminProfile != null && isEditMode) 'Download Template',
                  if (widget.adminProfile != null && isEditMode) 'Upload from Template',
                  if (!isEditMode && filteredAdminExpenses.isNotEmpty) 'Date Wise Stats',
                  if (filteredAdminExpenses.isNotEmpty) 'Go to date',
                  if (filteredAdminExpenses.isNotEmpty) 'Search',
                }.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
        ],
      ),
      drawer: widget.adminProfile != null
          ? AdminAppDrawer(
              adminProfile: widget.adminProfile!,
            )
          : ReceptionistAppDrawer(
              receptionistProfile: widget.receptionistProfile!,
            ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : _reportDownloadStatus != null
              ? reportDownloadInProgressWidget()
              : _uploadingFile != null
                  ? fileUploadInProgressWidget()
                  : Stack(
                      children: [
                        expensesListViewWidget(),
                        if (isSearchBarSelected)
                          Align(
                            alignment: Alignment.topRight,
                            child: searchBar(),
                          ),
                      ],
                    ),
      floatingActionButton: isEditMode && !isAddNew && !(filteredAdminExpenses.map((e) => e.isEditMode).contains(true))
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildAddNewButton(),
                const SizedBox(height: 10),
                buildEditButton(),
              ],
            )
          : buildEditButton(),
    );
  }

  Container searchBar() {
    return Container(
      height: 75,
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
      child: Container(
        color: clayContainerColor(context),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: SearchWidget(
          isSearchBarSelectedByDefault: true,
          onComplete: scrollToIndex,
          receiptNumbers: filteredAdminExpenses.map((e) => "${e.receiptId ?? ""}").toList(),
          isSearchButtonSelected: isSearchButtonSelected,
          searchType: "Voucher",
        ),
      ),
    );
  }

  Column fileUploadInProgressWidget() {
    return Column(
      children: [
        const Expanded(
          flex: 1,
          child: Center(
            child: Text("Uploading files"),
          ),
        ),
        Expanded(
          flex: 3,
          child: Image.asset(
            'assets/images/eis_loader.gif',
            fit: BoxFit.scaleDown,
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text("Uploading file $_uploadingFile"),
          ),
        ),
        Expanded(
          child: Center(
            child: LinearPercentIndicator(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              alignment: MainAxisAlignment.center,
              width: 140.0,
              lineHeight: 14.0,
              percent: (_fileUploadProgress ?? 0) / 100,
              center: Text(
                "${(_fileUploadProgress ?? 0).toStringAsFixed(2)} %",
                style: const TextStyle(fontSize: 12.0),
              ),
              leading: const Icon(Icons.file_upload),
              linearStrokeCap: LinearStrokeCap.roundAll,
              backgroundColor: Colors.grey,
              progressColor: Colors.blue,
            ),
          ),
        )
      ],
    );
  }

  Column reportDownloadInProgressWidget() {
    return Column(
      children: [
        const Expanded(
          flex: 1,
          child: Center(
            child: Text("Report download in progress"),
          ),
        ),
        Expanded(
          flex: 3,
          child: Image.asset(
            'assets/images/eis_loader.gif',
            fit: BoxFit.scaleDown,
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text("$reportName"),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(_reportDownloadStatus!),
          ),
        )
      ],
    );
  }

  GestureDetector buildAddNewButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isAddNew = !isAddNew;
        });
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 40,
        width: 40,
        borderRadius: 50,
        spread: 2,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  GestureDetector buildEditButton() {
    return GestureDetector(
      onTap: () {
        if (filteredAdminExpenses.map((e) => e.isEditMode).contains(true) || isAddNew) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Save changes to continue.."),
            ),
          );
          scrollToIndex(filteredAdminExpenses.indexWhere((e) => e.isEditMode));
          return;
        }
        setState(() {
          isEditMode = !isEditMode;
        });
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 40,
        width: 40,
        borderRadius: 50,
        spread: 2,
        child: Icon(
          isEditMode ? Icons.check : Icons.edit,
        ),
      ),
    );
  }

  Widget expensesListViewWidget() {
    if (!isAddNew) {
      return ScrollablePositionedList.builder(
        initialScrollIndex: 0,
        physics: const BouncingScrollPhysics(),
        itemScrollController: _itemScrollController,
        itemCount: filteredAdminExpenses.length,
        itemBuilder: (BuildContext context, int index) {
          AdminExpenseBean e = filteredAdminExpenses[index];
          return e.isEditMode
              ? buildEachAdminExpenseBeanEditMode(e)
              : buildEachAdminExpenseBeanReadMode(e, canEdit: isEditMode && filteredAdminExpenses.where((e) => e.isEditMode).isEmpty);
        },
      );
    }
    return SingleChildScrollView(
      child: buildEachAdminExpenseBeanEditMode(newAdminExpenseBean),
    );
  }

  Widget buildEachAdminExpenseBeanReadMode(
    AdminExpenseBean eachExpense, {
    bool canEdit = true,
    bool noMargins = false,
  }) {
    return Container(
      margin: noMargins
          ? const EdgeInsets.all(20)
          : MediaQuery.of(context).orientation == Orientation.landscape
              ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
              : const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: buildReadModeExpenseVoucherWidget(eachExpense),
                      ),
                      if (canEdit)
                        const SizedBox(
                          width: 10,
                        ),
                      if (canEdit) buildEditButtonForExpense(eachExpense),
                      if (canEdit)
                        const SizedBox(
                          width: 10,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: buildReadModeExpenseTypeWidget(eachExpense)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildReadModeExpenseDescriptionWidget(eachExpense),
                      ),
                      buildReadModeExpenseAmountWidget(eachExpense),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if ((eachExpense.adminExpenseReceiptsList ?? []).isNotEmpty)
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(child: buildReadModeExpenseMedia(eachExpense)),
                        const SizedBox(width: 10),
                      ],
                    ),
                  if ((eachExpense.adminExpenseReceiptsList ?? []).isNotEmpty) const SizedBox(height: 10),
                  if (eachExpense.comments != null)
                    Row(
                      children: [
                        Expanded(child: buildReadModeExpenseCommentsWidget(eachExpense)),
                      ],
                    ),
                  if (eachExpense.comments != null) const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: buildReadModeExpenseModeOfPaymentWidget(eachExpense)),
                      const SizedBox(width: 10),
                      buildReadModeExpenseDateOfPaymentWidget(eachExpense),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            if (eachExpense.getIsPocketTransaction()) const SizedBox(height: 10),
            if (eachExpense.getIsPocketTransaction())
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: Colors.yellow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "This expense is spent from ${eachExpense.adminName ?? "-"}'s Wallet",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Row buildReadModeExpenseAmountWidget(AdminExpenseBean eachExpense) {
    return Row(
      children: [
        Text(
          INR_SYMBOL + " " + (eachExpense.amount == null ? "-" : doubleToStringAsFixed(eachExpense.amount! / 100, decimalPlaces: 2)),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        const Icon(
          Icons.arrow_drop_down_outlined,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget buildReadModeExpenseMedia(AdminExpenseBean eachExpense) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      itemCount: (eachExpense.adminExpenseReceiptsList ?? []).where((i) => i!.status != 'inactive').toList().length,
      itemBuilder: (context, index) {
        return buildMediaForReadMode(eachExpense, index);
      },
    );
  }

  Widget buildReadModeExpenseVoucherWidget(AdminExpenseBean eachExpense) {
    return Text(
      "Voucher No. ${eachExpense.receiptId ?? "-"}",
      style: const TextStyle(color: Colors.red),
    );
  }

  Text buildReadModeExpenseCommentsWidget(AdminExpenseBean eachExpense) {
    return Text(
      "Comments: ${eachExpense.comments ?? "-"}",
      style: const TextStyle(fontSize: 12),
      textAlign: (eachExpense.description ?? "").length > 120 ? TextAlign.justify : TextAlign.left,
    );
  }

  Text buildReadModeExpenseDescriptionWidget(AdminExpenseBean eachExpense) {
    return Text(
      eachExpense.description ?? "-",
      style: const TextStyle(fontSize: 14),
      textAlign: (eachExpense.description ?? "").length > 120 ? TextAlign.justify : TextAlign.left,
    );
  }

  Widget buildReadModeExpenseTypeWidget(AdminExpenseBean eachExpense) {
    return Text(
      eachExpense.expenseType ?? "-",
      style: const TextStyle(
        color: Colors.blue,
      ),
    );
  }

  Widget buildEachAdminExpenseBeanEditMode(AdminExpenseBean eachExpense) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
          : const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: buildVoucherTextField(eachExpense),
                  ),
                  if (eachExpense.adminExpenseId != null) const SizedBox(width: 10),
                  if (eachExpense.adminExpenseId != null) buildDeleteButtonForExpense(eachExpense),
                  const SizedBox(width: 10),
                  buildEditButtonForExpense(eachExpense),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              buildSimpleAutoCompleteTextFieldForExpenseType(eachExpense),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: buildDescriptionTextField(eachExpense),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          // height: 150,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 5.0,
                              mainAxisSpacing: 5.0,
                            ),
                            itemCount: eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList().length + 1,
                            itemBuilder: (context, index) {
                              if (index == eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList().length) {
                                return buildAddNewReceiptsToExpense(eachExpense);
                              }
                              return buildMediaForEditMode(eachExpense, index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    width: 100,
                    child: buildExpenseAmountTextField(eachExpense),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              buildCommentsTextField(eachExpense),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: buildEditModeExpenseModeOfPaymentWidget(eachExpense)),
                  const SizedBox(width: 10),
                  buildExpenseDatePicker(eachExpense),
                  const SizedBox(width: 10),
                  buildExpenseTimePicker(eachExpense),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: (eachExpense.isPocketTransaction ?? "N") == "Y",
                onChanged: (bool? newValue) {
                  if (!(eachExpense.getIsPocketTransaction()) &&
                      (newValue ?? false) &&
                      (pocketBalanceBean.balanceAmount ?? 0) < (eachExpense.amount ?? 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("You do not have enough balance to pay for this expense.."),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    eachExpense.isPocketTransaction = newValue ?? false ? "Y" : "N";
                  });
                },
                title: Text(
                  "Paying from ${eachExpense.adminName ?? "-"}'s Wallet\nCurrent Balance: $INR_SYMBOL ${(pocketBalanceBean.balanceAmount ?? 0) / 100} /-",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpenseTimePicker(AdminExpenseBean eachExpense) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.vibrate();
        TimeOfDay? expenseTimePicker = await showTimePicker(
          context: context,
          initialTime:
              convertDateTimeToTimeOfDay(DateTime.fromMillisecondsSinceEpoch(eachExpense.transactionTime ?? DateTime.now().millisecondsSinceEpoch)),
        );
        if (expenseTimePicker == null) return;
        DateTime existingDate = DateTime.fromMillisecondsSinceEpoch(eachExpense.transactionTime ?? DateTime.now().millisecondsSinceEpoch);
        DateTime newDateTime = DateTime(existingDate.year, existingDate.month, existingDate.day, expenseTimePicker.hour, expenseTimePicker.minute);
        setState(() {
          eachExpense.transactionTime = newDateTime.millisecondsSinceEpoch;
        });
      },
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        spread: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            convertDateTimeToHHMMA(DateTime.fromMillisecondsSinceEpoch(eachExpense.transactionTime ?? DateTime.now().millisecondsSinceEpoch)),
          ),
        ),
      ),
    );
  }

  Widget buildExpenseDatePicker(AdminExpenseBean eachExpense) {
    String txnDate = eachExpense.transactionTime == null
        ? convertDateTimeToDDMMYYYYFormat(DateTime.now())
        : convertDateToDDMMMYYYY(convertDateTimeToYYYYMMDDFormat(DateTime.fromMillisecondsSinceEpoch(eachExpense.transactionTime!)))
            .replaceAll("\n", " ");
    return InkWell(
      onTap: () async {
        DateTime? _newDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 364)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          helpText: "Select a date",
        );
        if (_newDate == null) return;
        int existingMillis = eachExpense.transactionTime ?? DateTime.now().millisecondsSinceEpoch;
        TimeOfDay existingTime = convertDateTimeToTimeOfDay(DateTime.fromMillisecondsSinceEpoch(existingMillis));
        _newDate = DateTime(_newDate.year, _newDate.month, _newDate.day, existingTime.hour, existingTime.minute);
        setState(() {
          eachExpense.transactionTime = _newDate!.millisecondsSinceEpoch;
        });
      },
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        spread: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(txnDate),
        ),
      ),
    );
  }

  Widget buildReadModeExpenseDateOfPaymentWidget(AdminExpenseBean eachExpense) {
    DateTime txnDateTime = eachExpense.transactionTime == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(eachExpense.transactionTime!);
    String txnDate = convertEpochToDDMMYYYYEEEEHHMMAA(txnDateTime.millisecondsSinceEpoch);
    return Text(txnDate);
  }

  Widget buildEditModeExpenseModeOfPaymentWidget(AdminExpenseBean eachExpense) {
    return DropdownButton<String>(
      value: eachExpense.modeOfPayment ?? ModeOfPayment.CASH.name,
      items: ModeOfPayment.values
          .map((e) => DropdownMenuItem<String>(
                value: e.name,
                child: Text(e.description),
                onTap: () {
                  setState(() {
                    eachExpense.modeOfPayment = e.name;
                  });
                },
              ))
          .toList(),
      onChanged: (String? e) {
        e ??= ModeOfPayment.CASH.name;
        setState(() {
          eachExpense.modeOfPayment = e;
        });
      },
    );
  }

  Text buildReadModeExpenseModeOfPaymentWidget(AdminExpenseBean eachExpense) {
    return Text(
      ModeOfPaymentExt.fromString(eachExpense.modeOfPayment ?? "CASH").description,
      style: const TextStyle(color: Colors.blue),
    );
  }

  InkWell buildAddNewReceiptsToExpense(AdminExpenseBean eachExpense) {
    return InkWell(
      onTap: () {
        html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
        uploadInput.multiple = true;
        uploadInput.draggable = true;
        uploadInput.accept =
            '.png,.jpg,.jpeg,.pdf,.zip,.doc,.7z,.arj,.deb,.pkg,.rar,.rpm,.tar.gz,.z,.zip,.csv,.dat,.db,.dbf,.log,.mdb,.sav,.sql,.tar,.xml';
        uploadInput.click();
        uploadInput.onChange.listen(
          (changeEvent) {
            final files = uploadInput.files!;
            for (html.File file in files) {
              final reader = html.FileReader();
              reader.readAsDataUrl(file);
              reader.onLoadEnd.listen(
                (loadEndEvent) async {
                  // _file = file;
                  debugPrint("File uploaded: " + file.name);
                  setState(() {
                    _uploadingFile = file.name;
                    _fileUploadProgress = ((files.indexOf(file) / files.length) + (1 / (2 * files.length))) * 100.0;
                  });

                  try {
                    UploadFileToDriveResponse uploadFileResponse = await uploadFileToDrive(reader.result!, file.name);

                    AdminExpenseReceiptBean newAdminExpenseReceiptBean = AdminExpenseReceiptBean();
                    newAdminExpenseReceiptBean.expenseId = eachExpense.adminExpenseId;
                    newAdminExpenseReceiptBean.status = "active";
                    newAdminExpenseReceiptBean.mediaType = uploadFileResponse.mediaBean!.mediaType;
                    newAdminExpenseReceiptBean.mediaUrl = uploadFileResponse.mediaBean!.mediaUrl;
                    newAdminExpenseReceiptBean.mediaId = uploadFileResponse.mediaBean!.mediaId;

                    if (eachExpense.adminExpenseReceiptsList == null && eachExpense.adminExpenseReceiptsList!.isEmpty) {
                      setState(() {
                        eachExpense.adminExpenseReceiptsList = [];
                      });
                    }
                    setState(() {
                      eachExpense.adminExpenseReceiptsList!.add(newAdminExpenseReceiptBean);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Something went wrong while trying to upload, ${file.name}..\nPlease try again later"),
                      ),
                    );
                  }

                  setState(() {
                    _uploadingFile = null;
                  });
                },
              );
            }
          },
        );
      },
      child: Stack(
        children: const [
          Align(
            alignment: Alignment.center,
            child: Icon(Icons.add_to_photos),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text("Add attachments"),
            ),
          )
        ],
      ),
    );
  }

  InkWell buildMediaForReadMode(AdminExpenseBean eachExpense, int index) {
    return InkWell(
      onTap: () {
        openMediaBeans(eachExpense, index);
      },
      child: Container(
        color: Colors.transparent,
        height: 100,
        width: 100,
        padding: const EdgeInsets.all(2),
        child: eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl != null &&
                getFileTypeForExtension(eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!) ==
                    MediaFileType.IMAGE_FILES
            ? MediaLoadingWidget(
                mediaUrl: eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
              )
            : Image.asset(
                getAssetImageForFileType(
                  getFileTypeForExtension(
                    eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!,
                  ),
                ),
                scale: 0.5,
              ),
      ),
    );
  }

  InkWell buildMediaForEditMode(AdminExpenseBean eachExpense, int index) {
    return InkWell(
      onTap: () {
        openMediaBeans(eachExpense, index);
      },
      child: Container(
        color: Colors.transparent,
        height: 100,
        width: 100,
        padding: const EdgeInsets.all(2),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child:
                  getFileTypeForExtension(eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!) ==
                          MediaFileType.IMAGE_FILES
                      ? MediaLoadingWidget(
                          mediaUrl: eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                        )
                      : Image.asset(
                          getAssetImageForFileType(
                            getFileTypeForExtension(
                              eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!,
                            ),
                          ),
                          scale: 0.5,
                        ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  if (eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.status == 'active') {
                    setState(() {
                      eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.status = 'inactive';
                    });
                  } else {
                    setState(() {
                      eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.status = 'active';
                    });
                  }
                },
                child: eachExpense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.status == 'active'
                    ? const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 18,
                      )
                    : const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  openMediaBeans(AdminExpenseBean expense, int index) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      expense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
      (int viewId) => html.IFrameElement()
        ..src = expense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!
        ..allowFullscreen = false
        ..style.border = 'none'
        ..height = '500'
        ..width = '300',
    );
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  expense.description ?? "-",
                ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  InkWell(
                    child: const Icon(Icons.download_rounded),
                    onTap: () {
                      downloadFile(
                        expense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                        filename: getCurrentTimeStringInDDMMYYYYHHMMSS() +
                            "." +
                            expense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!,
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    child: const Icon(Icons.open_in_new),
                    onTap: () {
                      html.window.open(
                        expense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                        '_blank',
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                ],
              )
            ],
          ),
          content: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  openMediaBeans(expense, index - 1);
                },
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: index == 0 ? null : const Icon(Icons.arrow_left),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 1,
                child: getFileTypeForExtension(expense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!) ==
                        MediaFileType.IMAGE_FILES
                    ? MediaLoadingWidget(
                        mediaUrl: expense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                      )
                    : HtmlElementView(
                        viewType: expense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                      ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  openMediaBeans(expense, index + 1);
                },
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: index == expense.adminExpenseReceiptsList!.where((i) => i!.status != 'inactive').toList().length - 1
                        ? null
                        : const Icon(Icons.arrow_right),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> handleMoreOptions(String value) async {
    if (widget.adminProfile == null) return;
    switch (value) {
      case "Download Report":
        if (_reportDownloadStatus == null) {
          downloadReport();
        }
        return;
      case "Download Template":
        await downloadTemplateAction();
        return;
      case "Upload from Template":
        await uploadFromTemplateAction();
        return;
      case "Go to date":
        await showGoToDateAction();
        return;
      case "Search":
        await showGoToDateAction();
        return;
      case "Date Wise Stats":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return DateWiseAdminExpensesStatsScreen(adminProfile: widget.adminProfile!, adminExpenses: filteredAdminExpenses);
            },
          ),
        );
        return;
      default:
        return;
    }
  }

  Future<void> showGoToDateAction() async {
    DateTime currentDate = DateTime.now();

    DateTime parseDateTime(int? timestamp) => DateTime.fromMillisecondsSinceEpoch(timestamp ?? currentDate.millisecondsSinceEpoch);

    DateTime firstDate = filteredAdminExpenses.map((e) => parseDateTime(e.transactionTime)).reduce((a, b) => a.isBefore(b) ? a : b);

    DateTime lastDate = filteredAdminExpenses.map((e) => parseDateTime(e.transactionTime)).reduce((a, b) => a.isAfter(b) ? a : b);

    DateTime initialDate = currentDate.isBefore(lastDate) ? currentDate : lastDate;

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (DateTime? eachDate) {
        String formattedDate = convertDateTimeToDDMMYYYYFormat(eachDate ?? currentDate);
        return filteredAdminExpenses.map((e) => convertDateTimeToDDMMYYYYFormat(parseDateTime(e.transactionTime))).contains(formattedDate);
      },
    );

    if (selectedDate == null) return;

    int scrollIndex = filteredAdminExpenses
        .map((e) => e.transactionTime)
        .toList()
        .indexWhere((time) => convertDateTimeToDDMMYYYYFormat(selectedDate) == convertDateTimeToDDMMYYYYFormat(parseDateTime(time)));

    scrollToIndex(scrollIndex);
  }

  void scrollToIndex(int e) {
    if (e == -1) return;
    _itemScrollController.scrollTo(
      index: e,
      duration: const Duration(milliseconds: 100),
      curve: Curves.bounceInOut,
    );
  }

  Future<void> downloadTemplateAction() async {
    setState(() => _isLoading = true);
    await AdminExpensesCreationInBulk(
      filteredAdminExpenses,
      widget.adminProfile!,
    ).downloadTemplate();
    setState(() => _isLoading = false);
  }

  Future<void> uploadFromTemplateAction() async {
    setState(() => _isLoading = true);
    List<AdminExpenseBean>? newExpenses = await AdminExpensesCreationInBulk(
      filteredAdminExpenses,
      widget.adminProfile!,
    ).readAndValidateExcel(context);
    if ((newExpenses ?? []).isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text("Confirm if the following are the new expenses"),
          content: SizedBox(
            height: MediaQuery.of(context).size.height - 150,
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListView(
              children: newExpenses!.map((e) => buildEachAdminExpenseBeanReadMode(e, canEdit: false, noMargins: true)).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });
                CreateOrUpdateAdminExpensesResponse createOrUpdateAdminExpensesResponse =
                    await createOrUpdateAdminExpenses(CreateOrUpdateAdminExpensesRequest(
                  agentId: widget.adminProfile!.userId,
                  schoolId: widget.adminProfile!.schoolId,
                  adminExpenseBeans: newExpenses,
                ));
                if (createOrUpdateAdminExpensesResponse.httpStatus != "OK" || createOrUpdateAdminExpensesResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                  setState(() => _isLoading = false);
                  return;
                } else {
                  await _loadData();
                }
              },
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                setState(() => _isLoading = false);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> downloadReport() async {
    setState(() {
      reportName = "Admin Expenses - ${convertEpochToDDMMYYYYHHMMSSAA(DateTime.now().millisecondsSinceEpoch)}.xls";
      _reportDownloadStatus = "Creating file";
    });
    List<int> bytes = await getAdminExpensesReport(GetAdminExpensesRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.receptionistProfile?.schoolId,
    ));
    html.AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", reportName!)
      ..click();
    setState(() {
      _reportDownloadStatus = "Writing your data into the file";
    });
    setState(() {
      _reportDownloadStatus = null;
    });
  }

  Future<void> _saveChanges(AdminExpenseBean eachExpense) async {
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: Text(eachExpense.status == "active" ? 'Are you sure you want to save changes?' : 'Are you sure you want to delete expense?'),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                if (mapEquals(eachExpense.toJson(), eachExpense.origJson())) {
                  return;
                }
                setState(() {
                  _isLoading = true;
                });
                CreateOrUpdateAdminExpenseRequest createOrUpdateAdminExpenseRequest = CreateOrUpdateAdminExpenseRequest()
                  ..agent = widget.adminProfile?.userId ?? widget.receptionistProfile?.userId
                  ..adminExpenseId = eachExpense.adminExpenseId
                  ..adminId = eachExpense.adminId
                  ..adminName = eachExpense.adminName
                  ..adminPhotoUrl = eachExpense.adminPhotoUrl
                  ..amount = eachExpense.amount
                  ..branchCode = eachExpense.branchCode
                  ..description = eachExpense.description
                  ..expenseType = eachExpense.expenseType
                  ..franchiseId = eachExpense.franchiseId
                  ..franchiseName = eachExpense.franchiseName
                  ..schoolId = eachExpense.schoolId
                  ..schoolName = eachExpense.schoolName
                  ..status = eachExpense.status
                  ..modeOfPayment = eachExpense.modeOfPayment
                  ..transactionId = eachExpense.transactionId
                  ..comments = eachExpense.comments
                  ..receiptId = eachExpense.receiptId
                  ..transactionTime = eachExpense.transactionTime ?? DateTime.now().millisecondsSinceEpoch
                  ..isPocketTransaction = eachExpense.isPocketTransaction
                  ..adminExpenseReceiptsList = eachExpense.adminExpenseReceiptsList
                      ?.where(
                          (eachReceipt) => eachReceipt != null && !const DeepCollectionEquality().equals(eachReceipt.toJson(), eachReceipt.origJson))
                      .toList();
                CreateOrUpdateAdminExpenseResponse createOrUpdateAdminExpenseResponse =
                    await createOrUpdateAdminExpense(createOrUpdateAdminExpenseRequest);
                if (createOrUpdateAdminExpenseResponse.httpStatus != "OK" || createOrUpdateAdminExpenseResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                  setState(() {
                    _isLoading = true;
                  });
                  return;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Changes updated successfully.."),
                    ),
                  );
                  await _loadData();
                }
              },
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                if (eachExpense.adminExpenseId == null) {
                  setState(() {
                    isAddNew = false;
                    newAdminExpenseBean = AdminExpenseBean(
                      franchiseId: widget.adminProfile?.franchiseId,
                      schoolId: widget.adminProfile?.schoolId ?? widget.receptionistProfile?.schoolId,
                      agent: widget.adminProfile?.userId ?? widget.receptionistProfile?.userId,
                      adminId: widget.adminProfile?.userId ?? widget.receptionistProfile?.userId,
                      adminName: widget.adminProfile?.firstName ?? widget.receptionistProfile?.userName,
                      adminPhotoUrl: widget.adminProfile?.adminPhotoUrl,
                      transactionTime: null,
                      adminExpenseReceiptsList: [],
                      status: "active",
                    )..isEditMode = true;
                  });
                } else {
                  setState(() {
                    eachExpense
                      ..agent = AdminExpenseBean.fromJson(eachExpense.origJson()).agent
                      ..adminExpenseId = AdminExpenseBean.fromJson(eachExpense.origJson()).adminExpenseId
                      ..adminId = AdminExpenseBean.fromJson(eachExpense.origJson()).adminId
                      ..adminName = AdminExpenseBean.fromJson(eachExpense.origJson()).adminName
                      ..adminPhotoUrl = AdminExpenseBean.fromJson(eachExpense.origJson()).adminPhotoUrl
                      ..amount = AdminExpenseBean.fromJson(eachExpense.origJson()).amount
                      ..branchCode = AdminExpenseBean.fromJson(eachExpense.origJson()).branchCode
                      ..description = AdminExpenseBean.fromJson(eachExpense.origJson()).description
                      ..expenseType = AdminExpenseBean.fromJson(eachExpense.origJson()).expenseType
                      ..franchiseId = AdminExpenseBean.fromJson(eachExpense.origJson()).franchiseId
                      ..franchiseName = AdminExpenseBean.fromJson(eachExpense.origJson()).franchiseName
                      ..schoolId = AdminExpenseBean.fromJson(eachExpense.origJson()).schoolId
                      ..schoolName = AdminExpenseBean.fromJson(eachExpense.origJson()).schoolName
                      ..status = AdminExpenseBean.fromJson(eachExpense.origJson()).status
                      ..transactionId = AdminExpenseBean.fromJson(eachExpense.origJson()).transactionId
                      ..transactionTime = AdminExpenseBean.fromJson(eachExpense.origJson()).transactionTime
                      ..receiptId = AdminExpenseBean.fromJson(eachExpense.origJson()).receiptId
                      ..adminExpenseReceiptsList = AdminExpenseBean.fromJson(eachExpense.origJson()).adminExpenseReceiptsList;
                    eachExpense.populateControllers();
                    eachExpense.isEditMode = false;
                  });
                }
              },
              child: const Text("NO"),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget buildEditButtonForExpense(AdminExpenseBean eachExpense) {
    return GestureDetector(
      onTap: () {
        if (eachExpense.isEditMode) {
          _saveChanges(eachExpense);
        } else {
          setState(() {
            eachExpense.isEditMode = !eachExpense.isEditMode;
          });
        }
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 30,
        width: 30,
        borderRadius: 50,
        spread: 2,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Icon(
              eachExpense.isEditMode ? Icons.check : Icons.edit,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDeleteButtonForExpense(AdminExpenseBean eachExpense) {
    return GestureDetector(
      onTap: () {
        setState(() {
          eachExpense.status = "inactive";
        });
        _saveChanges(eachExpense);
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 30,
        width: 30,
        borderRadius: 50,
        spread: 2,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSimpleAutoCompleteTextFieldForExpenseType(AdminExpenseBean eachExpense) {
    return EasyAutocomplete(
      autofocus: true,
      controller: eachExpense.expenseTypeController,
      suggestions: uniqueExpenseTypes.toList(),
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        errorText: eachExpense.errorTextForExpenseType,
        labelText: 'Expense Type',
        hintText: 'Expense Type',
        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      suggestionBuilder: (data) {
        return Container(
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.all(5),
          child: SubstringHighlight(
            text: data,
            term: eachExpense.expenseTypeController.text,
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
      onChanged: (value) {
        setState(() {
          eachExpense.expenseType = value;
        });
      },
    );
  }

  Widget buildVoucherTextField(AdminExpenseBean eachExpense) {
    return TextField(
      controller: eachExpense.receiptIdController,
      keyboardType: TextInputType.number,
      maxLines: null,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'Voucher No.',
        hintText: 'Voucher No.',
      ),
      style: const TextStyle(
        fontSize: 12,
      ),
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) int.parse(text);
            return newValue;
          } catch (e) {
            debugPrintStack();
          }
          return oldValue;
        }),
      ],
      textAlign: TextAlign.left,
      autofocus: true,
      onChanged: (String e) {
        print("1352: $e");
        if (e.trim() == "") {
          setState(() {
            eachExpense.receiptId = null;
          });
        }
        print("1358: $e");
        if (int.tryParse(e) == null) return;
        print("1360: $e");
        setState(() {
          eachExpense.receiptId = int.parse(e);
        });
        print("1364: $e");
      },
    );
  }

  Widget buildCommentsTextField(AdminExpenseBean eachExpense) {
    return TextField(
      controller: eachExpense.commentsController,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'Comments',
        hintText: 'Comments',
      ),
      style: const TextStyle(
        fontSize: 12,
      ),
      autofocus: true,
      onChanged: (String e) {
        setState(() {
          eachExpense.comments = e;
        });
      },
    );
  }

  Widget buildDescriptionTextField(AdminExpenseBean eachExpense) {
    return TextField(
      controller: eachExpense.descriptionController,
      keyboardType: TextInputType.multiline,
      minLines: 2,
      maxLines: null,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'Description',
        hintText: 'Description',
      ),
      style: const TextStyle(
        fontSize: 12,
      ),
      textAlign: (eachExpense.description ?? "").length > 120 ? TextAlign.justify : TextAlign.left,
      autofocus: true,
      onChanged: (String e) {
        setState(() {
          eachExpense.description = e;
        });
      },
    );
  }

  Widget buildExpenseAmountTextField(AdminExpenseBean eachExpense) {
    return TextField(
      controller: eachExpense.amountController,
      keyboardType: TextInputType.number,
      maxLines: 1,
      decoration: InputDecoration(
        errorText: eachExpense.errorTextForAmount,
        errorMaxLines: 3,
        contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
        border: const UnderlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'Amount',
        hintText: 'Amount',
        prefix: Text(
          INR_SYMBOL,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) double.parse(text);
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
      autofocus: true,
      onChanged: (String e) {
        setState(() {
          eachExpense.amount = ((double.tryParse(e) ?? 0) * 100).round();
        });
      },
    );
  }
}
