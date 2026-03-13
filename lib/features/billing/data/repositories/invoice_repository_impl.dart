import 'package:ca_app/features/billing/data/datasources/invoice_local_source.dart';
import 'package:ca_app/features/billing/data/datasources/invoice_remote_source.dart';
import 'package:ca_app/features/billing/data/mappers/invoice_mapper.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/billing/domain/repositories/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  const InvoiceRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final InvoiceRemoteSource remote;
  final InvoiceLocalSource local;
  final String firmId;

  @override
  Future<List<Invoice>> getAll({String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchAll(firmId: effectiveFirmId);
      final invoices = jsonList.map(InvoiceMapper.fromJson).toList();
      for (final invoice in invoices) {
        await local.upsert(invoice, firmId: effectiveFirmId);
      }
      return List.unmodifiable(invoices);
    } catch (_) {
      return local.getAll(firmId: effectiveFirmId);
    }
  }

  @override
  Future<Invoice?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final invoice = InvoiceMapper.fromJson(json);
      await local.upsert(invoice, firmId: firmId);
      return invoice;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<Invoice> create(Invoice invoice) async {
    final json = await remote.insert({
      ...InvoiceMapper.toJson(invoice),
      'firm_id': firmId,
    });
    final created = InvoiceMapper.fromJson(json);
    await local.upsert(created, firmId: firmId);
    return created;
  }

  @override
  Future<Invoice> update(Invoice invoice) async {
    final json = await remote.update(invoice.id, InvoiceMapper.toJson(invoice));
    final updated = InvoiceMapper.fromJson(json);
    await local.upsert(updated, firmId: firmId);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await remote.delete(id);
    await local.delete(id);
  }

  @override
  Future<List<Invoice>> getByClientId(String clientId) async {
    try {
      final jsonList = await remote.fetchByClientId(clientId);
      return List.unmodifiable(jsonList.map(InvoiceMapper.fromJson).toList());
    } catch (_) {
      return local.getByClientId(clientId);
    }
  }

  @override
  Future<List<Invoice>> getByStatus(
    InvoiceStatus status, {
    String? firmId,
  }) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchByStatus(
        status.name,
        firmId: effectiveFirmId,
      );
      return List.unmodifiable(jsonList.map(InvoiceMapper.fromJson).toList());
    } catch (_) {
      return local.getByStatus(status.name, firmId: effectiveFirmId);
    }
  }

  @override
  Future<List<Invoice>> search(String query, {String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.search(query, firmId: effectiveFirmId);
      return List.unmodifiable(jsonList.map(InvoiceMapper.fromJson).toList());
    } catch (_) {
      return local.search(query, firmId: effectiveFirmId);
    }
  }

  @override
  Stream<List<Invoice>> watchAll({String? firmId}) =>
      local.watchAll(firmId: firmId ?? this.firmId);
}
