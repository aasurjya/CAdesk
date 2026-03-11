import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/msme/data/providers/msme_providers.dart';
import 'package:ca_app/features/msme/domain/models/msme_vendor.dart';

/// Opens the 43B(h) Payment Tracker bottom sheet for the given [clientId].
void showPaymentTrackerSheet(
  BuildContext context,
  String clientId,
  String clientName,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        PaymentTrackerSheet(clientId: clientId, clientName: clientName),
  );
}

/// Draggable bottom sheet showing per-client MSME supplier payment tracking
/// with full Section 43B(h) impact analysis and Form MSME-1 info.
class PaymentTrackerSheet extends ConsumerWidget {
  const PaymentTrackerSheet({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  final String clientId;
  final String clientName;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  static final _compactFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(msmePaymentsByClientProvider(clientId));
    final theme = Theme.of(context);

    final overduePayments = payments
        .where((p) => p.isOverdue && !p.isPaid)
        .toList();
    final totalOutstanding = payments
        .where((p) => !p.isPaid)
        .fold(0.0, (s, p) => s + p.invoiceAmount);
    final totalDisallowable = payments.fold(
      0.0,
      (s, p) => s + p.disallowableAmount,
    );
    final totalInterest = payments.fold(0.0, (s, p) => s + p.interestLiability);
    final taxImpact = totalDisallowable * 0.30;
    final reportableCount = payments
        .where((p) => p.isOverdue && !p.isPaid)
        .length;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _DragHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    _SheetHeader(
                      clientName: clientName,
                      financialYear: payments.isNotEmpty
                          ? payments.first.financialYear
                          : '2025-26',
                    ),
                    const SizedBox(height: 12),
                    if (overduePayments.isNotEmpty) ...[
                      _OverdueBanner(
                        count: overduePayments.length,
                        disallowable: totalDisallowable,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _ImpactCard(
                      totalOutstanding: totalOutstanding,
                      totalDisallowable: totalDisallowable,
                      totalInterest: totalInterest,
                      taxImpact: taxImpact,
                      compactFormat: _compactFormat,
                      currencyFormat: _currencyFormat,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Supplier Payments',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...payments.map(
                      (p) => _PaymentRow(
                        payment: p,
                        currencyFormat: _currencyFormat,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormMsme1Section(
                      reportableCount: reportableCount,
                      clientName: clientName,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header widgets
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.clientName, required this.financialYear});

  final String clientName;
  final String financialYear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          clientName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              'FY $financialYear',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryVariant.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '43B(h) Payment Tracker',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Alert banner
// ---------------------------------------------------------------------------

class _OverdueBanner extends StatelessWidget {
  const _OverdueBanner({required this.count, required this.disallowable});

  final int count;
  final double disallowable;

  static final _fmt = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count payment${count == 1 ? '' : 's'} overdue — '
              '${_fmt.format(disallowable)} disallowable under Sec 43B(h)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 43B(h) impact card
// ---------------------------------------------------------------------------

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({
    required this.totalOutstanding,
    required this.totalDisallowable,
    required this.totalInterest,
    required this.taxImpact,
    required this.compactFormat,
    required this.currencyFormat,
  });

  final double totalOutstanding;
  final double totalDisallowable;
  final double totalInterest;
  final double taxImpact;
  final NumberFormat compactFormat;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Section 43B(h) Impact',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _ImpactRow(
            label: 'Total MSME payables outstanding',
            value: compactFormat.format(totalOutstanding),
            valueColor: AppColors.neutral900,
          ),
          const SizedBox(height: 6),
          _ImpactRow(
            label: 'Disallowable at year-end',
            value: compactFormat.format(totalDisallowable),
            valueColor: AppColors.error,
            isBold: true,
          ),
          const SizedBox(height: 6),
          _ImpactRow(
            label: 'Interest liability (3\u00d7 bank rate)',
            value: currencyFormat.format(totalInterest),
            valueColor: AppColors.warning,
          ),
          const SizedBox(height: 6),
          _ImpactRow(
            label: 'Tax impact @ 30%',
            value: currencyFormat.format(taxImpact),
            valueColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  const _ImpactRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: valueColor,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Payment row
// ---------------------------------------------------------------------------

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, required this.currencyFormat});

  final MsmeSupplierPayment payment;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysColor = _daysColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    payment.supplierName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _CategoryBadge(category: payment.supplierCategory),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              payment.supplierUdyam,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _InfoPill(label: 'Invoice: ${payment.invoiceDate}'),
                const SizedBox(width: 8),
                _InfoPill(label: 'Terms: ${payment.agreedTermDays} days'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  currencyFormat.format(payment.invoiceAmount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                _DaysPill(
                  days: payment.daysOutstanding,
                  color: daysColor,
                  isPaid: payment.isPaid,
                ),
              ],
            ),
            if (payment.isOverdue && !payment.isPaid) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Overdue',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Disallowable: ${currencyFormat.format(payment.disallowableAmount)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
            if (payment.interestLiability > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Interest: ${currencyFormat.format(payment.interestLiability)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
            if (payment.isPaid && payment.paidDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Paid on ${payment.paidDate}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color get _daysColor {
    if (payment.isPaid) {
      return payment.isOverdue ? AppColors.warning : AppColors.success;
    }
    if (payment.daysOutstanding > 45) {
      return AppColors.error;
    }
    if (payment.daysOutstanding >= 30) {
      return AppColors.warning;
    }
    return AppColors.success;
  }
}

class _DaysPill extends StatelessWidget {
  const _DaysPill({
    required this.days,
    required this.color,
    required this.isPaid,
  });

  final int days;
  final Color color;
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$days days${isPaid ? ' (paid)' : ''}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final MsmeClassification category;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color get _color {
    switch (category) {
      case MsmeClassification.micro:
        return AppColors.secondary;
      case MsmeClassification.small:
        return AppColors.primaryVariant;
      case MsmeClassification.medium:
        return AppColors.primary;
    }
  }
}

// ---------------------------------------------------------------------------
// Form MSME-1 section
// ---------------------------------------------------------------------------

class _FormMsme1Section extends StatelessWidget {
  const _FormMsme1Section({
    required this.reportableCount,
    required this.clientName,
  });

  final int reportableCount;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueDate = MsmePaymentCalculator.formMsme1DueDate(isMarchHalf: true);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: AppColors.accent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Form MSME-1',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _FormMsme1Row(label: 'Next due date', value: dueDate),
          const SizedBox(height: 4),
          _FormMsme1Row(
            label: 'Payments to be reported',
            value: '$reportableCount outstanding',
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () {
                _showGenerateSnackbar(context, clientName);
              },
              icon: const Icon(Icons.file_download_outlined, size: 16),
              label: const Text('Generate Form MSME-1'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                foregroundColor: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateSnackbar(BuildContext context, String clientName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form MSME-1 generated for $clientName'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _FormMsme1Row extends StatelessWidget {
  const _FormMsme1Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
