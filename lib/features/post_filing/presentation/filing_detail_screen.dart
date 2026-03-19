import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/post_filing/data/providers/post_filing_providers.dart';
import 'package:ca_app/features/post_filing/domain/models/filing_status.dart';
import 'package:ca_app/features/post_filing/presentation/widgets/filing_status_tile.dart';
import 'package:ca_app/features/post_filing/presentation/widgets/status_timeline.dart';

/// Detail screen for a single filing status record.
///
/// Shows filing header, status timeline, key details, and conditional
/// refund / demand / intimation sections.
class FilingDetailScreen extends ConsumerWidget {
  const FilingDetailScreen({super.key});

  static final _dateFmt = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedFilingIndexProvider);
    final filings = ref.watch(filingStatusListProvider);
    final refunds = ref.watch(refundTrackerListProvider);
    final demands = ref.watch(demandTrackerListProvider);
    final theme = Theme.of(context);

    if (selectedIndex == null || selectedIndex >= filings.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Filing Detail')),
        body: const Center(child: Text('No filing selected')),
      );
    }

    final filing = filings[selectedIndex];

    // Find matching refund/demand by PAN
    final refund = refunds.where((r) => r.pan == filing.pan).toList();
    final demand = demands.where((d) => d.pan == filing.pan).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${filing.filingType.label} Detail',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
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
            // Header card
            _HeaderCard(filing: filing),
            const SizedBox(height: 16),

            // Status timeline
            const _SectionHeader(
              title: 'Status Timeline',
              icon: Icons.timeline_rounded,
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StatusTimeline(steps: _buildTimelineSteps(filing)),
              ),
            ),
            const SizedBox(height: 16),

            // Key details
            const _SectionHeader(
              title: 'Key Details',
              icon: Icons.info_outline_rounded,
            ),
            const SizedBox(height: 10),
            _KeyDetailsCard(filing: filing),
            const SizedBox(height: 16),

            // Refund section
            if (refund.isNotEmpty) ...[
              const _SectionHeader(
                title: 'Refund Details',
                icon: Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(height: 10),
              ...refund.map(
                (r) => _RefundCard(
                  amount: formatPaise(r.refundAmount),
                  status: r.status.label,
                  bankAccount: r.refundBankAccount,
                  expectedDate: r.expectedDate != null
                      ? _dateFmt.format(r.expectedDate!)
                      : null,
                  issuedDate: r.issuedDate != null
                      ? _dateFmt.format(r.issuedDate!)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Demand section
            if (demand.isNotEmpty) ...[
              const _SectionHeader(
                title: 'Demand Notice',
                icon: Icons.warning_rounded,
              ),
              const SizedBox(height: 10),
              ...demand.map(
                (d) => _DemandCard(
                  amount: formatPaise(d.demandAmount),
                  outstanding: formatPaise(d.outstandingAmount),
                  section: d.section,
                  dueDate: _dateFmt.format(d.dueDate),
                  status: d.status.label,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Intimation 143(1) card
            if (filing.currentState == FilingState.intimationIssued) ...[
              const _SectionHeader(
                title: 'Intimation u/s 143(1)',
                icon: Icons.mail_rounded,
              ),
              const SizedBox(height: 10),
              _IntimationCard(filing: filing),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<TimelineStep> _buildTimelineSteps(FilingStatus filing) {
    // Define the canonical order of states
    const canonicalOrder = [
      FilingState.submitted,
      FilingState.eVerificationPending,
      FilingState.eVerified,
      FilingState.processing,
      FilingState.processed,
    ];

    // Gather completed states from history
    final completedStates = <FilingState>{};
    for (final transition in filing.history) {
      completedStates.add(transition.toState);
    }

    final steps = <TimelineStep>[];

    for (final state in canonicalOrder) {
      final isCompleted = completedStates.contains(state);
      final isActive = filing.currentState == state;

      // Find the transition date for this state
      final transition = filing.history
          .where((t) => t.toState == state)
          .toList();
      final dateStr = transition.isNotEmpty
          ? _dateFmt.format(transition.first.transitionedAt)
          : 'Pending';

      steps.add(
        TimelineStep(
          title: state.label,
          subtitle: dateStr,
          isCompleted: isCompleted && !isActive,
          isActive: isActive,
        ),
      );
    }

    // Add terminal states if applicable
    final terminalStates = [
      FilingState.refundInitiated,
      FilingState.demandRaised,
      FilingState.intimationIssued,
      FilingState.defective,
    ];

    for (final state in terminalStates) {
      if (completedStates.contains(state)) {
        final transition = filing.history
            .where((t) => t.toState == state)
            .toList();
        final dateStr = transition.isNotEmpty
            ? _dateFmt.format(transition.first.transitionedAt)
            : '';

        steps.add(
          TimelineStep(
            title: state.label,
            subtitle: dateStr,
            isCompleted: filing.currentState != state,
            isActive: filing.currentState == state,
          ),
        );
      }
    }

    return steps;
  }
}

// ---------------------------------------------------------------------------
// Section header (matches analytics style)
// ---------------------------------------------------------------------------

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
// Header card
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.filing});

  final FilingStatus filing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    filing.filingType.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  filing.currentState.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'PAN: ${filing.pan}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Period: ${filing.period}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Key details card
// ---------------------------------------------------------------------------

class _KeyDetailsCard extends StatelessWidget {
  const _KeyDetailsCard({required this.filing});

  final FilingStatus filing;

  static final _dateFmt = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final processingDate = filing.history
        .where((t) => t.toState == FilingState.processed)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(
              label: 'Acknowledgement No.',
              value: filing.acknowledgementNumber ?? 'N/A',
            ),
            const Divider(height: 20),
            _DetailRow(
              label: 'Filing Date',
              value: _dateFmt.format(filing.submittedAt),
            ),
            if (processingDate.isNotEmpty) ...[
              const Divider(height: 20),
              _DetailRow(
                label: 'Processing Date',
                value: _dateFmt.format(processingDate.first.transitionedAt),
              ),
            ],
            const Divider(height: 20),
            _DetailRow(
              label: 'Current Status',
              value: filing.currentState.label,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Refund card
// ---------------------------------------------------------------------------

class _RefundCard extends StatelessWidget {
  const _RefundCard({
    required this.amount,
    required this.status,
    required this.bankAccount,
    this.expectedDate,
    this.issuedDate,
  });

  final String amount;
  final String status;
  final String bankAccount;
  final String? expectedDate;
  final String? issuedDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(label: 'Refund Amount', value: amount),
            const Divider(height: 20),
            _DetailRow(label: 'Status', value: status),
            const Divider(height: 20),
            _DetailRow(label: 'Bank Account', value: bankAccount),
            if (expectedDate != null) ...[
              const Divider(height: 20),
              _DetailRow(label: 'Expected Date', value: expectedDate!),
            ],
            if (issuedDate != null) ...[
              const Divider(height: 20),
              _DetailRow(label: 'Issued Date', value: issuedDate!),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Demand card
// ---------------------------------------------------------------------------

class _DemandCard extends StatelessWidget {
  const _DemandCard({
    required this.amount,
    required this.outstanding,
    required this.section,
    required this.dueDate,
    required this.status,
  });

  final String amount;
  final String outstanding;
  final String section;
  final String dueDate;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(label: 'Demand Amount', value: amount),
            const Divider(height: 20),
            _DetailRow(label: 'Outstanding', value: outstanding),
            const Divider(height: 20),
            _DetailRow(label: 'Section', value: section),
            const Divider(height: 20),
            _DetailRow(label: 'Due Date', value: dueDate),
            const Divider(height: 20),
            _DetailRow(label: 'Status', value: status),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.payment_rounded),
                    label: const Text('Pay'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.gavel_rounded),
                    label: const Text('Appeal'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Intimation 143(1) card
// ---------------------------------------------------------------------------

class _IntimationCard extends StatelessWidget {
  const _IntimationCard({required this.filing});

  final FilingStatus filing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transition = filing.history
        .where((t) => t.toState == FilingState.intimationIssued)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.mail_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Intimation u/s 143(1)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (transition.isNotEmpty)
              Text(
                transition.first.reason,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Review the intimation on the Income Tax portal and verify '
              'the computed tax liability matches your filed return.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
