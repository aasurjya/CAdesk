import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/billing/domain/models/payment_record.dart';
import 'package:ca_app/features/billing/data/repositories/mock_payment_repository.dart';

void main() {
  group('MockPaymentRepository', () {
    late MockPaymentRepository repo;

    setUp(() {
      repo = MockPaymentRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    group('getAll', () {
      test('returns all seeded payment records', () async {
        final all = await repo.getAll();
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAll();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });

    group('getById', () {
      test('returns payment record for valid ID', () async {
        final payment = await repo.getById('pay-001');
        expect(payment, isNotNull);
        expect(payment!.id, 'pay-001');
        expect(payment.invoiceId, 'inv-001');
      });

      test('returns null for unknown ID', () async {
        final payment = await repo.getById('no-such-id');
        expect(payment, isNull);
      });
    });

    group('create', () {
      test('creates payment record and returns it', () async {
        const newPayment = PaymentRecord(
          id: 'pay-new-001',
          invoiceId: 'inv-002',
          clientName: 'Rajesh Kumar Sharma',
          amount: 5900,
          paymentDate: '10 Mar 2026',
          mode: 'UPI',
          reference: 'UPI20260310RAJESH',
          notes: 'Full payment for INV-2026-002.',
        );

        final created = await repo.create(newPayment);
        expect(created.id, 'pay-new-001');
        expect(created.amount, 5900);

        final fetched = await repo.getById('pay-new-001');
        expect(fetched, isNotNull);
        expect(fetched!.mode, 'UPI');
      });
    });

    group('delete', () {
      test('deletes payment so it no longer appears in getById', () async {
        const toDelete = PaymentRecord(
          id: 'pay-to-delete',
          invoiceId: 'inv-002',
          clientName: 'Delete Client',
          amount: 100,
          paymentDate: '01 Jan 2026',
          mode: 'Cash',
          reference: 'CASH001',
          notes: '',
        );

        await repo.create(toDelete);
        await repo.delete('pay-to-delete');

        final fetched = await repo.getById('pay-to-delete');
        expect(fetched, isNull);
      });

      test('delete on non-existent ID does not throw', () async {
        await expectLater(repo.delete('no-such-pay'), completes);
      });
    });

    group('getByInvoiceId', () {
      test('returns payments for inv-001', () async {
        final results = await repo.getByInvoiceId('inv-001');
        expect(results, isNotEmpty);
        expect(results.every((p) => p.invoiceId == 'inv-001'), isTrue);
      });

      test('returns multiple payments for inv-003', () async {
        final results = await repo.getByInvoiceId('inv-003');
        expect(results.length, 2);
        expect(results.every((p) => p.invoiceId == 'inv-003'), isTrue);
      });

      test('returns empty list for invoice with no payments', () async {
        final results = await repo.getByInvoiceId('inv-999');
        expect(results, isEmpty);
      });
    });

    group('watchByInvoiceId', () {
      test('emits a list after create for the watched invoice', () async {
        final stream = repo.watchByInvoiceId('inv-002');
        final future = stream.first;

        await repo.create(
          const PaymentRecord(
            id: 'pay-stream-test',
            invoiceId: 'inv-002',
            clientName: 'Stream Client',
            amount: 1000,
            paymentDate: '15 Mar 2026',
            mode: 'NEFT',
            reference: 'NEFT001',
            notes: 'Stream test payment.',
          ),
        );

        final emitted = await future;
        expect(emitted.any((p) => p.id == 'pay-stream-test'), isTrue);
      });

      test('does not emit for a different invoice', () async {
        final stream = repo.watchByInvoiceId('inv-005');
        var emitted = false;
        final sub = stream.listen((_) => emitted = true);

        // Create payment for a different invoice
        await repo.create(
          const PaymentRecord(
            id: 'pay-other-inv',
            invoiceId: 'inv-001',
            clientName: 'Other Client',
            amount: 500,
            paymentDate: '15 Mar 2026',
            mode: 'Cash',
            reference: 'CASH002',
            notes: '',
          ),
        );

        // Give any queued microtasks a chance to run
        await Future<void>.delayed(Duration.zero);
        expect(emitted, isFalse);
        await sub.cancel();
      });
    });
  });
}
