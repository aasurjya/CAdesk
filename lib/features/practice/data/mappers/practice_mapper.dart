import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/practice/domain/models/workflow.dart';

class PracticeMapper {
  const PracticeMapper._();

  // ---------------------------------------------------------------------------
  // Workflow — JSON (Supabase) ↔ domain
  // ---------------------------------------------------------------------------

  /// JSON (from Supabase) → Workflow domain model
  static Workflow workflowFromJson(Map<String, dynamic> json) {
    return Workflow(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      steps: _parseStringList(json['steps']),
      estimatedDays: (json['estimated_days'] as num?)?.toInt() ?? 1,
      category: _safeCategory(json['category'] as String? ?? 'other'),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Workflow domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> workflowToJson(Workflow workflow) {
    return {
      'id': workflow.id,
      'name': workflow.name,
      'description': workflow.description,
      'steps': workflow.steps,
      'estimated_days': workflow.estimatedDays,
      'category': workflow.category.name,
      'is_active': workflow.isActive,
    };
  }

  // ---------------------------------------------------------------------------
  // Workflow — Drift row ↔ domain
  // ---------------------------------------------------------------------------

  /// Drift row → Workflow domain model
  static Workflow workflowFromRow(WorkflowRow row) {
    return Workflow(
      id: row.id,
      name: row.name,
      description: row.description,
      steps: _parseStringListFromJson(row.steps),
      estimatedDays: row.estimatedDays,
      category: _safeCategory(row.category),
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Workflow → Drift companion (for insert/update)
  static PracticeWorkflowsTableCompanion workflowToCompanion(
    Workflow workflow,
  ) {
    return PracticeWorkflowsTableCompanion(
      id: Value(workflow.id),
      name: Value(workflow.name),
      description: Value(workflow.description),
      steps: Value(jsonEncode(workflow.steps)),
      estimatedDays: Value(workflow.estimatedDays),
      category: Value(workflow.category.name),
      isActive: Value(workflow.isActive),
      createdAt: Value(workflow.createdAt),
      updatedAt: Value(workflow.updatedAt),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.whereType<String>().toList();
    }
    return const [];
  }

  static List<String> _parseStringListFromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.whereType<String>().toList();
    } catch (_) {
      return const [];
    }
  }

  static WorkflowCategory _safeCategory(String name) {
    try {
      return WorkflowCategory.values.byName(name);
    } catch (_) {
      return WorkflowCategory.other;
    }
  }
}
