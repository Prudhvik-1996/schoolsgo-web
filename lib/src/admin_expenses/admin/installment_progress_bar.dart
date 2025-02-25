import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class InstallmentProgressBar extends StatelessWidget {
  final List<int> installments;
  final int amountPaid;
  final int totalAmount;

  const InstallmentProgressBar({
    Key? key,
    required this.installments,
    required this.amountPaid,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        double paidWidth = (amountPaid / totalAmount) * totalWidth;

        List<Widget> sections = [];
        double accumulatedWidth = 0;

        for (int i = 0; i < installments.length; i++) {
          double sectionWidth = (installments[i] / totalAmount) * totalWidth;
          accumulatedWidth += sectionWidth;

          sections.add(
            Positioned(
              left: accumulatedWidth,
              child: Container(
                width: 2,
                height: 10,
                color: Colors.white,
              ),
            ),
          );
        }

        return Column(
          children: [
            Stack(
              children: [
                Container(
                  width: totalWidth,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Container(
                  width: paidWidth,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                ...sections,
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Paid: $INR_SYMBOL ${doubleToStringAsFixed(amountPaid / 100, decimalPlaces: 2)}/-",
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                if (totalAmount - amountPaid != 0)
                  Expanded(
                    child: Text(
                      "Due: $INR_SYMBOL ${doubleToStringAsFixed((totalAmount - amountPaid) / 100, decimalPlaces: 2)}/-",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.end,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
