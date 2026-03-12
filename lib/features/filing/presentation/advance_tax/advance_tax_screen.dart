import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';

class AdvanceTaxScreen extends StatelessWidget {
  const AdvanceTaxScreen({super.key});

  static final _installments = [
    _Installment('Q1', DateTime(2025, 6, 15), 15),
    _Installment('Q2', DateTime(2025, 9, 15), 45),
    _Installment('Q3', DateTime(2025, 12, 15), 75),
    _Installment('Q4', DateTime(2026, 3, 15), 100),
  ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Advance Tax Calendar',
          style: TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FY 2025-26 Installment Schedule',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Advance tax is payable if estimated tax liability '
              'exceeds ₹10,000 in the financial year.',
              style: TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
            const SizedBox(height: 16),
            ..._installments.map((inst) {
              final isPast = DateTime.now().isAfter(inst.dueDate);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: isPast
                        ? AppColors.success
                        : AppColors.warning,
                    child: Text(
                      inst.quarter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(
                    'By ${dateFormat.format(inst.dueDate)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Cumulative: ${inst.cumulativePercent}% of estimated tax',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: isPast
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        )
                      : const Icon(
                          Icons.schedule,
                          color: AppColors.warning,
                          size: 20,
                        ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Card(
              color: AppColors.neutral100,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interest Implications',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _infoRow(
                      'Section 234B',
                      '1% per month if advance tax < 90% of assessed tax',
                    ),
                    _infoRow(
                      'Section 234C',
                      '1% per month for 3 months per quarterly shortfall',
                    ),
                    _infoRow(
                      'Threshold',
                      'Not applicable if tax payable < ${CurrencyUtils.formatINR(10000)}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Installment {
  const _Installment(this.quarter, this.dueDate, this.cumulativePercent);
  final String quarter;
  final DateTime dueDate;
  final int cumulativePercent;
}
