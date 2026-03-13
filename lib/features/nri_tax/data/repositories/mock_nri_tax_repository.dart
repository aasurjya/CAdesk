import 'package:ca_app/features/nri_tax/domain/models/nri_tax_record.dart';
import 'package:ca_app/features/nri_tax/domain/repositories/nri_tax_repository.dart';

class MockNriTaxRepository implements NriTaxRepository {
  static final List<NriTaxRecord> _seed = [
    NriTaxRecord(
      id: 'nri-1',
      clientId: 'client-1',
      assessmentYear: '2024-25',
      residencyStatus: ResidencyStatus.nonResident,
      foreignIncomeSources: 'US employment income',
      dtaaCountry: 'USA',
      dtaaRelief: 150000.0,
      scheduleFA: true,
      scheduleFSL: false,
      status: NriTaxStatus.filed,
      createdAt: DateTime(2024, 4, 1),
      updatedAt: DateTime(2024, 4, 1),
    ),
    NriTaxRecord(
      id: 'nri-2',
      clientId: 'client-2',
      assessmentYear: '2024-25',
      residencyStatus: ResidencyStatus.rnor,
      scheduleFA: false,
      scheduleFSL: false,
      status: NriTaxStatus.draft,
      createdAt: DateTime(2024, 4, 1),
      updatedAt: DateTime(2024, 4, 1),
    ),
  ];

  final List<NriTaxRecord> _state = List.of(_seed);

  @override
  Future<void> insert(NriTaxRecord record) async {
    _state.add(record);
  }

  @override
  Future<List<NriTaxRecord>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((r) => r.clientId == clientId));

  @override
  Future<List<NriTaxRecord>> getByYear(String assessmentYear) async =>
      List.unmodifiable(
        _state.where((r) => r.assessmentYear == assessmentYear),
      );

  @override
  Future<void> updateStatus(String id, NriTaxStatus status) async {
    final idx = _state.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _state[idx] = _state[idx].copyWith(status: status);
  }

  @override
  Future<List<NriTaxRecord>> getScheduleFARequired() async =>
      List.unmodifiable(_state.where((r) => r.scheduleFA));
}
