import 'dart:async';

import 'package:ca_app/features/mca/domain/models/mca_filing_data.dart';
import 'package:ca_app/features/mca/domain/repositories/mca_repository.dart';

/// In-memory mock implementation of [McaRepository].
///
/// Seeded with realistic MCA filings for development and testing.
class MockMcaRepository implements McaRepository {
  static final _now = DateTime.now();

  static final List<McaFilingData> _seedFilings = [
    McaFilingData(
      id: 'mca-data-001',
      clientId: 'mock-client-001',
      formType: MCAFormType.aoc4,
      financialYear: '2024-25',
      dueDate: DateTime(_now.year, _now.month, _now.day + 45),
      status: 'pending',
      remarks: 'Financial statements to be attached',
    ),
    McaFilingData(
      id: 'mca-data-002',
      clientId: 'mock-client-001',
      formType: MCAFormType.dir3,
      financialYear: '2025-26',
      dueDate: DateTime(_now.year, _now.month + 3, 30),
      status: 'pending',
      remarks: 'Director KYC due by 30 Sep',
    ),
    McaFilingData(
      id: 'mca-data-003',
      clientId: 'mock-client-002',
      formType: MCAFormType.inc22a,
      financialYear: '2024-25',
      dueDate: DateTime(_now.year, _now.month - 1, 25),
      filedDate: DateTime(_now.year, _now.month - 1, 20),
      status: 'approved',
      filingNumber: 'G12345678',
      remarks: 'Active company tagging filed on time',
    ),
    McaFilingData(
      id: 'mca-data-004',
      clientId: 'mock-client-002',
      formType: MCAFormType.dpt3,
      financialYear: '2024-25',
      dueDate: DateTime(_now.year, _now.month, _now.day + 10),
      status: 'filed',
      filingNumber: 'G23456789',
    ),
    McaFilingData(
      id: 'mca-data-005',
      clientId: 'mock-client-003',
      formType: MCAFormType.mbp1,
      financialYear: '2024-25',
      dueDate: DateTime(_now.year, _now.month, _now.day - 5),
      status: 'pending',
      remarks: 'MBP-1 overdue — requires immediate attention',
    ),
  ];

  final List<McaFilingData> _state = List.of(_seedFilings);
  final StreamController<List<McaFilingData>> _controller =
      StreamController<List<McaFilingData>>.broadcast();

  // ---------------------------------------------------------------------------
  // Insert
  // ---------------------------------------------------------------------------

  @override
  Future<String> insertMCAFiling(McaFilingData filing) async {
    _state.add(filing);
    _controller.add(List.unmodifiable(_state));
    return filing.id;
  }

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  @override
  Future<List<McaFilingData>> getMCAFilingsByClient(String clientId) async =>
      List.unmodifiable(
        _state.where((f) => f.clientId == clientId).toList(),
      );

  @override
  Future<List<McaFilingData>> getMCAFilingsByYear(
    String clientId,
    String year,
  ) async =>
      List.unmodifiable(
        _state
            .where((f) => f.clientId == clientId && f.financialYear == year)
            .toList(),
      );

  @override
  Future<List<McaFilingData>> getMCAFilingsByStatus(String status) async =>
      List.unmodifiable(_state.where((f) => f.status == status).toList());

  @override
  Future<List<McaFilingData>> getDueMCAFilings(int daysAhead) async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final cutoff = todayMidnight.add(Duration(days: daysAhead));
    return List.unmodifiable(
      _state
          .where(
            (f) =>
                !f.dueDate.isBefore(todayMidnight) &&
                !f.dueDate.isAfter(cutoff) &&
                f.status != 'filed' &&
                f.status != 'approved',
          )
          .toList(),
    );
  }

  @override
  Future<McaFilingData?> getMCAFilingById(String id) async {
    try {
      return _state.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  @override
  Future<bool> updateMCAFiling(McaFilingData filing) async {
    final idx = _state.indexWhere((f) => f.id == filing.id);
    if (idx == -1) return false;
    final updated = List<McaFilingData>.of(_state)..[idx] = filing;
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return true;
  }

  // ---------------------------------------------------------------------------
  // Stream
  // ---------------------------------------------------------------------------

  @override
  Stream<List<McaFilingData>> watchMCAFilingsByClient(String clientId) =>
      _controller.stream.map(
        (all) => all.where((f) => f.clientId == clientId).toList(),
      );

  void dispose() => _controller.close();
}
