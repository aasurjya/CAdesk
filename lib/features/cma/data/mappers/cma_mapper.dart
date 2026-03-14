import 'package:ca_app/features/cma/domain/models/cma_report.dart';

/// Bi-directional converter between [CmaReport] domain model
/// and Supabase JSON maps.
class CmaMapper {
  const CmaMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → CmaReport domain model
  // ---------------------------------------------------------------------------
  static CmaReport fromJson(Map<String, dynamic> json) {
    final rawProjections = json['projections'];
    final projections = rawProjections is List
        ? rawProjections
              .map((p) => _projectionFromJson(p as Map<String, dynamic>))
              .toList()
        : <YearProjection>[];

    return CmaReport(
      id: json['id'] as String,
      clientId: json['client_id'] as String? ?? '',
      clientName: json['client_name'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? '',
      loanPurpose: json['loan_purpose'] as String? ?? '',
      projectionYears: json['projection_years'] as int? ?? 1,
      status: _parseStatus(json['status'] as String?),
      preparedDate: DateTime.parse(json['prepared_date'] as String),
      submittedDate: json['submitted_date'] != null
          ? DateTime.parse(json['submitted_date'] as String)
          : null,
      requestedAmount: _toDouble(json['requested_amount']),
      sanctionedAmount: json['sanctioned_amount'] != null
          ? _toDouble(json['sanctioned_amount'])
          : null,
      projections: projections,
    );
  }

  // ---------------------------------------------------------------------------
  // CmaReport domain model → JSON (Supabase insert/update)
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> toJson(CmaReport r) {
    return {
      'id': r.id,
      'client_id': r.clientId,
      'client_name': r.clientName,
      'bank_name': r.bankName,
      'loan_purpose': r.loanPurpose,
      'projection_years': r.projectionYears,
      'status': r.status.name,
      'prepared_date': r.preparedDate.toIso8601String(),
      'submitted_date': r.submittedDate?.toIso8601String(),
      'requested_amount': r.requestedAmount,
      'sanctioned_amount': r.sanctionedAmount,
      'projections': r.projections.map(_projectionToJson).toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static YearProjection _projectionFromJson(Map<String, dynamic> json) {
    return YearProjection(
      year: json['year'] as int? ?? 0,
      sales: _toDouble(json['sales']),
      cogs: _toDouble(json['cogs']),
      grossProfit: _toDouble(json['gross_profit']),
      operatingExpenses: _toDouble(json['operating_expenses']),
      ebitda: _toDouble(json['ebitda']),
      netProfit: _toDouble(json['net_profit']),
      currentAssets: _toDouble(json['current_assets']),
      currentLiabilities: _toDouble(json['current_liabilities']),
      totalDebt: _toDouble(json['total_debt']),
      netWorth: _toDouble(json['net_worth']),
      dscr: _toDouble(json['dscr']),
      mpbf: _toDouble(json['mpbf']),
    );
  }

  static Map<String, dynamic> _projectionToJson(YearProjection p) {
    return {
      'year': p.year,
      'sales': p.sales,
      'cogs': p.cogs,
      'gross_profit': p.grossProfit,
      'operating_expenses': p.operatingExpenses,
      'ebitda': p.ebitda,
      'net_profit': p.netProfit,
      'current_assets': p.currentAssets,
      'current_liabilities': p.currentLiabilities,
      'total_debt': p.totalDebt,
      'net_worth': p.netWorth,
      'dscr': p.dscr,
      'mpbf': p.mpbf,
    };
  }

  static CmaReportStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'submitted':
        return CmaReportStatus.submitted;
      case 'approved':
        return CmaReportStatus.approved;
      case 'rejected':
        return CmaReportStatus.rejected;
      case 'draft':
      default:
        return CmaReportStatus.draft;
    }
  }

  static double _toDouble(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0.0;
    return 0.0;
  }
}
