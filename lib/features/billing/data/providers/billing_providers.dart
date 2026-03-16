import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/billing/domain/models/payment_receipt.dart';
import 'package:ca_app/features/billing/domain/models/payment_record.dart';

// ---------------------------------------------------------------------------
// GST calculation service
// ---------------------------------------------------------------------------

/// Result of a GST computation for a single invoice line item.
class InvoiceTax {
  const InvoiceTax({
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.total,
  });

  final double igst;
  final double cgst;
  final double sgst;

  /// Grand total (taxable value + GST).
  final double total;
}

/// Stateless service for GST calculations per Indian tax norms.
class GstInvoiceCalculator {
  GstInvoiceCalculator._();

  /// Computes GST amounts for an invoice line item.
  ///
  /// For intra-state: splits into CGST + SGST (half each).
  /// For inter-state: charges IGST.
  static InvoiceTax compute({
    required double taxableValue,
    required double gstRatePercent,
    required bool isInterState,
  }) {
    final gstAmount = taxableValue * gstRatePercent / 100;
    if (isInterState) {
      return InvoiceTax(
        igst: gstAmount,
        cgst: 0,
        sgst: 0,
        total: taxableValue + gstAmount,
      );
    } else {
      final half = gstAmount / 2;
      return InvoiceTax(
        igst: 0,
        cgst: half,
        sgst: half,
        total: taxableValue + gstAmount,
      );
    }
  }

  /// Reverse-computes taxable value from a GST-inclusive amount.
  static double reverseCompute({
    required double inclusiveAmount,
    required double gstRatePercent,
  }) {
    return inclusiveAmount / (1 + gstRatePercent / 100);
  }

  /// Late payment interest at 18% p.a. per RBI norms.
  static double latePaymentInterest({
    required double amount,
    required int daysOverdue,
  }) {
    return amount * 0.18 / 365 * daysOverdue;
  }
}

// ---------------------------------------------------------------------------
// Helpers — build line items with CGST+SGST (intra-state) or IGST (inter-state)
// ---------------------------------------------------------------------------

LineItem _lineItem({
  required String description,
  required String hsn,
  required double quantity,
  required double rate,
  required double gstRate,
  bool interstate = false,
}) {
  final taxableAmount = quantity * rate;
  final gstAmount = taxableAmount * gstRate / 100;
  final cgst = interstate ? 0.0 : gstAmount / 2;
  final sgst = interstate ? 0.0 : gstAmount / 2;
  final igst = interstate ? gstAmount : 0.0;
  final total = taxableAmount + gstAmount;
  return LineItem(
    description: description,
    hsn: hsn,
    quantity: quantity,
    rate: rate,
    taxableAmount: taxableAmount,
    gstRate: gstRate,
    cgst: cgst,
    sgst: sgst,
    igst: igst,
    total: total,
  );
}

// ---------------------------------------------------------------------------
// Mock invoices — 15 invoices across 8 clients, mix of statuses
// ---------------------------------------------------------------------------

