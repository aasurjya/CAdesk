import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/gstn_api/data/providers/gstn_api_providers.dart';
import 'package:ca_app/features/gstn_api/presentation/widgets/gstin_result_card.dart';

/// GSTN API dashboard: GSTIN lookup, filing status, GSTR-2B, API quota.
class GstnApiScreen extends ConsumerWidget {
  const GstnApiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(gstnApiQuotaProvider);
    final searchResult = ref.watch(gstinSearchResultProvider);
    final filingStatus = ref.watch(gstnFilingStatusProvider);
    final gstr2b = ref.watch(gstr2bResultProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GSTN API',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'GST Network integration hub',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
            _ApiQuotaMeter(quota: quota),
            const SizedBox(height: 20),
            const _SectionHeader(
              title: 'GSTIN Lookup',
              icon: Icons.search_rounded,
            ),
            const SizedBox(height: 10),
            _GstinQuickSearch(onSearch: () => context.go('/gstn-api/search')),
            const SizedBox(height: 8),
            searchResult.when(
              data: (result) {
                if (result == null) return const SizedBox.shrink();
                return GstinResultCard(result: result);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => _ErrorCard(message: e.toString()),
            ),
            const SizedBox(height: 20),
            const _SectionHeader(
              title: 'Filing Status',
              icon: Icons.fact_check_rounded,
            ),
            const SizedBox(height: 10),
            _FilingStatusCard(filingStatus: filingStatus),
            const SizedBox(height: 20),
            const _SectionHeader(
              title: 'GSTR-2B ITC',
              icon: Icons.receipt_long_rounded,
            ),
            const SizedBox(height: 10),
            _Gstr2bCard(gstr2b: gstr2b, ref: ref),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// API quota meter
// ---------------------------------------------------------------------------

class _ApiQuotaMeter extends StatelessWidget {
  const _ApiQuotaMeter({required this.quota});

  final GstnApiQuota quota;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = quota.usagePercent > 0.8
        ? AppColors.error
        : quota.usagePercent > 0.5
        ? AppColors.warning
        : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(8), color.withAlpha(4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'API Usage',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                '${quota.used} / ${quota.total}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: quota.usagePercent,
              minHeight: 8,
              backgroundColor: AppColors.neutral100,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${quota.remaining} requests remaining',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GSTIN quick search (navigates to search screen)
// ---------------------------------------------------------------------------

class _GstinQuickSearch extends StatelessWidget {
  const _GstinQuickSearch({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onSearch,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppColors.neutral400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Enter 15-character GSTIN to search...',
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

// ---------------------------------------------------------------------------
// Filing status card
// ---------------------------------------------------------------------------

class _FilingStatusCard extends StatelessWidget {
  const _FilingStatusCard({required this.filingStatus});

  final AsyncValue filingStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check return filing status for any GSTIN.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 12),
            filingStatus.when(
              data: (result) {
                if (result == null) {
                  return Text(
                    'No status checked yet',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  );
                }
                return const Text('Status loaded');
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorCard(message: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GSTR-2B card
// ---------------------------------------------------------------------------

class _Gstr2bCard extends StatelessWidget {
  const _Gstr2bCard({required this.gstr2b, required this.ref});

  final AsyncValue gstr2b;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auto-drafted ITC statement from GSTN',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 12),
            gstr2b.when(
              data: (result) {
                if (result == null) {
                  return OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(gstr2bResultProvider.notifier)
                          .fetch('27AADCR0000A1Z5', '032024');
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Fetch GSTR-2B'),
                  );
                }
                return _Gstr2bSummary(result: result);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorCard(message: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _Gstr2bSummary extends StatelessWidget {
  const _Gstr2bSummary({required this.result});

  final dynamic result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // result is Gstr2bFetchResult from the provider
    final totalCredit = result.totalCredit as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total ITC: ${_formatPaise(totalCredit)}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'IGST: ${_formatPaise(result.totalIgstCredit as int)} | '
          'CGST: ${_formatPaise(result.totalCgstCredit as int)} | '
          'SGST: ${_formatPaise(result.totalSgstCredit as int)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${result.entryCount} supplier entries',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Format paise to INR with Indian grouping (XX,XX,XXX).
String _formatPaise(int paise) {
  final rupees = paise ~/ 100;
  final paisePart = (paise % 100).toString().padLeft(2, '0');
  final formatted = _indianGrouping(rupees);
  return '\u20B9$formatted.$paisePart';
}

String _indianGrouping(int value) {
  if (value < 0) return '-${_indianGrouping(-value)}';
  final str = value.toString();
  if (str.length <= 3) return str;

  final lastThree = str.substring(str.length - 3);
  var remaining = str.substring(0, str.length - 3);
  final buffer = StringBuffer();
  while (remaining.length > 2) {
    buffer.write(remaining.substring(0, remaining.length - 2));
    buffer.write(',');
    remaining = remaining.substring(remaining.length - 2);
  }
  if (remaining.isNotEmpty) {
    buffer.write(remaining);
    buffer.write(',');
  }
  buffer.write(lastThree);

  // Fix double comma issue for small numbers
  var result = buffer.toString();
  if (result.startsWith(',')) {
    result = result.substring(1);
  }
  return result;
}
