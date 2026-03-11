import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/dsc_vault_providers.dart';
import '../domain/models/dsc_certificate.dart';
import 'widgets/dsc_certificate_tile.dart';
import 'widgets/portal_credential_tile.dart';

/// Main screen for the DSC & Credential Vault module.
///
/// Provides two tabs:
///   1. DSC Certificates — filterable by [DscStatus]
///   2. Portal Credentials — full list
class DscVaultScreen extends ConsumerStatefulWidget {
  const DscVaultScreen({super.key});

  @override
  ConsumerState<DscVaultScreen> createState() => _DscVaultScreenState();
}

class _DscVaultScreenState extends ConsumerState<DscVaultScreen>
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
    final summary = ref.watch(dscVaultSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('DSC & Credential Vault'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'DSC Certificates'),
            Tab(text: 'Portal Credentials'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _SummaryCard(
                  label: 'Total DSCs',
                  count: summary.totalDsc,
                  icon: Icons.verified_user_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Expiring Soon',
                  count: summary.expiringSoon,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Expired',
                  count: summary.expired,
                  icon: Icons.cancel_rounded,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Active Portals',
                  count: summary.activePortals,
                  icon: Icons.language_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_DscCertificatesTab(), _PortalCredentialsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DSC Certificates tab
// ---------------------------------------------------------------------------

class _DscCertificatesTab extends ConsumerWidget {
  const _DscCertificatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certs = ref.watch(filteredDscProvider);
    final selectedStatus = ref.watch(dscStatusFilterProvider);

    return Column(
      children: [
        // Status filter chips
        _DscStatusFilterBar(selectedStatus: selectedStatus),

        // Certificate list
        Expanded(
          child: certs.isEmpty
              ? const _EmptyState(
                  message: 'No certificates match the selected filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: certs.length,
                  itemBuilder: (context, index) =>
                      DscCertificateTile(certificate: certs[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Portal Credentials tab
// ---------------------------------------------------------------------------

class _PortalCredentialsTab extends ConsumerWidget {
  const _PortalCredentialsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(allPortalCredentialsProvider);

    return credentials.isEmpty
        ? const _EmptyState(message: 'No portal credentials stored')
        : ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 80),
            itemCount: credentials.length,
            itemBuilder: (context, index) =>
                PortalCredentialTile(credential: credentials[index]),
          );
  }
}

// ---------------------------------------------------------------------------
// DSC status filter bar
// ---------------------------------------------------------------------------

class _DscStatusFilterBar extends ConsumerWidget {
  const _DscStatusFilterBar({required this.selectedStatus});

  final DscStatus? selectedStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: DscStatus.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = DscStatus.values[index];
          final isActive = status == selectedStatus;
          final color = status.color;

          return FilterChip(
            label: Text(status.label),
            selected: isActive,
            onSelected: (_) {
              ref
                  .read(dscStatusFilterProvider.notifier)
                  .update(isActive ? null : status);
            },
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : color,
            ),
            selectedColor: color,
            backgroundColor: color.withValues(alpha: 0.08),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral200),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
