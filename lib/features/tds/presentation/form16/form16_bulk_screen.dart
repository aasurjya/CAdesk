import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tds/data/providers/form16_providers.dart';
import 'package:ca_app/features/tds/domain/models/form16_data.dart';

/// Bulk Form 16 generation screen — employee selection, progress, and result.
class Form16BulkScreen extends ConsumerStatefulWidget {
  const Form16BulkScreen({super.key});

  @override
  ConsumerState<Form16BulkScreen> createState() => _Form16BulkScreenState();
}

class _Form16BulkScreenState extends ConsumerState<Form16BulkScreen> {
  final Set<String> _selectedPans = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allForms = ref.watch(form16ListProvider);
    final progress = ref.watch(form16BulkProgressProvider);
    final fy = ref.watch(form16FinancialYearProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bulk Generate Form 16',
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
            // FY display
            _FYBanner(fy: fy),
            const SizedBox(height: 16),

            if (progress.isRunning || progress.completedCount > 0) ...[
              _ProgressSection(progress: progress),
              const SizedBox(height: 16),
              if (!progress.isRunning &&
                  progress.completedCount == progress.totalCount &&
                  progress.totalCount > 0)
                _CompletedSection(
                  count: progress.completedCount,
                  onViewAll: () {
                    ref.read(form16BulkProgressProvider.notifier).reset();
                    context.go('/tds/form16');
                  },
                ),
            ] else ...[
              // Select all toggle
              _SelectAllRow(
                selectAll: _selectAll,
                onChanged: (value) {
                  setState(() {
                    _selectAll = value;
                    if (value) {
                      _selectedPans.addAll(allForms.map((f) => f.employeePan));
                    } else {
                      _selectedPans.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 8),

              // Employee list
              ...allForms.map((form) {
                return _EmployeeCheckTile(
                  form16: form,
                  isSelected: _selectedPans.contains(form.employeePan),
                  onChanged: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPans.add(form.employeePan);
                      } else {
                        _selectedPans.remove(form.employeePan);
                      }
                      _selectAll = _selectedPans.length == allForms.length;
                    });
                  },
                );
              }),
              const SizedBox(height: 24),

              // Generate button
              FilledButton.icon(
                onPressed: _selectedPans.isEmpty
                    ? null
                    : () => _startGeneration(allForms),
                icon: const Icon(Icons.bolt_rounded),
                label: Text(
                  'Generate Form 16 for ${_selectedPans.length} employee${_selectedPans.length == 1 ? '' : 's'}',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startGeneration(List<Form16Data> allForms) async {
    final notifier = ref.read(form16BulkProgressProvider.notifier);
    notifier.start(_selectedPans.length);

    // Simulate generation with delays
    for (var i = 0; i < _selectedPans.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      notifier.increment();
    }
  }
}

// ---------------------------------------------------------------------------
// FY banner
// ---------------------------------------------------------------------------

class _FYBanner extends StatelessWidget {
  const _FYBanner({required this.fy});

  final String fy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Text(
            'Financial Year: $fy',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Select all row
// ---------------------------------------------------------------------------

class _SelectAllRow extends StatelessWidget {
  const _SelectAllRow({required this.selectAll, required this.onChanged});

  final bool selectAll;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: CheckboxListTile(
        value: selectAll,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(
          'Select All Employees',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Employee check tile
// ---------------------------------------------------------------------------

class _EmployeeCheckTile extends StatelessWidget {
  const _EmployeeCheckTile({
    required this.form16,
    required this.isSelected,
    required this.onChanged,
  });

  final Form16Data form16;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(
          form16.employeeName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        subtitle: Text(
          'PAN: ${form16.employeePan}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress section
// ---------------------------------------------------------------------------

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.progress});

  final BulkGenerationProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              progress.isRunning ? 'Generating...' : 'Generation Complete',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.fraction,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Generated ${progress.completedCount} of ${progress.totalCount}...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Completed section
// ---------------------------------------------------------------------------

class _CompletedSection extends StatelessWidget {
  const _CompletedSection({required this.count, required this.onViewAll});

  final int count;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Successfully generated $count Form 16 certificate${count == 1 ? '' : 's'}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
      ),
    );
  }
}
