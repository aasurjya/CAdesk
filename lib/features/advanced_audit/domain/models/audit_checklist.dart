import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';

/// A single item in an audit checklist.
class ChecklistItem {
  const ChecklistItem({
    required this.description,
    required this.isCompleted,
    this.completedBy,
    this.completedAt,
    this.notes,
  });

  final String description;
  final bool isCompleted;
  final String? completedBy;
  final DateTime? completedAt;
  final String? notes;

  ChecklistItem copyWith({
    String? description,
    bool? isCompleted,
    String? completedBy,
    DateTime? completedAt,
    String? notes,
  }) {
    return ChecklistItem(
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedBy: completedBy ?? this.completedBy,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }
}

/// Immutable model representing an audit checklist.
class AuditChecklist {
  const AuditChecklist({
    required this.id,
    required this.auditType,
    required this.title,
    required this.items,
    required this.totalItems,
    required this.completedItems,
  });

  final String id;
  final AuditType auditType;
  final String title;
  final List<ChecklistItem> items;
  final int totalItems;
  final int completedItems;

  /// Completion percentage (0.0 to 1.0).
  double get completionPercent {
    if (totalItems == 0) return 0;
    return completedItems / totalItems;
  }

  AuditChecklist copyWith({
    String? id,
    AuditType? auditType,
    String? title,
    List<ChecklistItem>? items,
    int? totalItems,
    int? completedItems,
  }) {
    return AuditChecklist(
      id: id ?? this.id,
      auditType: auditType ?? this.auditType,
      title: title ?? this.title,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      completedItems: completedItems ?? this.completedItems,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditChecklist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
