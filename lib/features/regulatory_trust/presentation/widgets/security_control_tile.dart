import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/security_control.dart';

/// A card tile displaying a single security control with category icon,
/// status chip, and severity badge.
class SecurityControlTile extends StatelessWidget {
  const SecurityControlTile({super.key, required this.control});

  final SecurityControl control;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar icon + title + status chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _categoryColor(
                      control.category,
                    ).withValues(alpha: 0.12),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: _categoryColor(control.category),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          control.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          control.category.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: control.status),
                ],
              ),
              const SizedBox(height: 10),

              // Severity badge row
              Row(
                children: [
                  _SeverityBadge(severity: control.severity),
                  const Spacer(),
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Next: ${dateFormat.format(control.nextDueDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),

              // Owner if present
              if (control.owner != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      control.owner!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(SecurityControlCategory category) {
    switch (category) {
      case SecurityControlCategory.soc2:
        return AppColors.primary;
      case SecurityControlCategory.iso27001:
        return AppColors.secondary;
      case SecurityControlCategory.vapt:
        return AppColors.error;
      case SecurityControlCategory.rbiCyber:
        return AppColors.accent;
      case SecurityControlCategory.dataResidency:
        return AppColors.primaryVariant;
      case SecurityControlCategory.privacy:
        return AppColors.warning;
    }
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SecurityControlStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.label),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: status.color,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      backgroundColor: status.color.withValues(alpha: 0.10),
      side: BorderSide(color: status.color.withValues(alpha: 0.3)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final ControlSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: severity.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 11, color: severity.color),
          const SizedBox(width: 4),
          Text(
            severity.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: severity.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
