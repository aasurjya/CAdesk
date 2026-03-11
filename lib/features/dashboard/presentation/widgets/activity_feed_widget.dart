import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A compact activity feed showing recent cross-module actions.
///
/// Data is intentionally mocked at this stage: the activity log module
/// that will eventually feed this widget is not yet implemented.
class ActivityFeedWidget extends StatelessWidget {
  const ActivityFeedWidget({super.key});

  static const _activities = <_Activity>[
    _Activity(
      title: 'ITR Filed',
      subtitle: 'Rajesh Kumar Sharma — AY 2026-27 ITR-1',
      timeAgo: '2 hrs ago',
      icon: Icons.check_circle_outline,
    ),
    _Activity(
      title: 'GST Filed',
      subtitle: 'TCS Ltd — GSTR-3B Feb 2026',
      timeAgo: '4 hrs ago',
      icon: Icons.receipt_outlined,
    ),
    _Activity(
      title: 'Challan Paid',
      subtitle: 'TDS ₹1.24L via ITNS 281',
      timeAgo: '6 hrs ago',
      icon: Icons.payments_outlined,
    ),
    _Activity(
      title: 'Notice Received',
      subtitle: 'Sharma Traders — GST notice sec 61',
      timeAgo: '1 day ago',
      icon: Icons.warning_amber_outlined,
    ),
    _Activity(
      title: 'Client Added',
      subtitle: 'Bharat Pharma Ltd onboarded',
      timeAgo: '1 day ago',
      icon: Icons.person_add_outlined,
    ),
    _Activity(
      title: 'Document Uploaded',
      subtitle: 'Form 16 — Priya Nair FY 2024-25',
      timeAgo: '2 days ago',
      icon: Icons.upload_file_outlined,
    ),
    _Activity(
      title: 'Invoice Raised',
      subtitle: 'TCS Ltd — ₹45,000 GST audit fee',
      timeAgo: '2 days ago',
      icon: Icons.receipt_long_outlined,
    ),
    _Activity(
      title: 'Assessment Reply',
      subtitle: 'Sec 143(1) reply sent — Arjun Mehta',
      timeAgo: '3 days ago',
      icon: Icons.gavel_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _activities.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _ActivityTile(activity: _activities[index]);
          },
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final _Activity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          activity.icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        activity.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.neutral900,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          activity.subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ),
      trailing: Text(
        activity.timeAgo,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.neutral400,
        ),
      ),
    );
  }
}

class _Activity {
  const _Activity({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;
}
