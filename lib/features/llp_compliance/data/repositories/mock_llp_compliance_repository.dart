import 'package:ca_app/features/llp_compliance/domain/models/llp_entity.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_filing.dart';
import 'package:ca_app/features/llp_compliance/domain/repositories/llp_compliance_repository.dart';

/// In-memory mock implementation of [LlpComplianceRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockLlpComplianceRepository implements LlpComplianceRepository {
  static final List<LLPEntity> _seedEntities = [
    LLPEntity(
      id: 'mock-llp-001',
      llpName: 'Sharma & Associates LLP',
      llpin: 'AAA-1234',
      incorporationDate: DateTime(2019, 4, 1),
      turnover: 4500000,
      capitalContribution: 2000000,
      isAuditRequired: true,
      designatedPartners: [
        const LLPPartner(
          name: 'Rajesh Kumar Sharma',
          din: 'DIN00123456',
          email: 'rajesh@sharmaassociates.in',
          isDesignated: true,
        ),
        const LLPPartner(
          name: 'Sunita Sharma',
          din: 'DIN00234567',
          email: 'sunita@sharmaassociates.in',
          isDesignated: true,
        ),
      ],
      registeredOffice: 'Mumbai, Maharashtra',
      rocJurisdiction: 'RoC Mumbai',
    ),
    LLPEntity(
      id: 'mock-llp-002',
      llpName: 'Nair Tech Solutions LLP',
      llpin: 'BBB-5678',
      incorporationDate: DateTime(2021, 7, 15),
      turnover: 2800000,
      capitalContribution: 1200000,
      isAuditRequired: false,
      designatedPartners: [
        const LLPPartner(
          name: 'Priya Nair',
          din: 'DIN00345678',
          email: 'priya@nairtech.in',
          isDesignated: true,
        ),
      ],
      registeredOffice: 'Kochi, Kerala',
      rocJurisdiction: 'RoC Kerala',
    ),
    LLPEntity(
      id: 'mock-llp-003',
      llpName: 'Patel & Partners LLP',
      llpin: 'CCC-9012',
      incorporationDate: DateTime(2018, 1, 10),
      turnover: 8200000,
      capitalContribution: 3500000,
      isAuditRequired: true,
      designatedPartners: [
        const LLPPartner(
          name: 'Amit Patel',
          din: 'DIN00456789',
          email: 'amit@patelandpartners.in',
          isDesignated: true,
        ),
        const LLPPartner(
          name: 'Meena Patel',
          din: 'DIN00567890',
          email: 'meena@patelandpartners.in',
          isDesignated: true,
        ),
        const LLPPartner(
          name: 'Kiran Patel',
          din: 'DIN00678901',
          email: 'kiran@patelandpartners.in',
          isDesignated: false,
        ),
      ],
      registeredOffice: 'Ahmedabad, Gujarat',
      rocJurisdiction: 'RoC Ahmedabad',
    ),
  ];

  static final List<LLPFiling> _seedFilings = [
    LLPFiling(
      id: 'mock-filing-001',
      llpId: 'mock-llp-001',
      llpName: 'Sharma & Associates LLP',
      formType: LLPFormType.form11,
      dueDate: DateTime(2026, 5, 30),
      status: LLPFilingStatus.pending,
      financialYear: 'FY 2025-26',
      penaltyPerDay: 100,
      maxPenalty: 100000,
      currentPenalty: 0,
      certifyingProfessional: 'CA Suresh Iyer',
    ),
    LLPFiling(
      id: 'mock-filing-002',
      llpId: 'mock-llp-001',
      llpName: 'Sharma & Associates LLP',
      formType: LLPFormType.form8,
      dueDate: DateTime(2026, 10, 30),
      status: LLPFilingStatus.pending,
      financialYear: 'FY 2025-26',
      penaltyPerDay: 100,
      maxPenalty: 100000,
      currentPenalty: 0,
    ),
    LLPFiling(
      id: 'mock-filing-003',
      llpId: 'mock-llp-002',
      llpName: 'Nair Tech Solutions LLP',
      formType: LLPFormType.form11,
      dueDate: DateTime(2025, 5, 30),
      filedDate: DateTime(2025, 5, 25),
      status: LLPFilingStatus.filed,
      financialYear: 'FY 2024-25',
      penaltyPerDay: 100,
      maxPenalty: 100000,
      currentPenalty: 0,
      certifyingProfessional: 'CA Meera Joshi',
    ),
  ];

  final List<LLPEntity> _entities = List.of(_seedEntities);
  final List<LLPFiling> _filings = List.of(_seedFilings);

  // -------------------------------------------------------------------------
  // LLPEntity
  // -------------------------------------------------------------------------

  @override
  Future<List<LLPEntity>> getEntities() async => List.unmodifiable(_entities);

  @override
  Future<LLPEntity?> getEntityById(String id) async {
    final matches = _entities.where((e) => e.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<List<LLPEntity>> searchEntities(String query) async {
    final q = query.toLowerCase();
    return List.unmodifiable(
      _entities
          .where(
            (e) =>
                e.llpName.toLowerCase().contains(q) ||
                e.llpin.toLowerCase().contains(q),
          )
          .toList(),
    );
  }

  @override
  Future<String> insertEntity(LLPEntity entity) async {
    _entities.add(entity);
    return entity.id;
  }

  @override
  Future<bool> updateEntity(LLPEntity entity) async {
    final idx = _entities.indexWhere((e) => e.id == entity.id);
    if (idx == -1) return false;
    final updated = List<LLPEntity>.of(_entities)..[idx] = entity;
    _entities
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteEntity(String id) async {
    final before = _entities.length;
    _entities.removeWhere((e) => e.id == id);
    return _entities.length < before;
  }

  // -------------------------------------------------------------------------
  // LLPFiling
  // -------------------------------------------------------------------------

  @override
  Future<List<LLPFiling>> getFilings() async => List.unmodifiable(_filings);

  @override
  Future<List<LLPFiling>> getFilingsByEntity(String llpId) async =>
      List.unmodifiable(_filings.where((f) => f.llpId == llpId).toList());

  @override
  Future<List<LLPFiling>> getFilingsByStatus(LLPFilingStatus status) async =>
      List.unmodifiable(_filings.where((f) => f.status == status).toList());

  @override
  Future<String> insertFiling(LLPFiling filing) async {
    _filings.add(filing);
    return filing.id;
  }

  @override
  Future<bool> updateFiling(LLPFiling filing) async {
    final idx = _filings.indexWhere((f) => f.id == filing.id);
    if (idx == -1) return false;
    final updated = List<LLPFiling>.of(_filings)..[idx] = filing;
    _filings
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteFiling(String id) async {
    final before = _filings.length;
    _filings.removeWhere((f) => f.id == id);
    return _filings.length < before;
  }
}
