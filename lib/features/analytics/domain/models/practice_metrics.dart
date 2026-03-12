/// Aggregated practice performance metrics for a given fiscal period.
///
/// All monetary values are in paise (100 paise = ₹1).
class PracticeMetrics {
  const PracticeMetrics({
    required this.period,
    required this.firmId,
    required this.totalRevenue,
    required this.revenueGrowth,
    required this.totalClients,
    required this.newClients,
    required this.churnedClients,
    required this.filingComplianceRate,
    required this.pendingFilings,
    required this.overdueFilings,
    required this.utilizationRate,
  });

  /// Fiscal period label, e.g. "FY2024-25".
  final String period;

  /// Identifier for the CA firm.
  final String firmId;

  /// Total revenue billed in this period, in paise.
  final int totalRevenue;

  /// Year-over-year revenue growth as a percentage.
  ///
  /// Positive values indicate growth; negative indicates decline.
  final double revenueGrowth;

  /// Total number of active clients in this period.
  final int totalClients;

  /// Number of new clients acquired in this period.
  final int newClients;

  /// Number of clients lost in this period.
  final int churnedClients;

  /// Fraction of filings submitted on or before deadline (0.0–1.0).
  final double filingComplianceRate;

  /// Count of filings awaiting submission.
  final int pendingFilings;

  /// Count of filings past their deadline.
  final int overdueFilings;

  /// Ratio of billable hours to total available hours (0.0–1.0).
  final double utilizationRate;

  /// Average revenue per active client in paise.
  ///
  /// Returns 0 when [totalClients] is zero to avoid division by zero.
  int get avgRevenuePerClient {
    if (totalClients == 0) return 0;
    return (totalRevenue / totalClients).truncate();
  }

  PracticeMetrics copyWith({
    String? period,
    String? firmId,
    int? totalRevenue,
    double? revenueGrowth,
    int? totalClients,
    int? newClients,
    int? churnedClients,
    double? filingComplianceRate,
    int? pendingFilings,
    int? overdueFilings,
    double? utilizationRate,
  }) {
    return PracticeMetrics(
      period: period ?? this.period,
      firmId: firmId ?? this.firmId,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      revenueGrowth: revenueGrowth ?? this.revenueGrowth,
      totalClients: totalClients ?? this.totalClients,
      newClients: newClients ?? this.newClients,
      churnedClients: churnedClients ?? this.churnedClients,
      filingComplianceRate: filingComplianceRate ?? this.filingComplianceRate,
      pendingFilings: pendingFilings ?? this.pendingFilings,
      overdueFilings: overdueFilings ?? this.overdueFilings,
      utilizationRate: utilizationRate ?? this.utilizationRate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PracticeMetrics &&
        other.period == period &&
        other.firmId == firmId &&
        other.totalRevenue == totalRevenue &&
        other.revenueGrowth == revenueGrowth &&
        other.totalClients == totalClients &&
        other.newClients == newClients &&
        other.churnedClients == churnedClients &&
        other.filingComplianceRate == filingComplianceRate &&
        other.pendingFilings == pendingFilings &&
        other.overdueFilings == overdueFilings &&
        other.utilizationRate == utilizationRate;
  }

  @override
  int get hashCode => Object.hash(
    period,
    firmId,
    totalRevenue,
    revenueGrowth,
    totalClients,
    newClients,
    churnedClients,
    filingComplianceRate,
    pendingFilings,
    overdueFilings,
    utilizationRate,
  );
}
