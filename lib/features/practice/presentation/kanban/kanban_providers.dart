import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_mock_data.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// Priority levels for kanban cards.
enum KanbanPriority {
  critical(label: 'Critical'),
  high(label: 'High'),
  medium(label: 'Medium'),
  low(label: 'Low');

  const KanbanPriority({required this.label});

  final String label;

  Color get color {
    switch (this) {
      case KanbanPriority.critical:
        return AppColors.error;
      case KanbanPriority.high:
        return AppColors.warning;
      case KanbanPriority.medium:
        return AppColors.accent;
      case KanbanPriority.low:
        return AppColors.neutral400;
    }
  }
}

/// Immutable subtask within a kanban card.
class KanbanSubtask {
  const KanbanSubtask({required this.title, required this.isCompleted});

  final String title;
  final bool isCompleted;

  KanbanSubtask copyWith({String? title, bool? isCompleted}) {
    return KanbanSubtask(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KanbanSubtask &&
        other.title == title &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode => Object.hash(title, isCompleted);
}

/// A single column in the kanban board.
class KanbanColumn {
  const KanbanColumn({
    required this.id,
    required this.title,
    required this.order,
    required this.color,
  });

  final String id;
  final String title;
  final int order;
  final Color color;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KanbanColumn && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Immutable kanban card data.
class KanbanCardData {
  const KanbanCardData({
    required this.id,
    required this.title,
    required this.description,
    required this.assignee,
    required this.priority,
    required this.dueDate,
    required this.clientName,
    required this.columnId,
    required this.tags,
    required this.subtasks,
    this.hoursLogged = 0,
  });

  final String id;
  final String title;
  final String description;
  final String assignee;
  final KanbanPriority priority;
  final DateTime dueDate;
  final String clientName;
  final String columnId;
  final List<String> tags;
  final List<KanbanSubtask> subtasks;
  final double hoursLogged;

  KanbanCardData copyWith({
    String? id,
    String? title,
    String? description,
    String? assignee,
    KanbanPriority? priority,
    DateTime? dueDate,
    String? clientName,
    String? columnId,
    List<String>? tags,
    List<KanbanSubtask>? subtasks,
    double? hoursLogged,
  }) {
    return KanbanCardData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      clientName: clientName ?? this.clientName,
      columnId: columnId ?? this.columnId,
      tags: tags ?? this.tags,
      subtasks: subtasks ?? this.subtasks,
      hoursLogged: hoursLogged ?? this.hoursLogged,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KanbanCardData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// Filter state
// ---------------------------------------------------------------------------

/// Filter criteria for the kanban board.
class KanbanFilter {
  const KanbanFilter({this.assignee, this.clientName, this.priority});

  final String? assignee;
  final String? clientName;
  final KanbanPriority? priority;

  bool get isActive =>
      assignee != null || clientName != null || priority != null;

  KanbanFilter copyWith({
    String? Function()? assignee,
    String? Function()? clientName,
    KanbanPriority? Function()? priority,
  }) {
    return KanbanFilter(
      assignee: assignee != null ? assignee() : this.assignee,
      clientName: clientName != null ? clientName() : this.clientName,
      priority: priority != null ? priority() : this.priority,
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Default kanban columns.
final kanbanColumnsProvider = Provider<List<KanbanColumn>>((ref) {
  return const [
    KanbanColumn(
      id: 'backlog',
      title: 'Backlog',
      order: 0,
      color: AppColors.neutral300,
    ),
    KanbanColumn(
      id: 'todo',
      title: 'To Do',
      order: 1,
      color: AppColors.primaryVariant,
    ),
    KanbanColumn(
      id: 'in_progress',
      title: 'In Progress',
      order: 2,
      color: AppColors.accent,
    ),
    KanbanColumn(
      id: 'review',
      title: 'Review',
      order: 3,
      color: AppColors.secondary,
    ),
    KanbanColumn(id: 'done', title: 'Done', order: 4, color: AppColors.success),
  ];
});

/// Kanban cards state with CRUD + move operations.
final kanbanCardsProvider =
    NotifierProvider<KanbanCardsNotifier, List<KanbanCardData>>(
      KanbanCardsNotifier.new,
    );

class KanbanCardsNotifier extends Notifier<List<KanbanCardData>> {
  @override
  List<KanbanCardData> build() => List.unmodifiable(mockKanbanCards);

  void addCard(KanbanCardData card) {
    state = List.unmodifiable([card, ...state]);
  }

  void updateCard(KanbanCardData updated) {
    state = List.unmodifiable(
      state.map((c) => c.id == updated.id ? updated : c).toList(),
    );
  }

  void deleteCard(String cardId) {
    state = List.unmodifiable(state.where((c) => c.id != cardId).toList());
  }

  void moveCard(String cardId, String targetColumnId) {
    state = List.unmodifiable(
      state.map((c) {
        if (c.id == cardId) {
          return c.copyWith(columnId: targetColumnId);
        }
        return c;
      }).toList(),
    );
  }
}

/// Filter provider for kanban board.
final kanbanFilterProvider =
    NotifierProvider<KanbanFilterNotifier, KanbanFilter>(
      KanbanFilterNotifier.new,
    );

class KanbanFilterNotifier extends Notifier<KanbanFilter> {
  @override
  KanbanFilter build() => const KanbanFilter();

  void setAssignee(String? value) {
    state = state.copyWith(assignee: () => value);
  }

  void setClient(String? value) {
    state = state.copyWith(clientName: () => value);
  }

  void setPriority(KanbanPriority? value) {
    state = state.copyWith(priority: () => value);
  }

  void clear() {
    state = const KanbanFilter();
  }
}

/// Filtered cards grouped by column ID.
final filteredKanbanCardsProvider = Provider<Map<String, List<KanbanCardData>>>(
  (ref) {
    final cards = ref.watch(kanbanCardsProvider);
    final filter = ref.watch(kanbanFilterProvider);
    final columns = ref.watch(kanbanColumnsProvider);

    final filtered = cards.where((card) {
      if (filter.assignee != null && card.assignee != filter.assignee) {
        return false;
      }
      if (filter.clientName != null && card.clientName != filter.clientName) {
        return false;
      }
      if (filter.priority != null && card.priority != filter.priority) {
        return false;
      }
      return true;
    }).toList();

    final grouped = <String, List<KanbanCardData>>{};
    for (final column in columns) {
      grouped[column.id] = filtered
          .where((c) => c.columnId == column.id)
          .toList();
    }
    return Map.unmodifiable(grouped);
  },
);

/// Unique assignee names for filter dropdown.
final kanbanAssigneesProvider = Provider<List<String>>((ref) {
  final cards = ref.watch(kanbanCardsProvider);
  return cards.map((c) => c.assignee).toSet().toList()..sort();
});

/// Unique client names for filter dropdown.
final kanbanClientsProvider = Provider<List<String>>((ref) {
  final cards = ref.watch(kanbanCardsProvider);
  return cards.map((c) => c.clientName).toSet().toList()..sort();
});
