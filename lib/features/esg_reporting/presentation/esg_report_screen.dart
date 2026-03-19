import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _EsgMetric {
  const _EsgMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.target,
    required this.trend,
  });

  final String name;
  final String value;
  final String unit;
  final String target;
  final String trend; // 'up', 'down', 'stable'

  double get completionPct {
    final v = double.tryParse(value) ?? 0;
    final t = double.tryParse(target) ?? 1;
    return (v / t).clamp(0, 1);
  }
}

class _EsgCategory {
  const _EsgCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.score,
    required this.metrics,
  });

  final String name;
  final IconData icon;
  final Color color;
  final int score;
  final List<_EsgMetric> metrics;
}

class _EsgReport {
  const _EsgReport({
    required this.id,
    required this.companyName,
    required this.reportingPeriod,
    required this.overallScore,
    required this.categories,
  });

  final String id;
  final String companyName;
  final String reportingPeriod;
  final int overallScore;
  final List<_EsgCategory> categories;
}

const _mockReport = _EsgReport(
  id: 'ESG-2026-003',
  companyName: 'Meridian Steel Industries Ltd',
  reportingPeriod: 'FY 2025-26',
  overallScore: 72,
  categories: [
    _EsgCategory(
      name: 'Environmental',
      icon: Icons.eco_rounded,
      color: Color(0xFF2E7D32),
      score: 68,
      metrics: [
        _EsgMetric(
          name: 'Carbon Emissions',
          value: '1250',
          unit: 'tCO2e',
          target: '1000',
          trend: 'down',
        ),
        _EsgMetric(
          name: 'Energy Consumption',
          value: '4500',
          unit: 'MWh',
          target: '4000',
          trend: 'down',
        ),
        _EsgMetric(
          name: 'Water Usage',
          value: '12000',
          unit: 'KL',
          target: '15000',
          trend: 'stable',
        ),
        _EsgMetric(
          name: 'Waste Recycled',
          value: '78',
          unit: '%',
          target: '85',
          trend: 'up',
        ),
      ],
    ),
    _EsgCategory(
      name: 'Social',
      icon: Icons.groups_rounded,
      color: Color(0xFF1565C0),
      score: 75,
      metrics: [
        _EsgMetric(
          name: 'Gender Diversity',
          value: '32',
          unit: '%',
          target: '40',
          trend: 'up',
        ),
        _EsgMetric(
          name: 'Safety Incidents',
          value: '3',
          unit: 'count',
          target: '0',
          trend: 'down',
        ),
        _EsgMetric(
          name: 'Training Hours',
          value: '24',
          unit: 'hrs/emp',
          target: '30',
          trend: 'up',
        ),
        _EsgMetric(
          name: 'CSR Spend',
          value: '2.1',
          unit: '% PAT',
          target: '2.0',
          trend: 'stable',
        ),
      ],
    ),
    _EsgCategory(
      name: 'Governance',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF6A1B9A),
      score: 82,
      metrics: [
        _EsgMetric(
          name: 'Board Independence',
          value: '60',
          unit: '%',
          target: '50',
          trend: 'stable',
        ),
        _EsgMetric(
          name: 'Ethics Violations',
          value: '0',
          unit: 'count',
          target: '0',
          trend: 'stable',
        ),
        _EsgMetric(
          name: 'Audit Committee Meets',
          value: '6',
          unit: 'count',
          target: '4',
          trend: 'stable',
        ),
        _EsgMetric(
          name: 'Policy Compliance',
          value: '95',
          unit: '%',
          target: '100',
          trend: 'up',
        ),
      ],
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// ESG report compilation with environment, social, governance metrics.
///
/// Route: `/esg-reporting/report/:reportId`
class EsgReportScreen extends ConsumerWidget {
  const EsgReportScreen({required this.reportId, super.key});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const r = _mockReport;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('ESG Report'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('BRSR'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const _ReportHeader(report: r),
          const SizedBox(height: 12),

          // Score cards
          Row(
            children: r.categories.map((cat) {
              return SummaryCard(
                label: cat.name,
                value: '${cat.score}/100',
                icon: cat.icon,
                color: cat.color,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Category sections
          ...r.categories.expand(
            (cat) => [
              _CategorySection(category: cat),
              const SizedBox(height: 20),
            ],
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.report});

  final _EsgReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = report.overallScore >= 80
        ? AppColors.success
        : report.overallScore >= 60
        ? AppColors.warning
        : AppColors.error;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.companyName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(
                    label: report.reportingPeriod,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
            // Overall score circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scoreColor, width: 3),
              ),
              child: Center(
                child: Text(
                  '${report.overallScore}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category});

  final _EsgCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: category.name,
          icon: category.icon,
          trailing: Text(
            '${category.score}/100',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: category.color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...category.metrics.map(
          (m) => _MetricRow(metric: m, categoryColor: category.color),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric, required this.categoryColor});

  final _EsgMetric metric;
  final Color categoryColor;

  IconData get _trendIcon => switch (metric.trend) {
    'up' => Icons.trending_up_rounded,
    'down' => Icons.trending_down_rounded,
    _ => Icons.trending_flat_rounded,
  };

  Color get _trendColor => switch (metric.trend) {
    'up' => AppColors.success,
    'down' => AppColors.error,
    _ => AppColors.neutral400,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    metric.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                Icon(_trendIcon, size: 16, color: _trendColor),
                const SizedBox(width: 6),
                Text(
                  '${metric.value} ${metric.unit}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: metric.completionPct,
                      minHeight: 5,
                      backgroundColor: AppColors.neutral200,
                      valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Target: ${metric.target} ${metric.unit}',
                  style: const TextStyle(
                    fontSize: 10,
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
}
