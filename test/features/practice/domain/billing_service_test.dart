import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/staff_assignment.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';
import 'package:ca_app/features/practice/domain/models/billing_invoice.dart';
import 'package:ca_app/features/practice/domain/models/billing_line_item.dart';
import 'package:ca_app/features/practice/domain/services/billing_service.dart';
import 'package:ca_app/features/practice/domain/services/engagement_letter_service.dart';

const _firm = CaFirmData(
  firmName: 'Shah & Associates',
  membershipNumber: '123456',
  firmRegistrationNumber: '001234N',
  address: '5th Floor, Prestige Tower, Bengaluru - 560025',
  signatoryName: 'CA Vikram Shah',
);

Engagement _makeEngagement({int billingAmount = 500000}) {
  return Engagement(
    engagementId: 'eng-001',
    clientId: 'client-001',
    templateId: 'tmpl-itr-individual',
    templateTasks: const [],
    assignedStaff: const [
      StaffAssignment(
        staffId: 'staff-001',
        role: StaffRole.senior,
        tasks: ['t1'],
        hoursLogged: 3,
        hoursEstimated: 3,
      ),
    ],
    status: EngagementStatus.done,
    dueDate: DateTime(2025, 7, 31),
    completedDate: DateTime(2025, 7, 28),
    billingAmount: billingAmount,
  );
}

BillingInvoice _makeInvoice({
  String invoiceId = 'inv-001',
  int subtotal = 500000,
  int gstAmount = 90000,
  bool paid = false,
}) {
  return BillingInvoice(
    invoiceId: invoiceId,
    clientId: 'client-001',
    engagementId: 'eng-001',
    lineItems: [
      BillingLineItem(
        description: 'ITR Filing Services',
        sacCode: '998221',
        quantity: 1.0,
        rate: subtotal,
        amount: subtotal,
        gstRate: 0.18,
      ),
    ],
    subtotal: subtotal,
    gstAmount: gstAmount,
    totalAmount: subtotal + gstAmount,
    dueDate: DateTime(2025, 8, 15),
    paymentStatus: paid ? PaymentStatus.paid : PaymentStatus.pending,
  );
}

