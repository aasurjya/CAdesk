import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/more/data/repositories/mock_more_repository.dart';
import 'package:ca_app/features/more/domain/models/menu_item_config.dart';

void main() {
  group('MockMoreRepository', () {
    late MockMoreRepository repo;

    setUp(() {
      repo = MockMoreRepository();
    });

    group('getMenuItems', () {
      test('returns seeded items', () async {
        final result = await repo.getMenuItems();
        expect(result, isNotEmpty);
      });

      test('items are sorted by sortOrder', () async {
        final result = await repo.getMenuItems();
        for (var i = 0; i < result.length - 1; i++) {
          expect(
            result[i].sortOrder,
            lessThanOrEqualTo(result[i + 1].sortOrder),
          );
        }
      });

      test('only visible items are returned', () async {
        final result = await repo.getMenuItems();
        for (final item in result) {
          expect(item.isVisible, isTrue);
        }
      });
    });

    group('updateMenuItem', () {
      test('updates existing item', () async {
        final items = await repo.getMenuItems();
        final existing = items.first;
        final updated = existing.copyWith(isPinned: !existing.isPinned);

        final result = await repo.updateMenuItem(updated);
        expect(result, isTrue);

        final fetched = await repo.getMenuItems();
        final found = fetched.firstWhere((i) => i.id == existing.id);
        expect(found.isPinned, updated.isPinned);
      });

      test('returns false for unknown item', () async {
        const unknown = MenuItemConfig(
          id: 'menu-unknown',
          title: 'Unknown',
          subtitle: 'Unknown',
          route: '/unknown',
        );
        final result = await repo.updateMenuItem(unknown);
        expect(result, isFalse);
      });
    });

    group('saveOrder', () {
      test('persists new order without throwing', () async {
        final items = await repo.getMenuItems();
        await expectLater(repo.saveOrder(items.reversed.toList()), completes);
      });
    });

    group('MenuItemConfig model', () {
      test('equality is based on id', () {
        const a = MenuItemConfig(
          id: 'item-1',
          title: 'A',
          subtitle: 'A',
          route: '/a',
        );
        const b = MenuItemConfig(
          id: 'item-1',
          title: 'B',
          subtitle: 'B',
          route: '/b',
        );
        expect(a, equals(b));
      });

      test('copyWith returns new instance', () {
        const item = MenuItemConfig(
          id: 'item-1',
          title: 'Title',
          subtitle: 'Sub',
          route: '/route',
        );
        final updated = item.copyWith(isPinned: true);
        expect(updated.isPinned, isTrue);
        expect(updated.id, 'item-1');
      });
    });
  });
}
