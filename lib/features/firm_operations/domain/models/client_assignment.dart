import 'package:flutter/foundation.dart';

/// Immutable model representing a client assignment to a team member.
@immutable
class ClientAssignment {
  const ClientAssignment({
    required this.id,
    required this.clientId,
    this.assignedToId,
    this.startDate,
    this.endDate,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String clientId;
  final String? assignedToId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClientAssignment copyWith({
    String? id,
    String? clientId,
    String? assignedToId,
    DateTime? startDate,
    DateTime? endDate,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientAssignment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      assignedToId: assignedToId ?? this.assignedToId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientAssignment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId;

  @override
  int get hashCode => Object.hash(id, clientId);

  @override
  String toString() =>
      'ClientAssignment(id: $id, clientId: $clientId, assignedToId: $assignedToId)';
}
