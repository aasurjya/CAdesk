import 'dart:async';

import 'package:ca_app/features/billing/domain/models/payment_record.dart';
import 'package:ca_app/features/billing/domain/repositories/payment_repository.dart';

class MockPaymentRepository implements PaymentRepository {
  static final List<PaymentRecord> _seedPayments = [
    const PaymentRecord(
      id: 'pay-001',
      invoiceId: 'inv-001',
      clientName: 'ABC Infra Pvt Ltd',
      amount: 27140,
      paymentDate: '25 Jan 2026',
      mode: 'NEFT',
      reference: 'NEFT20260125ABCINFRA',
      notes: 'Full payment for INV-2026-001.',
    ),
    const PaymentRecord(
      id: 'pay-002',
      invoiceId: 'inv-003',
      clientName: 'Mehta & Sons',
      amount: 8000,
      paymentDate: '20 Feb 2026',
      mode: 'RTGS',
      reference: 'RTGS20260220MEHTA',
      notes: 'Partial payment. Balance 9700 pending.',
    ),
    const PaymentRecord(
      id: 'pay-003',
      invoiceId: 'inv-003',
      clientName: 'Mehta & Sons',
      amount: 4000,
      paymentDate: '05 Mar 2026',
      mode: 'UPI',
      reference: 'UPI20260305MEHTA',
      notes: 'Second instalment. Balance 5700 still due.',
    ),
  ];

  final List<PaymentRecord> _state = List.of(_seedPayments);
  final _controllers = <String, StreamController<List<PaymentRecord>>>{};

  @override
  Future<List<PaymentRecord>> getAll({String? firmId}) async =>
      List.unmodifiable(_state);

  @override
  Future<PaymentRecord?> getById(String id) async {
    try {
      return _state.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PaymentRecord> create(PaymentRecord payment) async {
    _state.add(payment);
    _notifyControllers(payment.invoiceId);
    return payment;
  }

  @override
  Future<void> delete(String id) async {
    final payment = await getById(id);
    _state.removeWhere((p) => p.id == id);
    if (payment != null) {
      _notifyControllers(payment.invoiceId);
    }
  }

  @override
  Future<List<PaymentRecord>> getByInvoiceId(String invoiceId) async =>
      _state.where((p) => p.invoiceId == invoiceId).toList();

  @override
  Stream<List<PaymentRecord>> watchByInvoiceId(String invoiceId) {
    final controller = _controllers.putIfAbsent(
      invoiceId,
      () => StreamController<List<PaymentRecord>>.broadcast(),
    );
    return controller.stream;
  }

  void _notifyControllers(String invoiceId) {
    final controller = _controllers[invoiceId];
    if (controller != null) {
      final filtered = _state.where((p) => p.invoiceId == invoiceId).toList();
      controller.add(List.unmodifiable(filtered));
    }
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
