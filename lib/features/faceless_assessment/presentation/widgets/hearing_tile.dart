import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/hearing_schedule.dart';

/// A tile displaying a hearing schedule with date/time and document checklist.
class HearingTile extends StatelessWidget {
  const HearingTile({
    super.key,
    required this.hearing,
    this.onTap,
  });

  final HearingSchedule hearing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hearing.isImminent &&
                hearing.status == HearingStatus.scheduled
            ? BorderSide(
                color: AppColors.warning.withValues(alpha: 0.5),
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hearing.status.icon,
                    size: 20,
                    color: hearing.status.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hearing.clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: hearing.status),
                ],
              ),
              const SizedBox(height: 8),
              _DateTimeRow(hearing: hearing),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.videocam_outlined, size: 14,
                      color: AppColors.neutral400),
                  const SizedBox(width: 4),
                  Text(
                    hearing.platform.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.person_outline, size: 14,
                      color: AppColors.neutral400),
                  const SizedBox(width: 4),
                  Text(
                    hearing.representativeName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hearing.agenda,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (hearing.documentsToSubmit.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DocumentChecklist(documents: hearing.documentsToSubmit),
              ],
              if (hearing.notes != null) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 14,
                          color: AppColors.warning),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          hearing.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({required this.hearing});

  final HearingSchedule hearing;

  static final _dateFormat = DateFormat('EEE, dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = hearing.daysUntilHearing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.event, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            _dateFormat.format(hearing.hearingDate),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.access_time, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            hearing.hearingTime,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          if (hearing.status == HearingStatus.scheduled && daysLeft >= 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: daysLeft <= 3
                    ? AppColors.error.withValues(alpha: 0.12)
                    : AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                daysLeft == 0
                    ? 'Today'
                    : daysLeft == 1
                        ? 'Tomorrow'
                        : 'In $daysLeft days',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color:
                      daysLeft <= 3 ? AppColors.error : AppColors.success,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DocumentChecklist extends StatelessWidget {
  const _DocumentChecklist({required this.documents});

  final List<String> documents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents to Submit:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ...documents.take(3).map(
              (doc) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        doc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        if (documents.length > 3)
          Text(
            '+${documents.length - 3} more',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primaryVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final HearingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
