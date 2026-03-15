import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/e_verification/data/providers/e_verification_providers.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_request.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_status.dart';

void main() {
  group('E-Verification Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // pendingVerificationsProvider
    // -------------------------------------------------------------------------
    group('pendingVerificationsProvider', () {
      test('initial state is non-empty list', () {
        final list = container.read(pendingVerificationsProvider);
        expect(list, isNotEmpty);
        expect(list.length, greaterThanOrEqualTo(3));
      });

      test('all items are VerificationRequest objects', () {
        final list = container.read(pendingVerificationsProvider);
        expect(list, everyElement(isA<VerificationRequest>()));
      });

      test('list is unmodifiable', () {
        final list = container.read(pendingVerificationsProvider);
        expect(() => list.add(list.first), throwsA(anything));
      });

      test('initial list contains pending and verified statuses', () {
        final list = container.read(pendingVerificationsProvider);
        expect(
          list.any((r) => r.status == VerificationStatus.pending),
          isTrue,
        );
        expect(list.any((r) => r.status.isVerified), isTrue);
      });

      test('initial list contains an expired verification', () {
        final list = container.read(pendingVerificationsProvider);
        expect(
          list.any((r) => r.status == VerificationStatus.expired),
          isTrue,
        );
      });

      test('all requests have non-empty id, clientName and pan', () {
        final list = container.read(pendingVerificationsProvider);
        for (final req in list) {
          expect(req.id, isNotEmpty);
          expect(req.clientName, isNotEmpty);
          expect(req.pan, isNotEmpty);
        }
      });

      test('markVerified() updates status and acknowledgement', () {
        final first = container.read(pendingVerificationsProvider).first;
        container.read(pendingVerificationsProvider.notifier).markVerified(
          requestId: first.id,
          status: VerificationStatus.verifiedEvc,
          acknowledgementNumber: 'ACK-TEST-001',
        );
        final updated = container
            .read(pendingVerificationsProvider)
            .firstWhere((r) => r.id == first.id);
        expect(updated.status, VerificationStatus.verifiedEvc);
        expect(updated.acknowledgementNumber, 'ACK-TEST-001');
      });

      test('markVerified() preserves list length', () {
        final before = container.read(pendingVerificationsProvider).length;
        final first = container.read(pendingVerificationsProvider).first;
        container.read(pendingVerificationsProvider.notifier).markVerified(
          requestId: first.id,
          status: VerificationStatus.verifiedDsc,
          acknowledgementNumber: 'ACK-DSC-002',
        );
        final after = container.read(pendingVerificationsProvider).length;
        expect(after, before);
      });

      test('markVerified() with unknown id leaves list unchanged', () {
        final before = container.read(pendingVerificationsProvider);
        container.read(pendingVerificationsProvider.notifier).markVerified(
          requestId: 'nonexistent-id',
          status: VerificationStatus.verifiedEvc,
          acknowledgementNumber: 'ACK-XXX',
        );
        final after = container.read(pendingVerificationsProvider);
        expect(after.length, before.length);
        expect(after.any((r) => r.id == 'nonexistent-id'), isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // pendingCountProvider
    // -------------------------------------------------------------------------
    group('pendingCountProvider', () {
      test('count matches pending status items', () {
        final list = container.read(pendingVerificationsProvider);
        final expected =
            list.where((r) => r.status == VerificationStatus.pending).length;
        expect(container.read(pendingCountProvider), expected);
      });

      test('count decreases after marking a pending item as verified', () {
        final pending = container
            .read(pendingVerificationsProvider)
            .firstWhere((r) => r.status == VerificationStatus.pending);
        final before = container.read(pendingCountProvider);
        container.read(pendingVerificationsProvider.notifier).markVerified(
          requestId: pending.id,
          status: VerificationStatus.verifiedAadhaar,
          acknowledgementNumber: 'ACK-AAD-003',
        );
        expect(container.read(pendingCountProvider), before - 1);
      });
    });

    // -------------------------------------------------------------------------
    // verifiedCountProvider
    // -------------------------------------------------------------------------
    group('verifiedCountProvider', () {
      test('count matches verified status items', () {
        final list = container.read(pendingVerificationsProvider);
        final expected = list.where((r) => r.status.isVerified).length;
        expect(container.read(verifiedCountProvider), expected);
      });

      test('count increases after marking pending as verified', () {
        final pending = container
            .read(pendingVerificationsProvider)
            .firstWhere((r) => r.status == VerificationStatus.pending);
        final before = container.read(verifiedCountProvider);
        container.read(pendingVerificationsProvider.notifier).markVerified(
          requestId: pending.id,
          status: VerificationStatus.verifiedEvc,
          acknowledgementNumber: 'ACK-EVC-004',
        );
        expect(container.read(verifiedCountProvider), before + 1);
      });
    });

    // -------------------------------------------------------------------------
    // expiredCountProvider
    // -------------------------------------------------------------------------
    group('expiredCountProvider', () {
      test('count matches expired status items', () {
        final list = container.read(pendingVerificationsProvider);
        final expected =
            list.where((r) => r.status == VerificationStatus.expired).length;
        expect(container.read(expiredCountProvider), expected);
      });

      test('count is positive', () {
        expect(container.read(expiredCountProvider), greaterThan(0));
      });
    });

    // -------------------------------------------------------------------------
    // expiringSoonProvider
    // -------------------------------------------------------------------------
    group('expiringSoonProvider', () {
      test('returns a list of VerificationRequest', () {
        final list = container.read(expiringSoonProvider);
        expect(list, isA<List<VerificationRequest>>());
      });

      test('all items are not yet verified', () {
        final soon = container.read(expiringSoonProvider);
        expect(soon.every((r) => !r.status.isVerified), isTrue);
      });

      test('all items have daysRemaining <= 7', () {
        final soon = container.read(expiringSoonProvider);
        for (final req in soon) {
          expect(req.daysRemaining, lessThanOrEqualTo(7));
        }
      });
    });

    // -------------------------------------------------------------------------
    // VerificationStatus helper
    // -------------------------------------------------------------------------
    group('VerificationStatus.isVerified', () {
      test('verifiedEvc isVerified is true', () {
        expect(VerificationStatus.verifiedEvc.isVerified, isTrue);
      });

      test('verifiedAadhaar isVerified is true', () {
        expect(VerificationStatus.verifiedAadhaar.isVerified, isTrue);
      });

      test('verifiedDsc isVerified is true', () {
        expect(VerificationStatus.verifiedDsc.isVerified, isTrue);
      });

      test('pending isVerified is false', () {
        expect(VerificationStatus.pending.isVerified, isFalse);
      });

      test('expired isVerified is false', () {
        expect(VerificationStatus.expired.isVerified, isFalse);
      });

      test('all statuses have non-empty labels', () {
        for (final status in VerificationStatus.values) {
          expect(status.label, isNotEmpty);
        }
      });
    });
  });
}
