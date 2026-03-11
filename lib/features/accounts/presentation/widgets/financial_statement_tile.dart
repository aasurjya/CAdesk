import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../../domain/models/financial_statement.dart';

/// Tile displaying a financial statement with type icon, year,
/// status badge, and key figures.
class FinancialStatementTile extends StatelessWidget {
  const FinancialStatementTile({
    super.key,
    required this.statement,
    this.onTap,
  });

  final FinancialStatement statement;
  final VoidCallback? onTap;

  static final _dateFormat = DateFormat('dd MMM yyyy');

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statement type icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon, size: 22, color: _typeColor),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client name + status badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            statement.clientName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: statement.status),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Type label + format + year
                    Row(
                      children: [
                        Text(
                          statement.statementType.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: _typeColor,
                          ),
                        ),
                        const Text(
                          '  •  ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral400,
                          ),
                        ),
                        Text(
                          statement.format.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                        const Text(
                          '  •  ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral400,
                          ),
                        ),
                        Text(
                          statement.financialYear,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Key figures
                    _KeyFiguresRow(statement: statement),

                    const SizedBox(height: 6),

                    // Prepared by + date
                    Text(
                      'By ${statement.preparedBy}  •  '
                      '${_dateFormat.format(statement.preparedDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _typeIcon {
    switch (statement.statementType) {
      case StatementType.balanceSheet:
        return Icons.balance_rounded;
      case StatementType.profitLoss:
        return Icons.trending_up_rounded;
      case StatementType.trialBalance:
        return Icons.list_alt_rounded;
      case StatementType.cashFlow:
        return Icons.water_drop_rounded;
      case StatementType.capitalAccount:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color get _typeColor {
    switch (statement.statementType) {
      case StatementType.balanceSheet:
        return AppColors.primary;
      case StatementType.profitLoss:
        return AppColors.secondary;
      case StatementType.trialBalance:
        return AppColors.accent;
      case StatementType.cashFlow:
        return const Color(0xFF2196F3);
      case StatementType.capitalAccount:
        return AppColors.primaryVariant;
    }
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final StatementStatus status;

  Color get _color {
    switch (status) {
      case StatementStatus.draft:
        return AppColors.neutral400;
      case StatementStatus.prepared:
        return AppColors.warning;
      case StatementStatus.approved:
        return AppColors.secondary;
      case StatementStatus.filed:
        return AppColors.success;
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

class _KeyFiguresRow extends StatelessWidget {
  const _KeyFiguresRow({required this.statement});

  final FinancialStatement statement;

  @override
  Widget build(BuildContext context) {
    final showAssets = statement.totalAssets > 0;
    final showLiabilities = statement.totalLiabilities > 0;
    final showProfit = statement.netProfit != 0;

    final figures = <({String label, String value, Color color})>[];

    if (showAssets) {
      figures.add((
        label: 'Total Assets',
        value: CurrencyUtils.formatINRCompact(statement.totalAssets),
        color: AppColors.primary,
      ));
    }
    if (showLiabilities) {
      figures.add((
        label: 'Liabilities',
        value: CurrencyUtils.formatINRCompact(statement.totalLiabilities),
        color: AppColors.neutral600,
      ));
    }
    if (showProfit) {
      figures.add((
        label: 'Net Profit',
        value: CurrencyUtils.formatINRCompact(statement.netProfit),
        color: statement.netProfit >= 0 ? AppColors.success : AppColors.error,
      ));
    }

    if (figures.isEmpty) return const SizedBox.shrink();

    return Row(
      children: figures
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: f.color,
                    ),
                  ),
                  Text(
                    f.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
