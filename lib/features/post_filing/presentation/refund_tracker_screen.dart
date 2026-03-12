import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/post_filing/data/providers/post_filing_providers.dart';
import 'package:ca_app/features/post_filing/domain/models/refund_tracker.dart';
import 'package:ca_app/features/post_filing/presentation/widgets/filing_status_tile.dart';
import 'package:ca_app/features/post_filing/presentation/widgets/status_timeline.dart';

/// Screen showing a refund-only filtered view with summary and
/// per-refund timelines.
class RefundTrackerScreen extends ConsumerWidget {
  const RefundTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refunds = ref.watch(refundTrackerListProvider);
    final summary = ref.watch(refundSummaryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refund Tracker',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Track all pending and received refunds',
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
            // Summary cards
            _RefundSummaryRow(summary: summary),
            const SizedBox(height: 20),

            // Per-refund timelines
            _SectionHeader(
              title: 'Refund Status',
              icon: Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: 10),
            if (refunds.isEmpty)
              _EmptyRefunds()
            else
              ...refunds.map(
                (refund) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RefundTimelineCard(refund: refund),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Summary row
// ---------------------------------------------------------------------------

class _RefundSummaryRow extends StatelessWidget {
  const _RefundSummaryRow({required this.summary});

  final RefundSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RefundSummaryCard(
            label: 'Total Expected',
            value: formatPaise(summary.totalExpected),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RefundSummaryCard(
            label: 'Received',
            value: formatPaise(summary.received),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RefundSummaryCard(
            label: 'Pending',
            value: formatPaise(summary.pending),
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _RefundSummaryCard extends StatelessWidget {
  const _RefundSummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Refund timeline card
// ---------------------------------------------------------------------------

class _RefundTimelineCard extends StatelessWidget {
  const _RefundTimelineCard({required this.refund});

  final RefundTracker refund;

  static final _dateFmt = DateFormat('dd MMM yyyy');

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAN: ${refund.pan}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AY ${refund.assessmentYear}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatPaise(refund.refundAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timeline
            StatusTimeline(steps: _buildRefundSteps(refund)),

            // Bank info
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.account_balance_rounded,
                  size: 16,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 6),
                Text(
                  'Bank: ${refund.refundBankAccount}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TimelineStep> _buildRefundSteps(RefundTracker refund) {
    final statusOrder = [
      RefundTrackerStatus.notInitiated,
      RefundTrackerStatus.initiated,
      RefundTrackerStatus.processing,
      RefundTrackerStatus.issued,
    ];

    final currentIndex = statusOrder.indexOf(refund.status);

    return statusOrder.asMap().entries.map((entry) {
      final index = entry.key;
      final status = entry.value;
      final isCompleted = index < currentIndex;
      final isActive = index == currentIndex;

      String subtitle;
      if (status == RefundTrackerStatus.issued && refund.issuedDate != null) {
        subtitle = _dateFmt.format(refund.issuedDate!);
      } else if (status == RefundTrackerStatus.issued &&
          refund.expectedDate != null) {
        subtitle = 'Expected: ${_dateFmt.format(refund.expectedDate!)}';
      } else if (isCompleted || isActive) {
        subtitle = 'Completed';
      } else {
        subtitle = 'Pending';
      }

      return TimelineStep(
        title: _refundStatusLabel(status),
        subtitle: subtitle,
        isCompleted: isCompleted,
        isActive: isActive,
      );
    }).toList();
  }

  String _refundStatusLabel(RefundTrackerStatus status) {
    switch (status) {
      case RefundTrackerStatus.notInitiated:
        return 'Claimed';
      case RefundTrackerStatus.initiated:
        return 'Initiated';
      case RefundTrackerStatus.processing:
        return 'Processed';
      case RefundTrackerStatus.issued:
        return 'Issued / Credited';
      case RefundTrackerStatus.adjusted:
        return 'Adjusted';
      case RefundTrackerStatus.failed:
        return 'Failed';
    }
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyRefunds extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 12),
            Text(
              'No refunds to track',
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
