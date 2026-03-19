import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';
import 'package:ca_app/features/practice/presentation/deadline_mock_data.dart';

/// Deadline intelligence dashboard — risk-scored compliance deadline tracking.
///
/// Displays deadline summaries, penalty exposure, and a filterable list
/// of upcoming/overdue deadlines using [DeadlineIntelligenceCard].
class DeadlineDashboardScreen extends ConsumerStatefulWidget {
  const DeadlineDashboardScreen({super.key});

  @override
  ConsumerState<DeadlineDashboardScreen> createState() =>
      _DeadlineDashboardScreenState();
}

class _DeadlineDashboardScreenState
    extends ConsumerState<DeadlineDashboardScreen> {
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'ITR',
    'GST',
    'TDS',
    'ROC',
    'Audit',
    'PF/ESI',
  ];

  List<DeadlineItem> get _filteredDeadlines {
    if (_selectedCategory == 'All') return mockDeadlines;
    return mockDeadlines.where((d) => d.category == _selectedCategory).toList();
  }

  // ---------------------------------------------------------------------------
  // Summary computations
  // ---------------------------------------------------------------------------

  int get _upcomingCount {
    final now = DateTime.now();
    final sevenDays = now.add(const Duration(days: 7));
    return mockDeadlines
        .where((d) => d.dueDate.isAfter(now) && d.dueDate.isBefore(sevenDays))
        .length;
  }

  int get _thisMonthCount {
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return mockDeadlines
        .where((d) => d.dueDate.isAfter(now) && d.dueDate.isBefore(endOfMonth))
        .length;
  }

  int get _overdueCount {
    final now = DateTime.now();
    return mockDeadlines.where((d) => d.dueDate.isBefore(now)).length;
  }

  double get _totalPenaltyExposure {
    final now = DateTime.now();
    return mockDeadlines
        .where((d) => d.dueDate.isBefore(now.add(const Duration(days: 30))))
        .fold(0.0, (sum, d) => sum + (d.penaltyAmount ?? 0));
  }

  String _formatPenalty(double amount) {
    if (amount >= 100000) {
      return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '\u20B9${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\u20B9${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deadlines = _filteredDeadlines
      ..sort((a, b) => a.riskScore.compareTo(b.riskScore) * -1);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deadline Intelligence',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Risk-scored compliance deadlines',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
            // Penalty exposure banner
            _PenaltyExposureBanner(
              totalExposure: _formatPenalty(_totalPenaltyExposure),
            ),
            const SizedBox(height: 16),

            // Summary KPI row
            Row(
              children: [
                _SummaryChip(
                  label: 'Next 7 days',
                  count: _upcomingCount,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _SummaryChip(
                  label: 'This month',
                  count: _thisMonthCount,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                _SummaryChip(
                  label: 'Overdue',
                  count: _overdueCount,
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                      selectedColor: AppColors.primary.withAlpha(30),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutral600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Deadline list
            if (deadlines.isEmpty)
              _EmptyDeadlineState()
            else
              ...deadlines.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DeadlineIntelligenceCard(
                    title: d.title,
                    dueDate: d.dueDate,
                    riskScore: d.riskScore,
                    penaltyAmount: d.penaltyAmount,
                    category: d.category,
                  ),
                );
              }),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Penalty exposure banner
// ---------------------------------------------------------------------------

class _PenaltyExposureBanner extends StatelessWidget {
  const _PenaltyExposureBanner({required this.totalExposure});

  final String totalExposure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withAlpha(15),
            AppColors.warning.withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Penalty Exposure (30 days)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalExposure,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
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
// Summary chip
// ---------------------------------------------------------------------------

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyDeadlineState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 48,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 12),
            Text(
              'No deadlines match this filter',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
