import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

final _dateFmt = DateFormat('dd MMM yyyy');
final _currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9');

// ---------------------------------------------------------------------------
// Mock data models
// ---------------------------------------------------------------------------

enum FemaTransactionType {
  inwardRemittance('Inward Remittance', Icons.call_received_rounded),
  outwardRemittance('Outward Remittance', Icons.call_made_rounded);

  const FemaTransactionType(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum FemaFormType {
  fcGpr('FC-GPR'),
  fcTrs('FC-TRS'),
  odiPartI('ODI Part I'),
  odiPartII('ODI Part II');

  const FemaFormType(this.label);
  final String label;
}

class _MockTransaction {
  const _MockTransaction({
    required this.id,
    required this.entityName,
    required this.type,
    required this.amount,
    required this.currency,
    required this.inrEquivalent,
    required this.purpose,
    required this.formType,
    required this.transactionDate,
    required this.rbiRefNumber,
    required this.adBankName,
    required this.complianceChecklist,
  });

  final String id;
  final String entityName;
  final FemaTransactionType type;
  final double amount;
  final String currency;
  final double inrEquivalent;
  final String purpose;
  final FemaFormType formType;
  final DateTime transactionDate;
  final String rbiRefNumber;
  final String adBankName;
  final Map<String, bool> complianceChecklist;
}

final _mockTransaction = _MockTransaction(
  id: 'fema-txn-001',
  entityName: 'TechGlobal India Pvt Ltd',
  type: FemaTransactionType.inwardRemittance,
  amount: 2500000,
  currency: 'USD',
  inrEquivalent: 208750000,
  purpose: 'FDI — Equity Capital Infusion (Series B)',
  formType: FemaFormType.fcGpr,
  transactionDate: DateTime(2026, 2, 15),
  rbiRefNumber: 'RBI/2026/FDI/00487',
  adBankName: 'HDFC Bank — Fort Branch',
  complianceChecklist: {
    'KYC of foreign investor completed': true,
    'FIRC received from AD Bank': true,
    'FC-GPR filed within 30 days': true,
    'Valuation report obtained (Rule 11UA)': true,
    'Board resolution for allotment': true,
    'Sectoral cap compliance verified': false,
    'Annual return on foreign liabilities (FLA)': false,
  },
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// FEMA FDI/ODI transaction detail view.
///
/// Route: `/fema/transaction/:transactionId`
class FemaTransactionScreen extends ConsumerWidget {
  const FemaTransactionScreen({required this.transactionId, super.key});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In production, fetch from provider using transactionId
    final txn = _mockTransaction;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'FEMA — ${txn.entityName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TransactionHeaderCard(txn: txn),
            const SizedBox(height: 16),
            _TransactionInfoCard(txn: txn),
            const SizedBox(height: 16),
            _FormTrackingCard(txn: txn),
            const SizedBox(height: 16),
            _RbiComplianceChecklist(checklist: txn.complianceChecklist),
            const SizedBox(height: 24),
            _ActionButtons(txn: txn),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction header
// ---------------------------------------------------------------------------

class _TransactionHeaderCard extends StatelessWidget {
  const _TransactionHeaderCard({required this.txn});

  final _MockTransaction txn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInward = txn.type == FemaTransactionType.inwardRemittance;

    return Card(
      elevation: 0,
      color: (isInward ? AppColors.success : AppColors.warning).withValues(
        alpha: 0.05,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: (isInward ? AppColors.success : AppColors.warning).withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  txn.type.icon,
                  color: isInward ? AppColors.success : AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    txn.type.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    txn.formType.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${txn.currency} ${_currencyFmt.format(txn.amount).replaceAll('\u20B9', '').trim()}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'INR equivalent: ${_currencyFmt.format(txn.inrEquivalent)}',
              style: const TextStyle(fontSize: 13, color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction info
// ---------------------------------------------------------------------------

class _TransactionInfoCard extends StatelessWidget {
  const _TransactionInfoCard({required this.txn});

  final _MockTransaction txn;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(label: 'Entity', value: txn.entityName),
            _DetailRow(label: 'Purpose', value: txn.purpose),
            _DetailRow(label: 'Currency', value: txn.currency),
            _DetailRow(
              label: 'Date',
              value: _dateFmt.format(txn.transactionDate),
            ),
            _DetailRow(label: 'RBI Ref', value: txn.rbiRefNumber),
            _DetailRow(label: 'AD Bank', value: txn.adBankName),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form tracking card
// ---------------------------------------------------------------------------

class _FormTrackingCard extends StatelessWidget {
  const _FormTrackingCard({required this.txn});

  final _MockTransaction txn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form Tracking — ${txn.formType.label}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _FormStep(
              title: 'Form prepared',
              isComplete: true,
              isActive: false,
            ),
            _FormStep(
              title: 'CA certification',
              isComplete: true,
              isActive: false,
            ),
            _FormStep(
              title: 'Filed with RBI/AD Bank',
              isComplete: false,
              isActive: true,
            ),
            _FormStep(
              title: 'Acknowledgement received',
              isComplete: false,
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormStep extends StatelessWidget {
  const _FormStep({
    required this.title,
    required this.isComplete,
    required this.isActive,
  });

  final String title;
  final bool isComplete;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isComplete
        ? AppColors.success
        : isActive
        ? AppColors.primary
        : AppColors.neutral300;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isComplete || isActive ? color : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: isComplete
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isComplete || isActive
                  ? AppColors.neutral900
                  : AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RBI compliance checklist
// ---------------------------------------------------------------------------

class _RbiComplianceChecklist extends StatelessWidget {
  const _RbiComplianceChecklist({required this.checklist});

  final Map<String, bool> checklist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = checklist.values.where((v) => v).length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.checklist_rounded,
                  size: 18,
                  color: AppColors.primaryVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'RBI Compliance Checklist',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$completedCount / ${checklist.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...checklist.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      entry.value
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: entry.value
                          ? AppColors.success
                          : AppColors.neutral300,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 13,
                          color: entry.value
                              ? AppColors.neutral900
                              : AppColors.neutral400,
                          decoration: entry.value
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
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
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.txn});

  final _MockTransaction txn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _showSnack(context, 'Filing initiated'),
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: Text('File ${txn.formType.label}'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _showSnack(context, 'PDF report generated'),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
          label: const Text('Export Report'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryVariant,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared detail row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
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
