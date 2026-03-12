import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/platform/data/providers/platform_providers.dart';
import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';
import 'package:ca_app/features/platform/presentation/widgets/sync_item_tile.dart';

/// Sync status screen showing pending items, last sync time, and retry support.
class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  DateTime _lastSync = DateTime.now().subtract(const Duration(minutes: 12));
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(syncQueueProvider);
    final pending = items
        .where(
          (i) => i.status == SyncStatus.pending || i.status == SyncStatus.failed,
        )
        .toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sync Status',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () => _syncNow(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _SyncHeader(
                    pendingCount: pending.length,
                    lastSync: _lastSync,
                    syncing: _syncing,
                    onSyncNow: _syncNow,
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Column(
                        children: [
                          SyncItemTile(
                            item: items[i],
                            onRetry: items[i].status == SyncStatus.failed
                                ? () => _retryItem(items[i].itemId)
                                : null,
                          ),
                          if (i < items.length - 1)
                            const Divider(indent: 72, height: 1),
                        ],
                      ),
                      childCount: items.length,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    ref.read(syncQueueProvider.notifier).markAllSynced();
    setState(() {
      _syncing = false;
      _lastSync = DateTime.now();
    });
  }

  void _retryItem(String itemId) {
    ref.read(syncQueueProvider.notifier).retryItem(itemId);
  }
}

// ---------------------------------------------------------------------------
// Sync header
// ---------------------------------------------------------------------------

class _SyncHeader extends StatelessWidget {
  const _SyncHeader({
    required this.pendingCount,
    required this.lastSync,
    required this.syncing,
    required this.onSyncNow,
  });

  final int pendingCount;
  final DateTime lastSync;
  final bool syncing;
  final Future<void> Function() onSyncNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = pendingCount == 0 ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                pendingCount == 0
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_upload_rounded,
                color: statusColor,
              ),
              const SizedBox(width: 10),
              Text(
                pendingCount == 0
                    ? 'All items synced'
                    : '$pendingCount item${pendingCount > 1 ? 's' : ''} pending sync',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Last sync: ${_relativeTime(lastSync)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: syncing ? null : onSyncNow,
              icon: syncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync_rounded, size: 18),
              label: Text(syncing ? 'Syncing…' : 'Sync Now'),
            ),
          ),
        ],
      ),
    );
  }

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_done_rounded,
            size: 64,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          Text(
            'Sync queue is empty.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
