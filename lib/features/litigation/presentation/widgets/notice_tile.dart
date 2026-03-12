import 'package:flutter/material.dart';

import 'package:ca_app/features/litigation/domain/models/notice_triage_result.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/presentation/widgets/urgency_badge.dart';

/// ListTile showing notice summary: type, AY, demand, urgency, risk level.
class NoticeTile extends StatelessWidget {
  const NoticeTile({
    required this.notice,
    required this.urgency,
    required this.riskLevel,
    required this.onTap,
    super.key,
  });

  final TaxNotice notice;
  final UrgencyLevel urgency;
  final RiskLevel riskLevel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _noticeTypeLabel(notice.noticeType),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  UrgencyBadge(urgency: urgency),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _InfoChip(label: notice.assessmentYear),
                  const SizedBox(width: 6),
                  _InfoChip(label: 's. ${notice.section}'),
                  const SizedBox(width: 6),
                  _RiskDot(level: riskLevel),
                ],
              ),
              if (notice.demandAmount != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Demand: ${_formatPaise(notice.demandAmount!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'PAN: ${notice.pan}  ·  ${notice.issuedBy}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _noticeTypeLabel(NoticeType type) {
    return switch (type) {
      NoticeType.intimation143_1 => 'Intimation u/s 143(1) — CPC Adjustment',
      NoticeType.scrutiny143_2 => 'Scrutiny Notice u/s 143(2)',
      NoticeType.assessment143_3 => 'Assessment Order u/s 143(3)',
      NoticeType.reopening148 => 'Reopening Notice u/s 148',
      NoticeType.penalty156 => 'Demand/Penalty Notice u/s 156',
      NoticeType.showCause => 'Show-Cause Notice',
      NoticeType.highPitchAssessment => 'High-Pitched Assessment',
      NoticeType.searchSeizure => 'Search & Seizure u/s 132',
    };
  }

  /// Converts paise to INR and formats as ₹X,XX,XXX.
  static String _formatPaise(int paise) {
    final rupees = paise ~/ 100;
    return '₹${_formatIndian(rupees)}';
  }

  static String _formatIndian(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '${buf.toString()},$last3';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RiskDot extends StatelessWidget {
  const _RiskDot({required this.level});
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      RiskLevel.critical => const Color(0xFFB71C1C),
      RiskLevel.high => const Color(0xFFE65100),
      RiskLevel.medium => const Color(0xFFF57F17),
      RiskLevel.low => const Color(0xFF1B5E20),
    };
    final label = switch (level) {
      RiskLevel.critical => 'Critical',
      RiskLevel.high => 'High',
      RiskLevel.medium => 'Medium',
      RiskLevel.low => 'Low',
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
