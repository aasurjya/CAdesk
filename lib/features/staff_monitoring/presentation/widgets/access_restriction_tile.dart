import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/access_restriction.dart';
import 'package:ca_app/features/staff_monitoring/data/providers/staff_monitoring_providers.dart';

class AccessRestrictionTile extends ConsumerWidget {
  const AccessRestrictionTile({super.key, required this.restriction});

  final AccessRestriction restriction;

  static const _typeIcons = <RestrictionType, IconData>{
    RestrictionType.website: Icons.language,
    RestrictionType.time: Icons.schedule,
    RestrictionType.fileType: Icons.insert_drive_file_outlined,
    RestrictionType.module: Icons.apps,
  };

  static const _typeColors = <RestrictionType, Color>{
    RestrictionType.website: AppColors.secondary,
    RestrictionType.time: AppColors.warning,
    RestrictionType.fileType: AppColors.accent,
    RestrictionType.module: AppColors.primary,
  };

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final icon =
        _typeIcons[restriction.restrictionType] ?? Icons.block;
    final color =
        _typeColors[restriction.restrictionType] ?? AppColors.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          restriction.staffName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TypeBadge(
                        label: restriction.restrictionType.label,
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restriction.value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    restriction.reason,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Applied by ${restriction.appliedBy} on '
                    '${_formatDate(restriction.appliedAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: restriction.isActive,
              onChanged: (_) {
                ref
                    .read(allRestrictionsProvider.notifier)
                    .toggleActive(restriction.id);
              },
              activeThumbColor: AppColors.error,
              inactiveThumbColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
