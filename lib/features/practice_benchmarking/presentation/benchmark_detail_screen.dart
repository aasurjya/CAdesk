import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

class _BenchmarkMetric {
  const _BenchmarkMetric({
    required this.name,
    required this.yourValue,
    required this.peerAvg,
    required this.peerTop,
    required this.unit,
    required this.icon,
    required this.higherIsBetter,
  });

  final String name;
  final double yourValue;
  final double peerAvg;
  final double peerTop;
  final String unit;
  final IconData icon;
  final bool higherIsBetter;

  bool get isAboveAverage =>
      higherIsBetter ? yourValue >= peerAvg : yourValue <= peerAvg;
}

class _Recommendation {
  const _Recommendation({
    required this.title,
    required this.description,
    required this.impact,
  });

  final String title;
  final String description;
  final String impact;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockMetrics = <_BenchmarkMetric>[
  const _BenchmarkMetric(
    name: 'Revenue per Partner',
    yourValue: 42,
    peerAvg: 38,
    peerTop: 65,
    unit: 'L/yr',
    icon: Icons.attach_money_rounded,
    higherIsBetter: true,
  ),
  const _BenchmarkMetric(
    name: 'Staff Utilization',
    yourValue: 72,
    peerAvg: 68,
    peerTop: 85,
    unit: '%',
    icon: Icons.people_rounded,
    higherIsBetter: true,
  ),
  const _BenchmarkMetric(
    name: 'Active Clients',
    yourValue: 185,
    peerAvg: 150,
    peerTop: 320,
    unit: '',
    icon: Icons.groups_rounded,
    higherIsBetter: true,
  ),
  const _BenchmarkMetric(
    name: 'Avg Fee per Client',
    yourValue: 22,
    peerAvg: 25,
    peerTop: 40,
    unit: 'K',
    icon: Icons.receipt_long_rounded,
    higherIsBetter: true,
  ),
  const _BenchmarkMetric(
    name: 'Collection Cycle',
    yourValue: 45,
    peerAvg: 38,
    peerTop: 21,
    unit: 'days',
    icon: Icons.schedule_rounded,
    higherIsBetter: false,
  ),
  const _BenchmarkMetric(
    name: 'Client Retention',
    yourValue: 88,
    peerAvg: 82,
    peerTop: 96,
    unit: '%',
    icon: Icons.loyalty_rounded,
    higherIsBetter: true,
  ),
];

final _mockRecommendations = <_Recommendation>[
  const _Recommendation(
    title: 'Increase average fee per client',
    description:
        'Your avg fee (22K) is below the peer average (25K). Consider bundling compliance + advisory services.',
    impact: 'Potential +13% revenue',
  ),
  const _Recommendation(
    title: 'Reduce collection cycle',
    description:
        'At 45 days, your collection cycle exceeds the peer average of 38 days. Implement automated payment reminders.',
    impact: 'Improve cash flow by ~18%',
  ),
  const _Recommendation(
    title: 'Scale client base toward top quartile',
    description:
        'Top firms manage 320+ clients. Invest in automation to handle higher volume without proportional staff increase.',
    impact: 'Path to 250+ clients',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Practice benchmarking detail screen comparing firm metrics against peers.
class BenchmarkDetailScreen extends ConsumerWidget {
  const BenchmarkDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final aboveCount = _mockMetrics.where((m) => m.isAboveAverage).length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Practice Benchmarking',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Firm performance vs peers',
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
          // Summary
          Row(
            children: [
              SummaryCard(
                label: 'Metrics',
                value: '${_mockMetrics.length}',
                icon: Icons.analytics_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              SummaryCard(
                label: 'Above Avg',
                value: '$aboveCount',
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              SummaryCard(
                label: 'Below Avg',
                value: '${_mockMetrics.length - aboveCount}',
                icon: Icons.trending_down_rounded,
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Peer comparison
          const SectionHeader(
            title: 'Peer Comparison',
            icon: Icons.compare_arrows_rounded,
          ),
          const SizedBox(height: 10),
          ..._mockMetrics.map(
            (metric) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BenchmarkCard(metric: metric),
            ),
          ),
          const SizedBox(height: 24),

          // Recommendations
          const SectionHeader(
            title: 'Recommendations',
            icon: Icons.lightbulb_rounded,
          ),
          const SizedBox(height: 10),
          ..._mockRecommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecommendationCard(recommendation: rec),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Benchmark card
// ---------------------------------------------------------------------------

class _BenchmarkCard extends StatelessWidget {
  const _BenchmarkCard({required this.metric});

  final _BenchmarkMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendColor = metric.isAboveAverage
        ? AppColors.success
        : AppColors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: trendColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(metric.icon, color: trendColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    metric.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  metric.isAboveAverage
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: trendColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _CompareValue(
                  label: 'Your Firm',
                  value: '${metric.yourValue.toStringAsFixed(0)}${metric.unit}',
                  color: AppColors.primary,
                  isBold: true,
                ),
                const Spacer(),
                _CompareValue(
                  label: 'Peer Avg',
                  value: '${metric.peerAvg.toStringAsFixed(0)}${metric.unit}',
                  color: AppColors.neutral600,
                  isBold: false,
                ),
                const Spacer(),
                _CompareValue(
                  label: 'Top Quartile',
                  value: '${metric.peerTop.toStringAsFixed(0)}${metric.unit}',
                  color: AppColors.secondary,
                  isBold: false,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar showing position
            _PositionBar(metric: metric),
          ],
        ),
      ),
    );
  }
}

class _CompareValue extends StatelessWidget {
  const _CompareValue({
    required this.label,
    required this.value,
    required this.color,
    required this.isBold,
  });

  final String label;
  final String value;
  final Color color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PositionBar extends StatelessWidget {
  const _PositionBar({required this.metric});

  final _BenchmarkMetric metric;

  @override
  Widget build(BuildContext context) {
    final maxVal = metric.peerTop * 1.2;
    final yourPos = (metric.yourValue / maxVal).clamp(0.0, 1.0);
    final avgPos = (metric.peerAvg / maxVal).clamp(0.0, 1.0);

    return SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              Container(
                width: width,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Peer avg marker
              Positioned(
                left: (avgPos * width) - 1,
                child: Container(
                  width: 2,
                  height: 8,
                  color: AppColors.neutral400,
                ),
              ),
              // Your position
              Container(
                width: yourPos * width,
                decoration: BoxDecoration(
                  color: metric.isAboveAverage
                      ? AppColors.success.withAlpha(120)
                      : AppColors.error.withAlpha(120),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recommendation card
// ---------------------------------------------------------------------------

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final _Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.accent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recommendation.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                recommendation.impact,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
