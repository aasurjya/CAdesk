import 'package:ca_app/features/practice/domain/models/billing_line_item.dart';

/// Payment status of an invoice.
enum PaymentStatus {
  /// Invoice issued, awaiting payment.
  pending(label: 'Pending'),

  /// Payment received in full.
  paid(label: 'Paid'),

  /// Invoice is past due date and unpaid.
  overdue(label: 'Overdue'),

  /// Invoice cancelled or written off.
  cancelled(label: 'Cancelled');

  const PaymentStatus({required this.label});

  final String label;
}

/// Immutable GST-compliant billing invoice for CA services.
///
/// All monetary amounts are in paise (100 paise = ₹1).
class BillingInvoice {
  const BillingInvoice({
    required this.invoiceId,
    required this.clientId,
    required this.engagementId,
    required this.lineItems,
    required this.subtotal,
    required this.gstAmount,
    required this.totalAmount,
    required this.dueDate,
    required this.paymentStatus,
  });

  /// Unique invoice identifier.
  final String invoiceId;

  /// Client being billed.
  final String clientId;

  /// Engagement this invoice relates to.
  final String engagementId;

  /// Individual service line items on this invoice.
  final List<BillingLineItem> lineItems;

  /// Sum of all line item amounts before GST, in paise.
  final int subtotal;

  /// Total GST amount (18% on CA services), in paise.
  final int gstAmount;

  /// Grand total including GST, in paise.
  final int totalAmount;

  /// Date by which payment is due.
  final DateTime dueDate;

  /// Current payment status.
  final PaymentStatus paymentStatus;

  BillingInvoice copyWith({
    String? invoiceId,
    String? clientId,
    String? engagementId,
    List<BillingLineItem>? lineItems,
    int? subtotal,
    int? gstAmount,
    int? totalAmount,
    DateTime? dueDate,
    PaymentStatus? paymentStatus,
  }) {
    return BillingInvoice(
      invoiceId: invoiceId ?? this.invoiceId,
      clientId: clientId ?? this.clientId,
      engagementId: engagementId ?? this.engagementId,
      lineItems: lineItems ?? this.lineItems,
      subtotal: subtotal ?? this.subtotal,
      gstAmount: gstAmount ?? this.gstAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      dueDate: dueDate ?? this.dueDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillingInvoice &&
        other.invoiceId == invoiceId &&
        other.clientId == clientId &&
        other.engagementId == engagementId &&
        other.subtotal == subtotal &&
        other.gstAmount == gstAmount &&
        other.totalAmount == totalAmount &&
        other.dueDate == dueDate &&
        other.paymentStatus == paymentStatus;
  }

  @override
  int get hashCode => Object.hash(
    invoiceId,
    clientId,
    engagementId,
    subtotal,
    gstAmount,
    totalAmount,
    dueDate,
    paymentStatus,
  );
}
