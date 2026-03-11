import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/analytics/data/providers/analytics_providers.dart';

/// Horizontal stacked bar showing client health distribution.
///
/// Segments: Healthy (green) | Attention (amber) | Critical (red).
class ClientHealthChartWidget extends ConsumerWidget {
  const ClientHealthChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dist = ref.watch(clientHealthDistributionProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HealthBar(distribution: dist),
            const SizedBox(height: 12),
            _SegmentLabels(distribution: dist),
            const SizedBox(height: 12),
            _AttentionSummary(distribution: dist),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stacked horizontal bar
// ---------------------------------------------------------------------------

class _HealthBar extends StatelessWidget {
  const _HealthBar({required this.distribution});

  final ClientHealthDistribution distribution;

  @override
  Widget build(BuildContext context) {
    final dist = distribution;
    if (dist.total == 0) {
      return const SizedBox(height: 24);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            if (dist.healthy > 0)
              Expanded(
                flex: dist.healthy,
                child: _BarSegment(
                  color: AppColors.success,
                  label: '${dist.healthyPercent.toStringAsFixed(0)}%',
                ),
              ),
            if (dist.attention > 0)
              Expanded(
                flex: dist.attention,
                child: _BarSegment(
                  color: AppColors.warning,
                  label: '${dist.attentionPercent.toStringAsFixed(0)}%',
                ),
              ),
            if (dist.critical > 0)
              Expanded(
                flex: dist.critical,
                child: _BarSegment(
                  color: AppColors.error,
                  label: '${dist.criticalPercent.toStringAsFixed(0)}%',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BarSegment extends StatelessWidget {
  const _BarSegment({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.surface,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Segment count labels below the bar
// ---------------------------------------------------------------------------

class _SegmentLabels extends StatelessWidget {
  const _SegmentLabels({required this.distribution});

  final ClientHealthDistribution distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _LegendDot(color: AppColors.success),
        const SizedBox(width: 4),
        Text(
          'Healthy (${distribution.healthy})',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        _LegendDot(color: AppColors.warning),
        const SizedBox(width: 4),
        Text(
          'Attention (${distribution.attention})',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        _LegendDot(color: AppColors.error),
        const SizedBox(width: 4),
        Text(
          'Critical (${distribution.critical})',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary line
// ---------------------------------------------------------------------------

class _AttentionSummary extends StatelessWidget {
  const _AttentionSummary({required this.distribution});

  final ClientHealthDistribution distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsAttention = distribution.attention + distribution.critical;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$needsAttention client${needsAttention == 1 ? '' : 's'} '
              'need${needsAttention == 1 ? 's' : ''} attention or are critical',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
