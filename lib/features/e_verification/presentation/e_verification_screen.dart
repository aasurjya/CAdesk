import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/e_verification/data/providers/e_verification_providers.dart';
import 'package:ca_app/features/e_verification/presentation/widgets/verification_tile.dart';

/// Main E-Verification dashboard showing pending, verified, and expired
/// returns with a warning banner for those expiring within 7 days.
class EVerificationDashboardScreen extends ConsumerWidget {
  const EVerificationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifications = ref.watch(pendingVerificationsProvider);
    final pendingCount = ref.watch(pendingCountProvider);
    final verifiedCount = ref.watch(verifiedCountProvider);
    final expiredCount = ref.watch(expiredCountProvider);
    final expiringSoon = ref.watch(expiringSoonProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'E-Verification',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Post-filing ITR verification',
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
            // Summary row
            _SummaryRow(
              pending: pendingCount,
              verified: verifiedCount,
              expired: expiredCount,
            ),
            const SizedBox(height: 16),

            // Warning banner
            if (expiringSoon.isNotEmpty)
              _ExpiryWarningBanner(count: expiringSoon.length),
            if (expiringSoon.isNotEmpty) const SizedBox(height: 16),

            // Verification tiles
            ...verifications.map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: VerificationTile(
                  request: request,
                  onVerify: () =>
                      context.push('/e-verification/verify', extra: request),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary row
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.pending,
    required this.verified,
    required this.expired,
  });

  final int pending;
  final int verified;
  final int expired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Pending',
            count: pending,
            color: AppColors.warning,
            icon: Icons.hourglass_top_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Verified',
            count: verified,
            color: AppColors.success,
            icon: Icons.verified_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Expired',
            count: expired,
            color: AppColors.error,
            icon: Icons.error_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
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
// Expiry warning banner
// ---------------------------------------------------------------------------

class _ExpiryWarningBanner extends StatelessWidget {
  const _ExpiryWarningBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count return(s) expiring within 7 days. Verify immediately '
              'to avoid re-filing.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
