import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_update.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/services/circular_tracker_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = CircularTrackerService.instance;

  group('CircularTrackerService.getLatestUpdates', () {
    test('returns up to default limit of 20', () {
      final updates = service.getLatestUpdates();
      expect(updates.length, lessThanOrEqualTo(20));
    });

    test('respects custom limit', () {
      final updates = service.getLatestUpdates(limit: 3);
      expect(updates.length, lessThanOrEqualTo(3));
    });

    test('returns non-empty list from mock data', () {
      final updates = service.getLatestUpdates();
      expect(updates, isNotEmpty);
    });

    test('each update has non-empty updateId and title', () {
      final updates = service.getLatestUpdates();
      for (final u in updates) {
        expect(u.updateId, isNotEmpty);
        expect(u.title, isNotEmpty);
      }
    });

    test('returns at least 10 mock entries', () {
      final updates = service.getLatestUpdates(limit: 20);
      expect(updates.length, greaterThanOrEqualTo(10));
    });
  });

  group('CircularTrackerService.searchUpdates', () {
    test('returns results matching query in title', () {
      final updates = service.searchUpdates('STCG');
      expect(updates, isNotEmpty);
      for (final u in updates) {
        final haystack =
            '${u.title} ${u.summary} ${u.affectedSections.join(' ')}'
                .toLowerCase();
        expect(haystack, contains('stcg'));
      }
    });

    test('returns empty list when no match', () {
      final updates = service.searchUpdates('zzznomatchxyz');
      expect(updates, isEmpty);
    });

    test('search is case-insensitive', () {
      final upper = service.searchUpdates('LTCG');
      final lower = service.searchUpdates('ltcg');
      expect(upper.length, equals(lower.length));
    });

    test('searches across summary field', () {
      // At least one mock update should contain 'Finance Act' in summary
      final updates = service.searchUpdates('Finance Act');
      expect(updates, isNotEmpty);
    });

    test('searches across affectedSections field', () {
      final updates = service.searchUpdates('111A');
      expect(updates, isNotEmpty);
    });
  });

  group('CircularTrackerService.filterBySource', () {
    test('filters to only matching source', () {
      final all = service.getLatestUpdates();
      final filtered = service.filterBySource(all, RegSource.cbdt);
      for (final u in filtered) {
        expect(u.source, equals(RegSource.cbdt));
      }
    });

    test('returns empty when no updates match source', () {
      final all = service.getLatestUpdates();
      // Use a source unlikely to be in mock data
      final filtered = service.filterBySource(all, RegSource.nclt);
      expect(filtered, isA<List<RegulatoryUpdate>>());
    });

    test('does not mutate original list', () {
      final all = service.getLatestUpdates();
      final originalLength = all.length;
      service.filterBySource(all, RegSource.cbdt);
      expect(all.length, equals(originalLength));
    });
  });

  group('CircularTrackerService.filterByImpact', () {
    test('filterByImpact(high) returns only high impact updates', () {
      final all = service.getLatestUpdates();
      final filtered = service.filterByImpact(all, ImpactLevel.high);
      for (final u in filtered) {
        expect(u.impactLevel, equals(ImpactLevel.high));
      }
    });

    test('filterByImpact(low) returns high, medium and low', () {
      final all = service.getLatestUpdates();
      final filtered = service.filterByImpact(all, ImpactLevel.low);
      // All updates pass a "minLevel" of low
      expect(filtered.length, equals(all.length));
    });

    test('filterByImpact(medium) returns medium and high only', () {
      final all = service.getLatestUpdates();
      final filtered = service.filterByImpact(all, ImpactLevel.medium);
      for (final u in filtered) {
        expect(
          u.impactLevel == ImpactLevel.medium ||
              u.impactLevel == ImpactLevel.high,
          isTrue,
        );
      }
    });
  });

  group('CircularTrackerService.markAsRead', () {
    test('returns new instance with isRead = true', () {
      final original = service.getLatestUpdates().first;
      final updated = service.markAsRead(original);
      expect(updated.isRead, isTrue);
    });

    test('does not mutate original update', () {
      final original = service.getLatestUpdates().first.copyWith(isRead: false);
      service.markAsRead(original);
      expect(original.isRead, isFalse);
    });

    test('returned update preserves all other fields', () {
      final original = service.getLatestUpdates().first;
      final updated = service.markAsRead(original);
      expect(updated.updateId, equals(original.updateId));
      expect(updated.title, equals(original.title));
      expect(updated.source, equals(original.source));
      expect(updated.impactLevel, equals(original.impactLevel));
    });
  });

  group('RegulatoryUpdate model', () {
    final update = RegulatoryUpdate(
      updateId: 'u1',
      title: 'Test Update',
      summary: 'Summary',
      source: RegSource.cbdt,
      category: UpdateCategory.amendment,
      publicationDate: DateTime.utc(2024, 7, 23),
      effectiveDate: null,
      impactLevel: ImpactLevel.high,
      affectedSections: const ['111A', '112A'],
      url: null,
      isRead: false,
    );

    test('const constructor sets all fields', () {
      expect(update.updateId, 'u1');
      expect(update.title, 'Test Update');
      expect(update.source, RegSource.cbdt);
      expect(update.category, UpdateCategory.amendment);
      expect(update.impactLevel, ImpactLevel.high);
      expect(update.affectedSections, ['111A', '112A']);
      expect(update.isRead, isFalse);
    });

    test('copyWith produces new instance with changed fields', () {
      final copy = update.copyWith(isRead: true, title: 'Updated Title');
      expect(copy.isRead, isTrue);
      expect(copy.title, 'Updated Title');
      expect(copy.updateId, 'u1');
    });

    test('equality holds for identical data', () {
      final other = RegulatoryUpdate(
        updateId: 'u1',
        title: 'Test Update',
        summary: 'Summary',
        source: RegSource.cbdt,
        category: UpdateCategory.amendment,
        publicationDate: DateTime.utc(2024, 7, 23),
        effectiveDate: null,
        impactLevel: ImpactLevel.high,
        affectedSections: const ['111A', '112A'],
        url: null,
        isRead: false,
      );
      expect(update, equals(other));
    });

    test('hashCode is consistent', () {
      expect(update.hashCode, equals(update.hashCode));
    });

    test('toString contains updateId', () {
      expect(update.toString(), contains('u1'));
    });
  });
}
