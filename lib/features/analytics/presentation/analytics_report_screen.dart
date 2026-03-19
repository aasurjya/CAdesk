import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

enum _Metric { revenue, clients, compliance, billing, tasks }

extension _MetricExt on _Metric {
  String get label => switch (this) {
    _Metric.revenue => 'Revenue',
    _Metric.clients => 'Clients',
    _Metric.compliance => 'Compliance',
    _Metric.billing => 'Billing',
    _Metric.tasks => 'Tasks',
  };
  IconData get icon => switch (this) {
    _Metric.revenue => Icons.attach_money_rounded,
    _Metric.clients => Icons.people_rounded,
    _Metric.compliance => Icons.verified_rounded,
    _Metric.billing => Icons.receipt_long_rounded,
    _Metric.tasks => Icons.task_alt_rounded,
  };
}

enum _ChartType { bar, line, pie }

extension _ChartTypeExt on _ChartType {
  String get label => switch (this) {
    _ChartType.bar => 'Bar',
    _ChartType.line => 'Line',
    _ChartType.pie => 'Pie',
  };
  IconData get icon => switch (this) {
    _ChartType.bar => Icons.bar_chart_rounded,
    _ChartType.line => Icons.show_chart_rounded,
    _ChartType.pie => Icons.pie_chart_rounded,
  };
}

enum _TimePeriod { thisMonth, thisQuarter, thisYear, custom }

extension _TimePeriodExt on _TimePeriod {
  String get label => switch (this) {
    _TimePeriod.thisMonth => 'This Month',
    _TimePeriod.thisQuarter => 'This Quarter',
    _TimePeriod.thisYear => 'This Year',
    _TimePeriod.custom => 'Custom',
  };
}

// ---------------------------------------------------------------------------
// Mock table data
// ---------------------------------------------------------------------------

class _ReportRow {
  const _ReportRow({
    required this.label,
    required this.value,
    required this.change,
    required this.trend,
  });

  final String label;
  final String value;
  final String change;
  final bool trend; // true = up
}

const _mockRows = <_ReportRow>[
  _ReportRow(label: 'ITR Filing', value: '4.2L', change: '+12%', trend: true),
  _ReportRow(label: 'GST Filing', value: '3.8L', change: '+8%', trend: true),
  _ReportRow(label: 'Audit', value: '2.1L', change: '-3%', trend: false),
  _ReportRow(label: 'TDS Returns', value: '1.5L', change: '+5%', trend: true),
  _ReportRow(label: 'Bookkeeping', value: '1.2L', change: '+15%', trend: true),
  _ReportRow(label: 'Payroll', value: '0.9L', change: '-1%', trend: false),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Custom analytics report builder screen.
class AnalyticsReportScreen extends ConsumerStatefulWidget {
  const AnalyticsReportScreen({super.key});

  @override
  ConsumerState<AnalyticsReportScreen> createState() =>
      _AnalyticsReportScreenState();
}

class _AnalyticsReportScreenState extends ConsumerState<AnalyticsReportScreen> {
  var _selectedMetrics = <_Metric>{_Metric.revenue, _Metric.clients};
  var _chartType = _ChartType.bar;
  var _timePeriod = _TimePeriod.thisQuarter;
  var _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Builder',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Custom analytics report',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export',
            onSelected: (value) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Exporting as $value...')));
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'PDF', child: Text('Export PDF')),
              PopupMenuItem(value: 'Excel', child: Text('Export Excel')),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -- Metric selector --
          const SectionHeader(title: 'Metrics', icon: Icons.tune_rounded),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _Metric.values.map((m) {
              final isActive = _selectedMetrics.contains(m);
              return FilterChip(
                label: Text(m.label),
                avatar: Icon(m.icon, size: 16),
                selected: isActive,
                onSelected: (_) {
                  setState(() {
                    _selectedMetrics = isActive
                        ? (Set<_Metric>.of(_selectedMetrics)..remove(m))
                        : (Set<_Metric>.of(_selectedMetrics)..add(m));
                  });
                },
                selectedColor: AppColors.primary.withAlpha(30),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // -- Time period --
          const SectionHeader(
            title: 'Time Period',
            icon: Icons.date_range_rounded,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _TimePeriod.values.map((p) {
              final isActive = _timePeriod == p;
              return ChoiceChip(
                label: Text(p.label),
                selected: isActive,
                onSelected: (_) => setState(() => _timePeriod = p),
                selectedColor: AppColors.primary.withAlpha(30),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // -- Chart type --
          const SectionHeader(
            title: 'Visualization',
            icon: Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 8),
          Row(
            children: _ChartType.values.map((ct) {
              final isActive = _chartType == ct;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  avatar: Icon(ct.icon, size: 16),
                  label: Text(ct.label),
                  selected: isActive,
                  onSelected: (_) => setState(() => _chartType = ct),
                  selectedColor: AppColors.secondary.withAlpha(30),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // -- Chart placeholder --
          _ChartPlaceholder(chartType: _chartType),
          const SizedBox(height: 24),

          // -- Data table --
          SectionHeader(
            title: 'Data Table',
            icon: Icons.table_chart_rounded,
            trailing: IconButton(
              icon: Icon(
                _sortAsc
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 18,
              ),
              onPressed: () => setState(() => _sortAsc = !_sortAsc),
              tooltip: _sortAsc ? 'Sort descending' : 'Sort ascending',
            ),
          ),
          const SizedBox(height: 8),
          _DataTable(rows: _mockRows, sortAsc: _sortAsc),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chart placeholder
// ---------------------------------------------------------------------------

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.chartType});

  final _ChartType chartType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(chartType.icon, size: 48, color: AppColors.neutral300),
              const SizedBox(height: 8),
              Text(
                '${chartType.label} chart will render here',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Powered by fl_chart',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data table
// ---------------------------------------------------------------------------

class _DataTable extends StatelessWidget {
  const _DataTable({required this.rows, required this.sortAsc});

  final List<_ReportRow> rows;
  final bool sortAsc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<_ReportRow>.of(rows)
      ..sort(
        (a, b) =>
            sortAsc ? a.label.compareTo(b.label) : b.label.compareTo(a.label),
      );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header
            const Row(
              children: [
                _ColHeader(label: 'Service', flex: 3),
                _ColHeader(label: 'Value', flex: 2),
                _ColHeader(label: 'Change', flex: 2),
              ],
            ),
            const Divider(height: 16),
            ...sorted.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(
                            row.trend
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 14,
                            color: row.trend
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            row.change,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: row.trend
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader({required this.label, required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.neutral400,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
