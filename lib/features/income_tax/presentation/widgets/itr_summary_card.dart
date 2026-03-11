import 'package:flutter/material.dart';

/// A compact summary card that displays a metric count with label,
/// icon, and optional trend indicator.
class ItrSummaryCard extends StatelessWidget {
  const ItrSummaryCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    this.trend,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;

  /// Positive = up trend, negative = down trend, null = no indicator.
  final int? trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const Spacer(),
                  if (trend != null) _TrendBadge(trend: trend!),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend});

  final int trend;

  @override
  Widget build(BuildContext context) {
    final isUp = trend > 0;
    final color = isUp ? const Color(0xFF1A7A3A) : const Color(0xFFC62828);
    final icon = isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          '${isUp ? '+' : ''}$trend',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
