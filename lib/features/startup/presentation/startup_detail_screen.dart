import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/startup/data/providers/startup_providers.dart';
import 'package:ca_app/features/startup/domain/models/angel_tax_computation.dart';
import 'package:ca_app/features/startup/domain/services/section80iac_service.dart';

/// Detail screen for an individual startup showing incorporation date,
/// DPIIT certificate, 80-IAC application status, share premium valuation,
/// and angel tax computation.
class StartupDetailScreen extends ConsumerWidget {
  const StartupDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(selectedStartupProvider);
    final deduction = ref.watch(startup80IACDeductionProvider);
    final angelTax = ref.watch(startupAngelTaxProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          startup.name,
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
            _InfoCard(startup: startup),
            const SizedBox(height: 16),
            _DpiitSection(startup: startup),
            const SizedBox(height: 16),
            _Iac80Section(startup: startup, deductionPaise: deduction),
            const SizedBox(height: 16),
            if (angelTax != null) ...[
              _AngelTaxSection(startup: startup, computation: angelTax),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info card
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.startup});

  final StartupEntity startup;

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
              'Company Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'CIN', value: startup.cin),
            _DetailRow(label: 'PAN', value: startup.pan),
            _DetailRow(
              label: 'Incorporation',
              value: _formatDate(startup.incorporationDate),
            ),
            _DetailRow(
              label: 'Entity Type',
              value: startup.entityType == StartupEntityType.company
                  ? 'Private Limited Company'
                  : startup.entityType == StartupEntityType.llp
                  ? 'Limited Liability Partnership'
                  : 'Partnership Firm',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DPIIT section
// ---------------------------------------------------------------------------

class _DpiitSection extends StatelessWidget {
  const _DpiitSection({required this.startup});

  final StartupEntity startup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRegistered = startup.dpiitStatus == DpiitStatus.registered;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isRegistered ? Icons.verified_rounded : Icons.pending_rounded,
                  color: isRegistered ? AppColors.success : AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'DPIIT Registration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Status',
              value: switch (startup.dpiitStatus) {
                DpiitStatus.registered => 'Registered',
                DpiitStatus.pending => 'Application Pending',
                DpiitStatus.notApplied => 'Not Applied',
              },
            ),
            if (startup.dpiitNumber.isNotEmpty)
              _DetailRow(label: 'DPIIT Number', value: startup.dpiitNumber),
            _DetailRow(
              label: 'Angel Tax Exemption',
              value: isRegistered ? 'Eligible (Sec 56(2)(viib))' : 'N/A',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 80-IAC section
// ---------------------------------------------------------------------------

class _Iac80Section extends StatelessWidget {
  const _Iac80Section({required this.startup, required this.deductionPaise});

  final StartupEntity startup;
  final int deductionPaise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final yearsUsed = startup.financialYears80IACApplied.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Section 80-IAC Tax Exemption',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Application Status',
              value: switch (startup.iac80Status) {
                Iac80Status.approved => 'Approved by DPIIT/CBDT',
                Iac80Status.applied => 'Application Submitted',
                Iac80Status.notEligible => 'Not Eligible',
                Iac80Status.notApplied => 'Not Applied',
              },
            ),
            _DetailRow(label: 'Years Claimed', value: '$yearsUsed of 3 (max)'),
            if (startup.financialYears80IACApplied.isNotEmpty)
              _DetailRow(
                label: 'FYs Applied',
                value: startup.financialYears80IACApplied
                    .map((y) => 'FY ${y - 1}-${y.toString().substring(2)}')
                    .join(', '),
              ),
            _DetailRow(
              label: 'Net Profit (FY 2025-26)',
              value: _formatPaise(startup.netProfitPaise),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deduction (FY 2025-26)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  deductionPaise > 0 ? _formatPaise(deductionPaise) : 'Nil',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: deductionPaise > 0
                        ? AppColors.success
                        : AppColors.neutral400,
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

// ---------------------------------------------------------------------------
// Angel tax section
// ---------------------------------------------------------------------------

class _AngelTaxSection extends StatelessWidget {
  const _AngelTaxSection({required this.startup, required this.computation});

  final StartupEntity startup;
  final AngelTaxComputation computation;

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
            Row(
              children: [
                const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Angel Tax -- Sec 56(2)(viib)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Issue Price / Share',
              value: _formatPaise(computation.issuePricePaise),
            ),
            _DetailRow(
              label: 'FMV / Share',
              value: _formatPaise(computation.fairMarketValuePaise),
            ),
            _DetailRow(
              label: 'Amount Raised',
              value: _formatPaise(computation.amountRaisedPaise),
            ),
            _DetailRow(
              label: 'Excess over FMV',
              value: _formatPaise(computation.excessOverFmvPaise),
            ),
            _DetailRow(
              label: 'DPIIT Exemption',
              value: computation.exemptionApplied ? 'Applied' : 'N/A',
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Angel Tax Payable',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  computation.angelTaxPayablePaise > 0
                      ? _formatPaise(computation.angelTaxPayablePaise)
                      : 'Nil (Exempt)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: computation.angelTaxPayablePaise > 0
                        ? AppColors.error
                        : AppColors.success,
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
