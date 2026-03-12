import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/msme/domain/models/msme_payment_tracker.dart';
import 'package:ca_app/features/msme/domain/models/msme_form1.dart';
import 'package:ca_app/features/msme/domain/services/msme_payment_engine.dart';
import 'package:ca_app/features/msme/domain/services/msme_vendor_verification_service.dart';

void main() {
  group('MsmePaymentEngine', () {
    late MsmePaymentEngine engine;

    setUp(() {
      engine = MsmePaymentEngine.instance;
    });

    test('singleton returns same instance', () {
      expect(MsmePaymentEngine.instance, same(MsmePaymentEngine.instance));
    });

    group('trackPayment — overdue status', () {
      test('not overdue when payment made within 45 days', () {
        final tracker = MsmePaymentTracker(
          vendorPan: 'ABCDE1234F',
          vendorName: 'Micro Vendor',
          msmeCategory: MsmeCategory.micro,
          invoiceDate: DateTime(2024, 1, 1),
          dueDate: DateTime(2024, 2, 15), // 45 days
          paymentDate: DateTime(2024, 2, 10),
          amountPaise: 500000,
        );
        final result = engine.trackPayment(tracker);
        expect(result.isOverdue, false);
        expect(result.daysOverdue, 0);
        expect(result.disallowanceRisk, false);
      });

      test('overdue when payment not made and past due date', () {
        final tracker = MsmePaymentTracker(
          vendorPan: 'ABCDE1234F',
          vendorName: 'Small Vendor',
          msmeCategory: MsmeCategory.small,
          invoiceDate: DateTime(2024, 1, 1),
          dueDate: DateTime(2024, 2, 15),
          paymentDate: null,
          amountPaise: 1000000,
          referenceDate: DateTime(2024, 3, 1),
        );
        final result = engine.trackPayment(tracker);
        expect(result.isOverdue, true);
        expect(result.daysOverdue, greaterThan(0));
      });

      test('disallowance risk when unpaid beyond 45 days by March 31', () {
        final tracker = MsmePaymentTracker(
          vendorPan: 'ABCDE1234F',
          vendorName: 'Small Vendor',
          msmeCategory: MsmeCategory.small,
          invoiceDate: DateTime(2024, 1, 1),
          dueDate: DateTime(2024, 2, 15),
          paymentDate: null,
          amountPaise: 1000000,
          referenceDate: DateTime(2024, 3, 31),
        );
        final result = engine.trackPayment(tracker);
        expect(result.disallowanceRisk, true);
      });
    });

    group('computeSection43BhDisallowance', () {
      test(
        'disallows amount for MSME vendors unpaid beyond 45 days at year end',
        () {
          final trackers = [
            MsmePaymentTracker(
              vendorPan: 'AAAAA0001A',
              vendorName: 'Micro Co',
              msmeCategory: MsmeCategory.micro,
              invoiceDate: DateTime(2024, 1, 1),
              dueDate: DateTime(2024, 2, 15),
              paymentDate: null, // still unpaid at year end
              amountPaise: 1000000,
              referenceDate: DateTime(2024, 3, 31),
            ),
          ];
          final disallowance = engine.computeSection43BhDisallowance(
            trackers,
            2024,
          );
          expect(disallowance, 1000000);
        },
      );

      test('no disallowance if payment made before year end', () {
        final trackers = [
          MsmePaymentTracker(
            vendorPan: 'AAAAA0001A',
            vendorName: 'Micro Co',
            msmeCategory: MsmeCategory.micro,
            invoiceDate: DateTime(2024, 1, 1),
            dueDate: DateTime(2024, 2, 15),
            paymentDate: DateTime(2024, 2, 20),
            amountPaise: 1000000,
            referenceDate: DateTime(2024, 3, 31),
          ),
        ];
        final disallowance = engine.computeSection43BhDisallowance(
          trackers,
          2024,
        );
        expect(disallowance, 0);
      });

      test(
        'no disallowance for medium category (only micro/small covered)',
        () {
          final trackers = [
            MsmePaymentTracker(
              vendorPan: 'BBBBB0002B',
              vendorName: 'Medium Corp',
              msmeCategory: MsmeCategory.medium,
              invoiceDate: DateTime(2024, 1, 1),
              dueDate: DateTime(2024, 2, 15),
              paymentDate: null,
              amountPaise: 2000000,
              referenceDate: DateTime(2024, 3, 31),
            ),
          ];
          final disallowance = engine.computeSection43BhDisallowance(
            trackers,
            2024,
          );
          expect(disallowance, 0);
        },
      );

      test('sums disallowances across multiple micro/small vendors', () {
        final trackers = [
          MsmePaymentTracker(
            vendorPan: 'AAAAA0001A',
            vendorName: 'Micro 1',
            msmeCategory: MsmeCategory.micro,
            invoiceDate: DateTime(2024, 1, 1),
            dueDate: DateTime(2024, 2, 15),
            paymentDate: null,
            amountPaise: 1000000,
            referenceDate: DateTime(2024, 3, 31),
          ),
          MsmePaymentTracker(
            vendorPan: 'BBBBB0002B',
            vendorName: 'Small 1',
            msmeCategory: MsmeCategory.small,
            invoiceDate: DateTime(2024, 1, 10),
            dueDate: DateTime(2024, 2, 24),
            paymentDate: null,
            amountPaise: 500000,
            referenceDate: DateTime(2024, 3, 31),
          ),
        ];
        final disallowance = engine.computeSection43BhDisallowance(
          trackers,
          2024,
        );
        expect(disallowance, 1500000);
      });
    });

    group('generateMsmeForm1', () {
      test('generates form with correct period and unpaid entries', () {
        final trackers = [
          MsmePaymentTracker(
            vendorPan: 'AAAAA0001A',
            vendorName: 'Micro 1',
            msmeCategory: MsmeCategory.micro,
            invoiceDate: DateTime(2024, 1, 1),
            dueDate: DateTime(2024, 2, 15),
            paymentDate: null,
            amountPaise: 1000000,
            referenceDate: DateTime(2024, 3, 31),
          ),
          MsmePaymentTracker(
            vendorPan: 'CCCCC0003C',
            vendorName: 'Paid Vendor',
            msmeCategory: MsmeCategory.small,
            invoiceDate: DateTime(2024, 1, 5),
            dueDate: DateTime(2024, 2, 19),
            paymentDate: DateTime(2024, 2, 15),
            amountPaise: 300000,
            referenceDate: DateTime(2024, 3, 31),
          ),
        ];
        final form = engine.generateMsmeForm1(trackers, 'H2-2024');
        expect(form.period, 'H2-2024');
        // Only unpaid entries should appear
        expect(form.unpaidEntries.length, 1);
        expect(form.unpaidEntries.first.vendorPan, 'AAAAA0001A');
      });
    });
  });

  group('MsmeVendorVerificationService', () {
    late MsmeVendorVerificationService service;

    setUp(() {
      service = MsmeVendorVerificationService.instance;
    });

    test('singleton returns same instance', () {
      expect(
        MsmeVendorVerificationService.instance,
        same(MsmeVendorVerificationService.instance),
      );
    });

    test('returns verification result for valid udyam number', () async {
      final result = await service.verifyMsmeStatus('UDYAM-MH-01-0000001');
      expect(result.udyamNumber, 'UDYAM-MH-01-0000001');
      expect(result.isVerified, isA<bool>());
    });
  });

  group('MsmePaymentTracker model', () {
    test('equality and copyWith', () {
      final ref = DateTime(2024, 3, 31);
      final a = MsmePaymentTracker(
        vendorPan: 'ABCDE1234F',
        vendorName: 'Test Vendor',
        msmeCategory: MsmeCategory.micro,
        invoiceDate: DateTime(2024, 1, 1),
        dueDate: DateTime(2024, 2, 15),
        paymentDate: null,
        amountPaise: 100000,
        referenceDate: ref,
      );
      final b = MsmePaymentTracker(
        vendorPan: 'ABCDE1234F',
        vendorName: 'Test Vendor',
        msmeCategory: MsmeCategory.micro,
        invoiceDate: DateTime(2024, 1, 1),
        dueDate: DateTime(2024, 2, 15),
        paymentDate: null,
        amountPaise: 100000,
        referenceDate: ref,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final updated = a.copyWith(vendorName: 'Updated Vendor');
      expect(updated.vendorName, 'Updated Vendor');
      expect(a.vendorName, 'Test Vendor');
    });
  });

  group('MsmeForm1 model', () {
    test('equality', () {
      const a = MsmeForm1(period: 'H1-2024', unpaidEntries: []);
      const b = MsmeForm1(period: 'H1-2024', unpaidEntries: []);
      expect(a, equals(b));
    });
  });
}
