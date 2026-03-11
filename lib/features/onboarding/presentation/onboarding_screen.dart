import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/onboarding/domain/models/kyc_record.dart';
import 'package:ca_app/features/onboarding/domain/models/document_expiry.dart';
import 'package:ca_app/features/onboarding/data/providers/onboarding_providers.dart';
import 'package:ca_app/features/onboarding/presentation/widgets/kyc_status_card.dart';
import 'package:ca_app/features/onboarding/presentation/widgets/checklist_progress.dart';
import 'package:ca_app/features/onboarding/presentation/widgets/expiry_alert_tile.dart';

/// Main Client Onboarding & KYC screen with tabs:
/// Active Onboarding, KYC Status, Document Expiry.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Onboarding & KYC',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                'Client activation and compliance readiness',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(62),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.neutral100),
                ),
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Onboarding'),
                    Tab(text: 'KYC Status'),
                    Tab(text: 'Doc Expiry'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: TabBarView(
            children: [_OnboardingTab(), _KycStatusTab(), _DocumentExpiryTab()],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active Onboarding tab
// ---------------------------------------------------------------------------

class _OnboardingTab extends ConsumerWidget {
  const _OnboardingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklists = ref.watch(activeChecklistsProvider);

    if (checklists.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.checklist_rounded,
        'No active onboarding',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      itemCount: checklists.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _OnboardingBanner(),
          );
        }
        return ChecklistProgress(checklist: checklists[index - 1]);
      },
    );
  }
}

class _OnboardingBanner extends StatelessWidget {
  const _OnboardingBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha(18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.badge_outlined, color: AppColors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bring clients live smoothly',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track onboarding progress, KYC completion, and expiring records in one calmer activation workspace.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      height: 1.4,
                    ),
                  ),
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
// KYC Status tab
// ---------------------------------------------------------------------------

class _KycStatusTab extends ConsumerWidget {
  const _KycStatusTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(filteredKycRecordsProvider);
    final summary = ref.watch(kycSummaryProvider);
    final selectedStatus = ref.watch(kycStatusFilterProvider);

    return Column(
      children: [
        // Summary card
        _KycSummaryCard(summary: summary),
        // Status filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _StatusChip(
                label: 'All (${summary.total})',
                isSelected: selectedStatus == null,
                onTap: () {
                  ref.read(kycStatusFilterProvider.notifier).update(null);
                },
              ),
              ...KycStatus.values.map(
                (s) => _StatusChip(
                  label: s.label,
                  isSelected: selectedStatus == s,
                  onTap: () {
                    ref.read(kycStatusFilterProvider.notifier).update(s);
                  },
                ),
              ),
            ],
          ),
        ),
        // KYC records list
        Expanded(
          child: records.isEmpty
              ? _buildEmptyState(
                  context,
                  Icons.verified_user_outlined,
                  'No KYC records',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return KycStatusCard(record: records[index]);
                  },
                ),
        ),
      ],
    );
  }
}

/// Summary card showing KYC counts.
class _KycSummaryCard extends StatelessWidget {
  const _KycSummaryCard({required this.summary});

  final KycSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _MetricTile(
              label: 'Total',
              value: summary.total.toString(),
              color: AppColors.primary,
              icon: Icons.people_outlined,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Verified',
              value: summary.verified.toString(),
              color: AppColors.success,
              icon: Icons.verified_outlined,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Pending',
              value: summary.pending.toString(),
              color: AppColors.warning,
              icon: Icons.hourglass_empty_rounded,
            ),
            const _VerticalDivider(),
            _MetricTile(
              label: 'Issues',
              value: (summary.rejected + summary.expired).toString(),
              color: AppColors.error,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ),
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
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: AppColors.neutral200);
  }
}

// ---------------------------------------------------------------------------
// Document Expiry tab
// ---------------------------------------------------------------------------

class _DocumentExpiryTab extends ConsumerWidget {
  const _DocumentExpiryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiries = ref.watch(filteredDocumentExpiriesProvider);
    final selectedStatus = ref.watch(expiryStatusFilterProvider);

    return Column(
      children: [
        // Expiry status filter chips
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _StatusChip(
                label: 'All',
                isSelected: selectedStatus == null,
                onTap: () {
                  ref.read(expiryStatusFilterProvider.notifier).update(null);
                },
              ),
              ...ExpiryStatus.values.map(
                (s) => _StatusChip(
                  label: s.label,
                  isSelected: selectedStatus == s,
                  onTap: () {
                    ref.read(expiryStatusFilterProvider.notifier).update(s);
                  },
                ),
              ),
            ],
          ),
        ),
        // Expiry list
        Expanded(
          child: expiries.isEmpty
              ? _buildEmptyState(
                  context,
                  Icons.event_note_outlined,
                  'No document expiries',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: expiries.length,
                  itemBuilder: (context, index) {
                    return ExpiryAlertTile(expiry: expiries[index]);
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accent.withValues(alpha: 0.18),
        checkmarkColor: AppColors.accent,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.neutral600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

Widget _buildEmptyState(BuildContext context, IconData icon, String message) {
  final theme = Theme.of(context);

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: AppColors.neutral200),
        const SizedBox(height: 16),
        Text(
          message,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    ),
  );
}
