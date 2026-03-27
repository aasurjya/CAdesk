import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/domain/models/advance_tax/advance_tax_schedule.dart';

/// Status of a single advance tax installment.
enum InstallmentStatus {
  paid('Paid', AppColors.success, Icons.check_circle_rounded),
  partiallyPaid('Partial', AppColors.warning, Icons.timelapse_rounded),
  unpaid('Unpaid', AppColors.neutral400, Icons.radio_button_unchecked),
  overdue('Overdue', AppColors.error, Icons.warning_amber_rounded);

  const InstallmentStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

/// Interactive card for a single advance tax quarter installment.
class InstallmentCard extends StatelessWidget {
  const InstallmentCard({
    super.key,
    required this.installment,
    required this.quarterIndex,
    required this.paidAmount,
    required this.challanNumber,
    required this.interestAmount,
    required this.onPaidChanged,
    required this.onChallanChanged,
    required this.onGenerateChallan,
  });

  final AdvanceTaxInstallment installment;
  final int quarterIndex;
  final double paidAmount;
  final String? challanNumber;
  final double interestAmount;
  final ValueChanged<double> onPaidChanged;
  final ValueChanged<String> onChallanChanged;
  final VoidCallback onGenerateChallan;

  InstallmentStatus get _status {
    final now = DateTime.now();
    if (paidAmount >= installment.amountDue && installment.amountDue > 0) {
      return InstallmentStatus.paid;
    }
    if (paidAmount > 0) {
      return InstallmentStatus.partiallyPaid;
    }
    if (now.isAfter(installment.dueDate) && installment.amountDue > 0) {
      return InstallmentStatus.overdue;
    }
    return InstallmentStatus.unpaid;
  }

  double get _shortfall => installment.amountDue - paidAmount;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final status = _status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: status.color.withValues(alpha: 0.12),
                  child: Text(
                    'Q${quarterIndex + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: status.color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        installment.quarterLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Due: ${dateFormat.format(installment.dueDate)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 12, color: status.color),
                      const SizedBox(width: 4),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Cumulative % and amount due
            Row(
              children: [
                _InfoChip(
                  label: 'Cumulative',
                  value: '${installment.cumulativePercent}%',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  label: 'Due',
                  value: CurrencyUtils.formatINRCompact(installment.amountDue),
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  label: _shortfall >= 0 ? 'Shortfall' : 'Excess',
                  value: CurrencyUtils.formatINRCompact(_shortfall.abs()),
                  color: _shortfall > 0 ? AppColors.error : AppColors.success,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Editable fields
            Row(
              children: [
                Expanded(
                  child: _CompactTextField(
                    label: 'Amount Paid',
                    initialValue: paidAmount > 0
                        ? paidAmount.toStringAsFixed(0)
                        : '',
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final parsed = double.tryParse(v) ?? 0;
                      onPaidChanged(parsed);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CompactTextField(
                    label: 'Challan No.',
                    initialValue: challanNumber ?? '',
                    onChanged: onChallanChanged,
                  ),
                ),
              ],
            ),

            // Interest and generate challan
            if (interestAmount > 0 || installment.amountDue > 0) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (interestAmount > 0) ...[
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '234C Interest: ${CurrencyUtils.formatINR(interestAmount)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onGenerateChallan,
                    icon: const Icon(Icons.receipt_long_rounded, size: 14),
                    label: const Text('Generate Challan'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.neutral400),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTextField extends StatelessWidget {
  const _CompactTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