final _mockInvoices = <Invoice>[
  // INV-001 — ABC Infra Pvt Ltd — Paid
  Invoice(
    id: 'inv1',
    invoiceNumber: 'CAD/2025-26/001',
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    gstin: '07AABCA1234C1Z5',
    invoiceDate: DateTime(2025, 4, 5),
    dueDate: DateTime(2025, 5, 5),
    lineItems: [
      _lineItem(
        description: 'Annual Statutory Audit Fees',
        hsn: '998222',
        quantity: 1,
        rate: 150000,
        gstRate: 18,
      ),
      _lineItem(
        description: 'ITR Filing — Company',
        hsn: '998221',
        quantity: 1,
        rate: 25000,
        gstRate: 18,
      ),
    ],
    subtotal: 175000,
    totalGst: 31500,
    grandTotal: 206500,
    paidAmount: 206500,
    balanceDue: 0,
    status: InvoiceStatus.paid,
    paymentDate: DateTime(2025, 4, 28),
    paymentMethod: 'Bank Transfer',
    remarks: 'Full payment received via NEFT.',
  ),

  // INV-002 — Bharat Electronics Ltd — Paid, Recurring
  Invoice(
    id: 'inv2',
    invoiceNumber: 'CAD/2025-26/002',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    gstin: '27AABCB9012H1Z1',
    invoiceDate: DateTime(2025, 4, 10),
    dueDate: DateTime(2025, 5, 10),
    lineItems: [
      _lineItem(
        description: 'Monthly Accounting & Bookkeeping',
        hsn: '998231',
        quantity: 1,
        rate: 35000,
        gstRate: 18,
      ),
      _lineItem(
        description: 'TDS Return Filing (Q4)',
        hsn: '998221',
        quantity: 1,
        rate: 8000,
        gstRate: 18,
      ),
    ],
    subtotal: 43000,
    totalGst: 7740,
    grandTotal: 50740,
    paidAmount: 50740,
    balanceDue: 0,
    status: InvoiceStatus.paid,
    paymentDate: DateTime(2025, 5, 2),
    paymentMethod: 'UPI',
    isRecurring: true,
    recurringFrequency: RecurringFrequency.monthly,
  ),

  // INV-003 — TechVista Solutions LLP — Overdue
  Invoice(
    id: 'inv3',
    invoiceNumber: 'CAD/2025-26/003',
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    gstin: '29AAFT1234F1Z2',
    invoiceDate: DateTime(2025, 5, 1),
    dueDate: DateTime(2025, 5, 31),
    lineItems: [
      _lineItem(
        description: 'GST Return Filing — GSTR-1 & 3B (Apr)',
        hsn: '998221',
        quantity: 2,
        rate: 5000,
        gstRate: 18,
      ),
      _lineItem(
        description: 'Payroll Processing (Apr)',
        hsn: '998511',
        quantity: 1,
        rate: 12000,
        gstRate: 18,
      ),
    ],
    subtotal: 22000,
    totalGst: 3960,
    grandTotal: 25960,
    paidAmount: 0,
    balanceDue: 25960,
    status: InvoiceStatus.overdue,
    remarks: 'Payment reminder sent on 5 Jun 2025.',
  ),

  // INV-004 — Mehta & Sons — Partial
  Invoice(
    id: 'inv4',
    invoiceNumber: 'CAD/2025-26/004',
    clientId: '4',
    clientName: 'Mehta & Sons',
    gstin: '24AAPFM5678D1Z8',
    invoiceDate: DateTime(2025, 6, 1),
    dueDate: DateTime(2025, 6, 30),
    lineItems: [
      _lineItem(
        description: 'ITR Filing — Firm',
        hsn: '998221',
        quantity: 1,
        rate: 18000,
        gstRate: 18,
      ),
      _lineItem(
        description: 'Bookkeeping Q1 FY 2025-26',
        hsn: '998231',
        quantity: 1,
        rate: 20000,
        gstRate: 18,
      ),
    ],
    subtotal: 38000,
    totalGst: 6840,
    grandTotal: 44840,
    paidAmount: 20000,
    balanceDue: 24840,
    status: InvoiceStatus.partial,
    remarks: 'Part payment of ₹20,000 received. Balance pending.',
  ),

  // INV-005 — GreenLeaf Organics LLP — Sent
  Invoice(
    id: 'inv5',
    invoiceNumber: 'CAD/2025-26/005',
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    gstin: '29AAFG9012M1Z7',
    invoiceDate: DateTime(2025, 7, 5),
    dueDate: DateTime(2025, 8, 4),
    lineItems: [
      _lineItem(
        description: 'GST Compliance — Jul 2025',
        hsn: '998221',
        quantity: 2,
        rate: 5000,
        gstRate: 18,
      ),
      _lineItem(
        description: 'TDS Filing — Q1 FY 2026',
        hsn: '998221',
        quantity: 1,
        rate: 6000,
        gstRate: 18,
      ),
    ],
    subtotal: 16000,
    totalGst: 2880,
    grandTotal: 18880,
    paidAmount: 0,
    balanceDue: 18880,
    status: InvoiceStatus.sent,
  ),

  // INV-006 — Rajesh Kumar Sharma — Paid
  Invoice(
    id: 'inv6',
    invoiceNumber: 'CAD/2025-26/006',
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    invoiceDate: DateTime(2025, 7, 20),
    dueDate: DateTime(2025, 8, 19),
    lineItems: [
      _lineItem(
        description: 'ITR-2 Filing AY 2025-26',
        hsn: '998221',
        quantity: 1,
        rate: 12000,
        gstRate: 18,
      ),
    ],
    subtotal: 12000,
    totalGst: 2160,
    grandTotal: 14160,
    paidAmount: 14160,
    balanceDue: 0,
    status: InvoiceStatus.paid,
    paymentDate: DateTime(2025, 7, 22),
    paymentMethod: 'UPI',
    remarks: 'Paid via PhonePe. UPI ref: 9988776655.',
  ),

  // INV-007 — Priya Mehta — Paid
  Invoice(
    id: 'inv7',
    invoiceNumber: 'CAD/2025-26/007',
    clientId: '2',
    clientName: 'Priya Mehta',
    invoiceDate: DateTime(2025, 7, 28),
    dueDate: DateTime(2025, 8, 27),
    lineItems: [
      _lineItem(
        description: 'ITR-2 Filing + Capital Gains Advisory',
        hsn: '998221',
        quantity: 1,
        rate: 15000,
        gstRate: 18,
      ),
    ],
    subtotal: 15000,
    totalGst: 2700,
    grandTotal: 17700,
    paidAmount: 17700,
    balanceDue: 0,
    status: InvoiceStatus.paid,
    paymentDate: DateTime(2025, 8, 10),
    paymentMethod: 'Bank Transfer',
  ),

  // INV-008 — ABC Infra Pvt Ltd — Draft
  Invoice(
    id: 'inv8',
    invoiceNumber: 'CAD/2025-26/008',
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    gstin: '07AABCA1234C1Z5',
    invoiceDate: DateTime(2025, 10, 1),
    dueDate: DateTime(2025, 10, 31),
    lineItems: [
      _lineItem(
        description: 'GST Returns Oct 2025 (GSTR-1 & 3B)',
        hsn: '998221',
        quantity: 2,
        rate: 7500,
        gstRate: 18,
      ),
    ],
    subtotal: 15000,
    totalGst: 2700,
    grandTotal: 17700,
    paidAmount: 0,
    balanceDue: 17700,
    status: InvoiceStatus.draft,
    remarks: 'Draft — pending review.',
  ),

  // INV-009 — Bharat Electronics Ltd — Overdue, Recurring
  Invoice(
    id: 'inv9',
    invoiceNumber: 'CAD/2025-26/009',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    gstin: '27AABCB9012H1Z1',
    invoiceDate: DateTime(2025, 9, 10),
    dueDate: DateTime(2025, 10, 10),
    lineItems: [
      _lineItem(
        description: 'Monthly Accounting & Bookkeeping — Sep',
        hsn: '998231',
        quantity: 1,
        rate: 35000,
        gstRate: 18,
      ),
    ],
    subtotal: 35000,
    totalGst: 6300,
    grandTotal: 41300,
    paidAmount: 0,
    balanceDue: 41300,
    status: InvoiceStatus.overdue,
    isRecurring: true,
    recurringFrequency: RecurringFrequency.monthly,
    remarks: 'Escalation pending.',
  ),

  // INV-010 — Deepak Patel — Sent
  Invoice(
    id: 'inv10',
    invoiceNumber: 'CAD/2025-26/010',
    clientId: '9',
    clientName: 'Deepak Patel',
    gstin: '24DLKPP3456I1Z4',
    invoiceDate: DateTime(2025, 10, 15),
    dueDate: DateTime(2025, 11, 14),
    lineItems: [
      _lineItem(
        description: 'GST Returns Filing — Oct 2025',
        hsn: '998221',
        quantity: 2,
        rate: 4000,
        gstRate: 18,
      ),
      _lineItem(
        description: 'ITR Filing Advisory',
        hsn: '998221',
        quantity: 1,
        rate: 8000,
        gstRate: 18,
      ),
    ],
    subtotal: 16000,
    totalGst: 2880,
    grandTotal: 18880,
    paidAmount: 0,
    balanceDue: 18880,
    status: InvoiceStatus.sent,
  ),

  // INV-011 — Nirmala Textiles Pvt Ltd — Cancelled
  Invoice(
    id: 'inv11',
    invoiceNumber: 'CAD/2025-26/011',
    clientId: '15',
    clientName: 'Nirmala Textiles Pvt Ltd',
    gstin: '24AABCN7890P1Z3',
    invoiceDate: DateTime(2025, 11, 1),
    dueDate: DateTime(2025, 11, 30),
    lineItems: [
      _lineItem(
        description: 'Annual ROC Compliance',
        hsn: '998211',
        quantity: 1,
        rate: 20000,
        gstRate: 18,
      ),
    ],
    subtotal: 20000,
    totalGst: 3600,
    grandTotal: 23600,
    paidAmount: 0,
    balanceDue: 0,
    status: InvoiceStatus.cancelled,
    remarks: 'Client turned inactive. Invoice cancelled.',
  ),

  // INV-012 — TechVista Solutions LLP — Paid, Recurring
  Invoice(
    id: 'inv12',
    invoiceNumber: 'CAD/2025-26/012',
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    gstin: '29AAFT1234F1Z2',
    invoiceDate: DateTime(2025, 11, 1),
    dueDate: DateTime(2025, 11, 30),
    lineItems: [
      _lineItem(
        description: 'GST Compliance — Nov 2025',
        hsn: '998221',
        quantity: 2,
        rate: 5000,
        gstRate: 18,
      ),
      _lineItem(
        description: 'Payroll Processing — Nov 2025',
        hsn: '998511',
        quantity: 1,
        rate: 12000,
        gstRate: 18,
      ),
    ],
    subtotal: 22000,
    totalGst: 3960,
    grandTotal: 25960,
    paidAmount: 25960,
    balanceDue: 0,
    status: InvoiceStatus.paid,
    paymentDate: DateTime(2025, 11, 25),
    paymentMethod: 'Bank Transfer',
    isRecurring: true,
    recurringFrequency: RecurringFrequency.monthly,
  ),

  // INV-013 — GreenLeaf Organics LLP — Partial
  Invoice(
    id: 'inv13',
    invoiceNumber: 'CAD/2025-26/013',
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    gstin: '29AAFG9012M1Z7',
    invoiceDate: DateTime(2025, 12, 5),
    dueDate: DateTime(2026, 1, 4),
    lineItems: [
      _lineItem(
        description: 'Annual LLP Compliance (Form 11 & 8)',
        hsn: '998211',
        quantity: 1,
        rate: 18000,
        gstRate: 18,
      ),
      _lineItem(
        description: 'GST Annual Return — GSTR-9',
        hsn: '998221',
        quantity: 1,
        rate: 12000,
        gstRate: 18,
      ),
    ],
    subtotal: 30000,
    totalGst: 5400,
    grandTotal: 35400,
    paidAmount: 15000,
    balanceDue: 20400,
    status: InvoiceStatus.partial,
  ),

  // INV-014 — Rajesh Kumar Sharma — Sent, Recurring
  Invoice(
    id: 'inv14',
    invoiceNumber: 'CAD/2025-26/014',
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    invoiceDate: DateTime(2026, 1, 10),
    dueDate: DateTime(2026, 2, 9),
    lineItems: [
      _lineItem(
        description: 'Quarterly Tax Planning & Advisory',
        hsn: '998221',
        quantity: 1,
        rate: 10000,
        gstRate: 18,
      ),
    ],
    subtotal: 10000,
    totalGst: 1800,
    grandTotal: 11800,
    paidAmount: 0,
    balanceDue: 11800,
    status: InvoiceStatus.sent,
    isRecurring: true,
    recurringFrequency: RecurringFrequency.quarterly,
  ),

  // INV-015 — Deepak Patel — Overdue
  Invoice(
    id: 'inv15',
    invoiceNumber: 'CAD/2025-26/015',
    clientId: '9',
    clientName: 'Deepak Patel',
    gstin: '24DLKPP3456I1Z4',
    invoiceDate: DateTime(2025, 12, 15),
    dueDate: DateTime(2026, 1, 14),
    lineItems: [
      _lineItem(
        description: 'GST Returns Dec 2025',
        hsn: '998221',
        quantity: 2,
        rate: 4000,
        gstRate: 18,
      ),
    ],
    subtotal: 8000,
    totalGst: 1440,
    grandTotal: 9440,
    paidAmount: 0,
    balanceDue: 9440,
    status: InvoiceStatus.overdue,
    remarks: 'Second reminder sent.',
  ),
];

