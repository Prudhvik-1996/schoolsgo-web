import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/ExpenseInstallmentPlanDetailsPage.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/admin_expenses.dart';

class ExpenseInstallmentsScreen extends StatefulWidget {
  final List<ExpenseInstallmentPlanBean> installmentPlans;
  final List<ExpenseInstallmentBean> installments;

  const ExpenseInstallmentsScreen({
    super.key,
    required this.installmentPlans,
    required this.installments,
  });

  @override
  State<ExpenseInstallmentsScreen> createState() => _ExpenseInstallmentsScreenState();
}

class _ExpenseInstallmentsScreenState extends State<ExpenseInstallmentsScreen> {
  bool sortByDate = true;

  @override
  Widget build(BuildContext context) {
    List<ExpenseInstallmentBean> sortedInstallments = List.from(widget.installments);
    sortedInstallments.sort((a, b) {
      if (sortByDate) {
        return (a.dueDate ?? '').compareTo(b.dueDate ?? '');
      } else {
        return (a.amount ?? 0).compareTo(b.amount ?? 0);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Installment Plans'),
        actions: [
          IconButton(
            icon: Icon(sortByDate ? Icons.date_range : Icons.attach_money),
            onPressed: () {
              setState(() {
                sortByDate = !sortByDate;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sortedInstallments.length,
        itemBuilder: (context, index) {
          final installment = sortedInstallments[index];
          final isOverdue = isInstallmentOverdue(installment);
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.all(4),
                child: Text('Installment - ${(installment.installmentIndex ?? 0) + 1} - ${installment.installmentPlanName ?? "-"}'),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ₹${installment.amount ?? '-'}'),
                  const SizedBox(height: 8),
                  Text('Due Date: ${installment.dueDate ?? 'N/A'}'),
                  if (isOverdue) const SizedBox(height: 8),
                  if (isOverdue)
                    const Text(
                      'Overdue',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpenseInstallmentPlanDetailPage(
                        installmentPlan: widget.installmentPlans.firstWhere((e) => e.planId == installment.planId),
                      ),
                    ),
                  );
                },
                child: const Text('View'),
              ),
            ),
          );
        },
      ),
    );
  }

  bool isInstallmentOverdue(ExpenseInstallmentBean installment) {
    String? dueDate = installment.dueDate;
    if (dueDate == null || dueDate.isEmpty) return false;
    try {
      final dueDateTime = DateFormat('yyyy-MM-dd').parse(dueDate);
      return DateTime.now().isAfter(dueDateTime) && !installment.isPaid;
    } catch (e) {
      return false;
    }
  }
}
