import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';

/// ListTile showing a sync queue item with entity type icon, operation badge,
/// status chip, and a retry button when failed.
class SyncItemTile extends StatelessWidget {
  const SyncItemTile({
    super.key,
    required this.item,
    this.onRetry,
  });

  final SyncQueueItem item;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (entityIcon, entityColor) = _entityStyle(item.entityType);
    final isFailed = item.status == SyncStatus.failed;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: entityColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(entityIcon, color: entityColor, size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.entityType,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isFailed ? AppColors.error : AppColors.neutral900,
              ),
            ),
          ),
          _OperationBadge(operation: item.operation),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            item.entityId,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(status: item.status),
        ],
      ),
      trailing: isFailed
          ? IconButton(
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.primary,
              tooltip: 'Retry',
              onPressed: onRetry,
            )
          : null,
    );
  }

  static (IconData, Color) _entityStyle(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'client':
        return (Icons.person_rounded, AppColors.primary);
      case 'filingjob':
        return (Icons.assignment_rounded, AppColors.secondary);
      case 'invoice':
        return (Icons.receipt_long_rounded, AppColors.accent);
      case 'document':
        return (Icons.folder_rounded, AppColors.warning);
      default:
        return (Icons.sync_rounded, AppColors.neutral600);
    }
  }
}

class _OperationBadge extends StatelessWidget {
  const _OperationBadge({required this.operation});

  final SyncOperation operation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = _style();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
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

  (String, Color) _style() {
    switch (operation) {
      case SyncOperation.create:
        return ('CREATE', AppColors.success);
      case SyncOperation.update:
        return ('UPDATE', AppColors.accent);
      case SyncOperation.delete:
        return ('DELETE', AppColors.error);
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = _style();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
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

  (String, Color) _style() {
    switch (status) {
      case SyncStatus.pending:
        return ('Pending', AppColors.accent);
      case SyncStatus.syncing:
        return ('Syncing', AppColors.primary);
      case SyncStatus.synced:
        return ('Synced', AppColors.success);
      case SyncStatus.failed:
        return ('Failed', AppColors.error);
      case SyncStatus.conflicted:
        return ('Conflict', AppColors.warning);
    }
  }
}
