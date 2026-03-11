import 'package:flutter/material.dart';

/// Match status for a bank reconciliation entry.
enum MatchStatus {
  autoMatched(
    label: 'Auto-Matched',
    color: Color(0xFF1A7A3A),
    icon: Icons.auto_awesome_rounded,
  ),
  manual(
    label: 'Manual',
    color: Color(0xFF1565C0),
    icon: Icons.touch_app_rounded,
  ),
  unmatched(
    label: 'Unmatched',
    color: Color(0xFFEF6C00),
    icon: Icons.link_off_rounded,
  ),
  disputed(
    label: 'Disputed',
    color: Color(0xFFC62828),
    icon: Icons.warning_amber_rounded,
  );

  const MatchStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a bank reconciliation match.
class BankReconciliation {
  const BankReconciliation({
    required this.id,
    required this.bankEntry,
    required this.bookEntry,
    required this.matchConfidence,
    required this.matchStatus,
    required this.reconciledAt,
    required this.amountInr,
    required this.clientName,
    required this.bankName,
  });

  final String id;
  final String bankEntry;
  final String bookEntry;
  final double matchConfidence;
  final MatchStatus matchStatus;
  final DateTime reconciledAt;
  final double amountInr;
  final String clientName;
  final String bankName;

  /// Confidence percentage as a user-friendly string.
  String get confidenceLabel =>
      '${(matchConfidence * 100).toStringAsFixed(1)}%';

  /// True when match confidence is below 70%.
  bool get isLowConfidence => matchConfidence < 0.70;

  /// Amount formatted as INR string.
  String get formattedAmount {
    final isNegative = amountInr < 0;
    final absolute = amountInr.abs();
    final formatted = absolute >= 100000
        ? '${(absolute / 100000).toStringAsFixed(2)}L'
        : absolute >= 1000
            ? '${(absolute / 1000).toStringAsFixed(1)}K'
            : absolute.toStringAsFixed(2);
    return '${isNegative ? "-" : ""}INR $formatted';
  }

  BankReconciliation copyWith({
    String? id,
    String? bankEntry,
    String? bookEntry,
    double? matchConfidence,
    MatchStatus? matchStatus,
    DateTime? reconciledAt,
    double? amountInr,
    String? clientName,
    String? bankName,
  }) {
    return BankReconciliation(
      id: id ?? this.id,
      bankEntry: bankEntry ?? this.bankEntry,
      bookEntry: bookEntry ?? this.bookEntry,
      matchConfidence: matchConfidence ?? this.matchConfidence,
      matchStatus: matchStatus ?? this.matchStatus,
      reconciledAt: reconciledAt ?? this.reconciledAt,
      amountInr: amountInr ?? this.amountInr,
      clientName: clientName ?? this.clientName,
      bankName: bankName ?? this.bankName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankReconciliation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