// ---------------------------------------------------------------------------
// Mock payment receipts — 10 receipts
// ---------------------------------------------------------------------------

final _mockReceipts = <PaymentReceipt>[
  PaymentReceipt(
    id: 'rcpt1',
    invoiceId: 'inv1',
    invoiceNumber: 'CAD/2025-26/001',
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    amount: 206500,
    paymentDate: DateTime(2025, 4, 28),
    paymentMethod: PaymentMethod.bankTransfer,
    referenceNumber: 'UTR25042800123456',
    remarks: 'Full payment via NEFT.',
  ),
  PaymentReceipt(
    id: 'rcpt2',
    invoiceId: 'inv2',
    invoiceNumber: 'CAD/2025-26/002',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    amount: 50740,
    paymentDate: DateTime(2025, 5, 2),
    paymentMethod: PaymentMethod.upi,
    referenceNumber: 'UPI250502BEL00789',
    remarks: 'BHIM UPI.',
  ),
  PaymentReceipt(
    id: 'rcpt3',
    invoiceId: 'inv4',
    invoiceNumber: 'CAD/2025-26/004',
    clientId: '4',
    clientName: 'Mehta & Sons',
    amount: 20000,
    paymentDate: DateTime(2025, 6, 20),
    paymentMethod: PaymentMethod.cheque,
    referenceNumber: 'CHQ-005542',
    remarks: 'Part payment. Cheque cleared.',
  ),
  PaymentReceipt(
    id: 'rcpt4',
    invoiceId: 'inv6',
    invoiceNumber: 'CAD/2025-26/006',
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    amount: 14160,
    paymentDate: DateTime(2025, 7, 22),
    paymentMethod: PaymentMethod.upi,
    referenceNumber: 'PHONEPE25072200456',
  ),
  PaymentReceipt(
    id: 'rcpt5',
    invoiceId: 'inv7',
    invoiceNumber: 'CAD/2025-26/007',
    clientId: '2',
    clientName: 'Priya Mehta',
    amount: 17700,
    paymentDate: DateTime(2025, 8, 10),
    paymentMethod: PaymentMethod.bankTransfer,
    referenceNumber: 'UTR25081000234567',
  ),
  PaymentReceipt(
    id: 'rcpt6',
    invoiceId: 'inv12',
    invoiceNumber: 'CAD/2025-26/012',
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    amount: 25960,
    paymentDate: DateTime(2025, 11, 25),
    paymentMethod: PaymentMethod.bankTransfer,
    referenceNumber: 'UTR25112500345678',
    remarks: 'Nov retainer paid.',
  ),
  PaymentReceipt(
    id: 'rcpt7',
    invoiceId: 'inv13',
    invoiceNumber: 'CAD/2025-26/013',
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    amount: 15000,
    paymentDate: DateTime(2025, 12, 20),
    paymentMethod: PaymentMethod.upi,
    referenceNumber: 'GPAY25122000567890',
    remarks: 'Part payment received.',
  ),
  PaymentReceipt(
    id: 'rcpt8',
    invoiceId: 'inv2',
    invoiceNumber: 'CAD/2025-26/002',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    amount: 50740,
    paymentDate: DateTime(2025, 6, 5),
    paymentMethod: PaymentMethod.bankTransfer,
    referenceNumber: 'UTR25060500456789',
    remarks: 'May month recurring.',
  ),
  PaymentReceipt(
    id: 'rcpt9',
    invoiceId: 'inv2',
    invoiceNumber: 'CAD/2025-26/002',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    amount: 50740,
    paymentDate: DateTime(2025, 7, 3),
    paymentMethod: PaymentMethod.upi,
    referenceNumber: 'UPI250703BEL00890',
    remarks: 'Jun month recurring.',
  ),
  PaymentReceipt(
    id: 'rcpt10',
    invoiceId: 'inv12',
    invoiceNumber: 'CAD/2025-26/012',
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    amount: 25960,
    paymentDate: DateTime(2025, 12, 29),
    paymentMethod: PaymentMethod.bankTransfer,
    referenceNumber: 'UTR25122900678901',
    remarks: 'Dec retainer.',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final allInvoicesProvider =
    NotifierProvider<AllInvoicesNotifier, List<Invoice>>(
      AllInvoicesNotifier.new,
    );

class AllInvoicesNotifier extends Notifier<List<Invoice>> {
  @override
  List<Invoice> build() => List.unmodifiable(_mockInvoices);

  void update(List<Invoice> value) => state = List.unmodifiable(value);

  /// Add a new invoice to the list.
  void addInvoice(Invoice invoice) {
    state = List.unmodifiable([invoice, ...state]);
  }

  /// Update an existing invoice by ID (returns new list).
  void updateInvoice(Invoice updated) {
    state = List.unmodifiable(
      state.map((inv) => inv.id == updated.id ? updated : inv).toList(),
    );
  }

  /// Delete an invoice by ID.
  void deleteInvoice(String invoiceId) {
    state = List.unmodifiable(
      state.where((inv) => inv.id != invoiceId).toList(),
    );
  }

  /// Record a payment against an invoice. Validates amount ≤ balance due.
  /// Returns the updated invoice, or null if payment exceeds balance.
  Invoice? recordPayment(String invoiceId, double amount) {
    final invoice = state.firstWhere(
      (inv) => inv.id == invoiceId,
      orElse: () => throw StateError('Invoice $invoiceId not found'),
    );

    final balanceDue = invoice.grandTotal - invoice.paidAmount;
    if (amount <= 0 || amount > balanceDue + 0.01) return null;

    final newAmountPaid = invoice.paidAmount + amount;
    final isPaidInFull = (newAmountPaid >= invoice.grandTotal - 0.01);
    final updatedInvoice = invoice.copyWith(
      paidAmount: newAmountPaid,
      status: isPaidInFull
          ? InvoiceStatus.paid
          : InvoiceStatus.partial,
    );

    updateInvoice(updatedInvoice);
    return updatedInvoice;
  }
}

final allReceiptsProvider =
    NotifierProvider<AllReceiptsNotifier, List<PaymentReceipt>>(
      AllReceiptsNotifier.new,
    );

class AllReceiptsNotifier extends Notifier<List<PaymentReceipt>> {
  @override
  List<PaymentReceipt> build() => List.unmodifiable(_mockReceipts);

  void update(List<PaymentReceipt> value) => state = List.unmodifiable(value);
}

// Filter: invoice status
final invoiceStatusFilterProvider =
    NotifierProvider<InvoiceStatusFilterNotifier, InvoiceStatus?>(
      InvoiceStatusFilterNotifier.new,
    );

class InvoiceStatusFilterNotifier extends Notifier<InvoiceStatus?> {
  @override
  InvoiceStatus? build() => null;

  void update(InvoiceStatus? value) => state = value;
}

// Filter: client id
final billingClientFilterProvider =
    NotifierProvider<BillingClientFilterNotifier, String?>(
      BillingClientFilterNotifier.new,
    );

class BillingClientFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

// Filter: search query for billing
final billingSearchQueryProvider =
    NotifierProvider<BillingSearchQueryNotifier, String>(
      BillingSearchQueryNotifier.new,
    );

class BillingSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

/// Computed filtered invoice list.
final filteredInvoicesProvider = Provider<List<Invoice>>((ref) {
  final invoices = ref.watch(allInvoicesProvider);
  final statusFilter = ref.watch(invoiceStatusFilterProvider);
  final clientFilter = ref.watch(billingClientFilterProvider);
  final query = ref.watch(billingSearchQueryProvider).toLowerCase().trim();

  return List.unmodifiable(
    invoices.where((inv) {
      if (statusFilter != null && inv.status != statusFilter) return false;
      if (clientFilter != null && inv.clientId != clientFilter) return false;
      if (query.isNotEmpty) {
        final matchesClient = inv.clientName.toLowerCase().contains(query);
        final matchesNumber = inv.invoiceNumber.toLowerCase().contains(query);
        return matchesClient || matchesNumber;
      }
      return true;
    }).toList()..sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate)),
  );
});

