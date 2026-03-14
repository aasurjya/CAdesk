import 'package:ca_app/features/accounts/domain/models/financial_statement.dart';
import 'package:ca_app/features/accounts/domain/repositories/accounts_repository.dart';

/// In-memory mock implementation of [AccountsRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockAccountsRepository implements AccountsRepository {
  static final List<FinancialStatement> _seed = [
    FinancialStatement(
      id: 'mock-stmt-001',
      clientId: 'mock-client-001',
      clientName: 'Ravi Kumar Enterprises',
      statementType: StatementType.balanceSheet,
      financialYear: 'FY 2024-25',
      format: StatementFormat.vertical,
      preparedBy: 'CA Anil Sharma',
      preparedDate: DateTime(2025, 4, 15),
      status: StatementStatus.approved,
      totalAssets: 12500000,
      totalLiabilities: 7200000,
      netProfit: 1850000,
    ),
    FinancialStatement(
      id: 'mock-stmt-002',
      clientId: 'mock-client-001',
      clientName: 'Ravi Kumar Enterprises',
      statementType: StatementType.profitLoss,
      financialYear: 'FY 2024-25',
      format: StatementFormat.vertical,
      preparedBy: 'CA Anil Sharma',
      preparedDate: DateTime(2025, 4, 15),
      status: StatementStatus.prepared,
      totalAssets: 0,
      totalLiabilities: 0,
      netProfit: 1850000,
    ),
    FinancialStatement(
      id: 'mock-stmt-003',
      clientId: 'mock-client-002',
      clientName: 'Priya Textiles Pvt Ltd',
      statementType: StatementType.trialBalance,
      financialYear: 'FY 2024-25',
      format: StatementFormat.horizontal,
      preparedBy: 'CA Meena Iyer',
      preparedDate: DateTime(2025, 5, 10),
      status: StatementStatus.draft,
      totalAssets: 45000000,
      totalLiabilities: 28000000,
      netProfit: 5200000,
    ),
  ];

  final List<FinancialStatement> _state = List.of(_seed);

  @override
  Future<List<FinancialStatement>> getStatementsByClient(
    String clientId,
    String financialYear,
  ) async {
    return List.unmodifiable(
      _state
          .where(
            (s) => s.clientId == clientId && s.financialYear == financialYear,
          )
          .toList(),
    );
  }

  @override
  Future<FinancialStatement?> getStatementById(String id) async {
    try {
      return _state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertStatement(FinancialStatement statement) async {
    _state.add(statement);
    return statement.id;
  }

  @override
  Future<bool> updateStatement(FinancialStatement statement) async {
    final idx = _state.indexWhere((s) => s.id == statement.id);
    if (idx == -1) return false;
    final updated = List<FinancialStatement>.of(_state)..[idx] = statement;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteStatement(String id) async {
    final before = _state.length;
    _state.removeWhere((s) => s.id == id);
    return _state.length < before;
  }

  @override
  Future<List<FinancialStatement>> getAllStatements() async {
    return List.unmodifiable(_state);
  }
}
