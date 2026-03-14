import 'package:ca_app/features/vda/domain/models/vda_record.dart';
import 'package:ca_app/features/vda/domain/repositories/vda_repository.dart';

class MockVdaRepository implements VdaRepository {
  static final List<VdaRecord> _seed = [
    VdaRecord(
      id: 'vda-1',
      clientId: 'client-1',
      transactionDate: DateTime(2024, 6, 15),
      assetType: 'Bitcoin',
      buyPrice: 2500000.0,
      sellPrice: 3000000.0,
      quantity: 0.5,
      gainLoss: 250000.0,
      tdsDeducted: 30000.0,
      exchange: 'WazirX',
      assessmentYear: '2024-25',
    ),
    VdaRecord(
      id: 'vda-2',
      clientId: 'client-1',
      transactionDate: DateTime(2024, 9, 10),
      assetType: 'Ethereum',
      buyPrice: 180000.0,
      sellPrice: 150000.0,
      quantity: 2.0,
      gainLoss: -60000.0,
      tdsDeducted: 1500.0,
      exchange: 'CoinDCX',
      assessmentYear: '2024-25',
    ),
  ];

  final List<VdaRecord> _state = List.of(_seed);

  @override
  Future<void> insert(VdaRecord record) async {
    _state.add(record);
  }

  @override
  Future<List<VdaRecord>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((r) => r.clientId == clientId));

  @override
  Future<List<VdaRecord>> getByYear(String assessmentYear) async =>
      List.unmodifiable(
        _state.where((r) => r.assessmentYear == assessmentYear),
      );

  @override
  Future<double> getTotalGainLoss(
    String clientId,
    String assessmentYear,
  ) async {
    var total = 0.0;
    for (final r in _state) {
      if (r.clientId == clientId && r.assessmentYear == assessmentYear) {
        total += r.gainLoss;
      }
    }
    return total;
  }

  @override
  Future<double> getTdsDeducted(String clientId, String assessmentYear) async {
    var total = 0.0;
    for (final r in _state) {
      if (r.clientId == clientId && r.assessmentYear == assessmentYear) {
        total += r.tdsDeducted;
      }
    }
    return total;
  }

  @override
  Future<void> delete(String id) async {
    _state.removeWhere((r) => r.id == id);
  }
}
