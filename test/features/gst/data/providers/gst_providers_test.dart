import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/gst/data/providers/gst_providers.dart';
import 'package:ca_app/features/gst/domain/models/gst_client.dart';
import 'package:ca_app/features/gst/domain/models/gst_return.dart';

void main() {
  group('GST Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('LateFeesCalculator', () {
      test('returns zero for zero days late', () {
        expect(
          LateFeesCalculator.calculateLateFee(
            daysLate: 0,
            isNilReturn: false,
            returnType: GstReturnType.gstr3b,
          ),
          0,
        );
      });

      test('calculates standard late fee at ₹50/day', () {
        expect(
          LateFeesCalculator.calculateLateFee(
            daysLate: 5,
            isNilReturn: false,
            returnType: GstReturnType.gstr3b,
          ),
          250,
        );
      });

      test('standard late fee is capped at ₹10,000', () {
        expect(
          LateFeesCalculator.calculateLateFee(
            daysLate: 300,
            isNilReturn: false,
            returnType: GstReturnType.gstr3b,
          ),
          10000,
        );
      });

      test('nil return late fee at ₹20/day', () {
        expect(
          LateFeesCalculator.calculateLateFee(
            daysLate: 10,
            isNilReturn: true,
            returnType: GstReturnType.gstr1,
          ),
          200,
        );
      });

      test('nil return late fee capped at ₹500', () {
        expect(
          LateFeesCalculator.calculateLateFee(
            daysLate: 100,
            isNilReturn: true,
            returnType: GstReturnType.gstr1,
          ),
          500,
        );
      });

      test('interest: returns zero for zero days late', () {
        expect(
          LateFeesCalculator.calculateInterest(taxDue: 10000, daysLate: 0),
          0,
        );
      });

      test('interest: computes 18% p.a. for 30 days', () {
        final interest = LateFeesCalculator.calculateInterest(
          taxDue: 10000,
          daysLate: 30,
        );
        expect(interest, closeTo(10000 * 0.18 / 365 * 30, 0.01));
      });
    });

    group('gstClientsProvider', () {
      test('returns non-empty list of GST clients', () {
        final clients = container.read(gstClientsProvider);
        expect(clients, isNotEmpty);
        expect(clients.length, greaterThanOrEqualTo(6));
      });

      test('list is unmodifiable', () {
        final clients = container.read(gstClientsProvider);
        expect(
          () => (clients as dynamic).add(clients.first),
          throwsA(isA<Error>()),
        );
      });

      test('all entries are GstClient instances', () {
        final clients = container.read(gstClientsProvider);
        for (final c in clients) {
          expect(c, isA<GstClient>());
        }
      });
    });

    group('gstReturnsProvider', () {
      test('returns non-empty list of GST returns', () {
        final returns = container.read(gstReturnsProvider);
        expect(returns, isNotEmpty);
      });

      test('all entries are GstReturn instances', () {
        final returns = container.read(gstReturnsProvider);
        for (final r in returns) {
          expect(r, isA<GstReturn>());
        }
      });

      test('includes late-filed returns', () {
        final returns = container.read(gstReturnsProvider);
        final lateFiled = returns
            .where((r) => r.status == GstReturnStatus.lateFiled)
            .toList();
        expect(lateFiled, isNotEmpty);
      });
    });

    group('gstSelectedPeriodProvider', () {
      test('initial state is Feb 2026', () {
        final period = container.read(gstSelectedPeriodProvider);
        expect(period.month, 2);
        expect(period.year, 2026);
      });

      test('can be updated to a different period', () {
        container.read(gstSelectedPeriodProvider.notifier).update((
          month: 1,
          year: 2026,
        ));
        final period = container.read(gstSelectedPeriodProvider);
        expect(period.month, 1);
        expect(period.year, 2026);
      });
    });

    group('gstFilteredReturnsProvider', () {
      test('returns only Feb 2026 returns initially', () {
        final filtered = container.read(gstFilteredReturnsProvider);
        expect(filtered, isNotEmpty);
        for (final r in filtered) {
          expect(r.periodMonth, 2);
          expect(r.periodYear, 2026);
        }
      });

      test('changes when period is updated', () {
        container.read(gstSelectedPeriodProvider.notifier).update((
          month: 3,
          year: 2025,
        ));
        final filtered = container.read(gstFilteredReturnsProvider);
        for (final r in filtered) {
          expect(r.periodMonth, 3);
          expect(r.periodYear, 2025);
        }
      });
    });

    group('gstReturnsByTypeProvider', () {
      test('null type returns all filtered returns', () {
        final all = container.read(gstFilteredReturnsProvider);
        final byType = container.read(gstReturnsByTypeProvider(null));
        expect(byType.length, all.length);
      });

      test('filters to GSTR-1 only', () {
        final gstr1 = container.read(
          gstReturnsByTypeProvider(GstReturnType.gstr1),
        );
        expect(gstr1, isNotEmpty);
        expect(gstr1.every((r) => r.returnType == GstReturnType.gstr1), isTrue);
      });

      test('filters to GSTR-3B only', () {
        final gstr3b = container.read(
          gstReturnsByTypeProvider(GstReturnType.gstr3b),
        );
        expect(gstr3b, isNotEmpty);
        expect(
          gstr3b.every((r) => r.returnType == GstReturnType.gstr3b),
          isTrue,
        );
      });
    });

    group('gstSummaryProvider', () {
      test('totalGstins matches gstClientsProvider length', () {
        final summary = container.read(gstSummaryProvider);
        expect(summary.totalGstins, container.read(gstClientsProvider).length);
      });

      test('returnsDue is non-negative', () {
        final summary = container.read(gstSummaryProvider);
        expect(summary.returnsDue, greaterThanOrEqualTo(0));
      });

      test('overdue is non-negative and <= returnsDue', () {
        final summary = container.read(gstSummaryProvider);
        expect(summary.overdue, greaterThanOrEqualTo(0));
        expect(summary.overdue, lessThanOrEqualTo(summary.returnsDue));
      });
    });

    group('allItcReconciliationsProvider', () {
      test('returns non-empty list', () {
        final recs = container.read(allItcReconciliationsProvider);
        expect(recs, isNotEmpty);
        expect(recs.length, greaterThanOrEqualTo(6));
      });
    });

    group('itcReconForClientProvider', () {
      test('returns record for existing client', () {
        final rec = container.read(itcReconForClientProvider('gst-001'));
        expect(rec, isNotNull);
        expect(rec!.clientId, 'gst-001');
      });

      test('returns null for non-existent client', () {
        final rec = container.read(
          itcReconForClientProvider('no-such-client-xyz'),
        );
        expect(rec, isNull);
      });
    });

    group('itcReconSummaryProvider', () {
      test('total matches allItcReconciliationsProvider length', () {
        final summary = container.read(itcReconSummaryProvider);
        expect(
          summary.total,
          container.read(allItcReconciliationsProvider).length,
        );
      });

      test('totalMismatch is non-negative', () {
        final summary = container.read(itcReconSummaryProvider);
        expect(summary.totalMismatch, greaterThanOrEqualTo(0));
      });

      test('reconciled count matches Reconciled status', () {
        final summary = container.read(itcReconSummaryProvider);
        final expected = container
            .read(allItcReconciliationsProvider)
            .where((r) => r.status == 'Reconciled')
            .length;
        expect(summary.reconciled, expected);
      });
    });
  });
}
