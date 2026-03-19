import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _TdsEntry {
  const _TdsEntry({
    required this.deductorName,
    required this.tan,
    required this.section,
    required this.amountPaid,
    required this.tdsDeducted,
    required this.quarter,
    required this.bookAmount,
  });

  final String deductorName;
  final String tan;
  final String section;
  final double amountPaid;
  final double tdsDeducted;
  final String quarter;
  final double bookAmount;

  bool get hasMismatch => (tdsDeducted - bookAmount).abs() > 1;
}

class _Form26ASSummary {
  const _Form26ASSummary({
    required this.totalTds,
    required this.totalTcs,
    required this.advanceTax,
    required this.selfAssessmentTax,
    required this.refundReceived,
  });

  final double totalTds;
  final double totalTcs;
  final double advanceTax;
  final double selfAssessmentTax;
  final double refundReceived;
}

class _DownloadStatus {
  const _DownloadStatus({
    required this.formType,
    required this.status,
    required this.lastDownloaded,
  });

  final String formType;
  final String status;
  final String lastDownloaded;
}

class _TracesDetail {
  const _TracesDetail({
    required this.panId,
    required this.panHolder,
    required this.assessmentYear,
    required this.summary,
    required this.tdsEntries,
    required this.downloads,
    required this.mismatchCount,
  });

  final String panId;
  final String panHolder;
  final String assessmentYear;
  final _Form26ASSummary summary;
  final List<_TdsEntry> tdsEntries;
  final List<_DownloadStatus> downloads;
  final int mismatchCount;
}

