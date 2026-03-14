import 'package:ca_app/features/cma/domain/models/cma_report.dart';
import 'package:ca_app/features/cma/domain/repositories/cma_repository.dart';

/// In-memory mock implementation of [CmaRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations use immutable patterns.
class MockCmaRepository implements CmaRepository {
  static final List<CmaReport> _seed = [
    CmaReport(
      id: 'mock-cma-001',
      clientId: 'mock-client-001',
      clientName: 'Ravi Kumar Enterprises',
      bankName: 'Punjab National Bank',
      loanPurpose: 'Term Loan for Plant & Machinery',
      projectionYears: 5,
      status: CmaReportStatus.approved,
      preparedDate: DateTime(2025, 11, 1),
      submittedDate: DateTime(2025, 11, 15),
      requestedAmount: 25000000,
      sanctionedAmount: 22000000,
      projections: const [
        YearProjection(
          year: 2025,
          sales: 85000000,
          cogs: 62000000,
          grossProfit: 23000000,
          operatingExpenses: 10000000,
          ebitda: 13000000,
          netProfit: 8500000,
          currentAssets: 35000000,
          currentLiabilities: 18000000,
          totalDebt: 22000000,
          netWorth: 45000000,
          dscr: 1.85,
          mpbf: 11700000,
        ),
      ],
    ),
    CmaReport(
      id: 'mock-cma-002',
      clientId: 'mock-client-001',
      clientName: 'Ravi Kumar Enterprises',
      bankName: 'State Bank of India',
      loanPurpose: 'Working Capital Loan',
      projectionYears: 3,
      status: CmaReportStatus.draft,
      preparedDate: DateTime(2026, 2, 1),
      requestedAmount: 10000000,
      projections: const [],
    ),
    CmaReport(
      id: 'mock-cma-003',
      clientId: 'mock-client-002',
      clientName: 'Priya Textiles Pvt Ltd',
      bankName: 'HDFC Bank',
      loanPurpose: 'Expansion of Manufacturing Facility',
      projectionYears: 5,
      status: CmaReportStatus.submitted,
      preparedDate: DateTime(2026, 1, 20),
      submittedDate: DateTime(2026, 2, 5),
      requestedAmount: 50000000,
      projections: const [
        YearProjection(
          year: 2025,
          sales: 180000000,
          cogs: 130000000,
          grossProfit: 50000000,
          operatingExpenses: 22000000,
          ebitda: 28000000,
          netProfit: 18000000,
          currentAssets: 75000000,
          currentLiabilities: 40000000,
          totalDebt: 50000000,
          netWorth: 120000000,
          dscr: 1.65,
          mpbf: 26250000,
        ),
      ],
    ),
  ];

  final List<CmaReport> _state = List.of(_seed);

  @override
  Future<List<CmaReport>> getReportsByClient(String clientId) async {
    return List.unmodifiable(
      _state.where((r) => r.clientId == clientId).toList(),
    );
  }

  @override
  Future<CmaReport?> getReportById(String id) async {
    try {
      return _state.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertReport(CmaReport report) async {
    _state.add(report);
    return report.id;
  }

  @override
  Future<bool> updateReport(CmaReport report) async {
    final idx = _state.indexWhere((r) => r.id == report.id);
    if (idx == -1) return false;
    final updated = List<CmaReport>.of(_state)..[idx] = report;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteReport(String id) async {
    final before = _state.length;
    _state.removeWhere((r) => r.id == id);
    return _state.length < before;
  }

  @override
  Future<List<CmaReport>> getAllReports() async {
    return List.unmodifiable(_state);
  }
}
