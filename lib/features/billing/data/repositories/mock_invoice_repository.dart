import 'dart:async';

import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/billing/domain/repositories/invoice_repository.dart';

class MockInvoiceRepository implements InvoiceRepository {
  static final List<Invoice> _seedInvoices = [
    Invoice(
      id: 'inv-001',
      invoiceNumber: 'INV-2026-001',
      clientId: '3',
      clientName: 'ABC Infra Pvt Ltd',
      gstin: '07AABCA1234C1Z5',
      invoiceDate: DateTime(2026, 1, 10),
      dueDate: DateTime(2026, 2, 10),
      lineItems: [
        const LineItem(
          description: 'GST Filing — Q3 FY2025-26',
          hsn: '998231',
          quantity: 1,
          rate: 15000,
          taxableAmount: 15000,
          gstRate: 18,
          cgst: 1350,
          sgst: 1350,
          igst: 0,
          total: 17700,
        ),
        const LineItem(
          description: 'TDS Return Filing — Q3',
          hsn: '998231',
          quantity: 1,
          rate: 8000,
          taxableAmount: 8000,
          gstRate: 18,
          cgst: 720,
          sgst: 720,
          igst: 0,
          total: 9440,
        ),
      ],
      subtotal: 23000,
      totalGst: 4140,
      grandTotal: 27140,
      paidAmount: 27140,
      balanceDue: 0,
      status: InvoiceStatus.paid,
      paymentDate: DateTime(2026, 1, 25),
      paymentMethod: 'NEFT',
      remarks: 'Paid in full.',
      isRecurring: true,
      recurringFrequency: RecurringFrequency.quarterly,
    ),
    Invoice(
      id: 'inv-002',
      invoiceNumber: 'INV-2026-002',
      clientId: '1',
      clientName: 'Rajesh Kumar Sharma',
      invoiceDate: DateTime(2026, 2, 1),
      dueDate: DateTime(2026, 3, 1),
      lineItems: [
        const LineItem(
          description: 'ITR Filing — FY2024-25',
          hsn: '998231',
          quantity: 1,
          rate: 5000,
          taxableAmount: 5000,
          gstRate: 18,
          cgst: 450,
          sgst: 450,
          igst: 0,
          total: 5900,
        ),
      ],
      subtotal: 5000,
      totalGst: 900,
      grandTotal: 5900,
      paidAmount: 0,
      balanceDue: 5900,
      status: InvoiceStatus.sent,
    ),
    Invoice(
      id: 'inv-003',
      invoiceNumber: 'INV-2026-003',
      clientId: '4',
      clientName: 'Mehta & Sons',
      gstin: '24AAPFM5678D1Z8',
      invoiceDate: DateTime(2026, 1, 15),
      dueDate: DateTime(2026, 2, 15),
      lineItems: [
        const LineItem(
          description: 'Monthly Bookkeeping — Jan 2026',
          hsn: '998222',
          quantity: 1,
          rate: 12000,
          taxableAmount: 12000,
          gstRate: 18,
          cgst: 1080,
          sgst: 1080,
          igst: 0,
          total: 14160,
        ),
        const LineItem(
          description: 'GST Filing — Jan 2026',
          hsn: '998231',
          quantity: 1,
          rate: 3000,
          taxableAmount: 3000,
          gstRate: 18,
          cgst: 270,
          sgst: 270,
          igst: 0,
          total: 3540,
        ),
      ],
      subtotal: 15000,
      totalGst: 2700,
      grandTotal: 17700,
      paidAmount: 8000,
      balanceDue: 9700,
      status: InvoiceStatus.partial,
      remarks: 'Partial payment received via RTGS.',
    ),
    Invoice(
      id: 'inv-004',
      invoiceNumber: 'INV-2025-089',
      clientId: '5',
      clientName: 'TechVista Solutions LLP',
      gstin: '29AAFT1234F1Z2',
      invoiceDate: DateTime(2025, 11, 1),
      dueDate: DateTime(2025, 12, 1),
      lineItems: [
        const LineItem(
          description: 'Annual Audit — FY2024-25',
          hsn: '998222',
          quantity: 1,
          rate: 75000,
          taxableAmount: 75000,
          gstRate: 18,
          cgst: 6750,
          sgst: 6750,
          igst: 0,
          total: 88500,
        ),
      ],
      subtotal: 75000,
      totalGst: 13500,
      grandTotal: 88500,
      paidAmount: 0,
      balanceDue: 88500,
      status: InvoiceStatus.overdue,
      remarks: 'Follow up sent on 10-Dec-2025.',
    ),
    Invoice(
      id: 'inv-005',
      invoiceNumber: 'INV-2026-004',
      clientId: '2',
      clientName: 'Priya Mehta',
      invoiceDate: DateTime(2026, 3, 1),
      dueDate: DateTime(2026, 4, 1),
      lineItems: [
        const LineItem(
          description: 'ITR Filing — FY2025-26 (Advance)',
          hsn: '998231',
          quantity: 1,
          rate: 4500,
          taxableAmount: 4500,
          gstRate: 18,
          cgst: 405,
          sgst: 405,
          igst: 0,
          total: 5310,
        ),
      ],
      subtotal: 4500,
      totalGst: 810,
      grandTotal: 5310,
      paidAmount: 0,
      balanceDue: 5310,
      status: InvoiceStatus.draft,
    ),
  ];

  final List<Invoice> _state = List.of(_seedInvoices);
  final StreamController<List<Invoice>> _controller =
      StreamController<List<Invoice>>.broadcast();

  @override
  Future<List<Invoice>> getAll({String? firmId}) async =>
      List.unmodifiable(_state);

  @override
  Future<Invoice?> getById(String id) async {
    try {
      return _state.firstWhere((inv) => inv.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Invoice> create(Invoice invoice) async {
    _state.add(invoice);
    _controller.add(List.unmodifiable(_state));
    return invoice;
  }

  @override
  Future<Invoice> update(Invoice invoice) async {
    final idx = _state.indexWhere((inv) => inv.id == invoice.id);
    if (idx == -1) throw StateError('Invoice not found: ${invoice.id}');
    final updated = List<Invoice>.of(_state);
    updated[idx] = invoice;
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return invoice;
  }

  @override
  Future<void> delete(String id) async {
    _state.removeWhere((inv) => inv.id == id);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<Invoice>> getByClientId(String clientId) async =>
      _state.where((inv) => inv.clientId == clientId).toList();

  @override
  Future<List<Invoice>> getByStatus(
    InvoiceStatus status, {
    String? firmId,
  }) async => _state.where((inv) => inv.status == status).toList();

  @override
  Future<List<Invoice>> search(String query, {String? firmId}) async {
    final q = query.toLowerCase();
    return _state
        .where(
          (inv) =>
              inv.invoiceNumber.toLowerCase().contains(q) ||
              inv.clientName.toLowerCase().contains(q) ||
              inv.clientId.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Stream<List<Invoice>> watchAll({String? firmId}) => _controller.stream;

  void dispose() => _controller.close();
}
