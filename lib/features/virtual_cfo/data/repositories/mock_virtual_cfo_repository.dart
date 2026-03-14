import 'package:ca_app/features/virtual_cfo/domain/models/cfo_scenario.dart';
import 'package:ca_app/features/virtual_cfo/domain/models/mis_report.dart';
import 'package:ca_app/features/virtual_cfo/domain/repositories/virtual_cfo_repository.dart';

/// In-memory mock implementation of [VirtualCfoRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockVirtualCfoRepository implements VirtualCfoRepository {
  static final List<MisReport> _seedReports = [
    const MisReport(
      id: 'mis-mock-001',
      clientName: 'Apex Manufacturing Pvt Ltd',
      reportType: 'Monthly P&L',
      period: 'Feb 2026',
      revenue: 48.5,
      expenses: 36.2,
      netProfit: 12.3,
      ebitdaMarginPercent: 28.5,
      cashBalance: 15.8,
      status: 'Approved',
      keyHighlights: [
        'Revenue grew 12% MoM driven by export orders',
        'Raw material costs down 3% post renegotiation',
      ],
    ),
    const MisReport(
      id: 'mis-mock-002',
      clientName: 'Blue Horizon Retail LLP',
      reportType: 'Cash Flow',
      period: 'Feb 2026',
      revenue: 22.1,
      expenses: 19.8,
      netProfit: 2.3,
      ebitdaMarginPercent: 14.2,
      cashBalance: 4.5,
      status: 'Draft',
      keyHighlights: [
        'Working capital tightened — debtor days at 45',
        'Creditor days improved to 32',
      ],
    ),
  ];

  static final List<CfoScenario> _seedScenarios = [
    const CfoScenario(
      id: 'scen-mock-001',
      clientName: 'Apex Manufacturing Pvt Ltd',
      scenarioName: 'Best Case',
      category: 'Revenue',
      baselineValue: 48.5,
      projectedValue: 58.2,
      impactPercent: 20.0,
      timeHorizon: 'Q1 FY27',
      assumption: 'Export orders increase 25% with new Gulf market entry',
    ),
    const CfoScenario(
      id: 'scen-mock-002',
      clientName: 'Apex Manufacturing Pvt Ltd',
      scenarioName: 'Worst Case',
      category: 'Cost',
      baselineValue: 36.2,
      projectedValue: 41.5,
      impactPercent: -14.6,
      timeHorizon: 'Q1 FY27',
      assumption: 'Steel prices surge 15% on supply shock',
    ),
  ];

  final List<MisReport> _reports = List.of(_seedReports);
  final List<CfoScenario> _scenarios = List.of(_seedScenarios);

  @override
  Future<List<MisReport>> getAllReports() async {
    return List.unmodifiable(_reports);
  }

  @override
  Future<List<MisReport>> getReportsByClient(String clientName) async {
    return List.unmodifiable(
      _reports.where((r) => r.clientName == clientName).toList(),
    );
  }

  @override
  Future<String> insertReport(MisReport report) async {
    _reports.add(report);
    return report.id;
  }

  @override
  Future<bool> updateReport(MisReport report) async {
    final idx = _reports.indexWhere((r) => r.id == report.id);
    if (idx == -1) return false;
    final updated = List<MisReport>.of(_reports)..[idx] = report;
    _reports
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteReport(String id) async {
    final before = _reports.length;
    _reports.removeWhere((r) => r.id == id);
    return _reports.length < before;
  }

  @override
  Future<List<CfoScenario>> getAllScenarios() async {
    return List.unmodifiable(_scenarios);
  }

  @override
  Future<List<CfoScenario>> getScenariosByClient(String clientName) async {
    return List.unmodifiable(
      _scenarios.where((s) => s.clientName == clientName).toList(),
    );
  }

  @override
  Future<String> insertScenario(CfoScenario scenario) async {
    _scenarios.add(scenario);
    return scenario.id;
  }

  @override
  Future<bool> updateScenario(CfoScenario scenario) async {
    final idx = _scenarios.indexWhere((s) => s.id == scenario.id);
    if (idx == -1) return false;
    final updated = List<CfoScenario>.of(_scenarios)..[idx] = scenario;
    _scenarios
      ..clear()
      ..addAll(updated);
    return true;
  }
}
