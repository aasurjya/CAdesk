import 'package:flutter/foundation.dart';

/// A single item in the onboarding checklist.
@immutable
class ChecklistItem {
  const ChecklistItem({
    required this.name,
    required this.isRequired,
    required this.isCompleted,
    this.documentUrl,
    this.completedAt,
  });

  final String name;
  final bool isRequired;
  final bool isCompleted;
  final String? documentUrl;
  final DateTime? completedAt;

  /// Returns a new [ChecklistItem] with the given fields replaced.
  ChecklistItem copyWith({
    String? name,
    bool? isRequired,
    bool? isCompleted,
    String? documentUrl,
    DateTime? completedAt,
  }) {
    return ChecklistItem(
      name: name ?? this.name,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      documentUrl: documentUrl ?? this.documentUrl,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          isRequired == other.isRequired &&
          isCompleted == other.isCompleted &&
          documentUrl == other.documentUrl &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      Object.hash(name, isRequired, isCompleted, documentUrl, completedAt);
}

/// Immutable model representing a client onboarding checklist.
@immutable
class OnboardingChecklist {
  const OnboardingChecklist({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.serviceType,
    required this.items,
    required this.overallProgress,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String serviceType;
  final List<ChecklistItem> items;
  final double overallProgress;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Returns a new [OnboardingChecklist] with the given fields replaced.
  OnboardingChecklist copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? serviceType,
    List<ChecklistItem>? items,
    double? overallProgress,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return OnboardingChecklist(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      serviceType: serviceType ?? this.serviceType,
      items: items ?? this.items,
      overallProgress: overallProgress ?? this.overallProgress,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingChecklist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId &&
          serviceType == other.serviceType &&
          overallProgress == other.overallProgress &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt;

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    serviceType,
    overallProgress,
    createdAt,
    completedAt,
  );

  @override
  String toString() =>
      'OnboardingChecklist(id: $id, client: $clientName, progress: $overallProgress)';
}
