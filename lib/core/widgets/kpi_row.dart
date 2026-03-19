import 'package:flutter/material.dart';

import 'package:ca_app/core/widgets/summary_card.dart';

/// A horizontal row of [SummaryCard] widgets with consistent padding
/// and spacing.
///
/// Each card is already wrapped in [Expanded] internally, so they
/// distribute evenly within the row.
class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.cards});

  final List<SummaryCard> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            cards[i],
          ],
        ],
      ),
    );
  }
}
