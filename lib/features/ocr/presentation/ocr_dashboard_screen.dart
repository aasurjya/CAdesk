import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ocr/data/providers/ocr_providers.dart';
import 'package:ca_app/features/ocr/presentation/widgets/document_job_card.dart';

/// Main OCR dashboard showing the processing queue and job history.
class OcrDashboardScreen extends ConsumerStatefulWidget {
  const OcrDashboardScreen({super.key});

  @override
  ConsumerState<OcrDashboardScreen> createState() => _OcrDashboardScreenState();
}

class _OcrDashboardScreenState extends ConsumerState<OcrDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
    final theme = Theme.of(context);
    final queuedJobs = ref.watch(ocrQueuedJobsProvider);
    final historyJobs = ref.watch(ocrHistoryJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document OCR',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Intelligent document processing',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Queue'),
                  if (queuedJobs.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _CountBadge(count: queuedJobs.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('History'),
                  if (historyJobs.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _CountBadge(count: historyJobs.length),
                  ],
                ],
              ),
            ),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ocr/upload'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('Upload'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          return TabBarView(
            controller: _tabController,
            children: [
              _JobList(
                jobs: queuedJobs,
                emptyTitle: 'No documents queued',
                emptySubtitle:
                    'Tap Upload to scan a Form 16, bank statement, or invoice.',
                emptyIcon: Icons.inbox_outlined,
                isWide: isWide,
              ),
              _JobList(
                jobs: historyJobs,
                emptyTitle: 'No processed documents',
                emptySubtitle:
                    'Completed and failed jobs will appear here.',
                emptyIcon: Icons.history_outlined,
                isWide: isWide,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _JobList
// ---------------------------------------------------------------------------

class _JobList extends StatelessWidget {
  const _JobList({
    required this.jobs,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    required this.isWide,
  });

  final List<OcrJob> jobs;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return _EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    if (isWide) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 110,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        itemCount: jobs.length,
        itemBuilder: (context, index) => DocumentJobCard(job: jobs[index]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      itemCount: jobs.length,
      itemBuilder: (context, index) => DocumentJobCard(job: jobs[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// _EmptyState
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.neutral400),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CountBadge
// ---------------------------------------------------------------------------

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
