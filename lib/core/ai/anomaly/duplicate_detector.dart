// ---------------------------------------------------------------------------
// Transaction model
// ---------------------------------------------------------------------------

/// Immutable representation of a single financial transaction.
class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
  });

  final String id;

  /// Transaction amount (positive = credit, negative = debit).
  final double amount;

  final DateTime date;

  /// Narration / description from the bank or ledger.
  final String description;

  Transaction copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Transaction(id: $id, amount: $amount, date: ${date.toIso8601String()})';
}

// ---------------------------------------------------------------------------
// DuplicateGroup
// ---------------------------------------------------------------------------

/// An immutable group of [Transaction]s that are suspected duplicates.
class DuplicateGroup {
  const DuplicateGroup({
    required this.candidates,
    required this.similarity,
    required this.reason,
  });

  /// The transactions in this duplicate cluster.
  final List<Transaction> candidates;

  /// Similarity score in range [0.0, 1.0] (1.0 = identical).
  final double similarity;

  /// Short machine-readable reason code describing why these transactions
  /// were grouped.
  ///
  /// Values:
  /// - `'exact_amount_same_day'`
  /// - `'exact_amount_adjacent_day'`
  /// - `'similar_amount_same_day'`
  /// - `'similar_amount_same_party'`
  /// - `'similar_description_within_3_days'`
  final String reason;

  DuplicateGroup copyWith({
    List<Transaction>? candidates,
    double? similarity,
    String? reason,
  }) {
    return DuplicateGroup(
      candidates: candidates ?? this.candidates,
      similarity: similarity ?? this.similarity,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DuplicateGroup &&
        other.similarity == similarity &&
        other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(similarity, reason);

  @override
  String toString() =>
      'DuplicateGroup(count: ${candidates.length}, '
      'similarity: ${similarity.toStringAsFixed(2)}, reason: $reason)';
}

// ---------------------------------------------------------------------------
// DuplicateDetector
// ---------------------------------------------------------------------------

/// Fuzzy duplicate detection for financial transactions.
///
/// Identifies groups of transactions that are likely duplicates based on:
/// 1. Exact amount ± 0.1% within the same day → high confidence duplicate.
/// 2. Exact amount ± 0.1% within ±3 calendar days → medium confidence.
/// 3. Similar description (Jaccard similarity ≥ 0.5) within ±3 days.
///
/// This is a pure-Dart O(n²) service suitable for datasets up to ~5 000
/// transactions. For larger datasets use a database-side approach.
///
/// Usage:
/// ```dart
/// final detector = DuplicateDetector();
/// final groups = detector.findDuplicates(transactions);
/// ```
class DuplicateDetector {
  const DuplicateDetector({
    this.amountTolerancePct = 0.1,
    this.maxDaysDifference = 3,
    this.descriptionSimilarityThreshold = 0.5,
  });

  /// Amount tolerance as a percentage (0.1 = 0.1%).
  final double amountTolerancePct;

  /// Maximum calendar-day difference to still consider a date match.
  final int maxDaysDifference;

  /// Minimum Jaccard similarity for descriptions to be considered similar.
  final double descriptionSimilarityThreshold;

  // ---------------------------------------------------------------------------
  // findDuplicates
  // ---------------------------------------------------------------------------

  /// Returns a list of [DuplicateGroup]s found in [transactions].
  ///
  /// Each transaction can appear in at most one group. Groups are sorted by
  /// descending similarity.
  List<DuplicateGroup> findDuplicates(List<Transaction> transactions) {
    if (transactions.length < 2) return const [];

    // Sort by date to optimise the inner loop window.
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    final groups = <DuplicateGroup>[];
    final assigned = <String>{};

    for (var i = 0; i < sorted.length; i++) {
      if (assigned.contains(sorted[i].id)) continue;

      final candidates = <Transaction>[sorted[i]];

      for (var j = i + 1; j < sorted.length; j++) {
        final tx = sorted[j];
        if (assigned.contains(tx.id)) continue;

        // Early exit: if date difference exceeds window, no more matches possible.
        final daysDiff = tx.date.difference(sorted[i].date).inDays.abs();
        if (daysDiff > maxDaysDifference) break;

        final match = _matchReason(sorted[i], tx, daysDiff);
        if (match != null) {
          candidates.add(tx);
        }
      }

      if (candidates.length > 1) {
        final anchor = candidates.first;
        final last = candidates.last;
        final daysDiff = last.date.difference(anchor.date).inDays.abs();
        final reason =
            _matchReason(anchor, last, daysDiff) ??
            'similar_description_within_3_days';
        final similarity = _computeGroupSimilarity(candidates);

        for (final tx in candidates) {
          assigned.add(tx.id);
        }

        groups.add(
          DuplicateGroup(
            candidates: List.unmodifiable(candidates),
            similarity: similarity,
            reason: reason,
          ),
        );
      }
    }

    groups.sort((a, b) => b.similarity.compareTo(a.similarity));
    return List.unmodifiable(groups);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Returns a reason code if [a] and [b] are suspected duplicates, else null.
  String? _matchReason(Transaction a, Transaction b, int daysDiff) {
    final amountMatch = _amountsMatch(a.amount, b.amount);
    final sameDay = daysDiff == 0;
    final withinWindow = daysDiff <= maxDaysDifference;
    final descSim = _jaccardSimilarity(
      _tokenise(a.description),
      _tokenise(b.description),
    );

    if (amountMatch && sameDay) return 'exact_amount_same_day';
    if (amountMatch && withinWindow) return 'exact_amount_adjacent_day';
    if (amountMatch && descSim >= descriptionSimilarityThreshold) {
      return 'similar_amount_same_party';
    }
    if (descSim >= descriptionSimilarityThreshold && withinWindow) {
      return 'similar_description_within_3_days';
    }
    return null;
  }

  bool _amountsMatch(double a, double b) {
    if (a == 0 && b == 0) return true;
    if (a == 0 || b == 0) return false;
    final diff = (a - b).abs();
    final tolerance = a.abs() * (amountTolerancePct / 100.0);
    return diff <= tolerance;
  }

  double _computeGroupSimilarity(List<Transaction> group) {
    if (group.length < 2) return 1.0;

    var totalSimilarity = 0.0;
    var pairs = 0;

    for (var i = 0; i < group.length; i++) {
      for (var j = i + 1; j < group.length; j++) {
        final amountSim = _amountsMatch(group[i].amount, group[j].amount)
            ? 1.0
            : 0.0;
        final descSim = _jaccardSimilarity(
          _tokenise(group[i].description),
          _tokenise(group[j].description),
        );
        totalSimilarity += (amountSim + descSim) / 2.0;
        pairs++;
      }
    }

    return pairs > 0 ? totalSimilarity / pairs : 0.0;
  }

  Set<String> _tokenise(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toSet();
  }

  double _jaccardSimilarity(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    return union > 0 ? intersection / union : 0.0;
  }
}
