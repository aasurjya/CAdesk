import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/audit/data/providers/audit_providers.dart';
import 'package:ca_app/features/audit/presentation/widgets/clause_section.dart';

/// Form 3CD clause-wise editor with collapsible sections for major
/// clause groups, progress bar, and save/finalize actions.
class Form3cdScreen extends ConsumerWidget {
  const Form3cdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(activeForm3cdProvider);
    final theme = Theme.of(context);

    final completedCount = form.clauses
        .where((c) => c.response.isNotEmpty)
        .length;
    final totalCount = form.clauses.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          'Form 3CD',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '$completedCount / $totalCount',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          _ProgressHeader(progress: progress, completed: completedCount),
          // Clause sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(title: 'Clauses 1-5: Basic Information'),
                ..._clauseRange(ref, form, 1, 5),
                const SizedBox(height: 12),
                _SectionHeader(title: 'Clauses 6-12: Books & Accounting'),
                ..._clauseRange(ref, form, 6, 12),
                const SizedBox(height: 12),
                _SectionHeader(title: 'Clauses 13-19: Tax Compliance'),
                ..._clauseRange(ref, form, 13, 19),
                const SizedBox(height: 12),
                _SectionHeader(title: 'Clauses 20-30: Deductions & Allowances'),
                ..._clauseRange(ref, form, 20, 30),
                const SizedBox(height: 12),
                _SectionHeader(title: 'Clauses 31-44: Other Reporting'),
                ..._clauseRange(ref, form, 31, 44),
                const SizedBox(height: 24),
                _ActionButtons(onSave: () => _saveDraft(context)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _clauseRange(WidgetRef ref, dynamic form, int start, int end) {
    return form.clauses
        .where((c) => c.clauseNumber >= start && c.clauseNumber <= end)
        .map<Widget>(
          (clause) => ClauseSection(
            clause: clause,
            onResponseChanged: (value) {
              ref
                  .read(activeForm3cdProvider.notifier)
                  .updateClause(clause.clauseNumber, response: value);
            },
            amountLabel: _needsAmount(clause.clauseNumber)
                ? 'Amount (\u20B9)'
                : null,
          ),
        )
        .toList();
  }

  /// Clauses that typically need an amount field.
  static bool _needsAmount(int clauseNumber) {
    const amountClauses = {9, 18, 19, 20, 22, 26, 30, 36, 40, 41};
    return amountClauses.contains(clauseNumber);
  }

  void _saveDraft(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal widgets
// ---------------------------------------------------------------------------

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.progress, required this.completed});

  final double progress;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.neutral100,
                color: progress >= 1.0 ? AppColors.success : AppColors.primary,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(progress * 100).round()}%',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.neutral900,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save Draft'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report finalized'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Finalize'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          ),
        ),
      ],
    );
  }
}
