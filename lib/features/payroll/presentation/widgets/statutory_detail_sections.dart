import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../../domain/models/statutory_return.dart';

/// Status banner for the statutory return detail screen.
class StatutoryStatusBanner extends StatelessWidget {
  const StatutoryStatusBanner({super.key, required this.record});

  final StatutoryReturn record;

  @override
  Widget build(BuildContext context) {
    final isOverdue = record.isOverdue;
    final statusColor = isOverdue ? AppColors.error : record.status.color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(record.status.icon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.status.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: statusColor,
                  ),
                ),
                Text(
                  record.period,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: record.returnType.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              record.returnType.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: record.returnType.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Details card with key-value rows.
class StatutoryDetailsCard extends StatelessWidget {
  const StatutoryDetailsCard({super.key, required this.record});

  final StatutoryReturn record;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _DetailRow('Period', record.period),
            _DetailRow('Return Type', record.returnType.description),
            _DetailRow('Due Date', dateFormat.format(record.dueDate)),
            if (record.filedDate != null)
              _DetailRow('Filed Date', dateFormat.format(record.filedDate!)),
            _DetailRow('Total Employees', record.totalEmployees.toString()),
            _DetailRow(
              'Total Contribution',
              CurrencyUtils.formatINR(record.totalContribution),
            ),
            if (record.challanNumber != null)
              _DetailRow('Challan No.', record.challanNumber!),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contribution summary with per-employee average.
class StatutoryContributionPreview extends StatelessWidget {
  const StatutoryContributionPreview({super.key, required this.record});

  final StatutoryReturn record;

  @override
  Widget build(BuildContext context) {
    final perEmployee = record.totalEmployees > 0
        ? record.totalContribution / record.totalEmployees
        : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people_rounded, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Contribution Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 14),
            Row(
              children: [
                _StatChip(
                  label: 'Employees',
                  value: record.totalEmployees.toString(),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Total',
                  value: CurrencyUtils.formatINRCompact(
                    record.totalContribution,
                  ),
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Avg/Employee',
                  value: CurrencyUtils.formatINRCompact(perEmployee),
                  color: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

/// Challan payment status tile.
class StatutoryChallanStatus extends StatelessWidget {
  const StatutoryChallanStatus({super.key, required this.record});

  final StatutoryReturn record;

  @override
  Widget build(BuildContext context) {
    final hasChallan = record.challanNumber != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: ListTile(
        leading: Icon(
          hasChallan ? Icons.check_circle_rounded : Icons.pending_rounded,
          color: hasChallan ? AppColors.success : AppColors.warning,
        ),
        title: Text(
          hasChallan ? 'Challan Paid' : 'Payment Pending',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          hasChallan
              ? 'Challan: ${record.challanNumber}'
              : 'Generate and pay challan before filing',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: hasChallan
            ? null
            : TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generating challan...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Generate', style: TextStyle(fontSize: 11)),
              ),
      ),
    );
  }
}
