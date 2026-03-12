import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/reconciliation/data/providers/reconciliation_providers.dart';
import 'package:ca_app/features/reconciliation/presentation/widgets/comparison_card.dart';

/// Detail screen for a single reconciliation entry.
///
/// Shows a side-by-side comparison of 26AS, AIS, and ITR values, highlights
/// differences, and provides action buttons for the CA to resolve discrepancies.
class ReconDetailScreen extends ConsumerStatefulWidget {
  const ReconDetailScreen({super.key, required this.entry});

  final ReconEntry entry;

  @override
  ConsumerState<ReconDetailScreen> createState() => _ReconDetailScreenState();
}

class _ReconDetailScreenState extends ConsumerState<ReconDetailScreen> {
  final _notesController = TextEditingController();
  late ReconEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    _notesController.text = _entry.notes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _entry.source,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              _entry.incomeType,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
        child: isWide
            ? _WideDetailLayout(
                entry: _entry,
                notesController: _notesController,
                onAction: _handleAction,
              )
            : _NarrowDetailLayout(
                entry: _entry,
                notesController: _notesController,
                onAction: _handleAction,
              ),
      ),
    );
  }

  void _handleAction(String action) {
    final updatedEntry = switch (action) {
      'accept_ais' => _entry.copyWith(
          amountItr: _entry.amountAis,
          amount26as: _entry.amount26as > 0 ? _entry.amount26as : _entry.amountAis,
          status: ReconEntryStatus.matched,
          notes: '${_notesController.text}\nAccepted AIS value'.trim(),
        ),
      'accept_26as' => _entry.copyWith(
          amountItr: _entry.amount26as,
          amountAis: _entry.amountAis > 0 ? _entry.amountAis : _entry.amount26as,
          status: ReconEntryStatus.matched,
          notes: '${_notesController.text}\nAccepted 26AS value'.trim(),
        ),
      _ => _entry.copyWith(
          notes: _notesController.text,
        ),
    };

    ref.read(reconResultsProvider.notifier).updateEntry(updatedEntry);
    setState(() => _entry = updatedEntry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == 'manual'
              ? 'Notes saved'
              : 'Accepted ${action == 'accept_ais' ? 'AIS' : '26AS'} value',
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Narrow layout
// ---------------------------------------------------------------------------

class _NarrowDetailLayout extends StatelessWidget {
  const _NarrowDetailLayout({
    required this.entry,
    required this.notesController,
    required this.onAction,
  });

  final ReconEntry entry;
  final TextEditingController notesController;
  final void Function(String) onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatusHeader(entry: entry),
        const SizedBox(height: 14),
        ComparisonCard(
          title: '${entry.incomeType} - ${entry.source}',
          columns: [
            ComparisonColumn(label: '26AS', amountPaise: entry.amount26as),
            ComparisonColumn(label: 'AIS', amountPaise: entry.amountAis),
            ComparisonColumn(label: 'ITR', amountPaise: entry.amountItr),
          ],
        ),
        const SizedBox(height: 14),
        _ActionButtons(onAction: onAction),
        const SizedBox(height: 14),
        _NotesField(controller: notesController, onAction: onAction),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Wide layout — side-by-side
// ---------------------------------------------------------------------------

class _WideDetailLayout extends StatelessWidget {
  const _WideDetailLayout({
    required this.entry,
    required this.notesController,
    required this.onAction,
  });

  final ReconEntry entry;
  final TextEditingController notesController;
  final void Function(String) onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusHeader(entry: entry),
              const SizedBox(height: 14),
              ComparisonCard(
                title: '${entry.incomeType} - ${entry.source}',
                columns: [
                  ComparisonColumn(
                    label: '26AS',
                    amountPaise: entry.amount26as,
                  ),
                  ComparisonColumn(
                    label: 'AIS',
                    amountPaise: entry.amountAis,
                  ),
                  ComparisonColumn(
                    label: 'ITR',
                    amountPaise: entry.amountItr,
                  ),
                ],
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        SizedBox(
          width: 340,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ActionButtons(onAction: onAction),
              const SizedBox(height: 14),
              _NotesField(controller: notesController, onAction: onAction),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.entry});

  final ReconEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = _resolve(entry.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(entry.status), color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (entry.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.notes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static (String, Color) _resolve(ReconEntryStatus status) {
    return switch (status) {
      ReconEntryStatus.matched => ('All sources matched', AppColors.success),
      ReconEntryStatus.mismatched => ('Amounts differ across sources', AppColors.warning),
      ReconEntryStatus.missingIn26as => ('Not found in Form 26AS', AppColors.error),
      ReconEntryStatus.missingInAis => ('Not found in AIS', AppColors.error),
      ReconEntryStatus.missingInItr => ('Not declared in ITR', AppColors.error),
    };
  }

  static IconData _statusIcon(ReconEntryStatus status) {
    return switch (status) {
      ReconEntryStatus.matched => Icons.check_circle_rounded,
      ReconEntryStatus.mismatched => Icons.warning_amber_rounded,
      _ => Icons.error_outline_rounded,
    };
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onAction});

  final void Function(String) onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => onAction('accept_ais'),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Accept AIS'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => onAction('accept_26as'),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Accept 26AS'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => onAction('manual'),
          icon: const Icon(Icons.edit_rounded, size: 18),
          label: const Text('Manual Override'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({
    required this.controller,
    required this.onAction,
  });

  final TextEditingController controller;
  final void Function(String) onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CA Remarks',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add notes for this entry...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onAction('manual'),
                child: const Text('Save Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
