import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';
import 'package:ca_app/features/bulk_operations/domain/models/filing_batch.dart';
import 'package:ca_app/features/bulk_operations/data/providers/bulk_operations_providers.dart';

/// Financial year options.
const _financialYears = <String>[
  'AY 2026-27',
  'AY 2025-26',
  'FY 2025-26',
  'FY 2025-26 Q4',
  'FY 2025-26 Q3',
];

/// Mock clients available for selection.
const _availableClients = <({String id, String name})>[
  (id: '1', name: 'Rajesh Kumar Sharma'),
  (id: '2', name: 'Priya Mehta'),
  (id: '3', name: 'ABC Infra Pvt Ltd'),
  (id: '4', name: 'Mehta & Sons'),
  (id: '6', name: 'TechVista Solutions LLP'),
  (id: '7', name: 'Anil Gupta HUF'),
  (id: '8', name: 'Bharat Electronics Ltd'),
  (id: '9', name: 'Deepak Patel'),
  (id: '13', name: 'GreenLeaf Organics LLP'),
  (id: '14', name: 'Vikram Singh Rathore'),
];

/// Screen to configure and launch a new bulk filing batch.
class NewBatchScreen extends ConsumerStatefulWidget {
  const NewBatchScreen({super.key});

  @override
  ConsumerState<NewBatchScreen> createState() => _NewBatchScreenState();
}

class _NewBatchScreenState extends ConsumerState<NewBatchScreen> {
  BatchType _selectedType = BatchType.itrFiling;
  String _selectedFY = _financialYears.first;
  final Set<String> _selectedClientIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Batch',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Batch type selector
            const _SectionLabel(label: 'Batch Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BatchType.values.map((type) {
                final isSelected = type == _selectedType;
                return ChoiceChip(
                  label: Text(type.label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedType = type),
                  selectedColor: AppColors.primary.withAlpha(30),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.neutral600,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // FY / period selector
            const _SectionLabel(label: 'Financial Year / Period'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.neutral100),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFY,
                  isExpanded: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral900,
                  ),
                  items: _financialYears.map((fy) {
                    return DropdownMenuItem(value: fy, child: Text(fy));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedFY = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Client multi-select
            _SectionLabel(
              label: 'Select Clients (${_selectedClientIds.length})',
            ),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: _availableClients.map((client) {
                  final isSelected = _selectedClientIds.contains(client.id);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(
                      client.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    activeColor: AppColors.primary,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedClientIds.add(client.id);
                        } else {
                          _selectedClientIds.remove(client.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // Start batch button
            FilledButton.icon(
              onPressed: _selectedClientIds.isEmpty ? null : _startBatch,
              icon: const Icon(Icons.rocket_launch_rounded, size: 18),
              label: const Text('Start Batch'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                disabledBackgroundColor: AppColors.neutral200,
                minimumSize: const Size(double.infinity, 52),
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _startBatch() {
    final now = DateTime.now();
    final jobs = _selectedClientIds.map((clientId) {
      final client = _availableClients.firstWhere((c) => c.id == clientId);
      final jobType = _jobTypeForBatchType(_selectedType);
      return BatchJob(
        jobId: 'job-${now.microsecondsSinceEpoch}-$clientId',
        name: '${client.name} — ${_selectedType.label}',
        jobType: jobType,
        priority: JobPriority.normal,
        items: [
          BatchJobItem(
            itemId: 'item-${now.microsecondsSinceEpoch}-$clientId',
            clientName: client.name,
            pan: clientId,
            payload: '{"type":"${_selectedType.label}","fy":"$_selectedFY"}',
            status: BatchJobItemStatus.pending,
            attempts: 0,
          ),
        ],
        status: JobStatus.queued,
        completedItems: 0,
        failedItems: 0,
        createdAt: now,
      );
    }).toList();

    final batch = FilingBatch(
      batchId: 'batch-${DateTime.now().microsecondsSinceEpoch}',
      name: '${_selectedType.label} — $_selectedFY',
      type: _selectedType,
      status: BatchStatus.queued,
      jobs: List.unmodifiable(jobs),
      createdAt: DateTime.now(),
      financialYear: _selectedFY,
    );

    ref.read(batchListProvider.notifier).addBatch(batch);
    Navigator.of(context).pop();
  }

  static JobType _jobTypeForBatchType(BatchType type) {
    switch (type) {
      case BatchType.itrFiling:
        return JobType.itrFiling;
      case BatchType.gstFiling:
        return JobType.gstFiling;
      case BatchType.tdsReturns:
        return JobType.tdsFiling;
      case BatchType.form16Bulk:
        return JobType.bulkExport;
    }
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
      ),
    );
  }
}
