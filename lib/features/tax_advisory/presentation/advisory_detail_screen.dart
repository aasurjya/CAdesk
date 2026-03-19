import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _AdvisoryDetail {
  const _AdvisoryDetail({
    required this.id,
    required this.clientName,
    required this.query,
    required this.status,
    required this.date,
    required this.sections,
    required this.opinionText,
    required this.caseLaws,
    required this.circulars,
    required this.fee,
    required this.assignedTo,
  });

  final String id;
  final String clientName;
  final String query;
  final String status;
  final String date;
  final List<String> sections;
  final String opinionText;
  final List<String> caseLaws;
  final List<String> circulars;
  final double fee;
  final String assignedTo;
}

const _mockAdvisory = _AdvisoryDetail(
  id: 'ADV-001',
  clientName: 'Sunrise Technologies Pvt Ltd',
  query:
      'Whether the expenditure on software development qualifies for deduction '
      'under Section 35(1)(iv) of the Income Tax Act, 1961, and the applicable '
      'conditions for claiming weighted deduction under Section 35(2AB).',
  status: 'Draft',
  date: '15 Mar 2026',
  sections: ['35(1)(iv)', '35(2AB)', '37(1)', '32(1)(ii)'],
  opinionText:
      'Based on our analysis of the facts presented and the applicable legal '
      'provisions, it is our considered opinion that the expenditure incurred '
      'by the assessee on in-house software development qualifies for '
      'deduction under Section 35(1)(iv) of the Income Tax Act, 1961.\n\n'
      'The weighted deduction under Section 35(2AB) is available subject to '
      'the facility being approved by the prescribed authority (DSIR) and '
      'the expenditure being of a capital nature on scientific research.\n\n'
      'However, routine software maintenance and support costs would fall '
      'under Section 37(1) as revenue expenditure and not qualify for '
      'weighted deduction.',
  caseLaws: [
    'CIT vs Infosys Technologies Ltd (2015) 373 ITR 134 (Kar)',
    'DCIT vs Oracle India Pvt Ltd (2018) 96 taxmann.com 82 (Bang)',
    'Wipro Ltd vs DCIT (2017) 84 taxmann.com 327 (Bang)',
  ],
  circulars: [
    'CBDT Circular No. 5/2012 dated 01-08-2012',
    'DSIR Notification S.O. 2976(E) dated 16-09-2019',
    'CBDT Circular No. 6/2021 dated 17-03-2021',
  ],
  fee: 35000,
  assignedTo: 'CA Rajesh Verma',
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Tax advisory opinion detail screen.
///
/// Route: `/tax-advisory/detail/:advisoryId`
class AdvisoryDetailScreen extends ConsumerWidget {
  const AdvisoryDetailScreen({required this.advisoryId, super.key});

  final String advisoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In production, look up from provider by advisoryId.
    const advisory = _mockAdvisory;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('Advisory ${advisory.id}'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
            tooltip: 'Edit Advisory',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          const _HeaderCard(advisory: advisory),
          const SizedBox(height: 16),

          // Client query
          const SectionHeader(
            title: 'Client Query',
            icon: Icons.help_outline_rounded,
          ),
          const SizedBox(height: 8),
          _ContentCard(child: Text(advisory.query)),
          const SizedBox(height: 20),

          // Applicable sections
          const SectionHeader(
            title: 'Applicable Sections',
            icon: Icons.gavel_rounded,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: advisory.sections
                .map(
                  (s) => StatusBadge(label: 'Sec $s', color: AppColors.primary),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

          // Advisory opinion
          const SectionHeader(
            title: 'Advisory Opinion',
            icon: Icons.description_outlined,
          ),
          const SizedBox(height: 8),
          _ContentCard(child: Text(advisory.opinionText)),
          const SizedBox(height: 20),

          // Case laws
          const SectionHeader(
            title: 'Supporting Case Laws',
            icon: Icons.balance_rounded,
          ),
          const SizedBox(height: 8),
          ...advisory.caseLaws.map((law) => _BulletItem(text: law)),
          const SizedBox(height: 20),

          // Circulars
          const SectionHeader(
            title: 'Circulars & Notifications',
            icon: Icons.campaign_rounded,
          ),
          const SizedBox(height: 8),
          ...advisory.circulars.map((c) => _BulletItem(text: c)),
          const SizedBox(height: 20),

          // Fee
          const SectionHeader(
            title: 'Advisory Fee',
            icon: Icons.currency_rupee_rounded,
          ),
          const SizedBox(height: 8),
          _ContentCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Professional Fee',
                  style: TextStyle(color: AppColors.neutral600),
                ),
                Text(
                  '\u20B9${advisory.fee.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: _BottomBar(onSend: () {}, onExport: () {}),
    );
  }
}

// ---------------------------------------------------------------------------
// Header card
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.advisory});

  final _AdvisoryDetail advisory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (advisory.status) {
      'Final' => AppColors.success,
      'Review' => AppColors.accent,
      _ => AppColors.warning,
    };

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    advisory.clientName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                StatusBadge(label: advisory.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.person_outline, text: advisory.assignedTo),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.calendar_today_rounded, text: advisory.date),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.neutral400),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.neutral600),
        ),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onSend, required this.onExport});

  final VoidCallback onSend;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('Export PDF'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send to Client'),
            ),
          ),
        ],
      ),
    );
  }
}
