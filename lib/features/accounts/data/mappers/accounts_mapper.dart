import 'package:ca_app/features/accounts/domain/models/financial_statement.dart';

/// Bi-directional converter between [FinancialStatement] domain model
/// and Supabase JSON maps.
class AccountsMapper {
  const AccountsMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → FinancialStatement domain model
  // ---------------------------------------------------------------------------
  static FinancialStatement fromJson(Map<String, dynamic> json) {
    return FinancialStatement(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String? ?? '',
      statementType: _parseStatementType(json['statement_type'] as String?),
      financialYear: json['financial_year'] as String? ?? '',
      format: _parseFormat(json['format'] as String?),
      preparedBy: json['prepared_by'] as String? ?? '',
      preparedDate: DateTime.parse(json['prepared_date'] as String),
      approvedDate: json['approved_date'] != null
          ? DateTime.parse(json['approved_date'] as String)
          : null,
      status: _parseStatus(json['status'] as String?),
      totalAssets: _toDouble(json['total_assets']),
      totalLiabilities: _toDouble(json['total_liabilities']),
      netProfit: _toDouble(json['net_profit']),
    );
  }

  // ---------------------------------------------------------------------------
  // FinancialStatement domain model → JSON (Supabase insert/update)
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> toJson(FinancialStatement s) {
    return {
      'id': s.id,
      'client_id': s.clientId,
      'client_name': s.clientName,
      'statement_type': s.statementType.name,
      'financial_year': s.financialYear,
      'format': s.format.name,
      'prepared_by': s.preparedBy,
      'prepared_date': s.preparedDate.toIso8601String(),
      'approved_date': s.approvedDate?.toIso8601String(),
      'status': s.status.name,
      'total_assets': s.totalAssets,
      'total_liabilities': s.totalLiabilities,
      'net_profit': s.netProfit,
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static StatementType _parseStatementType(String? raw) {
    switch (raw) {
      case 'balanceSheet':
        return StatementType.balanceSheet;
      case 'profitLoss':
        return StatementType.profitLoss;
      case 'trialBalance':
        return StatementType.trialBalance;
      case 'cashFlow':
        return StatementType.cashFlow;
      case 'capitalAccount':
        return StatementType.capitalAccount;
      default:
        return StatementType.balanceSheet;
    }
  }

  static StatementFormat _parseFormat(String? raw) {
    switch (raw) {
      case 'horizontal':
        return StatementFormat.horizontal;
      case 'vertical':
      default:
        return StatementFormat.vertical;
    }
  }

  static StatementStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'prepared':
        return StatementStatus.prepared;
      case 'approved':
        return StatementStatus.approved;
      case 'filed':
        return StatementStatus.filed;
      case 'draft':
      default:
        return StatementStatus.draft;
    }
  }

  static double _toDouble(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0.0;
    return 0.0;
  }
}
