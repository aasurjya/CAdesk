import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tds/data/providers/form16_providers.dart';
import 'package:ca_app/features/tds/domain/models/form16_data.dart';

/// ListTile displaying employee name, masked PAN, status chip, and FY.
class Form16StatusTile extends StatelessWidget {
  const Form16StatusTile({
    super.key,
    required this.form16,
    required this.status,
    required this.onTap,
  });

  final Form16Data form16;
  final Form16Status status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(form16.employeeName),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + PAN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      form16.employeeName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PAN: ${_maskPan(form16.employeePan)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // FY label
              Text(
                'FY ${form16.assessmentYear}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(width: 8),
              // Status chip
              _StatusChip(status: status),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.neutral300,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Masks the PAN: ABCDE1234F → ABCD****4F
  static String _maskPan(String pan) {
    if (pan.length < 10) return pan;
    return '${pan.substring(0, 4)}****${pan.substring(8)}';
  }

  /// Gets initials from a name (first + last).
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, 1).toUpperCase();
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final Form16Status status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      Form16Status.generated => (
        AppColors.success.withAlpha(18),
        AppColors.success,
      ),
      Form16Status.pending => (
        AppColors.warning.withAlpha(18),
        AppColors.warning,
      ),
      Form16Status.error => (AppColors.error.withAlpha(18), AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
