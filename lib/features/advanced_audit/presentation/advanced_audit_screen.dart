import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/advanced_audit/data/providers/advanced_audit_providers.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_finding.dart';
import 'package:ca_app/features/advanced_audit/presentation/widgets/audit_checklist_tile.dart';
import 'package:ca_app/features/advanced_audit/presentation/widgets/audit_engagement_card.dart';
import 'package:ca_app/features/advanced_audit/presentation/widgets/audit_finding_tile.dart';

/// Main screen for Module 30: Advanced Audit Types.
class AdvancedAuditScreen extends ConsumerWidget {
  const AdvancedAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Audits'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Engagements'),
              Tab(text: 'Findings'),
              Tab(text: 'Checklists'),
            ],
          ),
        ),
        body: Column(
          children: [
            _AuditTypeFilterRow(),
            const Expanded(
              child: TabBarView(
                children: [
                  _EngagementsTab(),
                  _FindingsTab(),
                  _ChecklistsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Audit type filter chips (shared across tabs)
// ---------------------------------------------------------------------------

class _AuditTypeFilterRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(auditTypeFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip('All', selected == null, () {
              ref.read(auditTypeFilterProvider.notifier).update(null);
            }),
            ...AuditType.values.map((type) => Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _buildChip(
                    type.label,
                    selected == type,
                    () {
                      ref
                          .read(auditTypeFilterProvider.notifier)
                          .update(selected == type ? null : type);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.secondary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.secondary : AppColors.neutral600,
      ),
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
    );
  }
}

// ---------------------------------------------------------------------------
// Engagements tab
// ---------------------------------------------------------------------------

class _EngagementsTab extends ConsumerWidget {
  const _EngagementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engagements = ref.watch(filteredEngagementsProvider);

    if (engagements.isEmpty) {
      return _buildEmpty(context, 'No engagements found');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: engagements.length,
      itemBuilder: (_, index) => AuditEngagementCard(
        engagement: engagements[index],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Findings tab
// ---------------------------------------------------------------------------

class _FindingsTab extends ConsumerWidget {
  const _FindingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final findings = ref.watch(filteredFindingsProvider);
    final severityFilter = ref.watch(findingSeverityFilterProvider);

    return Column(
      children: [
        _SeverityFilterRow(
          selected: severityFilter,
          onSelected: (value) {
            ref.read(findingSeverityFilterProvider.notifier).update(value);
          },
        ),
        Expanded(
          child: findings.isEmpty
              ? _buildEmpty(context, 'No findings found')
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: findings.length,
                  itemBuilder: (_, index) => AuditFindingTile(
                    finding: findings[index],
                  ),
                ),
        ),
      ],
    );
  }
}

class _SeverityFilterRow extends StatelessWidget {
  const _SeverityFilterRow({
    required this.selected,
    required this.onSelected,
  });

  final FindingSeverity? selected;
  final ValueChanged<FindingSeverity?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip('All', selected == null, () => onSelected(null)),
            ...FindingSeverity.values.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _buildChip(
                    s.label,
                    selected == s,
                    () => onSelected(selected == s ? null : s),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accent.withValues(alpha: 0.15),
      checkmarkColor: AppColors.accent,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.accent : AppColors.neutral600,
      ),
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
    );
  }
}

// ---------------------------------------------------------------------------
// Checklists tab
// ---------------------------------------------------------------------------

class _ChecklistsTab extends ConsumerWidget {
  const _ChecklistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklists = ref.watch(filteredChecklistsProvider);

    if (checklists.isEmpty) {
      return _buildEmpty(context, 'No checklists found');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: checklists.length,
      itemBuilder: (_, index) => AuditChecklistTile(
        checklist: checklists[index],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared empty state
// ---------------------------------------------------------------------------

Widget _buildEmpty(BuildContext context, String message) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_rounded, size: 64, color: AppColors.neutral400),
        const SizedBox(height: 12),
        Text(
          message,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.neutral400,
              ),
        ),
      ],
    ),
  );
}
