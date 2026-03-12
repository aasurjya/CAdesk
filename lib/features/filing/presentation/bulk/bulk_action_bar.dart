import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/presentation/bulk/bulk_status_update_sheet.dart';

class BulkActionBar extends ConsumerWidget {
  const BulkActionBar({
    required this.selectedCount,
    required this.selectedIds,
    required this.onActionCompleted,
    super.key,
  });

  final int selectedCount;
  final List<String> selectedIds;
  final VoidCallback onActionCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Text(
              '$selectedCount selected',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            _ActionButton(
              icon: Icons.update,
              label: 'Status',
              onPressed: () => _showStatusUpdate(context, ref),
            ),
            const SizedBox(width: 8),
            const Tooltip(
              message: 'Coming soon',
              child: _ActionButton(
                icon: Icons.person_add_outlined,
                label: 'Assign',
                onPressed: null,
              ),
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.delete_outline,
              label: 'Delete',
              onPressed: () => _confirmDelete(context, ref),
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdate(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => BulkStatusUpdateSheet(
        selectedIds: selectedIds,
        onStatusSelected: (status) {
          final notifier = ref.read(filingJobsProvider.notifier);
          for (final id in selectedIds) {
            final jobs = ref.read(filingJobsProvider);
            final job = jobs.where((j) => j.id == id).firstOrNull;
            if (job != null) {
              notifier.update(
                job.copyWith(status: status, updatedAt: DateTime.now()),
              );
            }
          }
          onActionCompleted();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Filings'),
        content: Text(
          'Delete $selectedCount selected filing(s)? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final notifier = ref.read(filingJobsProvider.notifier);
              for (final id in selectedIds) {
                notifier.remove(id);
              }
              onActionCompleted();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color ?? Colors.white),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: color ?? Colors.white),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color ?? Colors.white54),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: const Size(48, 36),
      ),
    );
  }
}
