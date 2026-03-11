import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A compact card listing upcoming compliance deadlines for March 2026.
///
/// Deadlines are hardcoded for the current month (Mar 2026) since no
/// persistent calendar module is available yet. Each row shows a type
/// badge, description, due date, and a days-remaining pill coloured
/// red (overdue), orange (≤ 3 days), or green (safe).
class ComplianceDeadlineWidget extends StatelessWidget {
  const ComplianceDeadlineWidget({super.key});

  static const _deadlines = <_Deadline>[
    _Deadline(
      name: 'GST GSTR-3B',
      period: 'Feb 2026 period',
      dateLabel: 'Mar 20',
      type: 'GST',
      daysFromToday: 9,
    ),
    _Deadline(
      name: 'TDS Challan',
      period: 'Feb 2026 deductions',
      dateLabel: 'Mar 07',
      type: 'TDS',
      daysFromToday: -4,
    ),
    _Deadline(
      name: 'Advance Tax',
      period: 'Q4 FY 2025-26',
      dateLabel: 'Mar 15',
      type: 'IT',
      daysFromToday: 4,
    ),
    _Deadline(
      name: 'GSTR-1',
      period: 'Feb 2026 period',
      dateLabel: 'Mar 11',
      type: 'GST',
      daysFromToday: 0,
    ),
    _Deadline(
      name: 'TDS Return 26Q',
      period: 'Q3 FY 2025-26',
      dateLabel: 'Mar 31',
      type: 'TDS',
      daysFromToday: 20,
    ),
    _Deadline(
      name: 'GSTR-9',
      period: 'FY 2024-25 annual',
      dateLabel: 'Mar 31',
      type: 'GST',
      daysFromToday: 20,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _deadlines.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _DeadlineTile(deadline: _deadlines[index]);
          },
        ),
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  const _DeadlineTile({required this.deadline});

  final _Deadline deadline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = _badgeColor(deadline.type);
    final pillColor = _pillColor(deadline.daysFromToday);
    final pillText = _pillText(deadline.daysFromToday);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: badgeColor.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          deadline.type,
          style: TextStyle(
            color: badgeColor,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
      title: Text(
        deadline.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.neutral900,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          '${deadline.period} · Due ${deadline.dateLabel}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: pillColor.withAlpha(20),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          pillText,
          style: TextStyle(
            color: pillColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _badgeColor(String type) {
    switch (type) {
      case 'GST':
        return AppColors.secondary;
      case 'TDS':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  Color _pillColor(int days) {
    if (days < 0) {
      return AppColors.error;
    }
    if (days <= 3) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  String _pillText(int days) {
    if (days < 0) {
      return '${days.abs()} days overdue';
    }
    if (days == 0) {
      return 'Today';
    }
    return '$days days left';
  }
}

class _Deadline {
  const _Deadline({
    required this.name,
    required this.period,
    required this.dateLabel,
    required this.type,
    required this.daysFromToday,
  });

  final String name;
  final String period;
  final String dateLabel;

  /// 'GST', 'TDS', or 'IT'
  final String type;

  /// Positive = days remaining, 0 = today, negative = overdue by N days.
  final int daysFromToday;
}
