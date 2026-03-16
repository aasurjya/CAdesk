import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/income_tax/data/providers/income_tax_providers.dart';
import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/gst/data/providers/gst_providers.dart';
import 'package:ca_app/features/gst/domain/models/gst_return.dart';
import 'package:ca_app/features/tds/data/providers/tds_providers.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';

/// Computes a list of recent dashboard activities by aggregating data from
/// ITR filings, GST returns, and TDS challans. Each activity carries a
/// navigation route so it can link to the relevant module screen.
final dashboardActivitiesProvider = Provider<List<DashboardActivity>>((ref) {
  final activities = <DashboardActivity>[];

  // ── ITR filings ─────────────────────────────────────────────────────────
  final itrClients = ref.watch(itrClientsProvider);
  for (final client in itrClients) {
    if (client.filingStatus == FilingStatus.filed ||
        client.filingStatus == FilingStatus.verified ||
        client.filingStatus == FilingStatus.processed) {
      activities.add(DashboardActivity(
        title: 'ITR Filed',
        subtitle: '${client.name} — ${client.assessmentYear} ${client.itrType.label}',
        timeAgo: _formatDate(client.filedDate),
        icon: Icons.check_circle_outline,
        route: '/',
        sortDate: client.filedDate ?? DateTime(2025),
      ));
    }
  }

  // ── GST returns ─────────────────────────────────────────────────────────
  final gstReturns = ref.watch(gstReturnsProvider);
  for (final ret in gstReturns) {
    if (ret.status == GstReturnStatus.filed ||
        ret.status == GstReturnStatus.lateFiled) {
      activities.add(DashboardActivity(
        title: 'GST ${ret.returnType.label}',
        subtitle: '${ret.gstin} — ${ret.returnType.label} ${_monthLabel(ret.periodMonth)} ${ret.periodYear}',
        timeAgo: _formatDate(ret.filedDate),
        icon: Icons.receipt_outlined,
        route: '/gst',
        sortDate: ret.filedDate ?? DateTime(2025),
      ));
    }
  }

  // ── TDS returns ─────────────────────────────────────────────────────────
  final tdsReturns = ref.watch(tdsReturnsProvider);
  for (final ret in tdsReturns) {
    if (ret.status == TdsReturnStatus.filed ||
        ret.status == TdsReturnStatus.revised) {
      activities.add(DashboardActivity(
        title: 'TDS ${ret.formType.label}',
        subtitle: '${ret.tan} — ${ret.quarter.label} ${ret.financialYear}',
        timeAgo: _formatDate(ret.filedDate),
        icon: Icons.payments_outlined,
        route: '/tds',
        sortDate: ret.filedDate ?? DateTime(2025),
      ));
    }
  }

  // Sort by most recent first, then take the top 8.
  activities.sort((a, b) => b.sortDate.compareTo(a.sortDate));
  final limited = activities.length > 8 ? activities.sublist(0, 8) : activities;

  return List.unmodifiable(limited);
});

String _formatDate(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return '1 day ago';
  if (diff.inDays < 30) return '${diff.inDays} days ago';
  if (diff.inDays < 365) {
    final months = (diff.inDays / 30).floor();
    return months == 1 ? '1 month ago' : '$months months ago';
  }
  return '${(diff.inDays / 365).floor()}y ago';
}

String _monthLabel(int month) {
  const labels = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return (month >= 1 && month <= 12) ? labels[month] : '';
}

/// A compact activity feed showing recent cross-module actions.
///
/// Data is derived from ITR, GST, and TDS module providers via
/// [dashboardActivitiesProvider] instead of hardcoded values.
class ActivityFeedWidget extends ConsumerWidget {
  const ActivityFeedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(dashboardActivitiesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _ActivityTile(activity: activities[index]);
          },
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final DashboardActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.go(activity.route),
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(activity.icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          activity.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            activity.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
        trailing: Text(
          activity.timeAgo,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ),
    );
  }
}

/// Immutable model representing a single dashboard activity entry.
class DashboardActivity {
  const DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
    required this.route,
    required this.sortDate,
  });

  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;

  /// The GoRouter path to navigate to when tapped.
  final String route;

  /// Used for sorting activities by recency.
  final DateTime sortDate;
}
