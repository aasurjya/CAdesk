import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';

/// Immutable data class for a mock invoice.
class _MockInvoice {
  const _MockInvoice({
    required this.number,
    required this.amount,
    required this.date,
    required this.status,
  });

  final String number;
  final double amount;
  final String date;
  final _InvoiceStatus status;
}

enum _InvoiceStatus {
  outstanding('Outstanding', AppColors.warning),
  paid('Paid', AppColors.success);

  const _InvoiceStatus(this.label, this.color);
  final String label;
  final Color color;
}

/// Mock billing data.
const _outstandingAmount = 35000.0;

const _mockInvoices = <_MockInvoice>[
  _MockInvoice(
    number: 'INV-2026-042',
    amount: 35000,
    date: '01 Mar 2026',
    status: _InvoiceStatus.outstanding,
  ),
  _MockInvoice(
    number: 'INV-2025-198',
    amount: 18000,
    date: '15 Dec 2025',
    status: _InvoiceStatus.paid,
  ),
  _MockInvoice(
    number: 'INV-2025-156',
    amount: 25000,
    date: '01 Sep 2025',
    status: _InvoiceStatus.paid,
  ),
  _MockInvoice(
    number: 'INV-2025-102',
    amount: 12000,
    date: '15 Jun 2025',
    status: _InvoiceStatus.paid,
  ),
];

const _totalPaid = 55000.0;

/// Billing tab for the Client 360 screen.
///
/// Shows an outstanding amount card, recent invoices list with status pills,
/// and a payment history summary.
class BillingTab extends StatelessWidget {
  const BillingTab({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _OutstandingCard(amount: _outstandingAmount, theme: theme),
        const SizedBox(height: AppSpacing.md),
        _InvoicesCard(invoices: _mockInvoices, theme: theme),
        const SizedBox(height: AppSpacing.md),
        _PaymentSummaryCard(totalPaid: _totalPaid, theme: theme),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Outstanding amount card
// ---------------------------------------------------------------------------

class _OutstandingCard extends StatelessWidget {
  const _OutstandingCard({required this.amount, required this.theme});

  final double amount;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.warning.withAlpha(12),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              'Outstanding Amount',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '\u20B9${amount.toInt()}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '1 invoice pending',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Invoices list card
// ---------------------------------------------------------------------------

class _InvoicesCard extends StatelessWidget {
  const _InvoicesCard({required this.invoices, required this.theme});

  final List<_MockInvoice> invoices;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Invoices',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...invoices.map((inv) => _InvoiceRow(invoice: inv)),
          ],
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice});

  final _MockInvoice invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.receipt_outlined,
        color: invoice.status.color,
        size: 20,
      ),
      title: Text(
        invoice.number,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        invoice.date,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.neutral400,
        ),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\u20B9${invoice.amount.toInt()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: invoice.status.color.withAlpha(15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              invoice.status.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: invoice.status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment summary card
// ---------------------------------------------------------------------------

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({required this.totalPaid, required this.theme});

  final double totalPaid;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.success.withAlpha(8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Paid (FY 2025-26)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    '\u20B9${totalPaid.toInt()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '3 payments',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
