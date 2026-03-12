import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/litigation/data/providers/litigation_providers.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/presentation/widgets/triage_result_card.dart';
import 'package:ca_app/features/litigation/presentation/widgets/urgency_badge.dart';

/// Detail view for a [TaxNotice]. Receives the notice via GoRouter extra.
class NoticeDetailScreen extends ConsumerWidget {
  const NoticeDetailScreen({required this.notice, super.key});

  final TaxNotice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final triageMap = ref.watch(triageResultsProvider);
    final triage = triageMap[notice.noticeId];
    final urgency = urgencyOf(notice);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notice Detail',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notice header card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _TypeBadge(noticeType: notice.noticeType),
                      ),
                      UrgencyBadge(urgency: urgency),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Assessment Year', value: notice.assessmentYear),
                  _DetailRow(label: 'Section', value: notice.section),
                  _DetailRow(label: 'Issued By', value: notice.issuedBy),
                  _DetailRow(
                    label: 'Issued Date',
                    value: _formatDate(notice.issuedDate),
                  ),
                  _DetailRow(
                    label: 'Response Deadline',
                    value: _formatDate(notice.responseDeadline),
                    valueColor: theme.colorScheme.error,
                  ),
                  _DetailRow(label: 'PAN', value: notice.pan),
                  _DetailRow(
                    label: 'Status',
                    value: _statusLabel(notice.status),
                  ),
                  if (notice.demandAmount != null) ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Demand Amount',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatPaise(notice.demandAmount!),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Triage result
          if (triage != null) ...[
            Text(
              'AI Triage Analysis',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TriageResultCard(result: triage),
            const SizedBox(height: 24),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(
                    '/litigation/response',
                    extra: notice,
                  ),
                  icon: const Icon(Icons.edit_document),
                  label: const Text('Draft Response'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/litigation/appeal'),
                  icon: const Icon(Icons.gavel),
                  label: const Text('Track Appeal'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  /// Converts paise to ₹X,XX,XXX format.
  static String _formatPaise(int paise) {
    final rupees = paise ~/ 100;
    return '₹${_formatIndian(rupees)}';
  }

  static String _formatIndian(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '${buf.toString()},$last3';
  }

  static String _statusLabel(NoticeStatus status) {
    return switch (status) {
      NoticeStatus.received => 'Received',
      NoticeStatus.underReview => 'Under Review',
      NoticeStatus.responseDrafted => 'Response Drafted',
      NoticeStatus.responseFiled => 'Response Filed',
      NoticeStatus.resolved => 'Resolved',
      NoticeStatus.appealed => 'Appealed',
    };
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.noticeType});
  final NoticeType noticeType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label(noticeType),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static String _label(NoticeType type) {
    return switch (type) {
      NoticeType.intimation143_1 => 'Intimation 143(1)',
      NoticeType.scrutiny143_2 => 'Scrutiny 143(2)',
      NoticeType.assessment143_3 => 'Assessment 143(3)',
      NoticeType.reopening148 => 'Reopening u/s 148',
      NoticeType.penalty156 => 'Penalty/Demand 156',
      NoticeType.showCause => 'Show-Cause Notice',
      NoticeType.highPitchAssessment => 'High-Pitched Assessment',
      NoticeType.searchSeizure => 'Search & Seizure',
    };
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
