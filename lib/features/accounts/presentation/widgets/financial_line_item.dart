import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';

/// Reusable line item widget for financial statements (Balance Sheet / P&L).
///
/// Supports expandable sub-items, note references, and bold styling
/// for totals and subtotals.
class FinancialLineItem extends StatelessWidget {
  const FinancialLineItem({
    super.key,
    required this.label,
    required this.currentYear,
    this.previousYear,
    this.noteRef,
    this.isBold = false,
    this.isSubtotal = false,
    this.indent = 0,
    this.subItems = const [],
  });

  /// Line item label (e.g. "Trade Receivables").
  final String label;

  /// Current year amount in paise.
  final int currentYear;

  /// Previous year amount in paise (null if not available).
  final int? previousYear;

  /// Note reference number (e.g. "Note 5").
  final int? noteRef;

  /// Whether to render in bold (for totals).
  final bool isBold;

  /// Whether this is a subtotal row (lighter background).
  final bool isSubtotal;

  /// Indent level for hierarchy (0 = top level).
  final int indent;

  /// Expandable sub-items.
  final List<FinancialLineItem> subItems;

  @override
  Widget build(BuildContext context) {
    final hasSubItems = subItems.isNotEmpty;
    final leftPadding = 12.0 + (indent * 16.0);

    final fontWeight = isBold || isSubtotal ? FontWeight.w700 : FontWeight.w400;
    final fontSize = isBold ? 12.0 : 11.0;
    final bgColor = isSubtotal ? AppColors.neutral100 : Colors.transparent;

    if (hasSubItems) {
      return _ExpandableLineItem(
        label: label,
        currentYear: currentYear,
        previousYear: previousYear,
        noteRef: noteRef,
        isBold: isBold,
        isSubtotal: isSubtotal,
        leftPadding: leftPadding,
        fontWeight: fontWeight,
        fontSize: fontSize,
        bgColor: bgColor,
        subItems: subItems,
      );
    }

    return Container(
      color: bgColor,
      padding: EdgeInsets.fromLTRB(leftPadding, 5, 12, 5),
      child: Row(
        children: [
          // Label + note ref
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (noteRef != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '[$noteRef]',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Current year
          Expanded(
            flex: 3,
            child: Text(
              _formatPaise(currentYear),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: AppColors.neutral900,
              ),
            ),
          ),
          // Previous year
          if (previousYear != null)
            Expanded(
              flex: 3,
              child: Text(
                _formatPaise(previousYear!),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: AppColors.neutral400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatPaise(int paise) {
    return CurrencyUtils.formatINR(paise / 100);
  }
}

// ---------------------------------------------------------------------------
// Expandable variant
// ---------------------------------------------------------------------------

class _ExpandableLineItem extends StatefulWidget {
  const _ExpandableLineItem({
    required this.label,
    required this.currentYear,
    required this.previousYear,
    required this.noteRef,
    required this.isBold,
    required this.isSubtotal,
    required this.leftPadding,
    required this.fontWeight,
    required this.fontSize,
    required this.bgColor,
    required this.subItems,
  });

  final String label;
  final int currentYear;
  final int? previousYear;
  final int? noteRef;
  final bool isBold;
  final bool isSubtotal;
  final double leftPadding;
  final FontWeight fontWeight;
  final double fontSize;
  final Color bgColor;
  final List<FinancialLineItem> subItems;

  @override
  State<_ExpandableLineItem> createState() => _ExpandableLineItemState();
}

class _ExpandableLineItemState extends State<_ExpandableLineItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            color: widget.bgColor,
            padding: EdgeInsets.fromLTRB(widget.leftPadding, 5, 12, 5),
            child: Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 14,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: widget.fontSize,
                            fontWeight: widget.fontWeight,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ),
                      if (widget.noteRef != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '[${widget.noteRef}]',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    FinancialLineItem._formatPaise(widget.currentYear),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: widget.fontWeight,
                    ),
                  ),
                ),
                if (widget.previousYear != null)
                  Expanded(
                    flex: 3,
                    child: Text(
                      FinancialLineItem._formatPaise(widget.previousYear!),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: widget.fontWeight,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_expanded) ...widget.subItems,
      ],
    );
  }
}
