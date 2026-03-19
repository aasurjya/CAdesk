import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock data for period-level reconciliation detail
// ---------------------------------------------------------------------------

enum _MatchStatus {
  matched('Matched', AppColors.success, Icons.check_circle_rounded),
  unmatched('Unmatched', AppColors.error, Icons.cancel_rounded),
  partial('Partial', AppColors.warning, Icons.warning_amber_rounded);

  const _MatchStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class _ReconPeriod {
  const _ReconPeriod({
    required this.periodId,
    required this.clientName,
    required this.pan,
    required this.assessmentYear,
    required this.matchedCount,
    required this.unmatchedCount,
    required this.partialCount,
    required this.entries,
  });

  final String periodId;
  final String clientName;
  final String pan;
  final String assessmentYear;
  final int matchedCount;
  final int unmatchedCount;
  final int partialCount;
  final List<_ReconRow> entries;

  int get totalCount => matchedCount + unmatchedCount + partialCount;
}

class _ReconRow {
  const _ReconRow({
    required this.source,
    required this.incomeType,
    required this.booksAmount,
    required this.portalAmount,
    required this.difference,
    required this.status,
  });

  final String source;
  final String incomeType;
  final double booksAmount;
  final double portalAmount;
  final double difference;
  final _MatchStatus status;
}

_ReconPeriod _mockPeriod(String periodId) {
  return _ReconPeriod(
    periodId: periodId,
    clientName: 'Rajesh Sharma',
    pan: 'ABCPS1234K',
    assessmentYear: 'AY 2025-26',
    matchedCount: 8,
    unmatchedCount: 2,
    partialCount: 1,
    entries: const [
      _ReconRow(
        source: 'SBI',
        incomeType: 'Salary',
        booksAmount: 1250000,
        portalAmount: 1250000,
        difference: 0,
        status: _MatchStatus.matched,
      ),
      _ReconRow(
        source: 'HDFC Bank',
        incomeType: 'Interest - Savings',
        booksAmount: 32450,
        portalAmount: 32450,
        difference: 0,
        status: _MatchStatus.matched,
      ),
      _ReconRow(
        source: 'ICICI Bank',
        incomeType: 'Interest - FD',
        booksAmount: 85000,
        portalAmount: 82500,
        difference: 2500,
        status: _MatchStatus.partial,
      ),
      _ReconRow(
        source: 'ABC Ltd',
        incomeType: 'TDS on Salary',
        booksAmount: 125000,
        portalAmount: 125000,
        difference: 0,
        status: _MatchStatus.matched,
      ),
      _ReconRow(
        source: 'Mutual Fund House',
        incomeType: 'Dividend',
        booksAmount: 15000,
        portalAmount: 0,
        difference: 15000,
        status: _MatchStatus.unmatched,
      ),
      _ReconRow(
        source: 'Rental Income',
        incomeType: 'House Property',
        booksAmount: 240000,
        portalAmount: 240000,
        difference: 0,
        status: _MatchStatus.matched,
      ),
      _ReconRow(
        source: 'Equity Broker',
        incomeType: 'Capital Gains (STCG)',
        booksAmount: 45000,
        portalAmount: 0,
        difference: 45000,
        status: _MatchStatus.unmatched,
      ),
      _ReconRow(
        source: 'PPF',
        incomeType: '80C Deduction',
        booksAmount: 150000,
        portalAmount: 150000,
        difference: 0,
        status: _MatchStatus.matched,
      ),
    ],
  );
}

/// Detailed reconciliation view for a specific period showing side-by-side
/// comparison of books vs portal data, with match/unmatch actions.
class ReconciliationDetailScreen extends ConsumerStatefulWidget {
  const ReconciliationDetailScreen({super.key, required this.periodId});

  final String periodId;

  @override
  ConsumerState<ReconciliationDetailScreen> createState() =>
      _ReconciliationDetailScreenState();
}

class _ReconciliationDetailScreenState
    extends ConsumerState<ReconciliationDetailScreen> {
  _MatchStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final period = _mockPeriod(widget.periodId);
    final theme = Theme.of(context);

    final filteredEntries = _filter == null
        ? period.entries
        : period.entries.where((e) => e.status == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reconciliation Detail',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              '${period.clientName} \u2022 ${period.assessmentYear}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting reconciliation report...'),
                ),
              );
            },
          ),
        ],
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
            // Summary row
            _MatchSummaryRow(period: period),
            const SizedBox(height: 14),

            // Filter chips
            _FilterChips(
              active: _filter,
              onSelected: (status) =>
                  setState(() => _filter = _filter == status ? null : status),
            ),
            const SizedBox(height: 14),

            // Column headers
            _ColumnHeaders(theme: theme),
            const SizedBox(height: 6),

            // Entries
            ...filteredEntries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ReconEntryCard(entry: entry),
              ),
            ),

            if (filteredEntries.isEmpty) _EmptyState(filter: _filter),

            const SizedBox(height: 16),

            // Export button
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report exported')),
                );
              },
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('Export Reconciliation Report'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Match summary row
// ---------------------------------------------------------------------------

class _MatchSummaryRow extends StatelessWidget {
  const _MatchSummaryRow({required this.period});

  final _ReconPeriod period;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryChip(
          label: 'Total',
          value: '${period.totalCount}',
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Matched',
          value: '${period.matchedCount}',
          color: AppColors.success,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Partial',
          value: '${period.partialCount}',
          color: AppColors.warning,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Unmatched',
          value: '${period.unmatchedCount}',
          color: AppColors.error,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color.withAlpha(180),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips
// ---------------------------------------------------------------------------

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.active, required this.onSelected});

  final _MatchStatus? active;
  final ValueChanged<_MatchStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _MatchStatus.values.map((status) {
          final isActive = active == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status.icon,
                    size: 14,
                    color: isActive ? Colors.white : status.color,
                  ),
                  const SizedBox(width: 4),
                  Text(status.label),
                ],
              ),
              selected: isActive,
              selectedColor: status.color,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.neutral600,
              ),
              onSelected: (_) => onSelected(status),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Column headers
// ---------------------------------------------------------------------------

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final style = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.neutral400,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('', style: style)),
          Expanded(flex: 2, child: Text('Source / Type', style: style)),
          Expanded(
            child: Text('Books', style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            child: Text('Portal', style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            child: Text('Diff', style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reconciliation entry card
// ---------------------------------------------------------------------------

class _ReconEntryCard extends StatelessWidget {
  const _ReconEntryCard({required this.entry});

  final _ReconRow entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.status.color.withAlpha(6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: entry.status.color.withAlpha(25)),
      ),
      child: Row(
        children: [
          Icon(entry.status.icon, size: 20, color: entry.status.color),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.source,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  entry.incomeType,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              _formatAmount(entry.booksAmount),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              _formatAmount(entry.portalAmount),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              entry.difference == 0 ? '-' : _formatAmount(entry.difference),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: entry.difference == 0
                    ? AppColors.neutral400
                    : entry.status.color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '\u20B9${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\u20B9${amount.toStringAsFixed(0)}';
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.filter});

  final _MatchStatus? filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.playlist_add_check_rounded,
              size: 48,
              color: AppColors.neutral200,
            ),
            const SizedBox(height: 12),
            Text(
              filter != null
                  ? 'No ${filter!.label.toLowerCase()} entries'
                  : 'No entries found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
