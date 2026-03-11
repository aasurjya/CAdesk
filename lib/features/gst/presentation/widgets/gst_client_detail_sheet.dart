import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../data/providers/gst_providers.dart';
import '../../domain/models/gst_client.dart';
import '../../domain/models/gst_return.dart';
import '../../domain/models/itc_reconciliation.dart';

/// Formats a 15-character GSTIN as XX-XXXXXXXXXX-X-XX for readability.
String _fmtGstin(String gstin) {
  if (gstin.length != 15) return gstin;
  return '${gstin.substring(0, 2)}-${gstin.substring(2, 12)}-'
      '${gstin.substring(12, 13)}-${gstin.substring(13)}';
}

/// Formats a rupee amount in compact lakh notation, e.g. ₹8.45L.
String _fmtLakh(double amount) {
  final lakhs = amount / 100000;
  return '₹${lakhs.toStringAsFixed(2)}L';
}

/// Draggable bottom sheet showing per-client return history and ITC
/// reconciliation details.
class GstClientDetailSheet extends ConsumerStatefulWidget {
  const GstClientDetailSheet({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<GstClientDetailSheet> createState() =>
      _GstClientDetailSheetState();
}

class _GstClientDetailSheetState extends ConsumerState<GstClientDetailSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(gstClientsProvider);
    final client = clients.firstWhere(
      (c) => c.id == widget.clientId,
      orElse: () => const GstClient(
        id: '',
        businessName: 'Unknown',
        gstin: '000000000000000',
        pan: 'AAAAA0000A',
        registrationType: GstRegistrationType.regular,
        state: '',
        stateCode: '00',
      ),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header section
            _ClientHeader(client: client),

            // Tab bar
            TabBar(
              controller: _tabs,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.neutral400,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Returns'),
                Tab(text: 'ITC Reconciliation'),
              ],
            ),

            const Divider(height: 1, color: AppColors.neutral200),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _ReturnsTab(
                    clientId: widget.clientId,
                    scrollController: scrollController,
                  ),
                  _ItcReconTab(
                    clientId: widget.clientId,
                    scrollController: scrollController,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.client});

  final GstClient client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = client.complianceScore;
    final scoreColor = score >= 80
        ? AppColors.success
        : score >= 60
            ? AppColors.warning
            : AppColors.error;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compliance score ring
          _ComplianceRing(score: score, color: scoreColor),
          const SizedBox(width: 16),

