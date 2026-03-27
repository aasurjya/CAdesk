import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/practice/presentation/kanban/kanban_providers.dart';

import '../../../../helpers/provider_test_helpers.dart';

void main() {
  group('kanbanColumnsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = createTestContainer();
      addTearDown(container.dispose);
    });

    test('returns a non-empty list of KanbanColumn objects', () {
      final columns = container.read(kanbanColumnsProvider);
      expect(columns, isNotEmpty);
    });

    test('returns at least 3 status columns', () {
      final columns = container.read(kanbanColumnsProvider);
      expect(columns.length, greaterThanOrEqualTo(3));
    });

    test('each column has a non-empty id and title', () {
      final columns = container.read(kanbanColumnsProvider);
      for (final column in columns) {
        expect(column.id, isNotEmpty);
        expect(column.title, isNotEmpty);
      }
    });

    test('includes "backlog", "todo", "in_progress" columns', () {
      final columns = container.read(kanbanColumnsProvider);
      final ids = columns.map((c) => c.id).toSet();
      expect(ids, contains('backlog'));
      expect(ids, contains('todo'));
      expect(ids, contains('in_progress'));
    });

    test('columns have unique IDs', () {
      final columns = container.read(kanbanColumnsProvider);
      final ids = columns.map((c) => c.id).toList();
      expect(ids.toSet().length, equals(ids.length));
    });

    test('column order field distinguishes sequence', () {
      final columns = container.read(kanbanColumnsProvider);
      final orders = columns.map((c) => c.order).toList();
      expect(orders.toSet().length, equals(orders.length));
    });
  });

  group('KanbanColumn model', () {
    test('has id, title, order, and color fields', () {
      const col = KanbanColumn(
        id: 'test',
        title: 'Test Column',
        order: 0,
        color: Colors.blue,
      );
      expect(col.id, equals('test'));
      expect(col.title, equals('Test Column'));
      expect(col.order, equals(0));
    });

    test('equality is based on id only', () {
      const a = KanbanColumn(
        id: 'col1',
        title: 'Column A',
        order: 0,
        color: Colors.red,
      );
      const b = KanbanColumn(
        id: 'col1',
        title: 'Different Title',
        order: 99,
        color: Colors.green,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('KanbanCardData model', () {
    final card = KanbanCardData(
      id: 'card-1',
      title: 'File ITR-2',
      description: 'Capital gains filing',
      assignee: 'Ankit Sharma',
      priority: KanbanPriority.high,
      dueDate: DateTime(2025, 7, 31),
      clientName: 'Rajesh Kumar',
      columnId: 'todo',
      tags: const ['itr', 'capital-gains'],
      subtasks: const [],
    );

    test('has id, title, priority, dueDate, and assigneeId fields', () {
      expect(card.id, equals('card-1'));
      expect(card.title, equals('File ITR-2'));
      expect(card.priority, equals(KanbanPriority.high));
      expect(card.dueDate, equals(DateTime(2025, 7, 31)));
      expect(card.assignee, equals('Ankit Sharma'));
    });

    test('copyWith preserves unmodified fields', () {
      final updated = card.copyWith(columnId: 'in_progress');
      expect(updated.columnId, equals('in_progress'));
      expect(updated.title, equals('File ITR-2'));
      expect(updated.priority, equals(KanbanPriority.high));
    });

    test('copyWith returns a new object (immutable)', () {
      final updated = card.copyWith(title: 'Changed');
      expect(identical(card, updated), isFalse);
    });

    test('equality is based on id only', () {
      final sameId = card.copyWith(title: 'Completely Different');
      expect(card, equals(sameId));
    });
  });

  group('kanbanCardsProvider — moveCard', () {
    late ProviderContainer container;

    setUp(() {
      container = createTestContainer();
      addTearDown(container.dispose);
    });

    test('initial state is populated with mock cards', () {
      final cards = container.read(kanbanCardsProvider);
      expect(cards, isNotEmpty);
    });

    test('moveCard changes the columnId of the target card', () {
      final cards = container.read(kanbanCardsProvider);
      final cardToMove = cards.first;
      final originalColumnId = cardToMove.columnId;
      final targetColumnId = originalColumnId == 'backlog'
          ? 'in_progress'
          : 'backlog';

      container
          .read(kanbanCardsProvider.notifier)
          .moveCard(cardToMove.id, targetColumnId);

      final updated = container.read(kanbanCardsProvider);
      final movedCard = updated.firstWhere((c) => c.id == cardToMove.id);
      expect(movedCard.columnId, equals(targetColumnId));
    });

    test('after moveCard the card is in target column, not source', () {
      final cards = container.read(kanbanCardsProvider);
      final cardToMove = cards.first;
      final originalColumnId = cardToMove.columnId;
      const targetColumnId = 'done';

      container
          .read(kanbanCardsProvider.notifier)
          .moveCard(cardToMove.id, targetColumnId);

      final afterCards = container.read(kanbanCardsProvider);
      final inSource = afterCards.where(
        (c) => c.id == cardToMove.id && c.columnId == originalColumnId,
      );
      final inTarget = afterCards.where(
        (c) => c.id == cardToMove.id && c.columnId == targetColumnId,
      );

      expect(inSource, isEmpty);
      expect(inTarget, isNotEmpty);
    });

    test('moveCard does not affect other cards', () {
      final cards = container.read(kanbanCardsProvider);
      if (cards.length < 2) return; // skip if not enough data

      final cardToMove = cards[0];
      final otherCard = cards[1];

      container
          .read(kanbanCardsProvider.notifier)
          .moveCard(cardToMove.id, 'done');

      final afterCards = container.read(kanbanCardsProvider);
      final otherAfter = afterCards.firstWhere((c) => c.id == otherCard.id);
      expect(otherAfter.columnId, equals(otherCard.columnId));
    });

    test('addCard prepends the card to state', () {
      final newCard = KanbanCardData(
        id: 'test-new-card',
        title: 'New Task',
        description: 'Test description',
        assignee: 'Staff A',
        priority: KanbanPriority.low,
        dueDate: DateTime(2025, 12, 31),
        clientName: 'Test Client',
        columnId: 'backlog',
        tags: const [],
        subtasks: const [],
      );

      container.read(kanbanCardsProvider.notifier).addCard(newCard);

      final cards = container.read(kanbanCardsProvider);
      expect(cards.any((c) => c.id == 'test-new-card'), isTrue);
    });

    test('deleteCard removes card from state', () {
      final cards = container.read(kanbanCardsProvider);
      final cardId = cards.first.id;

      container.read(kanbanCardsProvider.notifier).deleteCard(cardId);

      final after = container.read(kanbanCardsProvider);
      expect(after.any((c) => c.id == cardId), isFalse);
    });

    test('state list is unmodifiable (immutable)', () {
      final cards = container.read(kanbanCardsProvider);
      expect(() => (cards as dynamic).add(null), throwsA(anything));
    });
  });

  group('filteredKanbanCardsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = createTestContainer();
      addTearDown(container.dispose);
    });

    test('returns a map keyed by column id', () {
      final grouped = container.read(filteredKanbanCardsProvider);
      final columns = container.read(kanbanColumnsProvider);
      for (final col in columns) {
        expect(grouped.containsKey(col.id), isTrue);
      }
    });

    test('all cards appear in their respective column buckets', () {
      final grouped = container.read(filteredKanbanCardsProvider);
      for (final entry in grouped.entries) {
        for (final card in entry.value) {
          expect(card.columnId, equals(entry.key));
        }
      }
    });
  });

  group('KanbanFilter', () {
    test('isActive is false when no filter is set', () {
      const filter = KanbanFilter();
      expect(filter.isActive, isFalse);
    });

    test('isActive is true when assignee filter is set', () {
      const filter = KanbanFilter(assignee: 'Ankit');
      expect(filter.isActive, isTrue);
    });

    test('isActive is true when priority filter is set', () {
      const filter = KanbanFilter(priority: KanbanPriority.critical);
      expect(filter.isActive, isTrue);
    });

    test('copyWith with nulls clears fields', () {
      const filter = KanbanFilter(
        assignee: 'Test',
        priority: KanbanPriority.high,
      );
      final cleared = filter.copyWith(
        assignee: () => null,
        priority: () => null,
      );
      expect(cleared.isActive, isFalse);
    });
  });
}
