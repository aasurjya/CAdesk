import 'package:ca_app/features/startup_compliance/domain/models/startup_entity.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_filing.dart';
import 'package:ca_app/features/startup_compliance/domain/repositories/startup_compliance_repository.dart';

/// In-memory mock implementation of [StartupComplianceRepository].
///
/// Seeded with realistic sample data for development and testing.
class MockStartupComplianceRepository implements StartupComplianceRepository {
  static final List<StartupEntity> _entitySeed = [
    StartupEntity(
      id: 'startup-001',
      entityName: 'RapidFintech Pvt Ltd',
      dpiitNumber: 'DPIIT2022001234',
      incorporationDate: DateTime(2021, 7, 15),
      sector: 'FinTech',
      turnover: 12.5,
      isBelow100Cr: true,
      section80IACStatus: Section80IACStatus.approved,
      taxHolidayStartYear: 2022,
      taxHolidayEndYear: 2025,
      recognitionStatus: RecognitionStatus.recognized,
      investmentRounds: [
        InvestmentRound(
          roundName: 'Seed',
          amount: 2.0,
          date: DateTime(2022, 1, 1),
          investor: 'Blume Ventures',
        ),
        InvestmentRound(
          roundName: 'Series A',
          amount: 25.0,
          date: DateTime(2023, 6, 1),
          investor: 'Sequoia India',
        ),
      ],
    ),
    StartupEntity(
      id: 'startup-002',
      entityName: 'GreenEnergy Solutions OPC',
      dpiitNumber: 'DPIIT2023005678',
      incorporationDate: DateTime(2022, 3, 1),
      sector: 'CleanTech',
      turnover: 3.8,
      isBelow100Cr: true,
      section80IACStatus: Section80IACStatus.applied,
      recognitionStatus: RecognitionStatus.recognized,
      investmentRounds: [
        InvestmentRound(
          roundName: 'Angel',
          amount: 0.5,
          date: DateTime(2023, 3, 15),
          investor: 'Individual Angel',
        ),
      ],
    ),
    StartupEntity(
      id: 'startup-003',
      entityName: 'HealthAI Technologies',
      dpiitNumber: 'DPIIT2021009012',
      incorporationDate: DateTime(2020, 11, 20),
      sector: 'HealthTech',
      turnover: 45.0,
      isBelow100Cr: true,
      section80IACStatus: Section80IACStatus.approved,
      taxHolidayStartYear: 2021,
      taxHolidayEndYear: 2024,
      recognitionStatus: RecognitionStatus.recognized,
      investmentRounds: [],
    ),
  ];

  static final List<StartupFiling> _filingSeed = [
    StartupFiling(
      id: 'filing-001',
      startupId: 'startup-001',
      entityName: 'RapidFintech Pvt Ltd',
      filingType: StartupFilingType.annualReturn,
      dueDate: DateTime(2026, 9, 30),
      status: StartupFilingStatus.pending,
      remarks: 'Due for FY 2025-26',
    ),
    StartupFiling(
      id: 'filing-002',
      startupId: 'startup-001',
      entityName: 'RapidFintech Pvt Ltd',
      filingType: StartupFilingType.itr,
      dueDate: DateTime(2025, 10, 31),
      filedDate: DateTime(2025, 10, 28),
      status: StartupFilingStatus.filed,
      remarks: 'Filed before deadline',
    ),
    StartupFiling(
      id: 'filing-003',
      startupId: 'startup-002',
      entityName: 'GreenEnergy Solutions OPC',
      filingType: StartupFilingType.dpiitUpdate,
      dueDate: DateTime(2026, 3, 31),
      status: StartupFilingStatus.overdue,
      remarks: 'DPIIT status renewal overdue',
    ),
  ];

  final List<StartupEntity> _entityState = List.of(_entitySeed);
  final List<StartupFiling> _filingState = List.of(_filingSeed);

  // ---------------------------------------------------------------------------
  // StartupEntity
  // ---------------------------------------------------------------------------

  @override
  Future<List<StartupEntity>> getStartupEntities() async =>
      List.unmodifiable(_entityState);

  @override
  Future<StartupEntity?> getStartupEntityById(String id) async {
    final idx = _entityState.indexWhere((e) => e.id == id);
    return idx == -1 ? null : _entityState[idx];
  }

  @override
  Future<List<StartupEntity>> getStartupEntitiesByRecognitionStatus(
    RecognitionStatus status,
  ) async => List.unmodifiable(
    _entityState.where((e) => e.recognitionStatus == status).toList(),
  );

  @override
  Future<String> insertStartupEntity(StartupEntity entity) async {
    _entityState.add(entity);
    return entity.id;
  }

  @override
  Future<bool> updateStartupEntity(StartupEntity entity) async {
    final idx = _entityState.indexWhere((e) => e.id == entity.id);
    if (idx == -1) return false;
    final updated = List<StartupEntity>.of(_entityState)..[idx] = entity;
    _entityState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteStartupEntity(String id) async {
    final before = _entityState.length;
    _entityState.removeWhere((e) => e.id == id);
    return _entityState.length < before;
  }

  // ---------------------------------------------------------------------------
  // StartupFiling
  // ---------------------------------------------------------------------------

  @override
  Future<List<StartupFiling>> getStartupFilings() async =>
      List.unmodifiable(_filingState);

  @override
  Future<StartupFiling?> getStartupFilingById(String id) async {
    final idx = _filingState.indexWhere((f) => f.id == id);
    return idx == -1 ? null : _filingState[idx];
  }

  @override
  Future<List<StartupFiling>> getStartupFilingsByStartup(
    String startupId,
  ) async => List.unmodifiable(
    _filingState.where((f) => f.startupId == startupId).toList(),
  );

  @override
  Future<List<StartupFiling>> getStartupFilingsByStatus(
    StartupFilingStatus status,
  ) async =>
      List.unmodifiable(_filingState.where((f) => f.status == status).toList());

  @override
  Future<String> insertStartupFiling(StartupFiling filing) async {
    _filingState.add(filing);
    return filing.id;
  }

  @override
  Future<bool> updateStartupFiling(StartupFiling filing) async {
    final idx = _filingState.indexWhere((f) => f.id == filing.id);
    if (idx == -1) return false;
    final updated = List<StartupFiling>.of(_filingState)..[idx] = filing;
    _filingState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteStartupFiling(String id) async {
    final before = _filingState.length;
    _filingState.removeWhere((f) => f.id == id);
    return _filingState.length < before;
  }
}