          // Name + GSTIN + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.businessName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _fmtGstin(client.gstin),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                _RegistrationBadge(type: client.registrationType),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceRing extends StatelessWidget {
  const _ComplianceRing({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 5,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationBadge extends StatelessWidget {
  const _RegistrationBadge({required this.type});

  final GstRegistrationType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryVariant.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryVariant,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Returns tab
// ---------------------------------------------------------------------------

class _ReturnsTab extends ConsumerWidget {
  const _ReturnsTab({
    required this.clientId,
    required this.scrollController,
  });

  final String clientId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReturns = ref.watch(gstReturnsProvider);
    final clientReturns = allReturns
        .where((r) => r.clientId == clientId)
        .toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

    if (clientReturns.isEmpty) {
      return const Center(
        child: Text(
          'No returns found',
          style: TextStyle(color: AppColors.neutral400),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: clientReturns.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _ReturnCard(gstReturn: clientReturns[index], context: context);
      },
    );
  }
}

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({required this.gstReturn, required this.context});

  final GstReturn gstReturn;
  final BuildContext context;

  @override
  Widget build(BuildContext buildContext) {
    final now = DateTime(2026, 3, 10);
    final r = gstReturn;
    final isPending = r.status == GstReturnStatus.pending;
    final isLateFiled = r.status == GstReturnStatus.lateFiled;

    final int daysLate;
    if (isLateFiled && r.filedDate != null) {
      daysLate = r.filedDate!.difference(r.dueDate).inDays;
    } else if (isPending && r.dueDate.isBefore(now)) {
      daysLate = now.difference(r.dueDate).inDays;
    } else {
      daysLate = 0;
    }

    final double lateFee = daysLate > 0
        ? LateFeesCalculator.calculateLateFee(
            daysLate: daysLate,
            isNilReturn: r.totalTax == 0,
            returnType: r.returnType,
          )
        : 0;

    final statusColor = _statusColor(r.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Return type chip
              _Chip(
                label: r.returnType.label,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                r.periodLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              const Spacer(),
              // Status chip
              _Chip(label: r.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),

          // Due date
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 14,
                color: daysLate > 0 ? AppColors.error : AppColors.neutral400,
              ),
              const SizedBox(width: 4),
              Text(
                'Due: ${DateFormat('d MMM yyyy').format(r.dueDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: daysLate > 0 ? AppColors.error : AppColors.neutral400,
                  fontWeight:
                      daysLate > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (daysLate > 0 && isPending) ...[
                const SizedBox(width: 6),
                Text(
                  '($daysLate days overdue)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),

          // Late fee row
          if (lateFee > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  'Late fee: ₹${lateFee.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // File Now button for pending returns
          if (isPending) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(buildContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${r.returnType.label} filing initiated for '
                        '${r.periodLabel}',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file_rounded, size: 16),
                label: const Text('File Now'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(GstReturnStatus status) {
    switch (status) {
      case GstReturnStatus.filed:
        return AppColors.success;
      case GstReturnStatus.pending:
        return AppColors.warning;
      case GstReturnStatus.lateFiled:
        return AppColors.error;
      case GstReturnStatus.notApplicable:
        return AppColors.neutral400;
    }
  }
}

// ---------------------------------------------------------------------------
// ITC Reconciliation tab
// ---------------------------------------------------------------------------

class _ItcReconTab extends ConsumerWidget {
  const _ItcReconTab({
    required this.clientId,
    required this.scrollController,
  });

  final String clientId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recon = ref.watch(itcReconForClientProvider(clientId));

    if (recon == null) {
      return const Center(
        child: Text(
          'No ITC reconciliation data found',
          style: TextStyle(color: AppColors.neutral400),
        ),
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _ItcReconCard(recon: recon),
      ],
    );
  }
}

class _ItcReconCard extends StatelessWidget {
  const _ItcReconCard({required this.recon});

  final ItcReconciliation recon;

  Color _differenceColor(double pct) {
    if (pct >= 2.0) return AppColors.error;
    if (pct >= 1.0) return AppColors.warning;
    return AppColors.success;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Reconciled':
        return AppColors.success;
      case 'Escalated':
        return AppColors.error;
      case 'In Progress':
        return AppColors.warning;
      default:
        return AppColors.neutral400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diffPct = recon.differencePercent;
    final diffColor = _differenceColor(diffPct);
    final showActionButton =
        recon.status == 'Pending' || recon.status == 'In Progress';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period + status row
        Row(
          children: [
            Text(
              'Period: ${recon.period}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            const Spacer(),
            _Chip(label: recon.status, color: _statusColor(recon.status)),
          ],
        ),
        const SizedBox(height: 16),

        // 2A vs Books side-by-side
        Row(
          children: [
            Expanded(
              child: _AmountBox(
                label: 'GSTR-2A ITC',
                amount: recon.gstr2aItc,
                color: AppColors.primaryVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AmountBox(
                label: 'Books ITC',
                amount: recon.booksItc,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Difference
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: diffColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: diffColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(
                diffPct < 1.0
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                size: 16,
                color: diffColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Difference: ${_fmtLakh((recon.booksItc - recon.gstr2aItc).abs())} '
                '(${diffPct.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: diffColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Breakdown
        const Text(
          'Breakdown',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _BreakdownRow(
          label: 'Matched',
          amount: recon.matchedItc,
          color: AppColors.success,
        ),
        const SizedBox(height: 6),
        _BreakdownRow(
          label: 'Mismatched',
          amount: recon.mismatchedItc,
          color: AppColors.warning,
        ),
        const SizedBox(height: 6),
        _BreakdownRow(
          label: 'Missing in Books',
          amount: recon.missingInBooks,
          color: AppColors.error,
        ),
        const SizedBox(height: 6),
        _BreakdownRow(
          label: 'Missing in 2A',
          amount: recon.missingIn2A,
          color: AppColors.error,
        ),

        if (showActionButton) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ITC reconciliation workflow opened'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.sync_rounded, size: 18),
              label: Text(
                recon.status == 'In Progress'
                    ? 'Continue Reconciliation'
                    : 'Start Reconciliation',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AmountBox extends StatelessWidget {
  const _AmountBox({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _fmtLakh(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
        Text(
          _fmtLakh(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared chip widget
// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
