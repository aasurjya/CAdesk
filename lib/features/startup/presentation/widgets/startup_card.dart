import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/startup/data/providers/startup_providers.dart';
import 'package:ca_app/features/startup/domain/services/section80iac_service.dart';

/// Card widget displaying a startup summary: name, DPIIT badge, 80-IAC status.
class StartupCard extends StatelessWidget {
  const StartupCard({
    super.key,
    required this.startup,
    required this.onTap,
  });

  final StartupEntity startup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      startup.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _DpiitBadge(status: startup.dpiitStatus),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'CIN: ${startup.cin}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'PAN: ${startup.pan}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Iac80Chip(status: startup.iac80Status),
                  const Spacer(),
                  Text(
                    startup.entityType == StartupEntityType.company
                        ? 'Pvt Ltd'
                        : 'LLP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DPIIT status badge
// ---------------------------------------------------------------------------

class _DpiitBadge extends StatelessWidget {
  const _DpiitBadge({required this.status});

  final DpiitStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      DpiitStatus.registered => ('DPIIT', AppColors.success),
      DpiitStatus.pending => ('DPIIT Pending', AppColors.warning),
      DpiitStatus.notApplied => ('No DPIIT', AppColors.neutral400),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 80-IAC status chip
// ---------------------------------------------------------------------------

class _Iac80Chip extends StatelessWidget {
  const _Iac80Chip({required this.status});

  final Iac80Status status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      Iac80Status.approved => ('80-IAC Approved', AppColors.success),
      Iac80Status.applied => ('80-IAC Applied', AppColors.accent),
      Iac80Status.notEligible => ('80-IAC N/A', AppColors.error),
      Iac80Status.notApplied => ('80-IAC Not Applied', AppColors.neutral400),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
