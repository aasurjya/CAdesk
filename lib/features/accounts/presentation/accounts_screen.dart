import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../data/providers/accounts_providers.dart';
import '../domain/models/account_client.dart';
import '../domain/models/depreciation_entry.dart';
import 'widgets/account_client_tile.dart';
import 'widgets/depreciation_schedule_widget.dart';
import 'widgets/depreciation_tile.dart';
import 'widgets/financial_ratios_sheet.dart';
import 'widgets/financial_statement_tile.dart';

/// Main screen for Module 5: Accounts & Balance Sheet.
class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(accountsSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Accounts & Balance Sheet'),
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
            Tab(text: 'Clients'),
            Tab(text: 'Statements'),
            Tab(text: 'Depreciation'),
            Tab(text: 'Ratios'),
          ],
        ),
      ),
      body: Column(
        children: [
          _SummaryRow(summary: summary),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ClientsTab(),
                _StatementsTab(),
                _DepreciationTab(),
                _RatiosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary row
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final AccountsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Finalized',
            value: summary.finalized.toString(),
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Drafts',
            value: summary.drafts.toString(),
            icon: Icons.edit_note_rounded,
            color: AppColors.neutral400,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'AUM',
            value: CurrencyUtils.formatINRCompact(
              summary.totalAssetsUnderManagement,
            ),
            icon: Icons.account_balance_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Pending',
            value: summary.pendingApproval.toString(),
            icon: Icons.hourglass_empty_rounded,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.neutral200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Clients tab
// ---------------------------------------------------------------------------

class _ClientsTab extends ConsumerWidget {
  const _ClientsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(accountStatusFilterProvider);
    final typeFilter = ref.watch(businessTypeFilterProvider);
    final clients = ref.watch(filteredAccountClientsProvider);

    return Column(
      children: [
        _FilterRow(
          statusFilter: statusFilter,
          typeFilter: typeFilter,
          onStatusChanged: (v) =>
              ref.read(accountStatusFilterProvider.notifier).update(v),
          onTypeChanged: (v) =>
              ref.read(businessTypeFilterProvider.notifier).update(v),
        ),
        Expanded(
          child: clients.isEmpty
              ? _buildEmpty(context, 'No clients found')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: clients.length,
                  itemBuilder: (_, i) => AccountClientTile(
                    client: clients[i],
                    onTap: () => _onClientTap(context, ref, clients[i]),
                  ),
                ),
        ),
      ],
    );
  }

  void _onClientTap(BuildContext context, WidgetRef ref, AccountClient client) {
    final snapshot = ref.read(clientRatioSnapshotProvider(client.id));
    if (snapshot != null) {
      showFinancialRatiosSheet(context, snapshot);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No ratio data available for ${client.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Statements tab
// ---------------------------------------------------------------------------

class _StatementsTab extends ConsumerWidget {
  const _StatementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statements = ref.watch(filteredStatementsProvider);

    if (statements.isEmpty) {
      return _buildEmpty(context, 'No statements found');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: statements.length,
      itemBuilder: (_, i) => FinancialStatementTile(
        statement: statements[i],
        onTap: () {
          final snapshot = ref.read(
            clientRatioSnapshotProvider(statements[i].clientId),
          );
          if (snapshot != null) {
            showFinancialRatiosSheet(context, snapshot);
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Depreciation tab
// ---------------------------------------------------------------------------

class _DepreciationTab extends ConsumerWidget {
  const _DepreciationTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(depreciationEntriesProvider);

    if (entries.isEmpty) {
      return _buildEmpty(context, 'No depreciation entries found');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: entries.length,
      itemBuilder: (_, i) => DepreciationTile(
        entry: entries[i],
        onTap: () => _onDepreciationTap(context, ref, entries[i]),
      ),
    );
  }

  void _onDepreciationTap(
    BuildContext context,
    WidgetRef ref,
    DepreciationEntry entry,
  ) {
    final allEntries = ref.read(depreciationEntriesProvider);
    final clientEntries = allEntries
        .where((e) => e.clientId == entry.clientId)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    child: DepreciationScheduleWidget(
                      entries: clientEntries,
                      clientName: clientEntries.isNotEmpty
                          ? clientEntries.first.assetName
                                .split(' ')
                                .take(3)
                                .join(' ')
                          : 'Client',
                      financialYear: entry.financialYear,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ratios tab
// ---------------------------------------------------------------------------

class _RatiosTab extends ConsumerWidget {
  const _RatiosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshots = ref.watch(ratioSnapshotsProvider);

    if (snapshots.isEmpty) {
      return _buildEmpty(context, 'No ratio data available');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: snapshots.length,
      itemBuilder: (_, i) => _RatioSnapshotTile(
        snapshot: snapshots[i],
        onTap: () => showFinancialRatiosSheet(context, snapshots[i]),
      ),
    );
  }
}

class _RatioSnapshotTile extends StatelessWidget {
  const _RatioSnapshotTile({required this.snapshot, required this.onTap});

  final FinancialRatioSnapshot snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = snapshot.overallRating;
    final ratingColor = _ratingColor(rating);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.clientName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          snapshot.period,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ratingColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ratingColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      rating,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ratingColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.neutral400,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Key ratio chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _RatioChip(
                    label: 'CR',
                    value: snapshot.currentRatio.toStringAsFixed(1),
                    color: _liquidityColor(snapshot.currentRatio),
                  ),
                  _RatioChip(
                    label: 'NM',
                    value: '${snapshot.netMargin.toStringAsFixed(1)}%',
                    color: _marginColor(snapshot.netMargin, 15, 5),
                  ),
                  _RatioChip(
                    label: 'D/E',
                    value: snapshot.debtToEquity.toStringAsFixed(1),
                    color: _debtEquityColor(snapshot.debtToEquity),
                  ),
                  _RatioChip(
                    label: 'ROE',
                    value: '${snapshot.roe.toStringAsFixed(1)}%',
                    color: _marginColor(snapshot.roe, 15, 8),
                  ),
                  _RatioChip(
                    label: 'GM',
                    value: '${snapshot.grossMargin.toStringAsFixed(1)}%',
                    color: _marginColor(snapshot.grossMargin, 40, 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _ratingColor(String rating) {
    switch (rating) {
      case 'Healthy':
        return AppColors.success;
      case 'Watch':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  Color _liquidityColor(double ratio) {
    if (ratio >= 2.0) return AppColors.success;
    if (ratio >= 1.0) return AppColors.warning;
    return AppColors.error;
  }

  Color _marginColor(double pct, double good, double ok) {
    if (pct >= good) return AppColors.success;
    if (pct >= ok) return AppColors.warning;
    return AppColors.error;
  }

  Color _debtEquityColor(double de) {
    if (de < 1.0) return AppColors.success;
    if (de <= 2.0) return AppColors.warning;
    return AppColors.error;
  }
}

class _RatioChip extends StatelessWidget {
  const _RatioChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.neutral600,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips for clients tab
// ---------------------------------------------------------------------------

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.statusFilter,
    required this.typeFilter,
    required this.onStatusChanged,
    required this.onTypeChanged,
  });

  final AccountClientStatus? statusFilter;
  final BusinessType? typeFilter;
  final ValueChanged<AccountClientStatus?> onStatusChanged;
  final ValueChanged<BusinessType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(
              context,
              label: 'All',
              isSelected: statusFilter == null && typeFilter == null,
              onTap: () {
                onStatusChanged(null);
                onTypeChanged(null);
              },
            ),
            const SizedBox(width: 6),
            ...AccountClientStatus.values.map(
              (s) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _chip(
                  context,
                  label: s.label,
                  isSelected: statusFilter == s,
                  onTap: () => onStatusChanged(statusFilter == s ? null : s),
                ),
              ),
            ),
            ...BusinessType.values.map(
              (t) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _chip(
                  context,
                  label: t.label,
                  isSelected: typeFilter == t,
                  onTap: () => onTypeChanged(typeFilter == t ? null : t),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.primary : AppColors.neutral600,
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