void main() {
  group('BillingService.generateInvoice', () {
    test('creates invoice with correct clientId and engagementId', () {
      final engagement = _makeEngagement();
      final invoice = BillingService.instance.generateInvoice(
        engagement,
        _firm,
      );
      expect(invoice.clientId, 'client-001');
      expect(invoice.engagementId, 'eng-001');
    });

    test('generates unique invoiceId', () {
      final e1 = _makeEngagement();
      final e2 = _makeEngagement(billingAmount: 300000);
      final inv1 = BillingService.instance.generateInvoice(e1, _firm);
      final inv2 = BillingService.instance.generateInvoice(e2, _firm);
      expect(inv1.invoiceId, isNot(equals(inv2.invoiceId)));
    });

    test('subtotal equals engagement billingAmount', () {
      final engagement = _makeEngagement(billingAmount: 500000);
      final invoice = BillingService.instance.generateInvoice(
        engagement,
        _firm,
      );
      expect(invoice.subtotal, 500000);
    });

    test('line items have SAC code 998221 for tax advisory', () {
      final engagement = _makeEngagement();
      final invoice = BillingService.instance.generateInvoice(
        engagement,
        _firm,
      );
      expect(invoice.lineItems, isNotEmpty);
      // SAC codes for CA services
      final sacCodes = invoice.lineItems.map((li) => li.sacCode).toList();
      expect(sacCodes.any((s) => s.startsWith('998')), isTrue);
    });

    test('payment status defaults to pending', () {
      final engagement = _makeEngagement();
      final invoice = BillingService.instance.generateInvoice(
        engagement,
        _firm,
      );
      expect(invoice.paymentStatus, PaymentStatus.pending);
    });
  });

  group('BillingService.computeGst', () {
    test('computes 18% GST on subtotal', () {
      final invoice = _makeInvoice(subtotal: 500000, gstAmount: 0);
      final gst = BillingService.instance.computeGst(invoice);
      // 18% of 500000 paise = 90000 paise
      expect(gst, 90000);
    });

    test('computes 18% GST on 1000000 paise (₹10,000)', () {
      final invoice = _makeInvoice(subtotal: 1000000, gstAmount: 0);
      final gst = BillingService.instance.computeGst(invoice);
      expect(gst, 180000);
    });

    test('returns zero GST on zero subtotal', () {
      final invoice = _makeInvoice(subtotal: 0, gstAmount: 0);
      final gst = BillingService.instance.computeGst(invoice);
      expect(gst, 0);
    });
  });

  group('BillingService.computeOutstandingAmount', () {
    test('returns zero when all invoices paid', () {
      final invoices = [
        _makeInvoice(invoiceId: 'inv-001', paid: true),
        _makeInvoice(invoiceId: 'inv-002', paid: true),
      ];
      final outstanding = BillingService.instance.computeOutstandingAmount(
        'client-001',
        invoices,
      );
      expect(outstanding, 0);
    });

    test('returns sum of unpaid invoice totals', () {
      final invoices = [
        _makeInvoice(
          invoiceId: 'inv-001',
          subtotal: 500000,
          gstAmount: 90000,
          paid: false,
        ),
        _makeInvoice(
          invoiceId: 'inv-002',
          subtotal: 300000,
          gstAmount: 54000,
          paid: true,
        ),
      ];
      final outstanding = BillingService.instance.computeOutstandingAmount(
        'client-001',
        invoices,
      );
      // Only inv-001 is unpaid: 500000 + 90000 = 590000
      expect(outstanding, 590000);
    });

    test('only counts invoices for specified clientId', () {
      final inv1 = BillingInvoice(
        invoiceId: 'inv-001',
        clientId: 'client-001',
        engagementId: 'eng-001',
        lineItems: const [],
        subtotal: 500000,
        gstAmount: 90000,
        totalAmount: 590000,
        dueDate: DateTime(2025, 8, 15),
        paymentStatus: PaymentStatus.pending,
      );
      final inv2 = BillingInvoice(
        invoiceId: 'inv-002',
        clientId: 'client-002',
        engagementId: 'eng-002',
        lineItems: const [],
        subtotal: 300000,
        gstAmount: 54000,
        totalAmount: 354000,
        dueDate: DateTime(2025, 8, 15),
        paymentStatus: PaymentStatus.pending,
      );
      final outstanding = BillingService.instance.computeOutstandingAmount(
        'client-001',
        [inv1, inv2],
      );
      expect(outstanding, 590000);
    });
  });

  group('BillingService.applyLateFeeIfApplicable', () {
    test('does not apply late fee when due date is in future', () {
      final invoice = _makeInvoice(subtotal: 500000, gstAmount: 90000);
      final futureInvoice = BillingInvoice(
        invoiceId: invoice.invoiceId,
        clientId: invoice.clientId,
        engagementId: invoice.engagementId,
        lineItems: invoice.lineItems,
        subtotal: invoice.subtotal,
        gstAmount: invoice.gstAmount,
        totalAmount: invoice.totalAmount,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        paymentStatus: PaymentStatus.pending,
      );
      final result = BillingService.instance.applyLateFeeIfApplicable(
        futureInvoice,
        DateTime.now(),
      );
      expect(result.totalAmount, futureInvoice.totalAmount);
    });

    test('applies late fee when past due date', () {
      final invoice = BillingInvoice(
        invoiceId: 'inv-late',
        clientId: 'client-001',
        engagementId: 'eng-001',
        lineItems: const [],
        subtotal: 500000,
        gstAmount: 90000,
        totalAmount: 590000,
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        paymentStatus: PaymentStatus.pending,
      );
      final result = BillingService.instance.applyLateFeeIfApplicable(
        invoice,
        DateTime.now(),
      );
      // Late fee should increase totalAmount
      expect(result.totalAmount, greaterThan(invoice.totalAmount));
    });

    test('does not apply late fee when already paid', () {
      final invoice = BillingInvoice(
        invoiceId: 'inv-paid',
        clientId: 'client-001',
        engagementId: 'eng-001',
        lineItems: const [],
        subtotal: 500000,
        gstAmount: 90000,
        totalAmount: 590000,
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        paymentStatus: PaymentStatus.paid,
      );
      final result = BillingService.instance.applyLateFeeIfApplicable(
        invoice,
        DateTime.now(),
      );
      expect(result.totalAmount, invoice.totalAmount);
    });
  });
}
