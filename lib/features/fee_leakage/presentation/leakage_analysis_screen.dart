import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _EngagementFee {
  const _EngagementFee({
    required this.client,
    required this.engagement,
    required this.agreedFee,
    required this.hoursLogged,
    required this.hoursBilled,
    required this.effectiveRate,
    required this.targetRate,
  });

  final String client;
  final String engagement;
  final double agreedFee;
  final double hoursLogged;
  final double hoursBilled;
  final double effectiveRate;
  final double targetRate;

  double get leakage => (hoursLogged - hoursBilled) * targetRate;
  double get billedPct => hoursLogged > 0 ? hoursBilled / hoursLogged : 1;
}

class _StaffUnbilled {
  const _StaffUnbilled({
    required this.name,
    required this.role,
    required this.unbilledHours,
    required this.tasks,
  });

  final String name;
  final String role;
  final double unbilledHours;
  final List<String> tasks;
}

class _RecoverySuggestion {
  const _RecoverySuggestion({
    required this.title,
    required this.potentialRecovery,
    required this.priority,
    required this.description,
  });

  final String title;
  final double potentialRecovery;
  final String priority;
  final String description;
}

const _mockEngagements = [
  _EngagementFee(
    client: 'Sunrise Tech Pvt Ltd',
    engagement: 'Statutory Audit',
    agreedFee: 450000,
    hoursLogged: 320,
    hoursBilled: 240,
    effectiveRate: 1406,
    targetRate: 1800,
  ),
  _EngagementFee(
    client: 'Greenfield Exports',
    engagement: 'GST Annual Return',
    agreedFee: 75000,
    hoursLogged: 65,
    hoursBilled: 50,
    effectiveRate: 1154,
    targetRate: 1500,
  ),
  _EngagementFee(
    client: 'Meridian Steel',
    engagement: 'Transfer Pricing',
    agreedFee: 200000,
    hoursLogged: 140,
    hoursBilled: 130,
    effectiveRate: 1429,
    targetRate: 1600,
  ),
];

const _mockStaff = [
  _StaffUnbilled(
    name: 'Ankit Sharma',
    role: 'Senior Associate',
    unbilledHours: 42,
    tasks: ['Client meetings', 'Internal review', 'Data requests'],
  ),
  _StaffUnbilled(
    name: 'Priya Mehta',
    role: 'Manager',
    unbilledHours: 28,
    tasks: ['Quality review', 'Training juniors'],
  ),
  _StaffUnbilled(
    name: 'Rahul Jain',
    role: 'Associate',
    unbilledHours: 55,
    tasks: ['Rework on deliverables', 'Scope creep tasks', 'Admin work'],
  ),
];

const _mockSuggestions = [
  _RecoverySuggestion(
    title: 'Bill scope-creep hours on Sunrise Tech audit',
    potentialRecovery: 144000,
    priority: 'High',
    description:
        '80 hours of additional work on internal controls not in original scope. '
        'Recommend supplemental billing at agreed rate.',
  ),
  _RecoverySuggestion(
    title: 'Renegotiate Greenfield GST engagement fee',
    potentialRecovery: 22500,
    priority: 'Medium',
    description:
        'Complexity increased due to multi-state registration. Current fee '
        'does not cover actual effort.',
  ),
  _RecoverySuggestion(
    title: 'Automate data collection for TP documentation',
    potentialRecovery: 16000,
    priority: 'Low',
    description:
        'Estimated 10 hours per engagement saved through automated data templates.',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Fee leakage analysis with engagement-wise breakdown, staff unbilled hours,
/// and recovery suggestions.
///
/// Route: `/fee-leakage/analysis`
class LeakageAnalysisScreen extends ConsumerWidget {
  const LeakageAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalLeakage = _mockEngagements.fold<double>(
      0,
      (sum, e) => sum + e.leakage,
    );

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Leakage Analysis'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary
          Row(
            children: [
              SummaryCard(
                label: 'Total Leakage',
                value: _formatCurrency(totalLeakage),
                icon: Icons.money_off_rounded,
                color: AppColors.error,
              ),
              SummaryCard(
                label: 'Engagements',
                value: '${_mockEngagements.length}',
                icon: Icons.work_outline_rounded,
                color: AppColors.primary,
              ),
              SummaryCard(
                label: 'Unbilled Hrs',
                value:
                    '${_mockStaff.fold<double>(0, (s, e) => s + e.unbilledHours).toInt()}',
                icon: Icons.schedule_rounded,
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Engagement-wise fee analysis
          const SectionHeader(
            title: 'Engagement Fee Analysis',
            icon: Icons.analytics_rounded,
          ),
          const SizedBox(height: 8),
          ..._mockEngagements.map((e) => _EngagementFeeCard(engagement: e)),
          const SizedBox(height: 20),

          // Unbilled hours by staff
          const SectionHeader(
            title: 'Unbilled Hours by Staff',
            icon: Icons.people_outline_rounded,
          ),
          const SizedBox(height: 8),
          ..._mockStaff.map((s) => _StaffUnbilledCard(staff: s)),
          const SizedBox(height: 20),

          // Recovery suggestions
          const SectionHeader(
            title: 'Recovery Suggestions',
            icon: Icons.lightbulb_outline_rounded,
          ),
          const SizedBox(height: 8),
          ..._mockSuggestions.map((s) => _SuggestionCard(suggestion: s)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static String _formatCurrency(double amount) {
    if (amount.abs() >= 100000) {
      return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount.abs() >= 1000) {
      return '\u20B9${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\u20B9${amount.toStringAsFixed(0)}';
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _EngagementFeeCard extends StatelessWidget {
  const _EngagementFeeCard({required this.engagement});

  final _EngagementFee engagement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final billedPct = engagement.billedPct;
    final barColor = billedPct >= 0.9
        ? AppColors.success
        : billedPct >= 0.7
        ? AppColors.warning
        : AppColors.error;

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
                    engagement.client,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                StatusBadge(
                  label: engagement.engagement,
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Metric(
                  label: 'Logged',
                  value: '${engagement.hoursLogged.toInt()}h',
                ),
                _Metric(
                  label: 'Billed',
                  value: '${engagement.hoursBilled.toInt()}h',
                ),
                _Metric(
                  label: 'Eff. Rate',
                  value: '\u20B9${engagement.effectiveRate.toInt()}',
                ),
                _Metric(
                  label: 'Leakage',
                  value:
                      '\u20B9${(engagement.leakage / 1000).toStringAsFixed(1)}K',
                  valueColor: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: billedPct,
                minHeight: 6,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: valueColor ?? AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
        ),
      ],
    );
  }
}

class _StaffUnbilledCard extends StatelessWidget {
  const _StaffUnbilledCard({required this.staff});

  final _StaffUnbilled staff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withAlpha(20),
              child: Text(
                staff.name.split(' ').map((w) => w[0]).take(2).join(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${staff.role} \u2022 ${staff.tasks.join(", ")}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: '${staff.unbilledHours.toInt()}h',
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion});

  final _RecoverySuggestion suggestion;

  Color get _priorityColor => switch (suggestion.priority) {
    'High' => AppColors.error,
    'Medium' => AppColors.warning,
    _ => AppColors.neutral400,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                StatusBadge(label: suggestion.priority, color: _priorityColor),
                const Spacer(),
                Text(
                  '+\u20B9${(suggestion.potentialRecovery / 1000).toStringAsFixed(0)}K',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              suggestion.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              suggestion.description,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }
}
