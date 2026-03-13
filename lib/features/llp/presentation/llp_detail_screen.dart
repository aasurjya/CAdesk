import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/llp/data/providers/llp_providers.dart';
import 'package:ca_app/features/llp/domain/models/llp_penalty_computation.dart';

/// LLP detail screen: LLPIN, partners, annual filings due, penalty computation.
class LlpDetailScreen extends ConsumerWidget {
  const LlpDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final llp = ref.watch(selectedLlpProvider);
    final f11Penalty = ref.watch(llpForm11PenaltyProvider);
    final f8Penalty = ref.watch(llpForm8PenaltyProvider);
    final totalPenalty = ref.watch(llpTotalPenaltyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          llp.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _LlpInfoCard(llp: llp),
            const SizedBox(height: 16),
            _PartnersCard(llp: llp),
            const SizedBox(height: 16),
            _FilingsCard(llp: llp),
            const SizedBox(height: 16),
            if (f11Penalty != null || f8Penalty != null)
              _PenaltyCard(
                f11Penalty: f11Penalty,
                f8Penalty: f8Penalty,
                totalPenaltyPaise: totalPenalty,
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LLP info card
// ---------------------------------------------------------------------------

class _LlpInfoCard extends StatelessWidget {
  const _LlpInfoCard({required this.llp});

  final LlpEntity llp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LLP Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'LLPIN', value: llp.llpin),
            _DetailRow(label: 'Registered Office', value: llp.registeredOffice),
            _DetailRow(
              label: 'Total Contribution',
              value: _formatPaise(llp.totalContributionPaise),
            ),
            _DetailRow(
              label: 'Financial Year',
              value:
                  'FY ${llp.financialYear - 1}-'
                  '${llp.financialYear.toString().substring(2)}',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Partners card
// ---------------------------------------------------------------------------

class _PartnersCard extends StatelessWidget {
  const _PartnersCard({required this.llp});

  final LlpEntity llp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partners (${llp.numberOfPartners})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            ...llp.partners.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: p.isDesignatedPartner
                            ? AppColors.primary.withAlpha(18)
                            : AppColors.neutral100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          p.name.isNotEmpty ? p.name[0] : '?',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: p.isDesignatedPartner
                                ? AppColors.primary
                                : AppColors.neutral600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                p.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral900,
                                ),
                              ),
                              if (p.isDesignatedPartner) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(18),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'DP',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            'DPIN: ${p.dpin}  |  '
                            '${_formatPaise(p.contributionPaise)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                        ],
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
// Filings card
// ---------------------------------------------------------------------------

class _FilingsCard extends StatelessWidget {
  const _FilingsCard({required this.llp});

  final LlpEntity llp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Annual Filings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            _FilingRow(
              form: 'Form 8 (Solvency)',
              status: llp.form8Status,
              deadline: 'Oct 30, ${llp.financialYear}',
              filedDate: llp.form8FiledDate,
            ),
            _FilingRow(
              form: 'Form 11 (Annual Return)',
              status: llp.form11Status,
              deadline: 'May 30, ${llp.financialYear}',
              filedDate: llp.form11FiledDate,
            ),
            _FilingRow(
              form: 'ITR-5',
              status: llp.itr5Status,
              deadline: 'Jul 31, ${llp.financialYear}',
              filedDate: null,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilingRow extends StatelessWidget {
  const _FilingRow({
    required this.form,
    required this.status,
    required this.deadline,
    this.filedDate,
  });

  final String form;
  final LlpFilingStatus status;
  final String deadline;
  final DateTime? filedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      LlpFilingStatus.filed => AppColors.success,
      LlpFilingStatus.overdue => AppColors.error,
      LlpFilingStatus.pending => AppColors.warning,
      LlpFilingStatus.notDue => AppColors.neutral400,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            status == LlpFilingStatus.filed
                ? Icons.check_circle_rounded
                : status == LlpFilingStatus.overdue
                ? Icons.error_rounded
                : Icons.schedule_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  form,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  filedDate != null
                      ? 'Filed: ${_formatDate(filedDate!)}  |  Due: $deadline'
                      : 'Due: $deadline',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
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
// Penalty card
// ---------------------------------------------------------------------------

class _PenaltyCard extends StatelessWidget {
  const _PenaltyCard({
    this.f11Penalty,
    this.f8Penalty,
    required this.totalPenaltyPaise,
  });

  final LlpPenaltyComputation? f11Penalty;
  final LlpPenaltyComputation? f8Penalty;
  final int totalPenaltyPaise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.error.withAlpha(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Penalty Calculator',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Penalty: \u20B9100/day per form beyond due date',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 10),
            if (f11Penalty != null) _PenaltyRow(penalty: f11Penalty!),
            if (f8Penalty != null) _PenaltyRow(penalty: f8Penalty!),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Penalty',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  _formatPaise(totalPenaltyPaise),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
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

class _PenaltyRow extends StatelessWidget {
  const _PenaltyRow({required this.penalty});

  final LlpPenaltyComputation penalty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${penalty.formType} (${penalty.daysBeyondDue} days late)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          Text(
            _formatPaise(penalty.penaltyPaise),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPaise(int paise) {
  final rupees = paise ~/ 100;
  if (rupees >= 10000000) {
    return '\u20B9${(rupees / 10000000).toStringAsFixed(2)} Cr';
  }
  if (rupees >= 100000) {
    return '\u20B9${(rupees / 100000).toStringAsFixed(2)} L';
  }
  if (rupees >= 1000) {
    return '\u20B9${(rupees / 1000).toStringAsFixed(1)}K';
  }
  return '\u20B9$rupees';
}

String _formatDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}
