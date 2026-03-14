import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/audit/data/providers/audit_providers.dart';
import 'package:ca_app/features/audit/presentation/widgets/audit_report_tile.dart';

/// Main audit reports screen with filter (Form 3CD / Form 29B / All),
/// report tiles, and a FAB to create new reports.
class AuditReportScreen extends ConsumerWidget {
  const AuditReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(auditFormFilterProvider);
    final reportsAsync = ref.watch(auditReportListProvider);
    final reports = ref.watch(filteredAuditReportsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit Reports',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Form 3CD & Form 29B management',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Form 3CD as default for new reports
          context.push('/audit-reports/3cd');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Audit Report'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: reportsAsync.isLoading && reports.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : reportsAsync.hasError && reports.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load audit reports',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(auditReportListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Filter chips
                  _FilterRow(activeFilter: filter),
                  const SizedBox(height: 16),

                  // Reports
                  if (reports.isEmpty)
                    _EmptyState()
                  else
                    ...reports.map(
                      (report) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AuditReportTile(
                          report: report,
                          onTap: () {
                            ref
                                .read(activeAuditReportProvider.notifier)
                                .select(report);
                            final route =
                                report.formType == AuditFormType.form3cd
                                ? '/audit-reports/3cd'
                                : '/audit-reports/29b';
                            context.push(route);
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 80), // FAB clearance
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter row
// ---------------------------------------------------------------------------

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.activeFilter});

  final AuditFormType? activeFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _FilterChip(
          label: 'All',
          isActive: activeFilter == null,
          onTap: () =>
              ref.read(auditFormFilterProvider.notifier).setFilter(null),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Form 3CD',
          isActive: activeFilter == AuditFormType.form3cd,
          onTap: () => ref
              .read(auditFormFilterProvider.notifier)
              .setFilter(AuditFormType.form3cd),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Form 29B',
          isActive: activeFilter == AuditFormType.form29b,
          onTap: () => ref
              .read(auditFormFilterProvider.notifier)
              .setFilter(AuditFormType.form29b),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.neutral200,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isActive ? Colors.white : AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 12),
            Text(
              'No audit reports found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
