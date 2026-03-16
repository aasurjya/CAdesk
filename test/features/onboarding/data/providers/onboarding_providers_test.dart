import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/onboarding/data/providers/onboarding_providers.dart';
import 'package:ca_app/features/onboarding/domain/models/kyc_record.dart';
import 'package:ca_app/features/onboarding/domain/models/onboarding_checklist.dart';
import 'package:ca_app/features/onboarding/domain/models/document_expiry.dart';

void main() {
  group('Onboarding Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // kycRecordsProvider
    // -------------------------------------------------------------------------
    group('kycRecordsProvider', () {
      test('initial state is non-empty list', () {
        final records = container.read(kycRecordsProvider);
        expect(records, isNotEmpty);
        expect(records.length, greaterThanOrEqualTo(5));
      });

      test('all items are KycRecord objects', () {
        final records = container.read(kycRecordsProvider);
        expect(records, everyElement(isA<KycRecord>()));
      });

      test('records have varied KYC statuses', () {
        final records = container.read(kycRecordsProvider);
        final statuses = records.map((r) => r.kycStatus).toSet();
        expect(statuses.length, greaterThanOrEqualTo(3));
      });

      test('list is unmodifiable', () {
        final records = container.read(kycRecordsProvider);
        expect(() => records.add(records.first), throwsA(anything));
      });
    });

    // -------------------------------------------------------------------------
    // onboardingChecklistsProvider
    // -------------------------------------------------------------------------
    group('onboardingChecklistsProvider', () {
      test('initial state is non-empty list', () {
        final checklists = container.read(onboardingChecklistsProvider);
        expect(checklists, isNotEmpty);
        expect(checklists.length, greaterThanOrEqualTo(4));
      });

      test('all items are OnboardingChecklist objects', () {
        final checklists = container.read(onboardingChecklistsProvider);
        expect(checklists, everyElement(isA<OnboardingChecklist>()));
      });

      test('checklists span different service types', () {
        final checklists = container.read(onboardingChecklistsProvider);
        final types = checklists.map((c) => c.serviceType).toSet();
        expect(types.length, greaterThanOrEqualTo(2));
      });

      test('list is unmodifiable', () {
        final checklists = container.read(onboardingChecklistsProvider);
        expect(() => checklists.add(checklists.first), throwsA(anything));
      });
    });

    // -------------------------------------------------------------------------
    // documentExpiriesProvider
    // -------------------------------------------------------------------------
    group('documentExpiriesProvider', () {
      test('initial state is non-empty list', () {
        final expiries = container.read(documentExpiriesProvider);
        expect(expiries, isNotEmpty);
        expect(expiries.length, greaterThanOrEqualTo(8));
      });

      test('all items are DocumentExpiry objects', () {
        final expiries = container.read(documentExpiriesProvider);
        expect(expiries, everyElement(isA<DocumentExpiry>()));
      });

      test('expiries include different document types', () {
        final expiries = container.read(documentExpiriesProvider);
        final types = expiries.map((e) => e.documentType).toSet();
        expect(types.length, greaterThanOrEqualTo(3));
      });

      test('list is unmodifiable', () {
        final expiries = container.read(documentExpiriesProvider);
        expect(() => expiries.add(expiries.first), throwsA(anything));
      });
    });

    // -------------------------------------------------------------------------
    // kycStatusFilterProvider
    // -------------------------------------------------------------------------
    group('kycStatusFilterProvider', () {
      test('initial state is null (show all)', () {
        expect(container.read(kycStatusFilterProvider), isNull);
      });

      test('can be set to verified', () {
        container
            .read(kycStatusFilterProvider.notifier)
            .update(KycStatus.verified);
        expect(container.read(kycStatusFilterProvider), KycStatus.verified);
      });

      test('can be set to pending', () {
        container
            .read(kycStatusFilterProvider.notifier)
            .update(KycStatus.pending);
        expect(container.read(kycStatusFilterProvider), KycStatus.pending);
      });

      test('can be cleared to null', () {
        container
            .read(kycStatusFilterProvider.notifier)
            .update(KycStatus.rejected);
        container.read(kycStatusFilterProvider.notifier).update(null);
        expect(container.read(kycStatusFilterProvider), isNull);
      });

      test('supports all KycStatus values', () {
        for (final status in KycStatus.values) {
          container.read(kycStatusFilterProvider.notifier).update(status);
          expect(container.read(kycStatusFilterProvider), status);
        }
      });
    });

    // -------------------------------------------------------------------------
    // filteredKycRecordsProvider
    // -------------------------------------------------------------------------
    group('filteredKycRecordsProvider', () {
      test('returns all records when filter is null', () {
        final all = container.read(kycRecordsProvider);
        final filtered = container.read(filteredKycRecordsProvider);
        expect(filtered.length, all.length);
      });

      test('filters records by verified status', () {
        container
            .read(kycStatusFilterProvider.notifier)
            .update(KycStatus.verified);
        final filtered = container.read(filteredKycRecordsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((r) => r.kycStatus == KycStatus.verified),
          isTrue,
        );
      });

      test('filters records by rejected status', () {
        container
            .read(kycStatusFilterProvider.notifier)
            .update(KycStatus.rejected);
        final filtered = container.read(filteredKycRecordsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((r) => r.kycStatus == KycStatus.rejected),
          isTrue,
        );
      });

      test('filters records by expired status', () {
        container
            .read(kycStatusFilterProvider.notifier)
            .update(KycStatus.expired);
        final filtered = container.read(filteredKycRecordsProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((r) => r.kycStatus == KycStatus.expired), isTrue);
      });

      test('result is unmodifiable', () {
        final filtered = container.read(filteredKycRecordsProvider);
        expect(() => filtered.add(filtered.first), throwsA(anything));
      });
    });

    // -------------------------------------------------------------------------
    // expiryStatusFilterProvider
    // -------------------------------------------------------------------------
    group('expiryStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(expiryStatusFilterProvider), isNull);
      });

      test('can be set to expiring soon', () {
        container
            .read(expiryStatusFilterProvider.notifier)
            .update(ExpiryStatus.expiringSoon);
        expect(
          container.read(expiryStatusFilterProvider),
          ExpiryStatus.expiringSoon,
        );
      });

      test('can be set to expired', () {
        container
            .read(expiryStatusFilterProvider.notifier)
            .update(ExpiryStatus.expired);
        expect(
          container.read(expiryStatusFilterProvider),
          ExpiryStatus.expired,
        );
      });

      test('can be cleared to null', () {
        container
            .read(expiryStatusFilterProvider.notifier)
            .update(ExpiryStatus.valid);
        container.read(expiryStatusFilterProvider.notifier).update(null);
        expect(container.read(expiryStatusFilterProvider), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // filteredDocumentExpiriesProvider
    // -------------------------------------------------------------------------
    group('filteredDocumentExpiriesProvider', () {
      test('returns all expiries when filter is null', () {
        final all = container.read(documentExpiriesProvider);
        final filtered = container.read(filteredDocumentExpiriesProvider);
        expect(filtered.length, all.length);
      });

      test('filters by expiring soon status', () {
        container
            .read(expiryStatusFilterProvider.notifier)
            .update(ExpiryStatus.expiringSoon);
        final filtered = container.read(filteredDocumentExpiriesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((e) => e.status == ExpiryStatus.expiringSoon),
          isTrue,
        );
      });

      test('filters by expired status', () {
        container
            .read(expiryStatusFilterProvider.notifier)
            .update(ExpiryStatus.expired);
        final filtered = container.read(filteredDocumentExpiriesProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((e) => e.status == ExpiryStatus.expired), isTrue);
      });

      test('filters by valid status', () {
        container
            .read(expiryStatusFilterProvider.notifier)
            .update(ExpiryStatus.valid);
        final filtered = container.read(filteredDocumentExpiriesProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((e) => e.status == ExpiryStatus.valid), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // activeChecklistsProvider
    // -------------------------------------------------------------------------
    group('activeChecklistsProvider', () {
      test('returns only checklists without completedAt', () {
        final active = container.read(activeChecklistsProvider);
        expect(active, isNotEmpty);
        expect(active.every((c) => c.completedAt == null), isTrue);
      });

      test('active count is less than or equal to total', () {
        final all = container.read(onboardingChecklistsProvider);
        final active = container.read(activeChecklistsProvider);
        expect(active.length, lessThanOrEqualTo(all.length));
      });

      test('result is unmodifiable', () {
        final active = container.read(activeChecklistsProvider);
        expect(() => active.add(active.first), throwsA(anything));
      });
    });

    // -------------------------------------------------------------------------
    // kycSummaryProvider
    // -------------------------------------------------------------------------
    group('kycSummaryProvider', () {
      test('returns a KycSummary with correct total', () {
        final records = container.read(kycRecordsProvider);
        final summary = container.read(kycSummaryProvider);
        expect(summary.total, records.length);
      });

      test('verified count matches verified records', () {
        final records = container.read(kycRecordsProvider);
        final expected = records
            .where((r) => r.kycStatus == KycStatus.verified)
            .length;
        final summary = container.read(kycSummaryProvider);
        expect(summary.verified, expected);
      });

      test('rejected count matches rejected records', () {
        final records = container.read(kycRecordsProvider);
        final expected = records
            .where((r) => r.kycStatus == KycStatus.rejected)
            .length;
        final summary = container.read(kycSummaryProvider);
        expect(summary.rejected, expected);
      });

      test('expired count matches expired records', () {
        final records = container.read(kycRecordsProvider);
        final expected = records
            .where((r) => r.kycStatus == KycStatus.expired)
            .length;
        final summary = container.read(kycSummaryProvider);
        expect(summary.expired, expected);
      });

      test(
        'pending includes pending + documentsSubmitted + underVerification',
        () {
          final records = container.read(kycRecordsProvider);
          final expected = records
              .where(
                (r) =>
                    r.kycStatus == KycStatus.pending ||
                    r.kycStatus == KycStatus.documentsSubmitted ||
                    r.kycStatus == KycStatus.underVerification,
              )
              .length;
          final summary = container.read(kycSummaryProvider);
          expect(summary.pending, expected);
        },
      );

      test('all counts sum correctly', () {
        final summary = container.read(kycSummaryProvider);
        expect(
          summary.verified +
              summary.pending +
              summary.rejected +
              summary.expired,
          lessThanOrEqualTo(summary.total),
        );
      });
    });
  });
}
