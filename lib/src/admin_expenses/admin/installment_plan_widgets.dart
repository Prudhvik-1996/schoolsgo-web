import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

// Your custom imports
import 'package:schoolsgo_web/src/admin_expenses/admin/installment_progress_bar.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/admin_expenses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

/// Displays a single installment plan in a card-like UI.
/// Contains title, description, amount, progress bar, installments, vouchers.
class InstallmentPlanCard extends StatelessWidget {
  final ExpenseInstallmentPlanBean plan;

  /// If another plan is in edit mode, we won't allow editing this plan.
  final bool isAnotherPlanInEditMode;

  /// Callbacks
  final VoidCallback onEditToggled;
  final Future<void> Function() onChangesSubmitted;
  final ValueChanged<String> onPlanTitleChanged;
  final ValueChanged<String> onPlanDescriptionChanged;
  final ValueChanged<double> onPlanAmountChanged;
  final VoidCallback onAddInstallment;
  final bool canToggleEditMode;

  const InstallmentPlanCard({
    Key? key,
    required this.plan,
    required this.isAnotherPlanInEditMode,
    required this.onEditToggled,
    required this.onChangesSubmitted,
    required this.onPlanTitleChanged,
    required this.onPlanDescriptionChanged,
    required this.onPlanAmountChanged,
    required this.onAddInstallment,
    required this.canToggleEditMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      depth: 40,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(context),
            const SizedBox(height: 8),
            _buildDescriptionAndAmount(context),
            _buildProgressIndicator(),
            const SizedBox(height: 8),
            _buildInstallmentsSection(context),
            const SizedBox(height: 8),
            _buildVouchersSection(context),
          ],
        ),
      ),
    );
  }

  /// Title row with edit button
  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: plan.isEditMode
              ? TextField(
                  controller: plan.titleEditingController,
                  keyboardType: TextInputType.text,
                  minLines: 2,
                  maxLines: null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    border: const UnderlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'Title',
                    hintText: 'Title',
                    errorText: plan.titleErrorText,
                  ),
                  style: const TextStyle(fontSize: 12),
                  autofocus: true,
                  onChanged: onPlanTitleChanged,
                )
              : Text(
                  plan.planTitle ?? " - ",
                  style: const TextStyle(color: Colors.blue, fontSize: 16),
                ),
        ),
        if (canToggleEditMode) const SizedBox(width: 8),
        if (canToggleEditMode) _buildEditButton(context),
      ],
    );
  }

  /// Shows edit button (or check icon).
  /// Disables editing if another plan is already in edit mode.
  Widget _buildEditButton(BuildContext context) {
    // If some other plan is in edit mode, hide the button
    if (isAnotherPlanInEditMode && !plan.isEditMode) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: !plan.isEditMode ? onEditToggled : onChangesSubmitted,
      child: ClayButton(
        color: clayContainerColor(context),
        height: 30,
        width: 30,
        borderRadius: 50,
        spread: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Icon(plan.isEditMode ? Icons.check : Icons.edit),
          ),
        ),
      ),
    );
  }

  /// Description and Amount row
  Widget _buildDescriptionAndAmount(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: plan.isEditMode
              ? TextField(
                  controller: plan.descriptionEditingController,
                  keyboardType: TextInputType.text,
                  minLines: 2,
                  maxLines: null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
                    border: const UnderlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'Description',
                    hintText: 'Description',
                    errorText: plan.descriptionErrorText,
                  ),
                  style: const TextStyle(fontSize: 12),
                  autofocus: true,
                  onChanged: onPlanDescriptionChanged,
                )
              : Text(plan.planDescription ?? " - "),
        ),
        plan.isEditMode
            ? SizedBox(
                width: 100,
                child: buildPlanAmountTextField(),
              )
            : _buildReadModeExpenseAmountWidget(plan),
      ],
    );
  }

  TextField buildPlanAmountTextField() {
    return TextField(
      onTap: () => plan.amountEditingController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: plan.amountEditingController.value.text.length,
      ),
      controller: plan.amountEditingController,
      keyboardType: TextInputType.number,
      maxLines: 1,
      decoration: InputDecoration(
        errorText: plan.amountErrorText,
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
      onChanged: (String val) {
        double newAmount = double.tryParse(val) ?? 0;
        onPlanAmountChanged(newAmount);
      },
    );
  }

  /// Displays the plan amount in read mode
  Widget _buildReadModeExpenseAmountWidget(ExpenseInstallmentPlanBean plan) {
    return Row(
      children: [
        Text(
          "$INR_SYMBOL ${doubleToStringAsFixed((plan.amount ?? 0) / 100, decimalPlaces: 2)}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5),
        const Icon(Icons.arrow_drop_down_outlined, color: Colors.red),
      ],
    );
  }

  /// Displays the green/red progress bar
  Widget _buildProgressIndicator() {
    if ((plan.amount ?? 0) == 0) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InstallmentProgressBar(
        amountPaid: plan.totalPaidAmount,
        totalAmount: plan.amount ?? 0,
        installments: plan.activeInstallments.map((e) => e.amount ?? 0).toList(),
      ),
    );
  }

  /// Installments section
  Widget _buildInstallmentsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        emboss: true,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Installments"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    Expanded(flex: 1, child: Center(child: Text("No."))),
                    Expanded(flex: 3, child: Center(child: Text("Due Date"))),
                    Expanded(flex: 2, child: Center(child: Text("Amount"))),
                    Expanded(flex: 1, child: Center(child: Text("Status"))),
                  ],
                ),
              ),
              InstallmentsTable(plan: plan),
              if (plan.isEditMode) const SizedBox(height: 8),
              if (plan.isEditMode)
                GestureDetector(
                  onTap: onAddInstallment,
                  child: ClayButton(
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    borderRadius: 20,
                    spread: 2,
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const [
                          Icon(Icons.add, color: Colors.green),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("Add New Installment"),
                            ),
                          ),
                        ],
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

  /// Vouchers/Expenses section
  Widget _buildVouchersSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        emboss: true,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Vouchers"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    Expanded(flex: 1, child: Text("No.")),
                    Expanded(flex: 3, child: Text("Date")),
                    Expanded(flex: 2, child: Text("Amount")),
                    Expanded(flex: 1, child: Text("Info")),
                  ],
                ),
              ),
              VouchersTable(plan: plan),
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays the table of installments within a plan
class InstallmentsTable extends StatefulWidget {
  final ExpenseInstallmentPlanBean plan;

