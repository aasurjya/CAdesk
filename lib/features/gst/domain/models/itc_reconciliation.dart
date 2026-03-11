/// ITC reconciliation between GSTR-2A/2B auto-data and books.
class ItcReconciliation {
  const ItcReconciliation({
    required this.id,
    required this.clientId,
    required this.gstin,
    required this.period,
    required this.gstr2aItc,
    required this.booksItc,
    required this.matchedItc,
    required this.mismatchedItc,
    required this.missingInBooks,
    required this.missingIn2A,
    required this.status,
  });

  final String id;
  final String clientId;
  final String gstin;

  /// Human-readable period, e.g. "Feb 2026".
  final String period;

  /// Auto-populated ITC from the GST portal (GSTR-2A/2B).
  final double gstr2aItc;

  /// ITC as per the client's books of accounts.
  final double booksItc;

  /// Confirmed matched ITC amount.
  final double matchedItc;

  /// Amount that appears in both 2A and books but with different values.
  final double mismatchedItc;

  /// ITC present in GSTR-2A but missing in books.
  final double missingInBooks;

  /// ITC present in books but missing in GSTR-2A.
  final double missingIn2A;

  /// One of: Pending, In Progress, Reconciled, Escalated.
  final String status;

  /// Absolute difference between books and portal ITC as a percentage of books.
  double get differencePercent =>
      booksItc > 0 ? ((booksItc - gstr2aItc).abs() / booksItc * 100) : 0;

  bool get isReconciled => status == 'Reconciled';

  ItcReconciliation copyWith({
    String? id,
    String? clientId,
    String? gstin,
    String? period,
    double? gstr2aItc,
    double? booksItc,
    double? matchedItc,
    double? mismatchedItc,
    double? missingInBooks,
    double? missingIn2A,
    String? status,
  }) {
    return ItcReconciliation(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      gstin: gstin ?? this.gstin,
      period: period ?? this.period,
      gstr2aItc: gstr2aItc ?? this.gstr2aItc,
      booksItc: booksItc ?? this.booksItc,
      matchedItc: matchedItc ?? this.matchedItc,
      mismatchedItc: mismatchedItc ?? this.mismatchedItc,
      missingInBooks: missingInBooks ?? this.missingInBooks,
      missingIn2A: missingIn2A ?? this.missingIn2A,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItcReconciliation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
