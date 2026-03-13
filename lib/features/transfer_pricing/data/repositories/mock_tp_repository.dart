import 'package:ca_app/features/transfer_pricing/domain/models/tp_transaction.dart';
import 'package:ca_app/features/transfer_pricing/domain/repositories/tp_transaction_repository.dart';

class MockTpRepository implements TpTransactionRepository {
  static final List<TpTransaction> _seed = [
    TpTransaction(
      id: 'tp-1',
      clientId: 'client-1',
      assessmentYear: '2024-25',
      relatedParty: 'ABC Corp USA',
      transactionType: 'Service',
      transactionValue: 5000000.0,
      tpMethod: TpMethod.tnmm,
      status: TpStatus.documented,
      createdAt: DateTime(2024, 4, 1),
      updatedAt: DateTime(2024, 4, 1),
    ),
    TpTransaction(
      id: 'tp-2',
      clientId: 'client-2',
      assessmentYear: '2024-25',
      relatedParty: 'XYZ Singapore',
      transactionType: 'Loan',
      transactionValue: 10000000.0,
      tpMethod: TpMethod.cup,
      status: TpStatus.draft,
      createdAt: DateTime(2024, 4, 1),
      updatedAt: DateTime(2024, 4, 1),
    ),
  ];

  final List<TpTransaction> _state = List.of(_seed);

  @override
  Future<void> insert(TpTransaction transaction) async {
    _state.add(transaction);
  }

  @override
  Future<List<TpTransaction>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((t) => t.clientId == clientId));

  @override
  Future<List<TpTransaction>> getByYear(String assessmentYear) async =>
      List.unmodifiable(
        _state.where((t) => t.assessmentYear == assessmentYear),
      );

  @override
  Future<void> updateStatus(String id, TpStatus status) async {
    final idx = _state.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _state[idx] = _state[idx].copyWith(status: status);
  }

  @override
  Future<List<TpTransaction>> getByMethod(TpMethod method) async =>
      List.unmodifiable(_state.where((t) => t.tpMethod == method));
}
