import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';

class FilingTimelineWidget extends StatelessWidget {
  const FilingTimelineWidget({required this.job, super.key});

  final FilingJob job;

  static const _statusOrder = [
    FilingJobStatus.notStarted,
    FilingJobStatus.documentsCollected,
    FilingJobStatus.draft,
    FilingJobStatus.review,
    FilingJobStatus.ready,
    FilingJobStatus.filed,
    FilingJobStatus.verified,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _statusOrder.indexOf(job.status);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Column(
      children: [
        for (int i = 0; i < _statusOrder.length; i++) ...[
          _TimelineEntry(
            status: _statusOrder[i],
            isCompleted: i <= currentIndex,
            isCurrent: i == currentIndex,
            date: i == 0
                ? dateFormat.format(job.createdAt)
                : i == currentIndex
                ? dateFormat.format(job.updatedAt)
                : null,
          ),
          if (i < _statusOrder.length - 1)
            _TimelineConnector(isCompleted: i < currentIndex),
        ],
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.status,
    required this.isCompleted,
    required this.isCurrent,
    this.date,
  });

  final FilingJobStatus status;
  final bool isCompleted;
  final bool isCurrent;
  final String? date;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? status.color : AppColors.neutral300;

    return Semantics(
      label:
          '${status.label}, ${isCompleted
              ? "completed"
              : isCurrent
              ? "current step"
              : "pending"}${date != null ? ", $date" : ""}',
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.transparent,
              border: Border.all(color: color, width: 2),
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                    semanticLabel: 'Completed',
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status.label,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: isCompleted
                    ? AppColors.neutral900
                    : AppColors.neutral400,
                fontSize: 14,
              ),
            ),
          ),
          if (date != null)
            Text(
              date!,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral400),
            ),
        ],
      ),
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      width: 2,
      height: 20,
      color: isCompleted ? AppColors.primary : AppColors.neutral300,
    );
  }
}
