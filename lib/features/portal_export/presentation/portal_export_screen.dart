import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_export/data/providers/export_job_repository_providers.dart';
import 'package:ca_app/features/portal_export/domain/models/export_job.dart';
import 'package:ca_app/features/portal_export/presentation/widgets/export_job_tile.dart';

// ---------------------------------------------------------------------------
// Screen-local providers
// ---------------------------------------------------------------------------

/// Selected export status filter (null = all).
final _statusFilterProvider =
    NotifierProvider<_StatusFilterNotifier, ExportJobStatus?>(
      _StatusFilterNotifier.new,
    );

class _StatusFilterNotifier extends Notifier<ExportJobStatus?> {
  @override
  ExportJobStatus? build() => null;

  void set(ExportJobStatus? value) => state = value;
}

/// Stream-based live export jobs (for real-time updates).
final _liveExportJobsProvider = StreamProvider.autoDispose<List<ExportJob>>((
  ref,
) {
  final repo = ref.watch(exportJobRepositoryProvider);
  return repo.watchByClient('client-1');
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Screen displaying export jobs (ITR XML, GSTR JSON, TDS FVU, Form 16 PDF).
class PortalExportScreen extends ConsumerWidget {
  const PortalExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(_liveExportJobsProvider);
    final statusFilter = ref.watch(_statusFilterProvider);

    // Merge live stream with filter
    final filtered = jobsAsync.when(
      data: (jobs) {
        if (statusFilter == null) return AsyncValue.data(jobs);
        return AsyncValue.data(
          jobs.where((j) => j.status == statusFilter).toList(),
        );
      },
      loading: () => const AsyncValue<List<ExportJob>>.loading(),
      error: AsyncValue.error,
    );

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Portal Export'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // Summary header
          _SummaryCard(jobsAsync: jobsAsync),

          // Status filter chips
          _StatusFilterRow(
            selected: statusFilter,
            onSelected: (s) => ref.read(_statusFilterProvider.notifier).set(s),
          ),

          // Job list
          Expanded(
            child: filtered.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorState(message: e.toString()),
              data: (jobs) {
                if (jobs.isEmpty) {
                  return const _EmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return ExportJobTile(
                      job: job,
                      onDownload: job.filePath != null
                          ? () => _onDownload(context, job)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'portal_export_fab',
        onPressed: () => _showNewExportSheet(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Export'),
      ),
    );
  }

  void _onDownload(BuildContext context, ExportJob job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${job.exportType.label}…'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNewExportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NewExportSheet(parentRef: ref),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.jobsAsync});

  final AsyncValue<List<ExportJob>> jobsAsync;

  @override
  Widget build(BuildContext context) {
    final jobs = jobsAsync.asData?.value ?? [];
    final completed = jobs
        .where((j) => j.status == ExportJobStatus.completed)
        .length;
    final processing = jobs
        .where((j) => j.status == ExportJobStatus.processing)
        .length;
    final failed = jobs.where((j) => j.status == ExportJobStatus.failed).length;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          _MetricTile(
            label: 'Completed',
            value: completed.toString(),
            color: AppColors.success,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(width: 8),
          _MetricTile(
            label: 'In Progress',
            value: processing.toString(),
            color: AppColors.primary,
            icon: Icons.hourglass_top_rounded,
          ),
          const SizedBox(width: 8),
          _MetricTile(
            label: 'Failed',
            value: failed.toString(),
            color: AppColors.error,
            icon: Icons.error_outline_rounded,
          ),
          const SizedBox(width: 8),
          _MetricTile(
            label: 'Total',
            value: jobs.length.toString(),
            color: AppColors.neutral400,
            icon: Icons.list_alt_rounded,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status filter row
// ---------------------------------------------------------------------------

class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({required this.selected, required this.onSelected});

  final ExportJobStatus? selected;
  final ValueChanged<ExportJobStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...ExportJobStatus.values.map(
            (s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: s.label,
                isSelected: selected == s,
                onTap: () => onSelected(selected == s ? null : s),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty / Error states
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.upload_file_rounded,
            size: 48,
            color: AppColors.neutral200,
          ),
          SizedBox(height: 12),
          Text(
            'No export jobs found',
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Tap "New Export" to generate a portal file',
            style: TextStyle(color: AppColors.neutral400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          const Text(
            'Failed to load export jobs',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(color: AppColors.neutral400, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// New export bottom sheet
// ---------------------------------------------------------------------------

class _NewExportSheet extends ConsumerStatefulWidget {
  const _NewExportSheet({required this.parentRef});

  final WidgetRef parentRef;

  @override
  ConsumerState<_NewExportSheet> createState() => _NewExportSheetState();
}

class _NewExportSheetState extends ConsumerState<_NewExportSheet> {
  ExportType _selectedType = ExportType.itrXml;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'New Export Job',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select the portal format to generate',
            style: TextStyle(color: AppColors.neutral400, fontSize: 13),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ExportType>(
            // ignore: deprecated_member_use
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Export Format',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: ExportType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedType = v);
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final repo = ref.read(exportJobRepositoryProvider);
              final job = ExportJob(
                id: 'job-${DateTime.now().millisecondsSinceEpoch}',
                clientId: 'client-1',
                exportType: _selectedType,
                status: ExportJobStatus.queued,
                createdAt: DateTime.now(),
              );
              await repo.insert(job);

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${_selectedType.label} export queued successfully',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text('Queue Export'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
