import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/analytics/data/providers/analytics_providers.dart';

/// A 2-column grid of 6 KPI summary cards derived from [practiceKpiProvider].
class KpiGridWidget extends ConsumerWidget {
  const KpiGridWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpi = ref.watch(practiceKpiProvider);

    final items = <_KpiItem>[
      _KpiItem(
        icon: Icons.currency_rupee_rounded,
        label: 'Total Revenue',
        value: _formatInr(kpi.totalRevenue),
        badge: kpi.revenueGrowthLabel,
        badgePositive: kpi.revenueGrowthPercent >= 0,
        color: AppColors.primary,
      ),
      _KpiItem(
        icon: Icons.people_alt_rounded,
        label: 'Active / Total Clients',
        value: '${kpi.activeClients} / ${kpi.totalClients}',
        badge: '+${kpi.newClientsThisMonth} this month',
        badgePositive: true,
        color: AppColors.secondary,
      ),
      _KpiItem(
        icon: Icons.person_outline_rounded,
        label: 'Avg Revenue / Client',
        value: _formatInr(kpi.avgRevenuePerClient),
        badge: null,
        badgePositive: true,
        color: AppColors.primaryVariant,
      ),
      _KpiItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Collection Efficiency',
        value: '${kpi.collectionEfficiency.toStringAsFixed(1)}%',
        badge: kpi.collectionEfficiency >= 85 ? 'On track' : 'Below target',
        badgePositive: kpi.collectionEfficiency >= 85,
        color: AppColors.secondary,
      ),
      _KpiItem(
        icon: Icons.description_rounded,
        label: 'ITR Filing Completion',
        value: '${kpi.itrFilingCompletion.toStringAsFixed(1)}%',
        badge: null,
        badgePositive: kpi.itrFilingCompletion >= 75,
        color: AppColors.accent,
      ),
      _KpiItem(
        icon: Icons.receipt_long_rounded,
        label: 'GST Compliance Rate',
        value: '${kpi.gstComplianceRate.toStringAsFixed(1)}%',
        badge: null,
        badgePositive: kpi.gstComplianceRate >= 70,
        color: AppColors.success,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) => _KpiCard(item: items[index]),
    );
  }

  static String _formatInr(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    }
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}

class _KpiItem {
  const _KpiItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.badge,
    required this.badgePositive,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? badge;
  final bool badgePositive;
  final Color color;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.item});

  final _KpiItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor =
        item.badgePositive ? AppColors.success : AppColors.error;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item.color.withAlpha(22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 18, color: item.color),
                ),
                if (item.badge != null) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.badge!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
