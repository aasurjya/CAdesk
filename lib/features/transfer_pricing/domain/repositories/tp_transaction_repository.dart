import 'package:ca_app/features/transfer_pricing/domain/models/tp_transaction.dart';

abstract class TpTransactionRepository {
  Future<void> insert(TpTransaction transaction);
  Future<List<TpTransaction>> getByClient(String clientId);
  Future<List<TpTransaction>> getByYear(String assessmentYear);
  Future<void> updateStatus(String id, TpStatus status);
  Future<List<TpTransaction>> getByMethod(TpMethod method);
}
