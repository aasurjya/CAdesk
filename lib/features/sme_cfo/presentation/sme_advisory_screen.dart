import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _HealthIndicator {
  const _HealthIndicator({
    required this.label,
    required this.value,
    required this.status,
    required this.description,
  });
  final String label, value, status, description;
  Color get statusColor => switch (status) {
    'good' => AppColors.success,
    'warning' => AppColors.warning,
    _ => AppColors.error,
  };
}

class _ComplianceScore {
  const _ComplianceScore({
    required this.name,
    required this.score,
    required this.maxScore,
    required this.issues,
  });
  final String name;
  final int score, maxScore;
  final List<String> issues;
  double get pct => maxScore > 0 ? score / maxScore : 0;
}

class _LoanEligibility {
  const _LoanEligibility({
    required this.loanType,
    required this.eligibleAmount,
    required this.interestRange,
    required this.remarks,
  });
  final String loanType, interestRange, remarks;
  final double eligibleAmount;
}

class _TaxSaving {
  const _TaxSaving({
    required this.title,
    required this.section,
    required this.potentialSaving,
    required this.description,
  });
  final String title, section, description;
  final double potentialSaving;
}

class _SmeAdvisory {
  const _SmeAdvisory({
    required this.clientId,
    required this.clientName,
    required this.turnover,
    required this.cashFlowHealth,
    required this.gstScore,
    required this.tdsScore,
    required this.loanEligibility,
    required this.taxSavings,
  });
  final String clientId, clientName, turnover;
  final _HealthIndicator cashFlowHealth;
  final _ComplianceScore gstScore, tdsScore;
  final List<_LoanEligibility> loanEligibility;
  final List<_TaxSaving> taxSavings;
}

