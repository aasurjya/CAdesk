import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/faceless_assessment/data/providers/faceless_assessment_providers.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/e_proceeding.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/hearing_schedule.dart';
import 'package:ca_app/features/faceless_assessment/presentation/widgets/e_proceeding_tile.dart';
import 'package:ca_app/features/faceless_assessment/presentation/widgets/hearing_tile.dart';
import 'package:ca_app/features/faceless_assessment/presentation/widgets/itr_u_tile.dart';

/// Main screen for Module 31: Faceless Assessment & E-Proceedings.
class FacelessAssessmentScreen extends ConsumerWidget {
  const FacelessAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('E-Proceedings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'E-Proceedings'),
              Tab(text: 'ITR-U'),
              Tab(text: 'Hearings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_EProceedingsTab(), _ItrUTab(), _HearingsTab()],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// E-Proceedings tab
// ---------------------------------------------------------------------------

class _EProceedingsTab extends ConsumerWidget {
  const _EProceedingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proceedings = ref.watch(filteredProceedingsProvider);
    final typeFilter = ref.watch(proceedingTypeFilterProvider);
    final statusFilter = ref.watch(proceedingStatusFilterProvider);

    return Column(
      children: [
        _ProceedingTypeChips(
          selected: typeFilter,
          onSelected: (value) {
            ref.read(proceedingTypeFilterProvider.notifier).update(value);
          },
        ),
        _ProceedingStatusChips(
          selected: statusFilter,
          onSelected: (value) {
            ref.read(proceedingStatusFilterProvider.notifier).update(value);
          },
        ),
        _UrgencyBanner(proceedings: proceedings),
        Expanded(
          child: proceedings.isEmpty
              ? _buildEmpty(context, 'No e-proceedings found')
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: proceedings.length,
                  itemBuilder: (_, index) =>
                      EProceedingTile(proceeding: proceedings[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ITR-U tab
// ---------------------------------------------------------------------------

class _ItrUTab extends ConsumerWidget {
  const _ItrUTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filings = ref.watch(itrUFilingsProvider);

    if (filings.isEmpty) {
      return _buildEmpty(context, 'No ITR-U filings found');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: filings.length,
      itemBuilder: (_, index) => ItrUTile(filing: filings[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Hearings tab
// ---------------------------------------------------------------------------

class _HearingsTab extends ConsumerWidget {
  const _HearingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hearings = ref.watch(filteredHearingsProvider);
    final statusFilter = ref.watch(hearingStatusFilterProvider);

    return Column(
      children: [
        _HearingStatusChips(
          selected: statusFilter,
          onSelected: (value) {
            ref.read(hearingStatusFilterProvider.notifier).update(value);
          },
        ),
        Expanded(
          child: hearings.isEmpty
              ? _buildEmpty(context, 'No hearings found')
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: hearings.length,
                  itemBuilder: (_, index) =>
                      HearingTile(hearing: hearings[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Urgency banner
// ---------------------------------------------------------------------------

class _UrgencyBanner extends StatelessWidget {
  const _UrgencyBanner({required this.proceedings});

  final List<EProceeding> proceedings;

  @override
  Widget build(BuildContext context) {
    final urgent = proceedings
        .where(
          (p) =>
              p.isUrgent &&
              p.status != ProceedingStatus.orderPassed &&
              p.status != ProceedingStatus.appealFiled,
        )
        .toList();
    final overdue = proceedings.where((p) => p.isOverdue).toList();

    if (urgent.isEmpty && overdue.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _buildMessage(urgent.length, overdue.length),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildMessage(int urgentCount, int overdueCount) {
    final parts = <String>[];
    if (overdueCount > 0) {
      parts.add('$overdueCount overdue');
    }
    if (urgentCount > 0) {
      parts.add('$urgentCount due within 7 days');
    }
    return '${parts.join(', ')} -- immediate action required';
  }
}

// ---------------------------------------------------------------------------
// Filter chip rows
// ---------------------------------------------------------------------------

class _ProceedingTypeChips extends StatelessWidget {
  const _ProceedingTypeChips({
    required this.selected,
    required this.onSelected,
  });

  final ProceedingType? selected;
  final ValueChanged<ProceedingType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('All', selected == null, () => onSelected(null)),
            ...ProceedingType.values.map(
              (t) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _chip(
                  t.label,
                  selected == t,
                  () => onSelected(selected == t ? null : t),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.secondary,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.secondary : AppColors.neutral600,
      ),
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ProceedingStatusChips extends StatelessWidget {
  const _ProceedingStatusChips({
    required this.selected,
    required this.onSelected,
  });

  final ProceedingStatus? selected;
  final ValueChanged<ProceedingStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('All', selected == null, () => onSelected(null)),
            ...ProceedingStatus.values.map(
              (s) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _chip(
                  s.label,
                  selected == s,
                  () => onSelected(selected == s ? null : s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
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

class _HearingStatusChips extends StatelessWidget {
  const _HearingStatusChips({required this.selected, required this.onSelected});

  final HearingStatus? selected;
  final ValueChanged<HearingStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('All', selected == null, () => onSelected(null)),
            ...HearingStatus.values.map(
              (s) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _chip(
                  s.label,
                  selected == s,
                  () => onSelected(selected == s ? null : s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.secondary,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.secondary : AppColors.neutral600,
      ),
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
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
        const Icon(Icons.inbox_rounded, size: 64, color: AppColors.neutral400),
        const SizedBox(height: 12),
        Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.neutral400),
        ),
      ],
    ),
  );
}