/// Total receivables (sum of all balance-due invoices).
final totalReceivablesProvider = Provider<double>((ref) {
  final invoices = ref.watch(allInvoicesProvider);
  return invoices.fold(0.0, (sum, inv) => sum + inv.balanceDue);
});

/// Total amount billed (sum of grand totals, excluding cancelled).
final totalBilledProvider = Provider<double>((ref) {
  final invoices = ref.watch(allInvoicesProvider);
  return invoices
      .where((inv) => inv.status != InvoiceStatus.cancelled)
      .fold(0.0, (sum, inv) => sum + inv.grandTotal);
});

/// Total amount collected (sum of paid amounts, excluding cancelled).
final totalCollectedProvider = Provider<double>((ref) {
  final invoices = ref.watch(allInvoicesProvider);
  return invoices
      .where((inv) => inv.status != InvoiceStatus.cancelled)
      .fold(0.0, (sum, inv) => sum + inv.paidAmount);
});

/// Count of overdue invoices.
final overdueCountProvider = Provider<int>((ref) {
  final invoices = ref.watch(allInvoicesProvider);
  return invoices.where((inv) => inv.status == InvoiceStatus.overdue).length;
});

/// Summary record for billing screen header.
final billingSummaryProvider =
    Provider<
      ({
        double totalBilled,
        double totalCollected,
        double outstanding,
        int overdueCount,
      })
    >((ref) {
      return (
        totalBilled: ref.watch(totalBilledProvider),
        totalCollected: ref.watch(totalCollectedProvider),
        outstanding: ref.watch(totalReceivablesProvider),
        overdueCount: ref.watch(overdueCountProvider),
      );
    });

