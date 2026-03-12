import 'package:ca_app/features/practice/domain/models/billing_invoice.dart';
import 'package:ca_app/features/practice/domain/models/billing_line_item.dart';
import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/services/engagement_letter_service.dart';

/// GST rate for CA professional services (SAC 998221 and related).
const double _caGstRate = 0.18;

/// SAC code for tax advisory and related CA services.
const String _defaultSacCode = '998221';

/// Late fee rate applied per month overdue (2% of outstanding).
const double _lateFeeRatePerMonth = 0.02;

/// Generates and manages GST-compliant billing invoices for CA engagements.
///
/// Stateless singleton — all methods are pure functions of their inputs.
class BillingService {
  BillingService._();

  static final BillingService instance = BillingService._();

  /// Generates a [BillingInvoice] for a completed [Engagement].
  ///
  /// - Subtotal equals [Engagement.billingAmount].
  /// - GST is computed at 18% (SAC 998221 — tax advisory services).
  /// - Payment status defaults to [PaymentStatus.pending].
  /// - Due date is set to 15 calendar days from today.
  BillingInvoice generateInvoice(Engagement engagement, CaFirmData firm) {
    final subtotal = engagement.billingAmount;
    final gst = computeGst(
      BillingInvoice(
        invoiceId: '',
        clientId: engagement.clientId,
        engagementId: engagement.engagementId,
        lineItems: const [],
        subtotal: subtotal,
        gstAmount: 0,
        totalAmount: subtotal,
        dueDate: DateTime.now(),
        paymentStatus: PaymentStatus.pending,
      ),
    );
    final total = subtotal + gst;
    final lineItem = BillingLineItem(
      description: 'Professional Services — ${firm.firmName}',
      sacCode: _defaultSacCode,
      quantity: 1.0,
      rate: subtotal,
      amount: subtotal,
      gstRate: _caGstRate,
    );
    final dueDate = DateTime.now().add(const Duration(days: 15));
    return BillingInvoice(
      invoiceId: _generateId('inv'),
      clientId: engagement.clientId,
      engagementId: engagement.engagementId,
      lineItems: [lineItem],
      subtotal: subtotal,
      gstAmount: gst,
      totalAmount: total,
      dueDate: dueDate,
      paymentStatus: PaymentStatus.pending,
    );
  }

  /// Computes 18% GST on the invoice subtotal, in paise.
  ///
  /// Result is truncated (floor) to avoid fractional paise.
  int computeGst(BillingInvoice invoice) {
    return (invoice.subtotal * _caGstRate).truncate();
  }

  /// Returns the total outstanding (unpaid) amount for [clientId] in paise.
  ///
  /// Sums [BillingInvoice.totalAmount] for all invoices where:
  /// - [BillingInvoice.clientId] matches [clientId]
  /// - [BillingInvoice.paymentStatus] is not [PaymentStatus.paid]
  int computeOutstandingAmount(String clientId, List<BillingInvoice> invoices) {
    return invoices
        .where(
          (inv) =>
              inv.clientId == clientId &&
              inv.paymentStatus != PaymentStatus.paid,
        )
        .fold(0, (sum, inv) => sum + inv.totalAmount);
  }

  /// Returns a new [BillingInvoice] with a late fee applied if applicable.
  ///
  /// A late fee of 2% per month overdue is added to [BillingInvoice.totalAmount]
  /// when all of the following are true:
  /// - [today] is after [BillingInvoice.dueDate]
  /// - [BillingInvoice.paymentStatus] is [PaymentStatus.pending] or [PaymentStatus.overdue]
  ///
  /// No mutation — returns a new invoice instance.
  BillingInvoice applyLateFeeIfApplicable(
    BillingInvoice invoice,
    DateTime today,
  ) {
    final isPaid =
        invoice.paymentStatus == PaymentStatus.paid ||
        invoice.paymentStatus == PaymentStatus.cancelled;
    if (isPaid || !today.isAfter(invoice.dueDate)) {
      return invoice;
    }

    final daysOverdue = today.difference(invoice.dueDate).inDays;
    final monthsOverdue = (daysOverdue / 30).ceil().clamp(1, 12);
    final lateFee = (invoice.totalAmount * _lateFeeRatePerMonth * monthsOverdue)
        .truncate();
    return invoice.copyWith(
      totalAmount: invoice.totalAmount + lateFee,
      paymentStatus: PaymentStatus.overdue,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  String _generateId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}
