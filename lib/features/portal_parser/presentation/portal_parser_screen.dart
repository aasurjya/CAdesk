import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_parser/data/providers/portal_import_repository_providers.dart';
import 'package:ca_app/features/portal_parser/domain/models/portal_import.dart';
import 'package:ca_app/features/portal_parser/presentation/widgets/import_record_tile.dart';

/// Providers for the portal parser screen.

/// Selected import type filter (null = all).
final _importTypeFilterProvider =
    NotifierProvider<_ImportTypeFilterNotifier, ImportType?>(
      _ImportTypeFilterNotifier.new,
    );

class _ImportTypeFilterNotifier extends Notifier<ImportType?> {
  @override
  ImportType? build() => null;

  void set(ImportType? value) => state = value;
}

/// Records for currently viewed client (hard-coded for demo).
final _importRecordsProvider = FutureProvider.autoDispose<List<PortalImport>>((
  ref,
) async {
  final repo = ref.watch(portalImportRepositoryProvider);
  final filter = ref.watch(_importTypeFilterProvider);

  if (filter != null) {
    return repo.getByType(filter);
  }
  // Return all records from a known demo client
  return repo.getByClient('client-1');
});

/// Screen for importing portal data (26AS, AIS, TIS, TRACES).
class PortalParserScreen extends ConsumerWidget {
  const PortalParserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_importRecordsProvider);
    final selectedType = ref.watch(_importTypeFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Portal Import'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary header
          _SummaryCard(recordsAsync: recordsAsync),

          // Type filter chips
          _TypeFilterRow(
            selected: selectedType,
            onSelected: (type) =>
                ref.read(_importTypeFilterProvider.notifier).set(type),
          ),

          // Records list
          Expanded(
            child: recordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorState(message: e.toString()),
              data: (records) {
                if (records.isEmpty) {
                  return const _EmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: records.length,
                  itemBuilder: (context, index) =>
                      ImportRecordTile(record: records[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'portal_parser_fab',
        onPressed: () => _showImportSheet(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_rounded),
        label: const Text('Import File'),
      ),
    );
  }

  void _showImportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ImportSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.recordsAsync});

  final AsyncValue<List<PortalImport>> recordsAsync;

  @override
  Widget build(BuildContext context) {
    final records = recordsAsync.asData?.value ?? [];
    final completed = records
        .where((r) => r.status == ImportStatus.completed)
        .length;
    final failed = records.where((r) => r.status == ImportStatus.failed).length;
    final pending = records
        .where(
          (r) =>
              r.status == ImportStatus.pending ||
              r.status == ImportStatus.parsing,
        )
        .length;

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
            label: 'Pending',
            value: pending.toString(),
            color: AppColors.warning,
            icon: Icons.hourglass_top_rounded,
          ),
          const SizedBox(width: 8),
          _MetricTile(
            label: 'Failed',
            value: failed.toString(),
            color: AppColors.error,
            icon: Icons.error_outline_rounded,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Type filter row
// ---------------------------------------------------------------------------

class _TypeFilterRow extends StatelessWidget {
  const _TypeFilterRow({required this.selected, required this.onSelected});

  final ImportType? selected;
  final ValueChanged<ImportType?> onSelected;

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
          ...ImportType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: type.label,
                isSelected: selected == type,
                onTap: () => onSelected(selected == type ? null : type),
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
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral200),
          SizedBox(height: 12),
          Text(
            'No import records found',
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Tap "Import File" to get started',
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
            'Failed to load records',
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
// Import sheet
// ---------------------------------------------------------------------------

class _ImportSheet extends ConsumerStatefulWidget {
  const _ImportSheet();

  @override
  ConsumerState<_ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends ConsumerState<_ImportSheet> {
  ImportType _selectedType = ImportType.form26as;

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
            'Import Portal Data',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select the type of portal document to import',
            style: TextStyle(color: AppColors.neutral400, fontSize: 13),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ImportType>(
            // ignore: deprecated_member_use
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Document Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: ImportType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedType = v);
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_selectedType.label} import initiated'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Select File & Import'),
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
