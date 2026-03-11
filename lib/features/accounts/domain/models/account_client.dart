/// Business type classifications for accounting clients.
enum BusinessType {
  proprietorship(label: 'Proprietorship'),
  partnership(label: 'Partnership'),
  company(label: 'Company'),
  trust(label: 'Trust'),
  huf(label: 'HUF');

  const BusinessType({required this.label});

  final String label;
}

/// Status of an account client's financial statements.
enum AccountClientStatus {
  draft(label: 'Draft'),
  underReview(label: 'Under Review'),
  finalized(label: 'Finalized');

  const AccountClientStatus({required this.label});

  final String label;
}

/// Immutable model representing a client for accounting/balance sheet work.
class AccountClient {
  const AccountClient({
    required this.id,
    required this.name,
    required this.pan,
    required this.businessType,
    required this.financialYear,
    required this.turnover,
    required this.totalAssets,
    required this.netProfit,
    required this.grossProfit,
    required this.currentRatio,
    required this.status,
    this.hasAudit = false,
    this.auditorName,
  });

  final String id;
  final String name;

  /// 10-character PAN (e.g. AABCS1234D).
  final String pan;
  final BusinessType businessType;

  /// e.g. "FY 2024-25"
  final String financialYear;
  final bool hasAudit;
  final double turnover;
  final double totalAssets;
  final double netProfit;
  final double grossProfit;

  /// Current ratio = current assets / current liabilities.
  final double currentRatio;
  final String? auditorName;
  final AccountClientStatus status;

  AccountClient copyWith({
    String? id,
    String? name,
    String? pan,
    BusinessType? businessType,
    String? financialYear,
    bool? hasAudit,
    double? turnover,
    double? totalAssets,
    double? netProfit,
    double? grossProfit,
    double? currentRatio,
    String? auditorName,
    AccountClientStatus? status,
  }) {
    return AccountClient(
      id: id ?? this.id,
      name: name ?? this.name,
      pan: pan ?? this.pan,
      businessType: businessType ?? this.businessType,
      financialYear: financialYear ?? this.financialYear,
      hasAudit: hasAudit ?? this.hasAudit,
      turnover: turnover ?? this.turnover,
      totalAssets: totalAssets ?? this.totalAssets,
      netProfit: netProfit ?? this.netProfit,
      grossProfit: grossProfit ?? this.grossProfit,
      currentRatio: currentRatio ?? this.currentRatio,
      auditorName: auditorName ?? this.auditorName,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountClient &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
