/// Sections under which interest on tax can be levied / claimed.
enum InterestSection {
  section234B(label: '234B', fullLabel: 'Section 234B — Advance Tax Default'),
  section234C(
    label: '234C',
    fullLabel: 'Section 234C — Deferment of Advance Tax',
  ),
  section234D(label: '234D', fullLabel: 'Section 234D — Excess Refund'),
  section220_2(
    label: '220(2)',
    fullLabel: 'Section 220(2) — Failure to Pay Demand',
  ),
  section244A(label: '244A', fullLabel: 'Section 244A — Interest on Refunds');

  const InterestSection({required this.label, required this.fullLabel});

  final String label;
  final String fullLabel;
}

/// Immutable model representing an interest calculation check
/// against a tax assessment order.
class InterestCalculation {
  const InterestCalculation({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.clientName,
    required this.section,
    required this.principal,
    required this.rate,
    required this.period,
    required this.calculatedInterest,
    required this.actualInterest,
    required this.variance,
    required this.isCorrect,
  });

  final String id;
  final String orderId;
  final String clientId;
  final String clientName;
  final InterestSection section;

  /// Principal tax amount on which interest is computed (INR).
  final double principal;

  /// Monthly interest rate (%).
  final double rate;

  /// Period in months.
  final int period;

  /// Interest as computed by the CA (INR).
  final double calculatedInterest;

  /// Interest as shown in the assessment order (INR).
  final double actualInterest;

  /// Difference: calculatedInterest - actualInterest (INR).
  /// Negative = over-charged by department; positive = under-charged.
  final double variance;

  /// True when |variance| <= 1 % of calculatedInterest (i.e., no material error).
  final bool isCorrect;

  InterestCalculation copyWith({
    String? id,
    String? orderId,
    String? clientId,
    String? clientName,
    InterestSection? section,
    double? principal,
    double? rate,
    int? period,
    double? calculatedInterest,
    double? actualInterest,
    double? variance,
    bool? isCorrect,
  }) {
    return InterestCalculation(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      section: section ?? this.section,
      principal: principal ?? this.principal,
      rate: rate ?? this.rate,
      period: period ?? this.period,
      calculatedInterest: calculatedInterest ?? this.calculatedInterest,
      actualInterest: actualInterest ?? this.actualInterest,
      variance: variance ?? this.variance,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterestCalculation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
