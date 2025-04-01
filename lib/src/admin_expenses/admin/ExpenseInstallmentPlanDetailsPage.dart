import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/admin_expenses.dart';

class ExpenseInstallmentPlanDetailPage extends StatelessWidget {
  final ExpenseInstallmentPlanBean installmentPlan;

  const ExpenseInstallmentPlanDetailPage({super.key, required this.installmentPlan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Installment Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan Name: ${installmentPlan.planTitle ?? '-'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Amount: ₹${installmentPlan.amount ?? '-'}'),
          ],
        ),
      ),
    );
  }
}