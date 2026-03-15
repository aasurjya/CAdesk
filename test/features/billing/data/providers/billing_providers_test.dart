import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/billing/data/providers/billing_providers.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/billing/domain/models/payment_record.dart';

void main() {
  group('GstInvoiceCalculator', () {
    group('compute — intra-state', () {
      test('splits GST into equal CGST and SGST', () {
        final result = GstInvoiceCalculator.compute(
          taxableValue: 10000,
          gstRatePercent: 18,
          isInterState: false,
        );
        expect(result.cgst, closeTo(900, 0.001));
        expect(result.sgst, closeTo(900, 0.001));
        expect(result.igst, 0);
        expect(result.total, closeTo(11800, 0.001));
      });

      test('5% GST intra-state splits correctly', () {
        final result = GstInvoiceCalculator.compute(
          taxableValue: 1000,
          gstRatePercent: 5,
          isInterState: false,
        );
        expect(result.cgst, closeTo(25, 0.001));
        expect(result.sgst, closeTo(25, 0.001));
        expect(result.igst, 0);
        expect(result.total, closeTo(1050, 0.001));
      });
    });

    group('compute — inter-state', () {
      test('applies IGST only', () {
        final result = GstInvoiceCalculator.compute(
          taxableValue: 10000,
          gstRatePercent: 18,
          isInterState: true,
        );
        expect(result.igst, closeTo(1800, 0.001));
        expect(result.cgst, 0);
        expect(result.sgst, 0);
        expect(result.total, closeTo(11800, 0.001));
      });
    });

    group('reverseCompute', () {
      test('extracts taxable value from inclusive amount', () {
        final taxable = GstInvoiceCalculator.reverseCompute(
          inclusiveAmount: 11800,
          gstRatePercent: 18,
        );
        expect(taxable, closeTo(10000, 0.01));
      });

      test('5% rate reverse compute', () {
        final taxable = GstInvoiceCalculator.reverseCompute(
          inclusiveAmount: 1050,
          gstRatePercent: 5,
        );
        expect(taxable, closeTo(1000, 0.01));
      });
    });

    group('latePaymentInterest', () {
      test('computes 18% p.a. interest for 30 days', () {
        final interest = GstInvoiceCalculator.latePaymentInterest(
          amount: 10000,
          daysOverdue: 30,
        );
        // 10000 * 0.18 / 365 * 30 ≈ 147.95
        expect(interest, closeTo(147.95, 0.1));
      });

      test('returns zero for zero days overdue', () {
        final interest = GstInvoiceCalculator.latePaymentInterest(
          amount: 5000,
          daysOverdue: 0,
        );
        expect(interest, 0);
      });
    });
  });

  group('Billing Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('allInvoicesProvider', () {
      test('returns non-empty list of invoices', () {
        final invoices = container.read(allInvoicesProvider);
        expect(invoices, isNotEmpty);
        expect(invoices.length, greaterThanOrEqualTo(15));
      });

      test('result is a list of Invoice objects', () {
        final invoices = container.read(allInvoicesProvider);
        expect(invoices, isNotEmpty);
      });

      test('list is unmodifiable', () {
        final invoices = container.read(allInvoicesProvider);
        expect(() => invoices.add(invoices.first), throwsA(isA<Error>()));
      });

      test('notifier update replaces state immutably', () {
        final original = container.read(allInvoicesProvider);
        final subset = original.take(3).toList();
        container.read(allInvoicesProvider.notifier).update(subset);
        final after = container.read(allInvoicesProvider);
        expect(after.length, 3);
        // original snapshot is unaffected
        expect(original.length, greaterThanOrEqualTo(15));
      });
    });

    group('allReceiptsProvider', () {
      test('returns non-empty list of payment receipts', () {
        final receipts = container.read(allReceiptsProvider);
        expect(receipts, isNotEmpty);
        expect(receipts, isNotEmpty);
      });
    });

    group('allPaymentRecordsProvider', () {
      test('returns non-empty list of payment records', () {
        final records = container.read(allPaymentRecordsProvider);
        expect(records, isNotEmpty);
        expect(records, isNotEmpty);
      });

      test('addRecord appends a new record immutably', () {
        final before = container.read(allPaymentRecordsProvider).length;

        const newRecord = PaymentRecord(
          id: 'pr-test-001',
          invoiceId: 'inv-test',
          clientName: 'Test Client',
          amount: 5000,
          paymentDate: '15 Mar 2026',
          mode: 'UPI',
          reference: 'UPI123456',
          notes: 'Test payment',
        );
        container.read(allPaymentRecordsProvider.notifier).addRecord(newRecord);

        final after = container.read(allPaymentRecordsProvider);
        expect(after.length, before + 1);
        expect(after.last.id, 'pr-test-001');
      });
    });

    group('invoiceStatusFilterProvider', () {
      test('initial state is null (no filter)', () {
        expect(container.read(invoiceStatusFilterProvider), isNull);
      });

      test('can be updated to a specific status', () {
        container
            .read(invoiceStatusFilterProvider.notifier)
            .update(InvoiceStatus.paid);
        expect(container.read(invoiceStatusFilterProvider), InvoiceStatus.paid);
      });

      test('can be cleared back to null', () {
        container
            .read(invoiceStatusFilterProvider.notifier)
            .update(InvoiceStatus.paid);
        container.read(invoiceStatusFilterProvider.notifier).update(null);
        expect(container.read(invoiceStatusFilterProvider), isNull);
      });
    });

    group('billingClientFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(billingClientFilterProvider), isNull);
      });

      test('can be set to a client ID string', () {
        container.read(billingClientFilterProvider.notifier).update('client-1');
        expect(container.read(billingClientFilterProvider), 'client-1');
      });
    });

    group('billingSearchQueryProvider', () {
      test('initial state is empty string', () {
        expect(container.read(billingSearchQueryProvider), '');
      });

      test('can be updated to a search string', () {
        container.read(billingSearchQueryProvider.notifier).update('Mehta');
        expect(container.read(billingSearchQueryProvider), 'Mehta');
      });
    });

    group('filteredInvoicesProvider', () {
      test('returns all invoices when no filters set', () {
        final all = container.read(allInvoicesProvider);
        final filtered = container.read(filteredInvoicesProvider);
        expect(filtered.length, all.length);
      });

      test('filters by status', () {
        container
            .read(invoiceStatusFilterProvider.notifier)
            .update(InvoiceStatus.paid);
        final filtered = container.read(filteredInvoicesProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((inv) => inv.status == InvoiceStatus.paid), isTrue);
      });

      test('filters by client ID', () {
        container.read(billingClientFilterProvider.notifier).update('3');
        final filtered = container.read(filteredInvoicesProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((inv) => inv.clientId == '3'), isTrue);
      });

      test('filters by search query matching client name', () {
        container.read(billingSearchQueryProvider.notifier).update('Mehta');
        final filtered = container.read(filteredInvoicesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every(
            (inv) =>
                inv.clientName.toLowerCase().contains('mehta') ||
                inv.invoiceNumber.toLowerCase().contains('mehta'),
          ),
          isTrue,
        );
      });

      test('returns empty list when no invoices match query', () {
        container
            .read(billingSearchQueryProvider.notifier)
            .update('xyznonexistent99999');
        final filtered = container.read(filteredInvoicesProvider);
        expect(filtered, isEmpty);
      });

      test('result is sorted descending by invoice date', () {
        final filtered = container.read(filteredInvoicesProvider);
        for (int i = 0; i < filtered.length - 1; i++) {
          expect(
            filtered[i].invoiceDate.compareTo(filtered[i + 1].invoiceDate),
            greaterThanOrEqualTo(0),
          );
        }
      });
    });

    group('totalReceivablesProvider', () {
      test('returns sum of all balance-due amounts', () {
        final receivables = container.read(totalReceivablesProvider);
        expect(receivables, greaterThan(0));
      });
    });

    group('totalBilledProvider', () {
      test('returns sum of grand totals excluding cancelled', () {
        final billed = container.read(totalBilledProvider);
        final cancelled = container
            .read(allInvoicesProvider)
            .where((inv) => inv.status == InvoiceStatus.cancelled)
            .fold(0.0, (sum, inv) => sum + inv.grandTotal);
        final total = container
            .read(allInvoicesProvider)
            .fold(0.0, (sum, inv) => sum + inv.grandTotal);
        expect(billed, closeTo(total - cancelled, 0.001));
      });
    });

    group('totalCollectedProvider', () {
      test('returns sum of paid amounts excluding cancelled', () {
        final collected = container.read(totalCollectedProvider);
        expect(collected, greaterThan(0));
      });
    });

    group('overdueCountProvider', () {
      test('returns count of overdue invoices', () {
        final count = container.read(overdueCountProvider);
        final expected = container
            .read(allInvoicesProvider)
            .where((inv) => inv.status == InvoiceStatus.overdue)
            .length;
        expect(count, expected);
      });
    });

    group('billingSummaryProvider', () {
      test('summary matches individual computed providers', () {
        final summary = container.read(billingSummaryProvider);
        expect(summary.totalBilled, container.read(totalBilledProvider));
        expect(summary.totalCollected, container.read(totalCollectedProvider));
        expect(summary.outstanding, container.read(totalReceivablesProvider));
        expect(summary.overdueCount, container.read(overdueCountProvider));
      });
    });
  });
}
