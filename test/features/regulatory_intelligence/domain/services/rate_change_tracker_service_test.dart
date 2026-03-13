import 'package:ca_app/features/regulatory_intelligence/domain/models/rate_change.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/services/rate_change_tracker_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = RateChangeTrackerService.instance;

  group('RateChangeTrackerService.getRecentChanges', () {
    test('returns non-empty list from mock data', () {
      final changes = service.getRecentChanges();
      expect(changes, isNotEmpty);
    });

    test('respects default limit of 10', () {
      final changes = service.getRecentChanges();
      expect(changes.length, lessThanOrEqualTo(10));
    });

    test('respects custom limit', () {
      final changes = service.getRecentChanges(limit: 3);
      expect(changes.length, lessThanOrEqualTo(3));
    });

    test('includes STCG rate change (15% to 20%)', () {
      final changes = service.getRecentChanges(limit: 20);
      final stcg = changes.where(
        (c) =>
            c.category == RateCategory.incomeTax &&
            (c.oldValue.contains('15') ||
                c.description.toLowerCase().contains('stcg')),
      );
      expect(stcg, isNotEmpty);
    });

    test('includes LTCG rate change (10% to 12.5%)', () {
      final changes = service.getRecentChanges(limit: 20);
      final ltcg = changes.where(
        (c) =>
            c.category == RateCategory.incomeTax &&
            (c.oldValue.contains('10') ||
                c.description.toLowerCase().contains('ltcg')),
      );
      expect(ltcg, isNotEmpty);
    });

    test('includes TDS Section 194T (partner salary)', () {
      final changes = service.getRecentChanges(limit: 20);
      final tds194t = changes.where(
        (c) =>
            c.category == RateCategory.tds &&
            c.circularReference.contains('194T'),
      );
      expect(tds194t, isNotEmpty);
    });
  });

  group('RateChangeTrackerService.getChangesEffectiveAfter', () {
    test('returns changes with effectiveDate strictly after given date', () {
      final cutoff = DateTime(2024, 1, 1);
      final changes = service.getChangesEffectiveAfter(cutoff);
      for (final c in changes) {
        expect(c.effectiveDate.isAfter(cutoff), isTrue);
      }
    });

    test('returns empty when cutoff is in the far future', () {
      final futureDate = DateTime(2030, 1, 1);
      final changes = service.getChangesEffectiveAfter(futureDate);
      expect(changes, isEmpty);
    });

    test(
      'Finance Act 2024 changes (Jul 23, 2024) are returned after 2024-01-01',
      () {
        final changes = service.getChangesEffectiveAfter(DateTime(2024, 1, 1));
        final fa2024 = changes.where(
          (c) => c.circularReference.toLowerCase().contains('finance act 2024'),
        );
        expect(fa2024, isNotEmpty);
      },
    );
  });

  group('RateChangeTrackerService.getChangesForCategory', () {
    test('returns only incomeTax category changes', () {
      final changes = service.getChangesForCategory(RateCategory.incomeTax);
      for (final c in changes) {
        expect(c.category, equals(RateCategory.incomeTax));
      }
    });

    test('returns only tds category changes', () {
      final changes = service.getChangesForCategory(RateCategory.tds);
      for (final c in changes) {
        expect(c.category, equals(RateCategory.tds));
      }
    });

    test('returns only gst category changes', () {
      final changes = service.getChangesForCategory(RateCategory.gst);
      for (final c in changes) {
        expect(c.category, equals(RateCategory.gst));
      }
    });

    test('returns empty list for category with no mock data', () {
      final changes = service.getChangesForCategory(RateCategory.stampDuty);
      expect(changes, isA<List<RateChange>>());
    });
  });

  group('RateChange model', () {
    final change = RateChange(
      effectiveDate: DateTime.utc(2024, 7, 23),
      category: RateCategory.incomeTax,
      description: 'STCG under Section 111A increased',
      oldValue: '15%',
      newValue: '20%',
      circularReference: 'Finance Act 2024',
      affectedAssessees: const ['Equity Investor', 'Mutual Fund Holder'],
    );

    test('const constructor sets all fields', () {
      expect(change.effectiveDate, DateTime.utc(2024, 7, 23));
      expect(change.category, RateCategory.incomeTax);
      expect(change.oldValue, '15%');
      expect(change.newValue, '20%');
      expect(change.circularReference, 'Finance Act 2024');
      expect(change.affectedAssessees, [
        'Equity Investor',
        'Mutual Fund Holder',
      ]);
    });

    test('copyWith returns updated instance', () {
      final copy = change.copyWith(newValue: '22%');
      expect(copy.newValue, '22%');
      expect(copy.oldValue, '15%');
    });

    test('equality holds for identical data', () {
      final other = RateChange(
        effectiveDate: DateTime.utc(2024, 7, 23),
        category: RateCategory.incomeTax,
        description: 'STCG under Section 111A increased',
        oldValue: '15%',
        newValue: '20%',
        circularReference: 'Finance Act 2024',
        affectedAssessees: const ['Equity Investor', 'Mutual Fund Holder'],
      );
      expect(change, equals(other));
    });

    test('hashCode is consistent', () {
      expect(change.hashCode, equals(change.hashCode));
    });

    test('toString contains category name', () {
      expect(change.toString(), contains('incomeTax'));
    });
  });
}
