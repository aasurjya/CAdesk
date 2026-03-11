/// Type of financial statement prepared.
enum StatementType {
  balanceSheet(label: 'Balance Sheet'),
  profitLoss(label: 'P&L'),
  trialBalance(label: 'Trial Balance'),
  cashFlow(label: 'Cash Flow'),
  capitalAccount(label: 'Capital Account');

  const StatementType({required this.label});

  final String label;
}

/// Presentation format for the balance sheet.
enum StatementFormat {
  horizontal(label: 'Horizontal'),
  vertical(label: 'Vertical');

  const StatementFormat({required this.label});

  final String label;
}

/// Workflow status of the financial statement.
enum StatementStatus {
  draft(label: 'Draft'),
  prepared(label: 'Prepared'),
  approved(label: 'Approved'),
  filed(label: 'Filed');

  const StatementStatus({required this.label});

  final String label;
}

/// Immutable model representing a prepared financial statement for a client.
class FinancialStatement {
  const FinancialStatement({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.statementType,
    required this.financialYear,
    required this.format,
    required this.preparedBy,
    required this.preparedDate,
    required this.status,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netProfit,
    this.approvedDate,
  });

  final String id;
  final String clientId;
  final String clientName;
  final StatementType statementType;

  /// e.g. "FY 2024-25"
  final String financialYear;
  final StatementFormat format;
  final String preparedBy;
  final DateTime preparedDate;
  final DateTime? approvedDate;
  final StatementStatus status;
  final double totalAssets;
  final double totalLiabilities;
  final double netProfit;

  FinancialStatement copyWith({
    String? id,
    String? clientId,
    String? clientName,
    StatementType? statementType,
    String? financialYear,
    StatementFormat? format,
    String? preparedBy,
    DateTime? preparedDate,
    DateTime? approvedDate,
    StatementStatus? status,
    double? totalAssets,
    double? totalLiabilities,
    double? netProfit,
  }) {
    return FinancialStatement(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      statementType: statementType ?? this.statementType,
      financialYear: financialYear ?? this.financialYear,
      format: format ?? this.format,
      preparedBy: preparedBy ?? this.preparedBy,
      preparedDate: preparedDate ?? this.preparedDate,
      approvedDate: approvedDate ?? this.approvedDate,
      status: status ?? this.status,
      totalAssets: totalAssets ?? this.totalAssets,
      totalLiabilities: totalLiabilities ?? this.totalLiabilities,
      netProfit: netProfit ?? this.netProfit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialStatement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
