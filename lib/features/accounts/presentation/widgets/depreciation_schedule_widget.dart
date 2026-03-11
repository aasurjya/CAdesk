import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../../data/providers/accounts_providers.dart';
import '../../domain/models/depreciation_entry.dart';

/// Widget displaying a WDV depreciation schedule for a list of asset blocks.
///
/// Shows a scrollable table with totals row, computed via [DepreciationCalculator].
class DepreciationScheduleWidget extends StatelessWidget {
  const DepreciationScheduleWidget({
    super.key,
    required this.entries,
    required this.clientName,
    required this.financialYear,
  });

  final List<DepreciationEntry> entries;
  final String clientName;
  final String financialYear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return _buildEmpty(context);
    }

    final totalOpeningWdv =
        entries.fold<double>(0, (s, e) => s + e.openingWDV);
    final totalAdditions =
        entries.fold<double>(0, (s, e) => s + e.additions);
    final totalDisposals =
        entries.fold<double>(0, (s, e) => s + e.disposals);
    final totalDepreciation =
        entries.fold<double>(0, (s, e) => s + e.depreciation);
    final totalClosingWdv =
        entries.fold<double>(0, (s, e) => s + e.closingWDV);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Depreciation Schedule',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$clientName  •  $financialYear  •  WDV Method',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),

        // Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column headers
              _TableHeaderRow(),

              const Divider(height: 1, color: AppColors.neutral200),

              // Data rows
              ...entries.map(
                (e) => _TableDataRow(entry: e, isEven: entries.indexOf(e).isEven),
              ),

              const Divider(height: 1, color: AppColors.primary),

              // Totals row
              _TableTotalRow(
                openingWdv: totalOpeningWdv,
                additions: totalAdditions,
                disposals: totalDisposals,
                depreciation: totalDepreciation,
                closingWdv: totalClosingWdv,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No depreciation entries for this client.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Table sub-widgets
// ---------------------------------------------------------------------------

/// Column widths (fixed) for the depreciation schedule table.
const double _colAsset = 160;
const double _colRate = 52;
const double _colAmount = 86;

class _TableHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Row(
        children: const [
          _HeaderCell(label: 'Asset Block', width: _colAsset, align: TextAlign.left),
          _HeaderCell(label: 'Opening\nWDV', width: _colAmount),
          _HeaderCell(label: 'Additions', width: _colAmount),
          _HeaderCell(label: 'Disposals', width: _colAmount),
          _HeaderCell(label: 'Rate\n(%)', width: _colRate),
          _HeaderCell(label: 'Deprecia-\ntion', width: _colAmount),
          _HeaderCell(label: 'Closing\nWDV', width: _colAmount),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.width,
    this.align = TextAlign.right,
  });

  final String label;
  final double width;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Text(
          label,
          textAlign: align,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  const _TableDataRow({
    required this.entry,
    required this.isEven,
  });

  final DepreciationEntry entry;
  final bool isEven;

  @override
  Widget build(BuildContext context) {
    final bgColor = isEven ? AppColors.neutral50 : AppColors.surface;

    return Container(
      color: bgColor,
      child: Row(
        children: [
          _DataCell(
            text: '${entry.assetName}\n(${entry.assetBlock.label})',
            width: _colAsset,
            align: TextAlign.left,
            color: AppColors.neutral900,
            bold: false,
          ),
          _DataCell(
            text: CurrencyUtils.formatINRCompact(entry.openingWDV),
            width: _colAmount,
          ),
          _DataCell(
            text: entry.additions > 0
                ? CurrencyUtils.formatINRCompact(entry.additions)
                : '—',
            width: _colAmount,
            color: entry.additions > 0 ? AppColors.success : AppColors.neutral400,
          ),
          _DataCell(
            text: entry.disposals > 0
                ? CurrencyUtils.formatINRCompact(entry.disposals)
                : '—',
            width: _colAmount,
            color: entry.disposals > 0 ? AppColors.error : AppColors.neutral400,
          ),
          _DataCell(
            text: '${entry.rate.toStringAsFixed(0)}%',
            width: _colRate,
            color: AppColors.accent,
          ),
          _DataCell(
            text: CurrencyUtils.formatINRCompact(entry.depreciation),
            width: _colAmount,
            color: AppColors.warning,
          ),
          _DataCell(
            text: CurrencyUtils.formatINRCompact(entry.closingWDV),
            width: _colAmount,
            color: AppColors.primary,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.text,
    required this.width,
    this.align = TextAlign.right,
    this.color = AppColors.neutral600,
    this.bold = false,
  });

  final String text;
  final double width;
  final TextAlign align;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontSize: 11,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: color,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

class _TableTotalRow extends StatelessWidget {
  const _TableTotalRow({
    required this.openingWdv,
    required this.additions,
    required this.disposals,
    required this.depreciation,
    required this.closingWdv,
  });

  final double openingWdv;
  final double additions;
  final double disposals;
  final double depreciation;
  final double closingWdv;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Row(
        children: [
          _TotalCell(text: 'TOTAL', width: _colAsset, align: TextAlign.left),
          _TotalCell(
            text: CurrencyUtils.formatINRCompact(openingWdv),
            width: _colAmount,
          ),
          _TotalCell(
            text: CurrencyUtils.formatINRCompact(additions),
            width: _colAmount,
          ),
          _TotalCell(
            text: CurrencyUtils.formatINRCompact(disposals),
            width: _colAmount,
          ),
          const _TotalCell(text: '', width: _colRate),
          _TotalCell(
            text: CurrencyUtils.formatINRCompact(depreciation),
            width: _colAmount,
            color: AppColors.warning,
          ),
          _TotalCell(
            text: CurrencyUtils.formatINRCompact(closingWdv),
            width: _colAmount,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _TotalCell extends StatelessWidget {
  const _TotalCell({
    required this.text,
    required this.width,
    this.align = TextAlign.right,
    this.color = AppColors.neutral900,
  });

  final String text;
  final double width;
  final TextAlign align;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}
