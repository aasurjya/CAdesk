import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/income_tax/data/providers/income_tax_providers.dart';
import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';

/// Bottom sheet showing full filing details, tax regime comparison,
/// advance tax schedule, and filing timeline for a single [ItrClient].
class FilingDetailSheet extends ConsumerWidget {
  const FilingDetailSheet({super.key, required this.client});

  final ItrClient client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final comparison = TaxComputationService.compare(client.totalIncome);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    _HeaderSection(client: client),
                    const SizedBox(height: 20),
                    _TaxComparisonSection(comparison: comparison),
                    const SizedBox(height: 20),
                    _AdvanceTaxSection(taxPayable: client.taxPayable),
                    const SizedBox(height: 20),
                    _FilingTimelineSection(status: client.filingStatus),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              _ActionBar(client: client),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header section
// ---------------------------------------------------------------------------

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.client});

  final ItrClient client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = client.filingStatus;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary,
          child: Text(
            client.initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PAN: ${client.pan}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Chip(
                    label: client.itrType.label,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: status.label,
                    color: status.color,
                    icon: status.icon,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tax comparison section
// ---------------------------------------------------------------------------

class _TaxComparisonSection extends StatelessWidget {
  const _TaxComparisonSection({required this.comparison});

  final TaxRegimeComparison comparison;

  static final _currencyFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final oldTaxable = (comparison.grossIncome - comparison.oldRegimeDeductions)
        .clamp(0.0, double.infinity);
    final newTaxable = (comparison.grossIncome - comparison.newRegimeDeductions)
        .clamp(0.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tax Computation',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RegimeCard(
                regime: 'Old Regime',
                grossIncome: comparison.grossIncome,
                deductions: comparison.oldRegimeDeductions,
                taxableIncome: oldTaxable,
                taxBeforeCess: comparison.oldRegimeTax / 1.04,
                totalTax: comparison.oldRegimeTax,
                isRecommended: comparison.recommendedRegime == 'Old',
                currencyFmt: _currencyFmt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RegimeCard(
                regime: 'New Regime',
                grossIncome: comparison.grossIncome,
                deductions: comparison.newRegimeDeductions,
                taxableIncome: newTaxable,
                taxBeforeCess: comparison.newRegimeTax / 1.04,
                totalTax: comparison.newRegimeTax,
                isRecommended: comparison.recommendedRegime == 'New',
                currencyFmt: _currencyFmt,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.success.withAlpha(77)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.savings_rounded,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Save ${_currencyFmt.format(comparison.savings)} by switching '
                  'to ${comparison.recommendedRegime} Regime',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegimeCard extends StatelessWidget {
  const _RegimeCard({
    required this.regime,
    required this.grossIncome,
    required this.deductions,
    required this.taxableIncome,
    required this.taxBeforeCess,
    required this.totalTax,
    required this.isRecommended,
    required this.currencyFmt,
  });

  final String regime;
  final double grossIncome;
  final double deductions;
  final double taxableIncome;
  final double taxBeforeCess;
  final double totalTax;
  final bool isRecommended;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cess = totalTax - taxBeforeCess;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRecommended
            ? AppColors.success.withAlpha(10)
            : AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended
              ? AppColors.success.withAlpha(128)
              : AppColors.neutral200,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  regime,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isRecommended
                        ? AppColors.success
                        : AppColors.neutral600,
                  ),
                ),
              ),
              if (isRecommended)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Gross Income',
            value: currencyFmt.format(grossIncome),
            bold: false,
          ),
          _Row(
            label: 'Deductions',
            value: '− ${currencyFmt.format(deductions)}',
            valueColor: AppColors.success,
            bold: false,
          ),
          _Row(
            label: 'Taxable',
            value: currencyFmt.format(taxableIncome),
            bold: true,
          ),
          const Divider(height: 12),
          _Row(
            label: 'Tax',
            value: currencyFmt.format(taxBeforeCess),
            bold: false,
          ),
          _Row(
            label: 'Cess (4%)',
            value: currencyFmt.format(cess),
            bold: false,
          ),
          _Row(
            label: 'Total',
            value: currencyFmt.format(totalTax),
            bold: true,
            valueColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.bold,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: valueColor ?? AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Advance tax schedule section
// ---------------------------------------------------------------------------

class _AdvanceTaxSection extends StatelessWidget {
  const _AdvanceTaxSection({required this.taxPayable});

  final double taxPayable;

  static final _currencyFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static const _installments = [
    _Installment(label: '15 Jun', cumulativePct: 0.15),
    _Installment(label: '15 Sep', cumulativePct: 0.45),
    _Installment(label: '15 Dec', cumulativePct: 0.75),
    _Installment(label: '15 Mar', cumulativePct: 1.00),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advance Tax Schedule',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            children: List.generate(_installments.length, (index) {
              final inst = _installments[index];
              final amount = taxPayable * inst.cumulativePct;
              final installmentAmt = index == 0
                  ? amount
                  : amount -
                        (taxPayable * _installments[index - 1].cumulativePct);
              final dueDate = inst.dueDate(today.year);
              final status = _installmentStatus(dueDate, today);
              return _InstallmentRow(
                label: inst.label,
                amount: installmentAmt,
                cumulative: amount,
                status: status,
                currencyFmt: _currencyFmt,
                isLast: index == _installments.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }

  String _installmentStatus(DateTime dueDate, DateTime today) {
    if (today.isAfter(dueDate)) {
      return 'overdue';
    }
    final diff = dueDate.difference(today).inDays;
    if (diff <= 30) {
      return 'due';
    }
    return 'upcoming';
  }
}

class _Installment {
  const _Installment({required this.label, required this.cumulativePct});

  final String label;
  final double cumulativePct;

  DateTime dueDate(int year) {
    final parts = label.split(' ');
    final day = int.parse(parts[0]);
    const months = {'Jun': 6, 'Sep': 9, 'Dec': 12, 'Mar': 3};
    final month = months[parts[1]]!;
    final effectiveYear = month == 3 ? year + 1 : year;
    return DateTime(effectiveYear, month, day);
  }
}

class _InstallmentRow extends StatelessWidget {
  const _InstallmentRow({
    required this.label,
    required this.amount,
    required this.cumulative,
    required this.status,
    required this.currencyFmt,
    required this.isLast,
  });

  final String label;
  final double amount;
  final double cumulative;
  final String status;
  final NumberFormat currencyFmt;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    switch (status) {
      case 'overdue':
        statusColor = AppColors.error;
        statusLabel = 'Overdue';
        statusIcon = Icons.warning_amber_rounded;
      case 'due':
        statusColor = AppColors.warning;
        statusLabel = 'Due Soon';
        statusIcon = Icons.schedule_rounded;
      default:
        statusColor = AppColors.neutral400;
        statusLabel = 'Upcoming';
        statusIcon = Icons.calendar_today_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currencyFmt.format(amount),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  'Cumulative: ${currencyFmt.format(cumulative)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 12, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filing timeline section
// ---------------------------------------------------------------------------

class _FilingTimelineSection extends StatelessWidget {
  const _FilingTimelineSection({required this.status});

  final FilingStatus status;

  static const _steps = [
    FilingStatus.pending,
    FilingStatus.inProgress,
    FilingStatus.filed,
    FilingStatus.verified,
    FilingStatus.processed,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _steps.indexOf(status);
    // If status is defective, treat it as failed after filed step.
    final effectiveIndex = status == FilingStatus.defective ? 2 : currentIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filing Timeline',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            children: List.generate(_steps.length, (index) {
              final step = _steps[index];
              final isDone = index < effectiveIndex;
              final isCurrent = index == effectiveIndex;
              final isLast = index == _steps.length - 1;
              final isDefectiveCurrent =
                  status == FilingStatus.defective && index == 2;

              return _TimelineStep(
                label: step.label,
                isDone: isDone,
                isCurrent: isCurrent,
                isLast: isLast,
                isError: isDefectiveCurrent,
                color: isDefectiveCurrent
                    ? AppColors.error
                    : isCurrent
                    ? step.color
                    : isDone
                    ? AppColors.success
                    : AppColors.neutral300,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
    required this.isError,
    required this.color,
  });

  final String label;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;
  final bool isError;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    if (isError) {
      icon = Icons.error_rounded;
    } else if (isDone) {
      icon = Icons.check_circle_rounded;
    } else if (isCurrent) {
      icon = Icons.radio_button_checked_rounded;
    } else {
      icon = Icons.radio_button_unchecked_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, size: 20, color: color),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isDone
                    ? AppColors.success.withAlpha(128)
                    : AppColors.neutral200,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: EdgeInsets.only(top: 1, bottom: isLast ? 0 : 16),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
              color: isCurrent ? color : AppColors.neutral600,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action bar
// ---------------------------------------------------------------------------

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.client});

  final ItrClient client;

  /// Whether to show the "Check Status on Portal" button.
  /// Shown for filed or verified statuses.
  bool get _shouldShowStatusCheck {
    return client.filingStatus == FilingStatus.filed ||
        client.filingStatus == FilingStatus.verified;
  }

  /// Returns the next filing status and its action label, or null if the
  /// filing is already at the terminal state (processed / defective).
  ({FilingStatus next, String label, IconData icon})? get _nextAction {
    return switch (client.filingStatus) {
      FilingStatus.pending || FilingStatus.inProgress => (
        next: FilingStatus.filed,
        label: 'Mark as Filed',
        icon: Icons.upload_file_rounded,
      ),
      FilingStatus.filed => (
        next: FilingStatus.verified,
        label: 'Mark as Verified',
        icon: Icons.verified_rounded,
      ),
      FilingStatus.verified => (
        next: FilingStatus.processed,
        label: 'Mark as Processed',
        icon: Icons.check_circle_rounded,
      ),
      FilingStatus.processed || FilingStatus.defective => null,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = _nextAction;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          if (action != null)
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _advanceStatus(context, ref, action),
                icon: Icon(action.icon, size: 18),
                label: Text(action.label),
                style: FilledButton.styleFrom(
                  backgroundColor: action.next.color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (action != null) const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _downloadItrV(context),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('ITR-V'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_shouldShowStatusCheck)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _checkStatusOnPortal(context),
                icon: const Icon(Icons.sync_rounded, size: 18),
                label: const Text('Check Status'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: AppColors.secondary,
                ),
              ),
            )
          else
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _sendToClient(context),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Send'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _advanceStatus(
    BuildContext context,
    WidgetRef ref,
    ({FilingStatus next, String label, IconData icon}) action,
  ) {
    final updated = client.copyWith(filingStatus: action.next);
    ref.read(itrClientsProvider.notifier).updateClient(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${client.name} marked as ${action.next.label}'),
        backgroundColor: action.next.color,
      ),
    );
  }

  void _downloadItrV(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading ITR-V acknowledgement...')),
    );
  }

  void _sendToClient(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sending filing details to ${client.email}')),
    );
  }

  void _checkStatusOnPortal(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checking filing status on ITD portal...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
