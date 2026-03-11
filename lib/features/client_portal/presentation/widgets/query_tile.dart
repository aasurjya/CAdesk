import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/client_portal/domain/models/client_query.dart';

/// Card widget for displaying a client query with status badge and priority.
class QueryTile extends StatelessWidget {
  const QueryTile({super.key, required this.query, this.onTap});

  final ClientQuery query;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  Expanded(
                    child: Text(
                      query.subject,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PriorityBadge(priority: query.priority),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                query.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatusBadge(status: query.status),
                  const SizedBox(width: 8),
                  _CategoryChip(category: query.category),
                  const Spacer(),
                  Icon(
                    Icons.person_outline,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      query.clientName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('d MMM yyyy, h:mm a').format(query.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 10,
                    ),
                  ),
                  if (query.assignedTo != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.assignment_ind,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      query.assignedTo!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                  if (query.messages.isNotEmpty) ...[
                    const Spacer(),
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${query.messages.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final QueryStatus status;

  Color get _color {
    switch (status) {
      case QueryStatus.open:
        return AppColors.accent;
      case QueryStatus.inProgress:
        return AppColors.primaryVariant;
      case QueryStatus.awaitingClient:
        return AppColors.warning;
      case QueryStatus.resolved:
        return AppColors.success;
      case QueryStatus.closed:
        return AppColors.neutral400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final QueryPriority priority;

  Color get _color {
    switch (priority) {
      case QueryPriority.low:
        return AppColors.neutral400;
      case QueryPriority.medium:
        return AppColors.warning;
      case QueryPriority.high:
        return AppColors.accent;
      case QueryPriority.urgent:
        return AppColors.error;
    }
  }

  IconData get _icon {
    switch (priority) {
      case QueryPriority.low:
        return Icons.arrow_downward;
      case QueryPriority.medium:
        return Icons.remove;
      case QueryPriority.high:
        return Icons.arrow_upward;
      case QueryPriority.urgent:
        return Icons.priority_high;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 10, color: _color),
          const SizedBox(width: 2),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final QueryCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category.label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
