import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/startup_compliance/data/providers/startup_providers.dart';

/// Bottom sheet showing full compliance detail for a [StartupProfile].
class StartupDetailSheet extends StatelessWidget {
  const StartupDetailSheet({super.key, required this.profile});

  final StartupProfile profile;

  /// Shows the bottom sheet anchored to [context].
  static void show(BuildContext context, StartupProfile profile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StartupDetailSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DragHandle(),
              const SizedBox(height: 12),
              _Header(profile: profile),
              const SizedBox(height: 16),
              _DpiitStatusCard(profile: profile),
              const SizedBox(height: 12),
              _Section80IacCard(profile: profile),
              const SizedBox(height: 12),
              _BenefitsRow(profile: profile),
              const SizedBox(height: 12),
              _CapTableCard(profile: profile),
              const SizedBox(height: 12),
              _NextActionCard(profile: profile),
              const SizedBox(height: 20),
              _ActionButtons(profile: profile),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.neutral300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final StartupProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CIN: ${profile.cin}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            _StatusChip(status: profile.status),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _SectorBadge(sector: profile.sectorVertical),
            const SizedBox(width: 8),
            Text(
              'Est. ${profile.incorporationYear}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final StartupStatus status;

  Color get _color {
    switch (status) {
      case StartupStatus.active:
        return AppColors.success;
      case StartupStatus.dormant:
        return AppColors.neutral400;
      case StartupStatus.fundingRound:
        return AppColors.accent;
      case StartupStatus.exited:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectorBadge extends StatelessWidget {
  const _SectorBadge({required this.sector});

  final String sector;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        sector,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DpiitStatusCard extends StatelessWidget {
  const _DpiitStatusCard({required this.profile});

  final StartupProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        profile.isDpiitRecognized ? AppColors.success : AppColors.warning;
    final label = profile.isDpiitRecognized
        ? 'DPIIT Recognised'
        : 'Not DPIIT Recognised';
    final icon = profile.isDpiitRecognized
        ? Icons.verified_rounded
        : Icons.pending_actions_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!profile.isDpiitEligible) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Note: Eligibility criteria not met',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (profile.isDpiitRecognized)
            const Icon(Icons.shield_rounded,
                color: AppColors.success, size: 18),
        ],
      ),
    );
  }
}

class _Section80IacCard extends StatelessWidget {
  const _Section80IacCard({required this.profile});

  final StartupProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deduction = profile.deduction80IACCrore;
    final taxSaving = profile.taxSavingCrore;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Section 80-IAC Deduction',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _IacMetric(
                label: 'Deduction',
                value: deduction > 0
                    ? '₹${deduction.toStringAsFixed(2)}Cr'
                    : '₹0',
                color: AppColors.primary,
              ),
              _IacMetric(
                label: 'Tax @ 25%',
                value: taxSaving > 0
                    ? '₹${taxSaving.toStringAsFixed(2)}Cr'
                    : '₹0',
                color: AppColors.success,
              ),
              _IacMetric(
                label: 'Certificate',
                value: profile.has80IacCertificate ? 'Obtained' : 'Pending',
                color: profile.has80IacCertificate
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IacMetric extends StatelessWidget {
  const _IacMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsRow extends StatelessWidget {
  const _BenefitsRow({required this.profile});

  final StartupProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _BenefitChip(
          icon: Icons.shield_moon_rounded,
          label: 'Angel Tax',
          detail: profile.isAngelTaxExempt ? 'Exempt' : 'Applicable',
          color: profile.isAngelTaxExempt ? AppColors.success : AppColors.error,
          theme: theme,
        ),
        const SizedBox(width: 8),
        _BenefitChip(
          icon: Icons.trending_up_rounded,
          label: 'Loss Carry-fwd',
          detail: profile.canCarryForwardLoss ? 'Allowed' : 'Restricted',
          color: profile.canCarryForwardLoss
              ? AppColors.success
              : AppColors.warning,
          theme: theme,
        ),
        const SizedBox(width: 8),
        _BenefitChip(
          icon: Icons.currency_rupee_rounded,
          label: 'Funding',
          detail: profile.raisedFundingCrore > 0
              ? '₹${profile.raisedFundingCrore.toStringAsFixed(1)}Cr'
              : 'Bootstrapped',
          color: AppColors.primary,
          theme: theme,
        ),
      ],
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({
    required this.icon,
    required this.label,
    required this.detail,
    required this.color,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String detail;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
                fontSize: 10,
              ),
            ),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapTableCard extends StatelessWidget {
  const _CapTableCard({required this.profile});

  final StartupProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cap Table',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.neutral400,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _CapSlice(
              label: 'Founders',
              percent: profile.founderPercent,
              color: AppColors.primary,
              theme: theme,
            ),
            const SizedBox(width: 6),
            _CapSlice(
              label: 'Investors',
              percent: profile.investorPercent,
              color: AppColors.secondary,
              theme: theme,
            ),
            const SizedBox(width: 6),
            _CapSlice(
              label: 'ESOP',
              percent: profile.esopPoolPercent,
              color: AppColors.accent,
              theme: theme,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              _CapBar(flex: profile.founderPercent, color: AppColors.primary),
              _CapBar(flex: profile.investorPercent, color: AppColors.secondary),
              _CapBar(flex: profile.esopPoolPercent, color: AppColors.accent),
            ],
          ),
        ),
      ],
    );
  }
}

class _CapSlice extends StatelessWidget {
  const _CapSlice({
    required this.label,
    required this.percent,
    required this.color,
    required this.theme,
  });

  final String label;
  final double percent;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
                fontSize: 10,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapBar extends StatelessWidget {
  const _CapBar({required this.flex, required this.color});

  final double flex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (flex <= 0) return const SizedBox.shrink();
    return Flexible(
      flex: flex.round(),
      child: Container(height: 8, color: color),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({required this.profile});

  final StartupProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.task_alt_rounded,
              color: AppColors.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              profile.nextComplianceDue,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.profile});

  final StartupProfile profile;

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          icon: const Icon(Icons.verified_rounded, size: 18),
          label: const Text('Renew DPIIT'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () {
            Navigator.of(context).pop();
            _snack(context, 'DPIIT renewal initiated for ${profile.name}');
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.savings_rounded, size: 18),
          label: const Text('Apply 80-IAC'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: const BorderSide(color: AppColors.secondary),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _snack(context, '80-IAC application initiated for ${profile.name}');
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.pie_chart_rounded, size: 18),
          label: const Text('View Cap Table'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _snack(context,
                'Cap table for ${profile.name}: '
                'Founders ${profile.founderPercent.toStringAsFixed(0)}% · '
                'Investors ${profile.investorPercent.toStringAsFixed(0)}% · '
                'ESOP ${profile.esopPoolPercent.toStringAsFixed(0)}%');
          },
        ),
      ],
    );
  }
}
