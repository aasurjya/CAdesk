/// Risk classification for client churn likelihood.
enum ChurnRisk {
  /// Score 70–100: client is healthy.
  low('Low'),

  /// Score 40–69: some warning signs present.
  medium('Medium'),

  /// Score 20–39: significant churn risk.
  high('High'),

  /// Score 0–19: likely churning.
  critical('Critical');

  const ChurnRisk(this.label);

  final String label;
}

/// Computed health score for a single client, used for churn prediction.
///
/// [score] is in the range 0–100; higher is healthier.
class ClientHealthScore {
  const ClientHealthScore({
    required this.clientPan,
    required this.score,
    required this.churnRisk,
    required this.riskFactors,
    required this.lastServiceDate,
    required this.lastPaymentDate,
    required this.outstandingAmount,
    required this.engagementCount,
    required this.recommendation,
  });

  /// PAN of the client being scored.
  final String clientPan;

  /// Health score in the range 0.0–100.0.
  final double score;

  /// Derived churn risk level based on [score].
  final ChurnRisk churnRisk;

  /// Human-readable list of negative factors that reduced the score.
  final List<String> riskFactors;

  /// Date of the most recent completed engagement, or null if none.
  final DateTime? lastServiceDate;

  /// Date of the most recent invoice payment, or null if none.
  final DateTime? lastPaymentDate;

  /// Total outstanding (unpaid) invoice amount in paise.
  final int outstandingAmount;

  /// Number of engagements completed in the past 12 months.
  final int engagementCount;

  /// Actionable recommendation for the CA to retain this client.
  final String recommendation;

  ClientHealthScore copyWith({
    String? clientPan,
    double? score,
    ChurnRisk? churnRisk,
    List<String>? riskFactors,
    DateTime? lastServiceDate,
    DateTime? lastPaymentDate,
    int? outstandingAmount,
    int? engagementCount,
    String? recommendation,
  }) {
    return ClientHealthScore(
      clientPan: clientPan ?? this.clientPan,
      score: score ?? this.score,
      churnRisk: churnRisk ?? this.churnRisk,
      riskFactors: riskFactors ?? this.riskFactors,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      engagementCount: engagementCount ?? this.engagementCount,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientHealthScore &&
        other.clientPan == clientPan &&
        other.score == score &&
        other.churnRisk == churnRisk &&
        other.outstandingAmount == outstandingAmount &&
        other.engagementCount == engagementCount &&
        other.lastServiceDate == lastServiceDate &&
        other.lastPaymentDate == lastPaymentDate &&
        other.recommendation == recommendation;
  }

  @override
  int get hashCode => Object.hash(
    clientPan,
    score,
    churnRisk,
    outstandingAmount,
    engagementCount,
    lastServiceDate,
    lastPaymentDate,
    recommendation,
  );
}
