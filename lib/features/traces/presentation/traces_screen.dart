import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/traces/data/providers/traces_providers.dart';
import 'package:ca_app/features/traces/domain/models/challan_status.dart';
import 'package:ca_app/features/traces/domain/models/tds_default.dart';
import 'package:ca_app/features/traces/presentation/widgets/traces_request_tile.dart';

/// TRACES portal dashboard: Form 16 queue, challan verification, TDS defaults,
/// justification report request.
class TracesScreen extends ConsumerWidget {
  const TracesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(tracesRequestsProvider);
    final challans = ref.watch(challanStatusesProvider);
    final defaults = ref.watch(tdsDefaultsProvider);
    final unresolvedDemand = ref.watch(totalUnresolvedDemandProvider);
    final unverifiedCount = ref.watch(unverifiedChallanCountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRACES Portal',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'TDS certificates, challans & defaults',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => context.push('/traces/download'),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Bulk Download'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
        ],
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
            _SummaryBanner(
              totalRequests: requests.length,
              unverifiedChallans: unverifiedCount,
              unresolvedDemandPaise: unresolvedDemand,
            ),
            const SizedBox(height: 16),
            const _SectionHeader(
              title: 'Recent Requests',
              icon: Icons.history_rounded,
            ),
            const SizedBox(height: 10),
            ...requests.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TracesRequestTile(request: r),
              ),
            ),
            const SizedBox(height: 16),
            const _SectionHeader(
              title: 'Challan Verification',
              icon: Icons.verified_rounded,
            ),
            const SizedBox(height: 10),
            _ChallanList(challans: challans),
            const SizedBox(height: 16),
            const _SectionHeader(
              title: 'TDS Defaults',
              icon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 10),
            _DefaultsList(defaults: defaults),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary banner
// ---------------------------------------------------------------------------

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.totalRequests,
    required this.unverifiedChallans,
    required this.unresolvedDemandPaise,
  });

  final int totalRequests;
  final int unverifiedChallans;
  final int unresolvedDemandPaise;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _StatItem(label: 'Requests', value: '$totalRequests'),
          _StatItem(
            label: 'Unverified',
            value: '$unverifiedChallans',
            color: unverifiedChallans > 0 ? AppColors.warning : null,
          ),
          _StatItem(
            label: 'Demand',
            value: _formatPaise(unresolvedDemandPaise),
            color: unresolvedDemandPaise > 0 ? AppColors.error : null,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Challan list
// ---------------------------------------------------------------------------

class _ChallanList extends StatelessWidget {
  const _ChallanList({required this.challans});

  final List<ChallanStatus> challans;

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
            ...challans.map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      c.isVerified
                          ? Icons.check_circle_rounded
                          : Icons.pending_rounded,
                      color: c.isVerified
                          ? AppColors.success
                          : AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BSR: ${c.bsrCode}  |  Sec ${c.section}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                          ),
                          Text(
                            'Serial: ${c.challanSerial}  |  '
                            '${_formatPaise(c.amountPaise)}',
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
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TDS defaults list
// ---------------------------------------------------------------------------

class _DefaultsList extends StatelessWidget {
  const _DefaultsList({required this.defaults});

  final List<TdsDefault> defaults;

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
            ...defaults.map((d) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      d.isResolved
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: d.isResolved ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TAN: ${d.tan}  |  Sec ${d.section}  |  '
                            'Q${d.quarter} FY ${d.financialYear}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                          ),
                          Text(
                            'Demand: ${_formatPaise(d.totalDemandPaise)}  |  '
                            '${d.isResolved ? "Resolved" : "Pending"}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: d.isResolved
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
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
// Helpers
// ---------------------------------------------------------------------------

String _formatPaise(int paise) {
  final rupees = paise ~/ 100;
  if (rupees >= 100000) {
    return '\u20B9${(rupees / 100000).toStringAsFixed(2)} L';
  }
  if (rupees >= 1000) {
    return '\u20B9${(rupees / 1000).toStringAsFixed(1)}K';
  }
  return '\u20B9$rupees';
}
