/// Immutable model representing a MIS (Management Information System) report
/// prepared for a Virtual CFO client.
class MisReport {
  const MisReport({
    required this.id,
    required this.clientName,
    required this.reportType,
    required this.period,
    required this.revenue,
    required this.expenses,
    required this.netProfit,
    required this.ebitdaMarginPercent,
    required this.cashBalance,
    required this.status,
    required this.keyHighlights,
  });

  final String id;
  final String clientName;

  /// One of: Monthly P&L, Cash Flow, Balance Sheet, KPI Dashboard, Board Pack
  final String reportType;

  /// Human-readable period label, e.g. "Feb 2025".
  final String period;

  /// Revenue in Indian Rupee lakhs.
  final double revenue;

  /// Total expenses in lakhs.
  final double expenses;

  /// Net profit in lakhs.
  final double netProfit;

  /// EBITDA margin expressed as a percentage (0–100).
  final double ebitdaMarginPercent;

  /// Closing cash balance in lakhs.
  final double cashBalance;

  /// Workflow status: Draft | Review | Approved | Delivered
  final String status;

  /// Two or three bullet-point highlights for this report.
  final List<String> keyHighlights;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  MisReport copyWith({
    String? id,
    String? clientName,
    String? reportType,
    String? period,
    double? revenue,
    double? expenses,
    double? netProfit,
    double? ebitdaMarginPercent,
    double? cashBalance,
    String? status,
    List<String>? keyHighlights,
  }) {
    return MisReport(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      reportType: reportType ?? this.reportType,
      period: period ?? this.period,
      revenue: revenue ?? this.revenue,
      expenses: expenses ?? this.expenses,
      netProfit: netProfit ?? this.netProfit,
      ebitdaMarginPercent: ebitdaMarginPercent ?? this.ebitdaMarginPercent,
      cashBalance: cashBalance ?? this.cashBalance,
      status: status ?? this.status,
      keyHighlights: keyHighlights ?? this.keyHighlights,
    );
  }
}
