import 'package:ca_app/features/billing/data/datasources/payment_local_source.dart';
import 'package:ca_app/features/billing/data/datasources/payment_remote_source.dart';
import 'package:ca_app/features/billing/data/mappers/payment_mapper.dart';
import 'package:ca_app/features/billing/domain/models/payment_record.dart';
import 'package:ca_app/features/billing/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final PaymentRemoteSource remote;
  final PaymentLocalSource local;
  final String firmId;

  @override
  Future<List<PaymentRecord>> getAll({String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchAll(firmId: effectiveFirmId);
      final payments = jsonList.map(PaymentMapper.fromJson).toList();
      for (final payment in payments) {
        await local.upsert(payment, firmId: effectiveFirmId);
      }
      return List.unmodifiable(payments);
    } catch (_) {
      return local.getAll(firmId: effectiveFirmId);
    }
  }

  @override
  Future<PaymentRecord?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final payment = PaymentMapper.fromJson(json);
      await local.upsert(payment, firmId: firmId);
      return payment;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<PaymentRecord> create(PaymentRecord payment) async {
    final json = await remote.insert({
      ...PaymentMapper.toJson(payment),
      'firm_id': firmId,
    });
    final created = PaymentMapper.fromJson(json);
    await local.upsert(created, firmId: firmId);
    return created;
  }

  @override
  Future<void> delete(String id) async {
    await remote.delete(id);
    await local.delete(id);
  }

  @override
  Future<List<PaymentRecord>> getByInvoiceId(String invoiceId) async {
    try {
      final jsonList = await remote.fetchByInvoiceId(invoiceId);
      return List.unmodifiable(jsonList.map(PaymentMapper.fromJson).toList());
    } catch (_) {
      return local.getByInvoiceId(invoiceId);
    }
  }

  @override
  Stream<List<PaymentRecord>> watchByInvoiceId(String invoiceId) =>
      local.watchByInvoiceId(invoiceId);
}