const _mockTraces = _TracesDetail(
  panId: 'AAAPZ1234C',
  panHolder: 'Pinnacle Infotech Solutions Pvt Ltd',
  assessmentYear: 'AY 2026-27',
  summary: _Form26ASSummary(
    totalTds: 845000,
    totalTcs: 12500,
    advanceTax: 500000,
    selfAssessmentTax: 125000,
    refundReceived: 0,
  ),
  tdsEntries: [
    _TdsEntry(
      deductorName: 'Sunrise Technologies Pvt Ltd',
      tan: 'MUMS12345A',
      section: '194J',
      amountPaid: 1200000,
      tdsDeducted: 120000,
      quarter: 'Q3',
      bookAmount: 120000,
    ),
    _TdsEntry(
      deductorName: 'Greenfield Exports Ltd',
      tan: 'DELG98765B',
      section: '194C',
      amountPaid: 850000,
      tdsDeducted: 17000,
      quarter: 'Q2',
      bookAmount: 18500,
    ),
    _TdsEntry(
      deductorName: 'Meridian Steel Industries',
      tan: 'MUMM54321C',
      section: '194J',
      amountPaid: 500000,
      tdsDeducted: 50000,
      quarter: 'Q1',
      bookAmount: 50000,
    ),
    _TdsEntry(
      deductorName: 'National Insurance Co Ltd',
      tan: 'CALN11111D',
      section: '194A',
      amountPaid: 320000,
      tdsDeducted: 32000,
      quarter: 'Q4',
      bookAmount: 28000,
    ),
  ],
  downloads: [
    _DownloadStatus(
      formType: 'Form 26AS',
      status: 'Downloaded',
      lastDownloaded: '10 Mar 2026',
    ),
    _DownloadStatus(
      formType: 'Form 16',
      status: 'Not Available',
      lastDownloaded: '-',
    ),
    _DownloadStatus(
      formType: 'Form 16A',
      status: 'Pending',
      lastDownloaded: '-',
    ),
  ],
  mismatchCount: 2,
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// TRACES detail screen showing Form 26AS summary, party-wise TDS,
/// mismatch highlights, and download statuses.
///
/// Route: `/traces/detail/:panId`
class TracesDetailScreen extends ConsumerWidget {
  const TracesDetailScreen({required this.panId, super.key});

  final String panId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const t = _mockTraces;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('TRACES \u2022 ${t.panId}'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {},
            tooltip: 'Refresh from TRACES',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PAN holder info
          const _PanInfoCard(traces: t),
          const SizedBox(height: 12),

          // Form 26AS summary
          Row(
            children: [
              SummaryCard(
                label: 'Total TDS',
                value: _fmt(t.summary.totalTds),
                icon: Icons.receipt_long_rounded,
                color: AppColors.primary,
              ),
              SummaryCard(
                label: 'TCS',
                value: _fmt(t.summary.totalTcs),
                icon: Icons.receipt_rounded,
                color: AppColors.secondary,
              ),
              SummaryCard(
                label: 'Advance Tax',
                value: _fmt(t.summary.advanceTax),
                icon: Icons.payments_rounded,
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Party-wise TDS
          SectionHeader(
            title: 'Party-wise TDS',
            icon: Icons.people_outline_rounded,
            trailing: t.mismatchCount > 0
                ? StatusBadge(
                    label: '${t.mismatchCount} mismatches',
                    color: AppColors.error,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          ...t.tdsEntries.map((entry) => _TdsEntryCard(entry: entry)),
          const SizedBox(height: 20),

          // Download statuses
          const SectionHeader(
            title: 'Download Status',
            icon: Icons.download_rounded,
          ),
          const SizedBox(height: 8),
          ...t.downloads.map((d) => _DownloadRow(download: d)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static String _fmt(double amount) {
    if (amount >= 100000) {
      return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) return '\u20B9${(amount / 1000).toStringAsFixed(1)}K';
    return '\u20B9${amount.toStringAsFixed(0)}';
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _PanInfoCard extends StatelessWidget {
  const _PanInfoCard({required this.traces});

  final _TracesDetail traces;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              traces.panHolder,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                StatusBadge(label: traces.panId, color: AppColors.primary),
                const SizedBox(width: 8),
                StatusBadge(
                  label: traces.assessmentYear,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TdsEntryCard extends StatelessWidget {
  const _TdsEntryCard({required this.entry});

  final _TdsEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: entry.hasMismatch
              ? AppColors.error.withAlpha(40)
              : AppColors.neutral200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.deductorName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (entry.hasMismatch)
                  const StatusBadge(label: 'Mismatch', color: AppColors.error),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                StatusBadge(
                  label: 'Sec ${entry.section}',
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                StatusBadge(label: entry.quarter, color: AppColors.neutral400),
                const SizedBox(width: 6),
                Text(
                  'TAN: ${entry.tan}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricCol(label: 'Amount Paid', value: _fmt(entry.amountPaid)),
                _MetricCol(label: 'TDS (26AS)', value: _fmt(entry.tdsDeducted)),
                _MetricCol(
                  label: 'TDS (Books)',
                  value: _fmt(entry.bookAmount),
                  highlight: entry.hasMismatch,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(double amt) {
    if (amt >= 100000) return '\u20B9${(amt / 100000).toStringAsFixed(2)}L';
    if (amt >= 1000) return '\u20B9${(amt / 1000).toStringAsFixed(1)}K';
    return '\u20B9${amt.toStringAsFixed(0)}';
  }
}

class _MetricCol extends StatelessWidget {
  const _MetricCol({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: highlight ? AppColors.error : AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
        ),
      ],
    );
  }
}

class _DownloadRow extends StatelessWidget {
  const _DownloadRow({required this.download});

  final _DownloadStatus download;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (download.status) {
      'Downloaded' => AppColors.success,
      'Pending' => AppColors.warning,
      _ => AppColors.neutral400,
    };

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.description_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    download.formType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral900,
                    ),
                  ),
                  if (download.lastDownloaded != '-')
                    Text(
                      'Last: ${download.lastDownloaded}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral400,
                      ),
                    ),
                ],
              ),
            ),
            StatusBadge(label: download.status, color: statusColor),
          ],
        ),
      ),
    );
  }
}
