import 'package:flutter/material.dart';

/// Status of a CMA report in its lifecycle.
enum CmaReportStatus {
  draft(
    label: 'Draft',
    color: Color(0xFF718096),
    icon: Icons.edit_note_rounded,
  ),
  submitted(
    label: 'Submitted',
    color: Color(0xFFD4890E),
    icon: Icons.upload_file_rounded,
  ),
  approved(
    label: 'Approved',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  ),
  rejected(
    label: 'Rejected',
    color: Color(0xFFC62828),
    icon: Icons.cancel_rounded,
  );

  const CmaReportStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Projected financials for a single year in a CMA report.
class YearProjection {
  const YearProjection({
    required this.year,
    required this.sales,
    required this.cogs,
    required this.grossProfit,
    required this.operatingExpenses,
    required this.ebitda,
    required this.netProfit,
    required this.currentAssets,
    required this.currentLiabilities,
    required this.totalDebt,
    required this.netWorth,
    required this.dscr,
    required this.mpbf,
  });

  final int year;
  final double sales;
  final double cogs;
  final double grossProfit;
  final double operatingExpenses;
  final double ebitda;
  final double netProfit;
  final double currentAssets;
  final double currentLiabilities;
  final double totalDebt;
  final double netWorth;

  /// Debt Service Coverage Ratio.
  final double dscr;

  /// Maximum Permissible Bank Finance.
  final double mpbf;

  double get grossMarginPct => sales > 0 ? (grossProfit / sales) * 100 : 0;

  double get netMarginPct => sales > 0 ? (netProfit / sales) * 100 : 0;

  double get currentRatio =>
      currentLiabilities > 0 ? currentAssets / currentLiabilities : 0;

  YearProjection copyWith({
    int? year,
    double? sales,
    double? cogs,
    double? grossProfit,
    double? operatingExpenses,
    double? ebitda,
    double? netProfit,
    double? currentAssets,
    double? currentLiabilities,
    double? totalDebt,
    double? netWorth,
    double? dscr,
    double? mpbf,
  }) {
    return YearProjection(
      year: year ?? this.year,
      sales: sales ?? this.sales,
      cogs: cogs ?? this.cogs,
      grossProfit: grossProfit ?? this.grossProfit,
      operatingExpenses: operatingExpenses ?? this.operatingExpenses,
      ebitda: ebitda ?? this.ebitda,
      netProfit: netProfit ?? this.netProfit,
      currentAssets: currentAssets ?? this.currentAssets,
      currentLiabilities: currentLiabilities ?? this.currentLiabilities,
      totalDebt: totalDebt ?? this.totalDebt,
      netWorth: netWorth ?? this.netWorth,
      dscr: dscr ?? this.dscr,
      mpbf: mpbf ?? this.mpbf,
    );
  }
}

/// Immutable CMA (Credit Monitoring Arrangement) report model.
class CmaReport {
  const CmaReport({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.bankName,
    required this.loanPurpose,
    required this.projectionYears,
    required this.status,
    required this.preparedDate,
    required this.requestedAmount,
    required this.projections,
    this.submittedDate,
    this.sanctionedAmount,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String bankName;
  final String loanPurpose;
  final int projectionYears;
  final CmaReportStatus status;
  final DateTime preparedDate;
  final DateTime? submittedDate;
  final double requestedAmount;
  final double? sanctionedAmount;
  final List<YearProjection> projections;

  /// DSCR from the latest projection year (or 0 if no projections).
  double get latestDscr => projections.isEmpty ? 0 : projections.last.dscr;

  /// Whether DSCR meets the typical minimum threshold of 1.25.
  bool get dscrAcceptable => latestDscr >= 1.25;

  CmaReport copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? bankName,
    String? loanPurpose,
    int? projectionYears,
    CmaReportStatus? status,
    DateTime? preparedDate,
    DateTime? submittedDate,
    double? requestedAmount,
    double? sanctionedAmount,
    List<YearProjection>? projections,
  }) {
    return CmaReport(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      bankName: bankName ?? this.bankName,
      loanPurpose: loanPurpose ?? this.loanPurpose,
      projectionYears: projectionYears ?? this.projectionYears,
      status: status ?? this.status,
      preparedDate: preparedDate ?? this.preparedDate,
      submittedDate: submittedDate ?? this.submittedDate,
      requestedAmount: requestedAmount ?? this.requestedAmount,
      sanctionedAmount: sanctionedAmount ?? this.sanctionedAmount,
      projections: projections ?? this.projections,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CmaReport && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
