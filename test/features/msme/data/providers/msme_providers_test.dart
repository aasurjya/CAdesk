import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/msme/data/providers/msme_providers.dart';
import 'package:ca_app/features/msme/domain/models/msme_vendor.dart';
import 'package:ca_app/features/msme/domain/models/msme_payment.dart';

void main() {
  group('allMsmePaymentsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 12 mock supplier payments', () {
      final payments = container.read(allMsmePaymentsProvider);
      expect(payments.length, 12);
    });

    test('all payments have non-empty ids', () {
      final payments = container.read(allMsmePaymentsProvider);
      expect(payments.every((p) => p.id.isNotEmpty), isTrue);
    });
  });

  group('msmePaymentsByClientProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns only payments for c1', () {
      final payments = container.read(msmePaymentsByClientProvider('c1'));
      expect(payments.every((p) => p.clientId == 'c1'), isTrue);
    });

    test('returns empty list for unknown client', () {
      final payments = container.read(
        msmePaymentsByClientProvider('c-unknown'),
      );
      expect(payments, isEmpty);
    });
  });

  group('msme43BhSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('totalOutstanding is non-negative', () {
      final summary = container.read(msme43BhSummaryProvider);
      expect(summary.totalOutstanding, greaterThanOrEqualTo(0));
    });

    test('overdueCount is non-negative', () {
      final summary = container.read(msme43BhSummaryProvider);
      expect(summary.overdueCount, greaterThanOrEqualTo(0));
    });
  });

  group('MsmeClassificationFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(msmeClassificationFilterProvider), isNull);
    });

    test('can be set to micro', () {
      container
          .read(msmeClassificationFilterProvider.notifier)
          .update(MsmeClassification.micro);
      expect(
        container.read(msmeClassificationFilterProvider),
        MsmeClassification.micro,
      );
    });

    test('can be reset to null', () {
      container
          .read(msmeClassificationFilterProvider.notifier)
          .update(MsmeClassification.small);
      container.read(msmeClassificationFilterProvider.notifier).update(null);
      expect(container.read(msmeClassificationFilterProvider), isNull);
    });
  });

  group('MsmePaymentStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(msmePaymentStatusFilterProvider), isNull);
    });

    test('can be set to overdue', () {
      container
          .read(msmePaymentStatusFilterProvider.notifier)
          .update(MsmePaymentStatus.overdue);
      expect(
        container.read(msmePaymentStatusFilterProvider),
        MsmePaymentStatus.overdue,
      );
    });
  });

  group('Msme43BhOnlyNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is false', () {
      expect(container.read(msme43BhOnlyProvider), isFalse);
    });

    test('can be toggled to true', () {
      container.read(msme43BhOnlyProvider.notifier).update(true);
      expect(container.read(msme43BhOnlyProvider), isTrue);
    });
  });

  group('MsmeVendorsNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 10 mock vendors', () {
      final vendors = container.read(msmeVendorsProvider);
      expect(vendors.length, 10);
    });

    test('all vendors have non-empty ids', () {
      final vendors = container.read(msmeVendorsProvider);
      expect(vendors.every((v) => v.id.isNotEmpty), isTrue);
    });

    test('add increases vendor count', () {
      final before = container.read(msmeVendorsProvider).length;
      final newVendor = MsmeVendor(
        id: 'mv-test',
        clientId: 'c1',
        vendorName: 'Test Vendor',
        msmeRegistrationNumber: 'UDYAM-TEST-01-0000001',
        classification: MsmeClassification.micro,
        registeredDate: DateTime(2024, 1, 1),
        isVerified: true,
        outstandingAmount: 0,
        daysPastDue: 0,
        section43BhAtRisk: false,
      );
      container.read(msmeVendorsProvider.notifier).add(newVendor);
      expect(container.read(msmeVendorsProvider).length, before + 1);
    });
  });

  group('MsmePaymentsNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 20 mock payments', () {
      final payments = container.read(msmePaymentsProvider);
      expect(payments.length, 20);
    });
  });

  group('filteredMsmeVendorsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all vendors when no filter', () {
      final all = container.read(msmeVendorsProvider);
      final filtered = container.read(filteredMsmeVendorsProvider);
      expect(filtered.length, all.length);
    });

    test('classification filter narrows results', () {
      container
          .read(msmeClassificationFilterProvider.notifier)
          .update(MsmeClassification.micro);
      final filtered = container.read(filteredMsmeVendorsProvider);
      expect(
        filtered.every((v) => v.classification == MsmeClassification.micro),
        isTrue,
      );
    });

    test('43Bh only filter returns only at-risk vendors', () {
      container.read(msme43BhOnlyProvider.notifier).update(true);
      final filtered = container.read(filteredMsmeVendorsProvider);
      expect(filtered.every((v) => v.section43BhAtRisk), isTrue);
    });
  });

  group('filteredMsmePaymentsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all payments when no filter', () {
      final all = container.read(msmePaymentsProvider);
      final filtered = container.read(filteredMsmePaymentsProvider);
      expect(filtered.length, all.length);
    });

    test('status filter narrows to overdue payments', () {
      container
          .read(msmePaymentStatusFilterProvider.notifier)
          .update(MsmePaymentStatus.overdue);
      final filtered = container.read(filteredMsmePaymentsProvider);
      expect(
        filtered.every((p) => p.status == MsmePaymentStatus.overdue),
        isTrue,
      );
    });
  });

  group('section43BhAlertsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns only at-risk vendors', () {
      final alerts = container.read(section43BhAlertsProvider);
      expect(alerts.every((v) => v.section43BhAtRisk), isTrue);
    });

    test('returns non-empty list', () {
      final alerts = container.read(section43BhAlertsProvider);
      expect(alerts, isNotEmpty);
    });
  });

  group('msmeSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('totalVendors matches vendor list length', () {
      final vendors = container.read(msmeVendorsProvider);
      final summary = container.read(msmeSummaryProvider);
      expect(summary.totalVendors, vendors.length);
    });

    test('atRiskDeductions is non-negative', () {
      final summary = container.read(msmeSummaryProvider);
      expect(summary.atRiskDeductions, greaterThanOrEqualTo(0));
    });
  });
}
