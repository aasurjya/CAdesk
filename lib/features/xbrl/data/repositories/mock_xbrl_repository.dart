import 'package:ca_app/features/xbrl/domain/models/xbrl_filing.dart';
import 'package:ca_app/features/xbrl/domain/repositories/xbrl_repository.dart';

/// In-memory mock implementation of [XbrlRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockXbrlRepository implements XbrlRepository {
  static final List<XbrlFiling> _seed = [
    XbrlFiling(
      id: 'xbrl-mock-001',
      companyId: 'comp-001',
      companyName: 'Reliance Industries Ltd',
      cin: 'L17110MH1973PLC019786',
      financialYear: '2024-25',
      reportType: XbrlReportType.standalone,
      taxonomyVersion: '2023',
      status: XbrlFilingStatus.filed,
      totalTags: 450,
      completedTags: 450,
      validationErrors: 0,
      validationWarnings: 2,
      startedDate: DateTime(2025, 6, 1),
      filedDate: DateTime(2025, 9, 28),
      preparedBy: 'Staff A',
      reviewedBy: 'Partner B',
    ),
    XbrlFiling(
      id: 'xbrl-mock-002',
      companyId: 'comp-002',
      companyName: 'Tata Consultancy Services Ltd',
      cin: 'L22210MH1995PLC084781',
      financialYear: '2024-25',
      reportType: XbrlReportType.consolidated,
      taxonomyVersion: '2023',
      status: XbrlFilingStatus.validation,
      totalTags: 620,
      completedTags: 498,
      validationErrors: 3,
      validationWarnings: 7,
      startedDate: DateTime(2025, 7, 10),
      preparedBy: 'Staff C',
    ),
    XbrlFiling(
      id: 'xbrl-mock-003',
      companyId: 'comp-003',
      companyName: 'Infosys Limited',
      cin: 'L85110KA1981PLC013115',
      financialYear: '2024-25',
      reportType: XbrlReportType.standalone,
      taxonomyVersion: '2023',
      status: XbrlFilingStatus.dataEntry,
      totalTags: 380,
      completedTags: 120,
      validationErrors: 0,
      validationWarnings: 0,
      startedDate: DateTime(2025, 8, 5),
    ),
  ];

  final List<XbrlFiling> _state = List.of(_seed);

  @override
  Future<List<XbrlFiling>> getAllFilings() async {
    return List.unmodifiable(_state);
  }

  @override
  Future<List<XbrlFiling>> getFilingsByCompany(String companyId) async {
    return List.unmodifiable(
      _state.where((f) => f.companyId == companyId).toList(),
    );
  }

  @override
  Future<XbrlFiling?> getFilingById(String id) async {
    try {
      return _state.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertFiling(XbrlFiling filing) async {
    _state.add(filing);
    return filing.id;
  }

  @override
  Future<bool> updateFiling(XbrlFiling filing) async {
    final idx = _state.indexWhere((f) => f.id == filing.id);
    if (idx == -1) return false;
    final updated = List<XbrlFiling>.of(_state)..[idx] = filing;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteFiling(String id) async {
    final before = _state.length;
    _state.removeWhere((f) => f.id == id);
    return _state.length < before;
  }
}
