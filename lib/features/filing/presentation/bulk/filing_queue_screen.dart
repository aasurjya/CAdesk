import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';
import 'package:ca_app/features/filing/presentation/bulk/bulk_action_bar.dart';

class FilingQueueScreen extends ConsumerStatefulWidget {
  const FilingQueueScreen({super.key});

  @override
  ConsumerState<FilingQueueScreen> createState() => _FilingQueueScreenState();
}

class _FilingQueueScreenState extends ConsumerState<FilingQueueScreen> {
  final Set<String> _selectedIds = {};
  String _filterStatus = 'all';
  String _searchQuery = '';

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<FilingJob> jobs) {
    setState(() {
      if (_selectedIds.length == jobs.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(jobs.map((j) => j.id));
      }
    });
  }

  List<FilingJob> _applyFilters(List<FilingJob> jobs) {
    var filtered = jobs;
    if (_filterStatus != 'all') {
      final status = FilingJobStatus.values.firstWhere(
        (s) => s.name == _filterStatus,
      );
      filtered = filtered.where((j) => j.status == status).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (j) =>
                j.clientName.toLowerCase().contains(q) ||
                j.pan.toLowerCase().contains(q),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final allJobs = ref.watch(filingJobsProvider);
    final jobs = _applyFilters(allJobs);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Filing Queue', style: TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          if (_selectedIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${_selectedIds.length} selected',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name or PAN...',
                      labelText: 'Search by name or PAN',
                      prefixIcon: Icon(Icons.search, size: 16),
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filterStatus,
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All')),
                    ...FilingJobStatus.values.map(
                      (s) =>
                          DropdownMenuItem(value: s.name, child: Text(s.label)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _filterStatus = v ?? 'all'),
                ),
              ],
            ),
          ),
          if (jobs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  MergeSemantics(
                    child: Row(
                      children: [
                        Checkbox(
                          value:
                              _selectedIds.length == jobs.length &&
                              jobs.isNotEmpty,
                          onChanged: (_) => _selectAll(jobs),
                        ),
                        const Text(
                          'Select All',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${jobs.length} filings',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: jobs.isEmpty
                ? const Center(child: Text('No filings match filters'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: jobs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final selected = _selectedIds.contains(job.id);
                      return _QueueJobTile(
                        job: job,
                        selected: selected,
                        onToggle: () => _toggleSelection(job.id),
                        onTap: () => context.push('/filing/status/${job.id}'),
                      );
                    },
                  ),
          ),
          if (_selectedIds.isNotEmpty)
            BulkActionBar(
              selectedCount: _selectedIds.length,
              selectedIds: _selectedIds.toList(),
              onActionCompleted: () => setState(() => _selectedIds.clear()),
            ),
        ],
      ),
    );
  }
}

class _QueueJobTile extends StatelessWidget {
  const _QueueJobTile({
    required this.job,
    required this.selected,
    required this.onToggle,
    required this.onTap,
  });

  final FilingJob job;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? AppColors.primary.withValues(alpha: 0.05) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Checkbox(value: selected, onChanged: (_) => onToggle()),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${job.pan}  •  ${job.assessmentYear}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: job.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  job.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: job.status.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
