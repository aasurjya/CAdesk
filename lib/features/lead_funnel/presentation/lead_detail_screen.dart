import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _LeadDetail {
  const _LeadDetail({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.source,
    required this.referredBy,
    required this.stage,
    required this.stageColor,
    required this.serviceInterests,
    required this.estimatedValue,
    required this.nextAction,
    required this.nextActionDate,
    required this.timeline,
    required this.notes,
    required this.createdDate,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String source;
  final String referredBy;
  final String stage;
  final Color stageColor;
  final List<String> serviceInterests;
  final double estimatedValue;
  final String nextAction;
  final String nextActionDate;
  final List<_TimelineEvent> timeline;
  final String notes;
  final String createdDate;
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.date,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String date;
  final String title;
  final String description;
  final IconData icon;
}

_LeadDetail _mockLead(String leadId) {
  return _LeadDetail(
    id: leadId,
    name: 'Vikram Mehta',
    email: 'vikram@mehta-group.com',
    phone: '+91 99887 76655',
    company: 'Mehta Group Holdings',
    source: 'Referral',
    referredBy: 'Rajesh Sharma',
    stage: 'Qualified',
    stageColor: AppColors.secondary,
    serviceInterests: [
      'ITR Filing',
      'Tax Planning',
      'GST Registration',
      'Audit',
    ],
    estimatedValue: 250000,
    nextAction: 'Send proposal for Tax Planning',
    nextActionDate: '20 Mar 2026',
    timeline: const [
      _TimelineEvent(
        date: '14 Mar 2026',
        title: 'Follow-up call',
        description: 'Discussed tax planning needs for FY 2025-26.',
        icon: Icons.phone_rounded,
      ),
      _TimelineEvent(
        date: '10 Mar 2026',
        title: 'Moved to Qualified',
        description: 'Lead qualified after initial assessment.',
        icon: Icons.verified_rounded,
      ),
      _TimelineEvent(
        date: '05 Mar 2026',
        title: 'Initial meeting',
        description: 'Met at CA conference. Interested in ITR and GST.',
        icon: Icons.handshake_rounded,
      ),
      _TimelineEvent(
        date: '01 Mar 2026',
        title: 'Lead created',
        description: 'Referred by Rajesh Sharma.',
        icon: Icons.person_add_rounded,
      ),
    ],
    notes:
        'High-value prospect. Multiple entities under the group. '
        'Wants consolidated tax planning across entities.',
    createdDate: '01 Mar 2026',
  );
}

/// Detail view for a single lead, showing contact info, timeline, service
/// interests, estimated value, and a convert-to-client action.
class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lead = _mockLead(leadId);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _LeadHeader(lead: lead),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ContactCard(lead: lead),
                const SizedBox(height: 16),
                _ValueCard(lead: lead),
                const SizedBox(height: 16),
                _NextActionCard(lead: lead),
                const SizedBox(height: 16),
                _ServiceInterests(interests: lead.serviceInterests),
                const SizedBox(height: 16),
                _TimelineSection(events: lead.timeline),
                const SizedBox(height: 16),
                _NotesCard(notes: lead.notes, theme: theme),
                const SizedBox(height: 24),
                _ConvertButton(context: context),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _LeadHeader extends StatelessWidget {
  const _LeadHeader({required this.lead});

  final _LeadDetail lead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 170,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryVariant],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withAlpha(40),
                  child: Text(
                    lead.name.split(' ').map((w) => w[0]).take(2).join(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lead.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lead.company,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: lead.stageColor.withAlpha(80),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lead.stage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contact card
// ---------------------------------------------------------------------------

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.lead});

  final _LeadDetail lead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: lead.email,
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: lead.phone,
            ),
            _InfoRow(
              icon: Icons.source_outlined,
              label: 'Source',
              value: lead.source,
            ),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Referred by',
              value: lead.referredBy,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Value card
// ---------------------------------------------------------------------------

class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.lead});

  final _LeadDetail lead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.success.withAlpha(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.success,
              size: 28,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Value',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                Text(
                  '\u20B9${_formatValue(lead.estimatedValue)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatValue(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

// ---------------------------------------------------------------------------
// Next action card
// ---------------------------------------------------------------------------

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({required this.lead});

  final _LeadDetail lead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.warning.withAlpha(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.next_plan_outlined, color: AppColors.warning, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Action',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  Text(
                    lead.nextAction,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Due: ${lead.nextActionDate}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Service interests
// ---------------------------------------------------------------------------

class _ServiceInterests extends StatelessWidget {
  const _ServiceInterests({required this.interests});

  final List<String> interests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Interests',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests
                  .map(
                    (tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.secondary.withAlpha(15),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline section
// ---------------------------------------------------------------------------

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.events});

  final List<_TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Engagement History',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isLast = index == events.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary.withAlpha(20),
                            child: Icon(
                              event.icon,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: AppColors.neutral200,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.date,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notes card
// ---------------------------------------------------------------------------

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes, required this.theme});

  final String notes;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notes,
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
// Convert button
// ---------------------------------------------------------------------------

class _ConvertButton extends StatelessWidget {
  const _ConvertButton({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext outerContext) {
    return FilledButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lead converted to client')),
        );
        context.pop();
      },
      icon: const Icon(Icons.person_add_alt_1_rounded),
      label: const Text('Convert to Client'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.success,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.neutral400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
