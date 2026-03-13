import 'package:ca_app/features/startup/domain/models/startup_record.dart';
import 'package:ca_app/features/startup/domain/repositories/startup_repository.dart';

/// In-memory mock implementation of [StartupRepository].
class MockStartupRepository implements StartupRepository {
  static final List<StartupRecord> _seedRecords = [
    StartupRecord(
      id: 'startup-001',
      clientId: 'mock-client-001',
      dpiitNumber: 'DIPP12345',
      incorporationDate: DateTime(2020, 3, 15),
      sectorCategory: 'fintech',
      recognitionStatus: 'recognised',
      section80IacEligible: true,
      section56ExemptEligible: true,
      notes: 'SEBI-regulated payment aggregator',
    ),
    StartupRecord(
      id: 'startup-002',
      clientId: 'mock-client-002',
      dpiitNumber: 'DIPP67890',
      incorporationDate: DateTime(2021, 8, 1),
      sectorCategory: 'agritech',
      recognitionStatus: 'recognised',
      section80IacEligible: false,
      section56ExemptEligible: true,
    ),
    StartupRecord(
      id: 'startup-003',
      clientId: 'mock-client-003',
      dpiitNumber: 'DIPP11111',
      incorporationDate: DateTime(2022, 1, 10),
      sectorCategory: 'healthtech',
      recognitionStatus: 'pending',
    ),
  ];

  final List<StartupRecord> _state = List.of(_seedRecords);

  @override
  Future<String> insert(StartupRecord record) async {
    _state.add(record);
    return record.id;
  }

  @override
  Future<List<StartupRecord>> getByClient(String clientId) async =>
      List.unmodifiable(
        _state.where((r) => r.clientId == clientId).toList(),
      );

  @override
  Future<bool> update(StartupRecord record) async {
    final idx = _state.indexWhere((r) => r.id == record.id);
    if (idx == -1) return false;
    final updated = List<StartupRecord>.of(_state)..[idx] = record;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<List<StartupRecord>> getByStatus(String status) async =>
      List.unmodifiable(
        _state.where((r) => r.recognitionStatus == status).toList(),
      );

  @override
  Future<List<StartupRecord>> getEligibleForExemptions() async =>
      List.unmodifiable(
        _state
            .where(
              (r) => r.section80IacEligible || r.section56ExemptEligible,
            )
            .toList(),
      );
}
