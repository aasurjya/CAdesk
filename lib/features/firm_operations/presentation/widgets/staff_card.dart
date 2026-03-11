import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/firm_operations/domain/models/staff_member.dart';
import 'package:ca_app/features/firm_operations/data/providers/firm_operations_providers.dart';

/// Displays a staff member card with CPE progress bar and utilization gauge.
class StaffCard extends ConsumerWidget {
  const StaffCard({super.key, required this.staff});

  final StaffMember staff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final kpi = ref.watch(kpiForStaffProvider(staff.id));
    final utilization = kpi?.utilizationRate ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar, name, designation
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _designationColor(
                    staff.designation,
                  ).withValues(alpha: 0.15),
                  child: Text(
                    _initials(staff.name),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: _designationColor(staff.designation),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${staff.designation.label} - ${staff.department}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Utilization gauge
                _UtilizationGauge(rate: utilization),
              ],
            ),
            const SizedBox(height: 12),
            // Skills chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: staff.skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.08,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            // CPE progress
            _CpeProgressBar(
              completed: staff.cpeHoursCompleted,
              required_: staff.cpeHoursRequired,
              progress: staff.cpeProgress,
            ),
            const SizedBox(height: 8),
            // Contact row
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 14,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    staff.email,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Text(
                  staff.phone,
                  style: theme.textTheme.labelSmall?.copyWith(
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

  Color _designationColor(StaffDesignation designation) {
    switch (designation) {
      case StaffDesignation.partner:
        return AppColors.primary;
      case StaffDesignation.manager:
        return AppColors.secondary;
      case StaffDesignation.senior:
        return AppColors.accent;
      case StaffDesignation.associate:
        return AppColors.success;
      case StaffDesignation.intern:
        return AppColors.neutral400;
    }
  }

  String _initials(String name) {
    final parts = name.replaceAll('CA ', '').split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 2).toUpperCase();
  }
}

/// Circular utilization gauge widget.
class _UtilizationGauge extends StatelessWidget {
  const _UtilizationGauge({required this.rate});

  final double rate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (rate * 100).round();
    final color = rate >= 0.80
        ? AppColors.success
        : rate >= 0.60
        ? AppColors.warning
        : AppColors.error;

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: rate,
            strokeWidth: 4,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '$percentage%',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// CPE hours progress bar.
class _CpeProgressBar extends StatelessWidget {
  const _CpeProgressBar({
    required this.completed,
    required this.required_,
    required this.progress,
  });

  final double completed;
  final double required_;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = progress >= 1.0
        ? AppColors.success
        : progress >= 0.5
        ? AppColors.warning
        : AppColors.error;

    if (required_ <= 0) {
      return Text(
        'CPE: Not applicable',
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.neutral400,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CPE Hours',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${completed.toInt()} / ${required_.toInt()} hrs',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