// ---------------------------------------------------------------------------
// Mock payment records — 8 records across multiple invoices
// ---------------------------------------------------------------------------

final _mockPaymentRecords = <PaymentRecord>[
  const PaymentRecord(
    id: 'pr1',
    invoiceId: 'inv1',
    clientName: 'ABC Infra Pvt Ltd',
    amount: 206500,
    paymentDate: '28 Apr 2025',
    mode: 'NEFT',
    reference: 'UTR25042800123456',
    notes: 'Full payment via NEFT.',
  ),
  const PaymentRecord(
    id: 'pr2',
    invoiceId: 'inv2',
    clientName: 'Bharat Electronics Ltd',
    amount: 50740,
    paymentDate: '02 May 2025',
    mode: 'UPI',
    reference: 'UPI250502BEL00789',
    notes: 'BHIM UPI payment.',
  ),
  const PaymentRecord(
    id: 'pr3',
    invoiceId: 'inv4',
    clientName: 'Mehta & Sons',
    amount: 20000,
    paymentDate: '20 Jun 2025',
    mode: 'Cheque',
    reference: 'CHQ-005542',
    notes: 'Part payment. Cheque cleared.',
  ),
  const PaymentRecord(
    id: 'pr4',
    invoiceId: 'inv6',
    clientName: 'Rajesh Kumar Sharma',
    amount: 14160,
    paymentDate: '22 Jul 2025',
    mode: 'UPI',
    reference: 'PHONEPE25072200456',
    notes: 'Paid via PhonePe.',
  ),
  const PaymentRecord(
    id: 'pr5',
    invoiceId: 'inv7',
    clientName: 'Priya Mehta',
    amount: 17700,
    paymentDate: '10 Aug 2025',
    mode: 'RTGS',
    reference: 'UTR25081000234567',
    notes: 'Bank transfer via RTGS.',
  ),
  const PaymentRecord(
    id: 'pr6',
    invoiceId: 'inv12',
    clientName: 'TechVista Solutions LLP',
    amount: 25960,
    paymentDate: '25 Nov 2025',
    mode: 'NEFT',
    reference: 'UTR25112500345678',
    notes: 'Nov retainer paid.',
  ),
  const PaymentRecord(
    id: 'pr7',
    invoiceId: 'inv13',
    clientName: 'GreenLeaf Organics LLP',
    amount: 15000,
    paymentDate: '20 Dec 2025',
    mode: 'UPI',
    reference: 'GPAY25122000567890',
    notes: 'Part payment received via GPay.',
  ),
  const PaymentRecord(
    id: 'pr8',
    invoiceId: 'inv15',
    clientName: 'Deepak Patel',
    amount: 5000,
    paymentDate: '05 Feb 2026',
    mode: 'Cash',
    reference: '',
    notes: 'Partial cash payment.',
  ),
];

// ---------------------------------------------------------------------------
// Payment records provider
// ---------------------------------------------------------------------------

final allPaymentRecordsProvider =
    NotifierProvider<AllPaymentRecordsNotifier, List<PaymentRecord>>(
      AllPaymentRecordsNotifier.new,
    );

class AllPaymentRecordsNotifier extends Notifier<List<PaymentRecord>> {
  @override
  List<PaymentRecord> build() => List.unmodifiable(_mockPaymentRecords);

  void addRecord(PaymentRecord record) {
    state = List.unmodifiable([...state, record]);
  }
}
