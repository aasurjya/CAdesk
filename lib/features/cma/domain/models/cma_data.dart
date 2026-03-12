import 'package:ca_app/features/cma/domain/models/cma_balance_sheet.dart';
import 'package:ca_app/features/cma/domain/models/cma_operating_statement.dart';
import 'package:ca_app/features/cma/domain/models/fund_flow_statement.dart';

/// Purpose of the bank loan for which the CMA is being prepared.
enum CmaLoanPurpose {
  /// Working capital facility (cash credit / overdraft).
  workingCapital(label: 'Working Capital'),

  /// Term loan for capital expenditure.
  termLoan(label: 'Term Loan'),

  /// Both working capital and term loan.
  both(label: 'Both');

  const CmaLoanPurpose({required this.label});

  final String label;
}

/// Immutable top-level CMA (Credit Monitoring Arrangement) data model.
///
/// Contains all five CMA forms' data keyed by fiscal year:
/// - Form I: [operatingStatements]
/// - Form II/III: [balanceSheets]
/// - Form V: [cashFlows]
///
/// [historicalYears] and [projectionYears] define which years contain
/// actual data versus projected figures.
class CmaData {
  const CmaData({
    required this.entityName,
    required this.pan,
    required this.purpose,
    required this.historicalYears,
    required this.projectionYears,
    required this.operatingStatements,
    required this.balanceSheets,
    required this.cashFlows,
  });

  /// Full legal name of the borrowing entity.
  final String entityName;

  /// Permanent Account Number (10-character alphanumeric, e.g. ABCDE1234F).
  final String pan;

  /// Nature of the credit facility being sought.
  final CmaLoanPurpose purpose;

  /// Fiscal years for which actual (audited) data is available.
  /// Typically the two most recent completed years.
  final List<int> historicalYears;

  /// Fiscal years for which projections are prepared.
  /// Typically 2–3 future years.
  final List<int> projectionYears;

  /// Operating statements (Form I) keyed by fiscal year.
  final Map<int, CmaOperatingStatement> operatingStatements;

  /// Balance sheet analysis (Form II) keyed by fiscal year.
  final Map<int, CmaBalanceSheet> balanceSheets;

  /// Fund flow statements (Form V) keyed by fiscal year.
  final Map<int, FundFlowStatement> cashFlows;

  /// All years covered: historical + projection years, sorted ascending.
  List<int> get allYears => [...historicalYears, ...projectionYears]..sort();

  CmaData copyWith({
    String? entityName,
    String? pan,
    CmaLoanPurpose? purpose,
    List<int>? historicalYears,
    List<int>? projectionYears,
    Map<int, CmaOperatingStatement>? operatingStatements,
    Map<int, CmaBalanceSheet>? balanceSheets,
    Map<int, FundFlowStatement>? cashFlows,
  }) {
    return CmaData(
      entityName: entityName ?? this.entityName,
      pan: pan ?? this.pan,
      purpose: purpose ?? this.purpose,
      historicalYears: historicalYears ?? this.historicalYears,
      projectionYears: projectionYears ?? this.projectionYears,
      operatingStatements: operatingStatements ?? this.operatingStatements,
      balanceSheets: balanceSheets ?? this.balanceSheets,
      cashFlows: cashFlows ?? this.cashFlows,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CmaData) return false;
    if (other.entityName != entityName) return false;
    if (other.pan != pan) return false;
    if (other.purpose != purpose) return false;
    if (other.historicalYears.length != historicalYears.length) return false;
    if (other.projectionYears.length != projectionYears.length) return false;
    for (var i = 0; i < historicalYears.length; i++) {
      if (other.historicalYears[i] != historicalYears[i]) return false;
    }
    for (var i = 0; i < projectionYears.length; i++) {
      if (other.projectionYears[i] != projectionYears[i]) return false;
    }
    if (other.operatingStatements.length != operatingStatements.length) {
      return false;
    }
    if (other.balanceSheets.length != balanceSheets.length) return false;
    if (other.cashFlows.length != cashFlows.length) return false;
    for (final key in operatingStatements.keys) {
      if (other.operatingStatements[key] != operatingStatements[key]) {
        return false;
      }
    }
    for (final key in balanceSheets.keys) {
      if (other.balanceSheets[key] != balanceSheets[key]) return false;
    }
    for (final key in cashFlows.keys) {
      if (other.cashFlows[key] != cashFlows[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    entityName,
    pan,
    purpose,
    Object.hashAll(historicalYears),
    Object.hashAll(projectionYears),
    Object.hashAll(operatingStatements.entries.map((e) => e.value)),
    Object.hashAll(balanceSheets.entries.map((e) => e.value)),
    Object.hashAll(cashFlows.entries.map((e) => e.value)),
  );
}
