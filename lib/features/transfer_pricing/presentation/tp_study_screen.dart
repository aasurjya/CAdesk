import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

final _dateFmt = DateFormat('dd MMM yyyy');
final _currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9');

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

enum TpMethod {
  cup('CUP', 'Comparable Uncontrolled Price'),
  rpm('RPM', 'Resale Price Method'),
  cpm('CPM', 'Cost Plus Method'),
  tnmm('TNMM', 'Transactional Net Margin Method'),
  psm('PSM', 'Profit Split Method');

  const TpMethod(this.code, this.fullName);
  final String code;
  final String fullName;
}

class _RelatedPartyTxn {
  const _RelatedPartyTxn({
    required this.partyName,
    required this.nature,
    required this.amount,
    required this.armLengthPrice,
    required this.method,
  });

  final String partyName;
  final String nature;
  final double amount;
  final double armLengthPrice;
  final TpMethod method;
}

class _MockStudy {
  const _MockStudy({
    required this.id,
    required this.entityName,
    required this.assessmentYear,
    required this.primaryMethod,
    required this.totalTransactionValue,
    required this.transactions,
    required this.benchmarkMargin,
    required this.entityMargin,
    required this.form3cebDue,
    required this.form3cebFiled,
    required this.analystName,
  });

  final String id;
  final String entityName;
  final String assessmentYear;
  final TpMethod primaryMethod;
  final double totalTransactionValue;
  final List<_RelatedPartyTxn> transactions;
  final double benchmarkMargin;
  final double entityMargin;
  final DateTime form3cebDue;
  final bool form3cebFiled;
  final String analystName;
}

final _mockStudy = _MockStudy(
  id: 'tp-study-001',
  entityName: 'Global Pharma India Ltd',
  assessmentYear: 'AY 2026-27',
  primaryMethod: TpMethod.tnmm,
  totalTransactionValue: 3250000000,
  transactions: const [
    _RelatedPartyTxn(
      partyName: 'Global Pharma Inc (USA)',
      nature: 'Purchase of raw materials',
      amount: 1800000000,
      armLengthPrice: 1820000000,
      method: TpMethod.tnmm,
    ),
    _RelatedPartyTxn(
      partyName: 'GP Europe GmbH (Germany)',
      nature: 'Management fees paid',
      amount: 450000000,
      armLengthPrice: 420000000,
      method: TpMethod.cup,
    ),
    _RelatedPartyTxn(
      partyName: 'GP Asia Pte Ltd (Singapore)',
      nature: 'Royalty for brand usage',
      amount: 600000000,
      armLengthPrice: 580000000,
      method: TpMethod.cup,
    ),
    _RelatedPartyTxn(
      partyName: 'GP Research Labs (UK)',
      nature: 'Contract R&D services',
      amount: 400000000,
      armLengthPrice: 410000000,
      method: TpMethod.cpm,
    ),
  ],
  benchmarkMargin: 12.5,
  entityMargin: 11.8,
  form3cebDue: DateTime(2026, 11, 30),
  form3cebFiled: false,
  analystName: 'CA Rajesh Mehta',
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Transfer pricing study detail screen.
///
/// Route: `/transfer-pricing/study/:studyId`
class TpStudyScreen extends ConsumerWidget {
  const TpStudyScreen({required this.studyId, super.key});

  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final study = _mockStudy;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'TP Study — ${study.entityName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StudyOverviewCard(study: study),
            const SizedBox(height: 16),
            _BenchmarkCard(study: study),
            const SizedBox(height: 16),
            _RelatedPartyList(transactions: study.transactions),
            const SizedBox(height: 16),
            _Form3cebCard(study: study),
            const SizedBox(height: 24),
            _ActionButtons(study: study),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Study overview
// ---------------------------------------------------------------------------

class _StudyOverviewCard extends StatelessWidget {
  const _StudyOverviewCard({required this.study});

  final _MockStudy study;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    study.entityName,
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
                    study.assessmentYear,
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
            _DetailRow(
              label: 'Primary Method',
              value: study.primaryMethod.fullName,
            ),
            _DetailRow(label: 'Method Code', value: study.primaryMethod.code),
            _DetailRow(
              label: 'Total Value',
              value: _currencyFmt.format(study.totalTransactionValue),
            ),
            _DetailRow(
              label: 'Related Parties',
              value: '${study.transactions.length} transactions',
            ),
            _DetailRow(label: 'Analyst', value: study.analystName),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Benchmarking analysis
// ---------------------------------------------------------------------------

class _BenchmarkCard extends StatelessWidget {
  const _BenchmarkCard({required this.study});

  final _MockStudy study;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWithinRange = study.entityMargin >= study.benchmarkMargin * 0.85;

    return Card(
      elevation: 0,
      color: (isWithinRange ? AppColors.success : AppColors.warning).withValues(
        alpha: 0.05,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (isWithinRange ? AppColors.success : AppColors.warning)
              .withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benchmarking Analysis',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MarginBox(
                    label: 'Benchmark Margin',
                    value: '${study.benchmarkMargin}%',
                    color: AppColors.primaryVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MarginBox(
                    label: 'Entity Margin',
                    value: '${study.entityMargin}%',
                    color: isWithinRange
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isWithinRange
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  size: 18,
                  color: isWithinRange ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isWithinRange
                        ? 'Entity margin is within arm\'s length range'
                        : 'Entity margin below benchmark — adjustment may be required',
                    style: TextStyle(
                      fontSize: 12,
                      color: isWithinRange
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MarginBox extends StatelessWidget {
  const _MarginBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Related party transactions
// ---------------------------------------------------------------------------

class _RelatedPartyList extends StatelessWidget {
  const _RelatedPartyList({required this.transactions});

  final List<_RelatedPartyTxn> transactions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Related Party Transactions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...transactions.map((txn) {
              final diff = txn.armLengthPrice - txn.amount;
              final isOk = diff.abs() / txn.amount < 0.05;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            txn.partyName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            txn.method.code,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      txn.nature,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Txn: ${_currencyFmt.format(txn.amount)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        Icon(
                          isOk
                              ? Icons.check_circle_rounded
                              : Icons.warning_rounded,
                          size: 14,
                          color: isOk ? AppColors.success : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ALP: ${_currencyFmt.format(txn.armLengthPrice)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form 3CEB card
// ---------------------------------------------------------------------------

class _Form3cebCard extends StatelessWidget {
  const _Form3cebCard({required this.study});

  final _MockStudy study;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: study.form3cebFiled
          ? AppColors.success.withValues(alpha: 0.05)
          : AppColors.warning.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (study.form3cebFiled ? AppColors.success : AppColors.warning)
              .withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              study.form3cebFiled
                  ? Icons.check_circle_rounded
                  : Icons.schedule_rounded,
              size: 24,
              color: study.form3cebFiled
                  ? AppColors.success
                  : AppColors.warning,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Form 3CEB',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    study.form3cebFiled
                        ? 'Filed successfully'
                        : 'Due: ${_dateFmt.format(study.form3cebDue)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
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
  const _ActionButtons({required this.study});

  final _MockStudy study;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _showSnack(context, 'TP study report generated'),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
          label: const Text('Generate TP Report'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _showSnack(context, 'Form 3CEB filing initiated'),
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('File Form 3CEB'),
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
            width: 120,
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