const _mockAdvisory = _SmeAdvisory(
  clientId: 'CLI-089',
  clientName: 'Greenfield Exports Pvt Ltd',
  turnover: '4.2 Cr',
  cashFlowHealth: _HealthIndicator(
    label: 'Cash Flow Health',
    value: '72/100',
    status: 'warning',
    description:
        'Cash conversion cycle of 85 days vs industry average 60 days. '
        'Cash reserves cover 2.1 months of operating expenses.',
  ),
  gstScore: _ComplianceScore(
    name: 'GST Compliance',
    score: 85,
    maxScore: 100,
    issues: [
      'GSTR-1 vs GSTR-3B mismatch for Dec 2025 (INR 42,000)',
      'ITC reversal pending under Rule 42 for Q3',
    ],
  ),
  tdsScore: _ComplianceScore(
    name: 'TDS Compliance',
    score: 92,
    maxScore: 100,
    issues: ['TDS on rent u/s 194I short deducted by INR 8,500'],
  ),
  loanEligibility: [
    _LoanEligibility(
      loanType: 'MSME Term Loan',
      eligibleAmount: 5000000,
      interestRange: '9.5% - 11.5%',
      remarks: 'Based on 3-year financials, CIBIL 740+',
    ),
    _LoanEligibility(
      loanType: 'Working Capital (CC/OD)',
      eligibleAmount: 2500000,
      interestRange: '10% - 12%',
      remarks: 'Against receivables and inventory',
    ),
    _LoanEligibility(
      loanType: 'CGTMSE Guarantee Loan',
      eligibleAmount: 2000000,
      interestRange: '8.5% - 10%',
      remarks: 'Collateral-free under CGTMSE scheme',
    ),
  ],
  taxSavings: [
    _TaxSaving(
      title: 'Section 80JJAA - Employment Generation',
      section: '80JJAA',
      potentialSaving: 125000,
      description:
          '12 new employees with salary < INR 25K/month. 30% deduction for 3 years.',
    ),
    _TaxSaving(
      title: 'Presumptive Taxation u/s 44AD',
      section: '44AD',
      potentialSaving: 85000,
      description:
          'Turnover < 3 Cr, digital receipts > 95%. Opt for 6% presumptive income.',
    ),
    _TaxSaving(
      title: 'Depreciation on IT Infrastructure',
      section: '32(1)',
      potentialSaving: 45000,
      description: 'Computers purchased in FY qualify for 40% depreciation.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// SME-specific financial advisory dashboard.
///
/// Route: `/sme-cfo/advisory/:clientId`
class SmeAdvisoryScreen extends ConsumerWidget {
  const SmeAdvisoryScreen({required this.clientId, super.key});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = _mockAdvisory;
    final totalSavings = a.taxSavings.fold<double>(
      0,
      (s, t) => s + t.potentialSaving,
    );

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('SME Advisory'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ClientHeader(advisory: a),
          const SizedBox(height: 12),

          // Summary KPIs
          Row(
            children: [
              SummaryCard(
                label: 'Cash Flow',
                value: a.cashFlowHealth.value,
                icon: Icons.water_drop_rounded,
                color: a.cashFlowHealth.statusColor,
              ),
              SummaryCard(
                label: 'GST Score',
                value: '${a.gstScore.score}%',
                icon: Icons.receipt_long_rounded,
                color: a.gstScore.pct >= 0.9
                    ? AppColors.success
                    : AppColors.warning,
              ),
              SummaryCard(
                label: 'Tax Savings',
                value: '\u20B9${(totalSavings / 1000).toStringAsFixed(0)}K',
                icon: Icons.savings_rounded,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Cash flow health
          const SectionHeader(
            title: 'Cash Flow Health',
            icon: Icons.water_drop_rounded,
          ),
          const SizedBox(height: 8),
          _HealthCard(indicator: a.cashFlowHealth),
          const SizedBox(height: 20),

          // GST compliance
          _ComplianceSection(score: a.gstScore),
          const SizedBox(height: 20),

          // TDS compliance
          _ComplianceSection(score: a.tdsScore),
          const SizedBox(height: 20),

          // Loan eligibility
          const SectionHeader(
            title: 'Loan Eligibility',
            icon: Icons.account_balance_rounded,
          ),
          const SizedBox(height: 8),
          ...a.loanEligibility.map((l) => _LoanCard(loan: l)),
          const SizedBox(height: 20),

          // Tax saving opportunities
          const SectionHeader(
            title: 'Tax Saving Opportunities',
            icon: Icons.savings_rounded,
          ),
          const SizedBox(height: 8),
          ...a.taxSavings.map((t) => _TaxSavingCard(saving: t)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.advisory});

  final _SmeAdvisory advisory;

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
              advisory.clientName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                StatusBadge(label: 'SME', color: AppColors.secondary),
                const SizedBox(width: 8),
                StatusBadge(
                  label: 'Turnover: \u20B9${advisory.turnover}',
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.indicator});

  final _HealthIndicator indicator;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: indicator.statusColor.withAlpha(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(
                  label: indicator.status.toUpperCase(),
                  color: indicator.statusColor,
                ),
                const Spacer(),
                Text(
                  indicator.value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: indicator.statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              indicator.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutral600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplianceSection extends StatelessWidget {
  const _ComplianceSection({required this.score});

  final _ComplianceScore score;

  @override
  Widget build(BuildContext context) {
    final barColor = score.pct >= 0.9
        ? AppColors.success
        : score.pct >= 0.7
        ? AppColors.warning
        : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: score.name,
          icon: Icons.verified_rounded,
          trailing: Text(
            '${score.score}/${score.maxScore}',
            style: TextStyle(fontWeight: FontWeight.bold, color: barColor),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score.pct,
            minHeight: 8,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        if (score.issues.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...score.issues.map((issue) => _IssueRow(text: issue)),
        ],
      ],
    );
  }
}

class _IssueRow extends StatelessWidget {
  const _IssueRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({required this.loan});
  final _LoanEligibility loan;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    loan.loanType,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '\u20B9${(loan.eligibleAmount / 100000).toStringAsFixed(1)}L',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                StatusBadge(
                  label: loan.interestRange,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loan.remarks,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _TaxSavingCard extends StatelessWidget {
  const _TaxSavingCard({required this.saving});
  final _TaxSaving saving;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.success.withAlpha(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(
                  label: 'Sec ${saving.section}',
                  color: AppColors.primary,
                ),
                const Spacer(),
                Text(
                  '\u20B9${(saving.potentialSaving / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              saving.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              saving.description,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }
}
