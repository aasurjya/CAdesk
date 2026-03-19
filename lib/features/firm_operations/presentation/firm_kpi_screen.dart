import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock KPI data
// ---------------------------------------------------------------------------

class _FirmKpiData {
  const _FirmKpiData({
    required this.revenueMonthly,
    required this.revenueQuarterly,
    required this.revenueAnnual,
    required this.revenueGrowth,
    required this.staffUtilization,
    required this.billingEfficiency,
    required this.collectionRate,
    required this.clientsAcquired,
    required this.clientsChurned,
    required this.activeClients,
    required this.complianceScore,
    required this.avgResponseTime,
    required this.monthlyTrend,
  });

  final double revenueMonthly;
  final double revenueQuarterly;
  final double revenueAnnual;
  final double revenueGrowth;
  final double staffUtilization;
  final double billingEfficiency;
  final double collectionRate;
  final int clientsAcquired;
  final int clientsChurned;
  final int activeClients;
  final int complianceScore;
  final String avgResponseTime;
  final List<_MonthRevenue> monthlyTrend;
}

class _MonthRevenue {
  const _MonthRevenue({required this.month, required this.amount});

  final String month;
  final double amount;
}

const _mockKpi = _FirmKpiData(
  revenueMonthly: 1250000,
  revenueQuarterly: 3650000,
  revenueAnnual: 14500000,
  revenueGrowth: 18.5,
  staffUtilization: 76,
  billingEfficiency: 82,
  collectionRate: 88,
  clientsAcquired: 12,
  clientsChurned: 3,
  activeClients: 187,
  complianceScore: 94,
  avgResponseTime: '4.2 hrs',
  monthlyTrend: [
    _MonthRevenue(month: 'Oct', amount: 980000),
    _MonthRevenue(month: 'Nov', amount: 1100000),
    _MonthRevenue(month: 'Dec', amount: 1320000),
    _MonthRevenue(month: 'Jan', amount: 1050000),
    _MonthRevenue(month: 'Feb', amount: 1180000),
    _MonthRevenue(month: 'Mar', amount: 1250000),
  ],
);

/// Firm-wide KPI dashboard showing revenue metrics, staff utilization,
/// client acquisition/churn, billing efficiency, and compliance health.
class FirmKpiScreen extends ConsumerWidget {
  const FirmKpiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    const kpi = _mockKpi;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firm KPIs',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Key performance indicators at a glance',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Revenue section
          _SectionHeader(title: 'Revenue', icon: Icons.trending_up_rounded),
          const SizedBox(height: 8),
          Row(
            children: [
              _KpiCard(
                label: 'Monthly',
                value: _formatInr(kpi.revenueMonthly),
                icon: Icons.calendar_today_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _KpiCard(
                label: 'Quarterly',
                value: _formatInr(kpi.revenueQuarterly),
                icon: Icons.date_range_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              _KpiCard(
                label: 'Annual',
                value: _formatInr(kpi.revenueAnnual),
                icon: Icons.calendar_month_rounded,
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _GrowthBanner(growth: kpi.revenueGrowth),
          const SizedBox(height: 16),

          // Revenue trend
          _RevenueTrendCard(trend: kpi.monthlyTrend),
          const SizedBox(height: 20),

          // Operational metrics
          _SectionHeader(
            title: 'Operational Metrics',
            icon: Icons.speed_rounded,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _GaugeCard(
                label: 'Staff Utilization',
                value: kpi.staffUtilization,
                color: _utilizationColor(kpi.staffUtilization),
              ),
              const SizedBox(width: 8),
              _GaugeCard(
                label: 'Billing Efficiency',
                value: kpi.billingEfficiency,
                color: _utilizationColor(kpi.billingEfficiency),
              ),
              const SizedBox(width: 8),
              _GaugeCard(
                label: 'Collection Rate',
                value: kpi.collectionRate,
                color: _utilizationColor(kpi.collectionRate),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Client metrics
          _SectionHeader(title: 'Client Portfolio', icon: Icons.people_rounded),
          const SizedBox(height: 8),
          Row(
            children: [
              _KpiCard(
                label: 'Active Clients',
                value: '${kpi.activeClients}',
                icon: Icons.people_outline_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _KpiCard(
                label: 'Acquired',
                value: '+${kpi.clientsAcquired}',
                icon: Icons.person_add_alt_1_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _KpiCard(
                label: 'Churned',
                value: '-${kpi.clientsChurned}',
                icon: Icons.person_remove_rounded,
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Health indicators
          _SectionHeader(
            title: 'Health Indicators',
            icon: Icons.health_and_safety_rounded,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _HealthCard(
                  label: 'Compliance Score',
                  value: '${kpi.complianceScore}%',
                  icon: Icons.verified_rounded,
                  color: kpi.complianceScore >= 90
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HealthCard(
                  label: 'Avg Response Time',
                  value: kpi.avgResponseTime,
                  icon: Icons.timer_rounded,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
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
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// KPI card
// ---------------------------------------------------------------------------

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neutral200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Growth banner
// ---------------------------------------------------------------------------

class _GrowthBanner extends StatelessWidget {
  const _GrowthBanner({required this.growth});

  final double growth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = growth >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${isPositive ? '+' : ''}${growth.toStringAsFixed(1)}% YoY growth',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Revenue trend card (simplified bar chart)
// ---------------------------------------------------------------------------

class _RevenueTrendCard extends StatelessWidget {
  const _RevenueTrendCard({required this.trend});

  final List<_MonthRevenue> trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxAmount = trend.fold<double>(
      0,
      (max, r) => r.amount > max ? r.amount : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Revenue Trend',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: trend
                    .map(
                      (m) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _formatInr(m.amount),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: maxAmount > 0
                                    ? (m.amount / maxAmount) * 80
                                    : 0,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(180),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.month,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.neutral400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gauge card
// ---------------------------------------------------------------------------

class _GaugeCard extends StatelessWidget {
  const _GaugeCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neutral200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: value / 100,
                      strokeWidth: 5,
                      backgroundColor: AppColors.neutral100,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                    Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Health card
// ---------------------------------------------------------------------------

class _HealthCard extends StatelessWidget {
  const _HealthCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
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
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatInr(double amount) {
  if (amount >= 10000000) {
    return '\u20B9${(amount / 10000000).toStringAsFixed(1)}Cr';
  }
  if (amount >= 100000) {
    return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
  }
  if (amount >= 1000) {
    return '\u20B9${(amount / 1000).toStringAsFixed(1)}K';
  }
  return '\u20B9${amount.toStringAsFixed(0)}';
}

Color _utilizationColor(double pct) {
  if (pct >= 80) return AppColors.success;
  if (pct >= 60) return AppColors.warning;
  return AppColors.error;
}
