import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/idp/data/providers/idp_providers.dart';
import 'package:ca_app/features/idp/domain/models/document_job.dart';
import 'package:ca_app/features/idp/domain/models/extracted_field.dart';
import 'package:ca_app/features/idp/presentation/widgets/document_job_card.dart';
import 'package:ca_app/features/idp/presentation/widgets/extracted_field_tile.dart';

/// Main screen for Intelligent Document Processing (Module 49).
class IdpScreen extends ConsumerStatefulWidget {
  const IdpScreen({super.key});

  @override
  ConsumerState<IdpScreen> createState() => _IdpScreenState();
}

class _IdpScreenState extends ConsumerState<IdpScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _statusFilters = <String?>[
    null,
    'Queued',
    'Processing',
    'Review',
    'Completed',
    'Failed',
  ];

  static const _statusLabels = <String>[
    'All',
    'Queued',
    'Processing',
    'Review',
    'Completed',
    'Failed',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allJobs = ref.watch(allDocumentJobsProvider);
    final filteredJobs = ref.watch(filteredDocumentJobsProvider);
    final allFields = ref.watch(allExtractedFieldsProvider);
    final selectedStatus = ref.watch(selectedDocStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Document Processing',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Document Jobs'),
            Tab(text: 'Extracted Fields'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DocumentJobsTab(
            allJobs: allJobs,
            filteredJobs: filteredJobs,
            selectedStatus: selectedStatus,
            statusFilters: _statusFilters,
            statusLabels: _statusLabels,
            onStatusSelected: (s) =>
                ref.read(selectedDocStatusProvider.notifier).select(s),
          ),
          _ExtractedFieldsTab(fields: allFields),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Accuracy summary card
// ---------------------------------------------------------------------------

class _AccuracySummaryCard extends StatelessWidget {
  const _AccuracySummaryCard({required this.jobs});

  final List<DocumentJob> jobs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = jobs.where((j) => j.status == 'Completed').toList();
    final queued = jobs.where((j) => j.status == 'Queued').length;

    double avgConfidence = 0.0;
    if (completed.isNotEmpty) {
      final total = completed.fold<double>(
        0,
        (sum, j) => sum + j.confidenceScore,
      );
      avgConfidence = total / completed.length;
    }
    final avgPercent = (avgConfidence * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Extraction Accuracy',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral200,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$avgPercent%',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryPill(
                label: 'Total',
                value: '${jobs.length}',
                icon: Icons.description_outlined,
              ),
              const SizedBox(width: 10),
              _SummaryPill(
                label: 'Completed',
                value: '${completed.length}',
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 10),
              _SummaryPill(
                label: 'Queued',
                value: '$queued',
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.neutral200),
          const SizedBox(width: 4),
          Text(
            '$value $label',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document Jobs tab
// ---------------------------------------------------------------------------

class _DocumentJobsTab extends StatelessWidget {
  const _DocumentJobsTab({
    required this.allJobs,
    required this.filteredJobs,
    required this.selectedStatus,
    required this.statusFilters,
    required this.statusLabels,
    required this.onStatusSelected,
  });

  final List<DocumentJob> allJobs;
  final List<DocumentJob> filteredJobs;
  final String? selectedStatus;
  final List<String?> statusFilters;
  final List<String> statusLabels;
  final ValueChanged<String?> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _AccuracySummaryCard(jobs: allJobs)),
        SliverToBoxAdapter(
          child: _StatusFilterBar(
            selectedStatus: selectedStatus,
            statusFilters: statusFilters,
            statusLabels: statusLabels,
            onSelected: onStatusSelected,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              '${filteredJobs.length} document${filteredJobs.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (filteredJobs.isEmpty)
          const SliverFillRemaining(child: _EmptyJobsState())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => DocumentJobCard(job: filteredJobs[index]),
              childCount: filteredJobs.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.selectedStatus,
    required this.statusFilters,
    required this.statusLabels,
    required this.onSelected,
  });

  final String? selectedStatus;
  final List<String?> statusFilters;
  final List<String> statusLabels;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statusFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = statusFilters[index];
          final label = statusLabels[index];
          final isSelected = selectedStatus == filter;
          return FilterChip(
            label: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
            selectedColor: AppColors.primary.withAlpha(30),
            checkmarkColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

class _EmptyJobsState extends StatelessWidget {
  const _EmptyJobsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_list_off_rounded,
            size: 64,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 12),
          Text(
            'No documents match this filter',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try selecting a different status',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Extracted Fields tab
// ---------------------------------------------------------------------------

class _ExtractedFieldsTab extends StatelessWidget {
  const _ExtractedFieldsTab({required this.fields});

  final List<ExtractedField> fields;

  /// Returns unique job IDs preserving first-seen order.
  List<String> _orderedJobIds(List<ExtractedField> fields) {
    final seen = <String>{};
    final result = <String>[];
    for (final f in fields) {
      if (seen.add(f.jobId)) {
        result.add(f.jobId);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return const _EmptyFieldsState();
    }

    final jobIds = _orderedJobIds(fields);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        for (final jobId in jobIds)
          _JobFieldsGroup(
            jobId: jobId,
            fields: fields.where((f) => f.jobId == jobId).toList(),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _JobFieldsGroup extends ConsumerWidget {
  const _JobFieldsGroup({required this.jobId, required this.fields});

  final String jobId;
  final List<ExtractedField> fields;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allJobs = ref.watch(allDocumentJobsProvider);

    String groupLabel = jobId;
    try {
      final job = allJobs.firstWhere((j) => j.id == jobId);
      groupLabel = '${job.clientName} — ${job.documentType}';
    } catch (_) {
      // fallback to jobId if not found
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              groupLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ExtractedFieldTile(field: fields[index]),
            childCount: fields.length,
          ),
        ),
      ],
    );
  }
}

class _EmptyFieldsState extends StatelessWidget {
  const _EmptyFieldsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.text_snippet_outlined,
            size: 64,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 12),
          Text(
            'No extracted fields yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete document jobs to see extracted data',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
