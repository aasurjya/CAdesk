import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/audit/domain/models/form3cd_clause.dart';

/// A reusable collapsible section for a Form 3CD clause with clause number,
/// title, and content area (text fields, amount fields).
class ClauseSection extends StatelessWidget {
  const ClauseSection({
    required this.clause,
    required this.onResponseChanged,
    this.amountLabel,
    this.onAmountChanged,
    super.key,
  });

  final Form3CDClause clause;
  final ValueChanged<String> onResponseChanged;

  /// Optional amount field label; when non-null, an amount input is shown.
  final String? amountLabel;
  final ValueChanged<String>? onAmountChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasResponse = clause.response.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: _ClauseNumber(number: clause.clauseNumber),
        title: Text(
          clause.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        trailing: hasResponse
            ? const Icon(Icons.check_circle, size: 18, color: AppColors.success)
            : const Icon(
                Icons.circle_outlined,
                size: 18,
                color: AppColors.neutral300,
              ),
        children: [
          TextFormField(
            initialValue: clause.response,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Response / Remarks',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: onResponseChanged,
          ),
          if (amountLabel != null) ...[
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: amountLabel,
                border: const OutlineInputBorder(),
                isDense: true,
                prefixText: '\u20B9 ',
              ),
              onChanged: onAmountChanged,
            ),
          ],
          if (clause.hasDisclosures) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Disclosures:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ...clause.disclosures.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('\u2022 ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(
                        d,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ClauseNumber extends StatelessWidget {
  const _ClauseNumber({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$number',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
