import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../../domain/models/account_client.dart';

/// List tile showing an accounting client with business-type badge,
/// turnover, audit status, and current ratio.
class AccountClientTile extends StatelessWidget {
  const AccountClientTile({super.key, required this.client, this.onTap});

  final AccountClient client;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: name + status badge
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PAN: ${client.pan}  •  ${client.financialYear}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: client.status),
                ],
              ),

              const SizedBox(height: 10),

              // Business type + audit badge row
              Row(
                children: [
                  _BusinessTypeBadge(type: client.businessType),
                  const SizedBox(width: 8),
                  if (client.hasAudit)
                    _AuditBadge(auditorName: client.auditorName),
                ],
              ),

              const SizedBox(height: 10),

              // Financial figures row
              _FinancialFiguresRow(client: client),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AccountClientStatus status;

  Color get _color {
    switch (status) {
      case AccountClientStatus.finalized:
        return AppColors.success;
      case AccountClientStatus.underReview:
        return AppColors.warning;
      case AccountClientStatus.draft:
        return AppColors.neutral400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _BusinessTypeBadge extends StatelessWidget {
  const _BusinessTypeBadge({required this.type});

  final BusinessType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryVariant.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryVariant,
        ),
      ),
    );
  }
}

class _AuditBadge extends StatelessWidget {
  const _AuditBadge({this.auditorName});

  final String? auditorName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 11,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 3),
          Text(
            auditorName != null
                ? 'Audit: ${_shortenName(auditorName!)}'
                : 'Audit',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String _shortenName(String name) {
    final parts = name.split(' ');
    if (parts.length <= 2) return name;
    return '${parts[0]} ${parts[1]}';
  }
}

class _FinancialFiguresRow extends StatelessWidget {
  const _FinancialFiguresRow({required this.client});

  final AccountClient client;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FigureCell(
          label: 'Turnover',
          value: CurrencyUtils.formatINRCompact(client.turnover),
          color: AppColors.primary,
        ),
        const _Divider(),
        _FigureCell(
          label: 'Net Profit',
          value: CurrencyUtils.formatINRCompact(client.netProfit),
          color: client.netProfit >= 0 ? AppColors.success : AppColors.error,
        ),
        const _Divider(),
        _FigureCell(
          label: 'Assets',
          value: CurrencyUtils.formatINRCompact(client.totalAssets),
          color: AppColors.neutral600,
        ),
        const _Divider(),
        _FigureCell(
          label: 'Cur. Ratio',
          value: client.currentRatio.toStringAsFixed(2),
          color: client.currentRatio >= 1.5
              ? AppColors.success
              : AppColors.warning,
        ),
      ],
    );
  }
}

class _FigureCell extends StatelessWidget {
  const _FigureCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.neutral200,
    );
  }
}
