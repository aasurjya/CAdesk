import 'package:flutter/material.dart';

import 'package:ca_app/features/litigation/domain/models/notice_triage_result.dart';

/// Card displaying risk level, recommended action, key issues, and timeline advice.
class TriageResultCard extends StatelessWidget {
  const TriageResultCard({required this.result, super.key});

  final NoticeTriageResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (riskLabel, riskBg, riskFg) = _riskStyle(result.riskLevel);
    final actionLabel = _actionLabel(result.recommendedAction);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    riskLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: riskFg,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recommended: $actionLabel',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Key issues
            Text(
              'Key Issues',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            ...result.keyIssues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.w700)),
                    Expanded(
                      child: Text(issue, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Suggested grounds
            Text(
              'Suggested Grounds',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            ...result.suggestedGrounds.map(
              (ground) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.w700)),
                    Expanded(
                      child: Text(ground, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Timeline advice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.timelineAdvice,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (String, Color, Color) _riskStyle(RiskLevel level) {
    return switch (level) {
      RiskLevel.critical => ('CRITICAL RISK', const Color(0xFFFFEBEE), const Color(0xFFB71C1C)),
      RiskLevel.high => ('HIGH RISK', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
      RiskLevel.medium => ('MEDIUM RISK', const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
      RiskLevel.low => ('LOW RISK', const Color(0xFFE8F5E9), const Color(0xFF1B5E20)),
    };
  }

  static String _actionLabel(RecommendedAction action) {
    return switch (action) {
      RecommendedAction.respond => 'Draft Response',
      RecommendedAction.appeal => 'File Appeal',
      RecommendedAction.pay => 'Pay Demand',
      RecommendedAction.ignore => 'No Action Needed',
      RecommendedAction.seekStay => 'Seek Stay of Demand',
    };
  }
}