  const InstallmentsTable({Key? key, required this.plan}) : super(key: key);

  @override
  State<InstallmentsTable> createState() => _InstallmentsTableState();
}

class _InstallmentsTableState extends State<InstallmentsTable> {
  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    return Column(
      children: plan.activeInstallments.mapIndexed((i, installment) {
        return _buildInstallmentRow(plan, installment, i);
      }).toList(),
    );
  }

  Widget _buildInstallmentRow(
    ExpenseInstallmentPlanBean plan,
    ExpenseInstallmentBean installmentBean,
    int index,
  ) {
    // Determine if this installment is already paid
    int cumulativeAmountForThisInstallment = plan.activeInstallments.take(index + 1).map((e) => e.amount ?? 0).sum;
    bool isCurrentInstallmentPaid = plan.totalPaidAmount >= cumulativeAmountForThisInstallment;

    // Check if due date is in future
    bool isBeforeDueDate = installmentBean.dueDate == null ||
        DateTime.now().isBefore(
          convertYYYYMMDDFormatToDateTime(installmentBean.dueDate!),
        );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("${index + 1}")),
          Expanded(
            flex: 3,
            child: plan.isEditMode
                ? _buildDueDatePicker(installmentBean)
                : Text(
                    installmentBean.dueDate == null
                        ? "-"
                        : convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(installmentBean.dueDate!)),
                  ),
          ),
          Expanded(
            flex: 2,
            child: plan.isEditMode
                ? _buildAmountField(installmentBean)
                : Text(
                    installmentBean.amount == null ? "-" : "$INR_SYMBOL ${doubleToStringAsFixed(installmentBean.amount! / 100, decimalPlaces: 2)}/-",
                  ),
          ),
          Expanded(
            flex: 1,
            child: plan.isEditMode
                ? InkWell(
                    onTap: () => setState(() {
                      installmentBean.status = 'inactive';
                    }),
                    child: const Icon(Icons.delete, color: Colors.red),
                  )
                : isCurrentInstallmentPaid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : isBeforeDueDate
                        ? const Icon(Icons.hourglass_bottom_outlined, color: Colors.blue)
                        : const Icon(Icons.cancel, color: Colors.red),
          ),
        ],
      ),
    );
  }

  /// Date picker for due date in edit mode
  Widget _buildDueDatePicker(ExpenseInstallmentBean installmentBean) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () async {
          HapticFeedback.vibrate();
          DateTime? newDate = await showDatePicker(
            context: context,
            initialDate: installmentBean.dueDate == null ? DateTime.now() : convertYYYYMMDDFormatToDateTime(installmentBean.dueDate),
            firstDate: DateTime.now().subtract(const Duration(days: 364)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            helpText: "Select a due date",
          );
          if (newDate == null) return;
          setState(() {
            installmentBean.dueDate = convertDateTimeToYYYYMMDDFormat(newDate);
          });
        },
        child: ClayButton(
          color: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded),
                  if (installmentBean.dueDate != null) const SizedBox(width: 15),
                  if (installmentBean.dueDate != null)
                    Text(
                      convertDateTimeToDDMMYYYYFormat(
                        convertYYYYMMDDFormatToDateTime(installmentBean.dueDate!),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Amount field in edit mode
  Widget _buildAmountField(ExpenseInstallmentBean installmentBean) {
    return TextField(
      onTap: () => installmentBean.amountEditingController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: installmentBean.amountEditingController.value.text.length,
      ),
      controller: installmentBean.amountEditingController,
      keyboardType: TextInputType.number,
      maxLines: 1,
      decoration: InputDecoration(
        errorText: installmentBean.amountErrorText,
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
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      onChanged: (String val) {
        setState(() {
          installmentBean.amount = ((double.tryParse(val) ?? 0) * 100).round();
        });
      },
    );
  }
}

/// Displays the vouchers/expenses table
class VouchersTable extends StatelessWidget {
  final ExpenseInstallmentPlanBean plan;

  const VouchersTable({
    Key? key,
    required this.plan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // plan.expenseBeans might contain null items, so we filter them out
    List<AdminExpenseBean> expenseBeans = (plan.expenseBeans ?? []).whereNotNull().toList();

    return Column(
      children: expenseBeans.mapIndexed((i, expenseBean) {
        return _buildExpenseRow(expenseBean, i);
      }).toList(),
    );
  }

  Widget _buildExpenseRow(AdminExpenseBean expenseBean, int i) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              "${expenseBean.receiptId ?? "-"}",
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              expenseBean.transactionTime == null
                  ? "-"
                  : convertDateTimeToDDMMYYYYFormat(
                      DateTime.fromMillisecondsSinceEpoch(expenseBean.transactionTime!),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              expenseBean.amount == null ? "-" : "$INR_SYMBOL ${doubleToStringAsFixed(expenseBean.amount! / 100, decimalPlaces: 2)}/-",
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                // TODO: Show more info, if needed
              },
              child: const Icon(Icons.info),
            ),
          ),
        ],
      ),
    );
  }
}
