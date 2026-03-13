import 'package:flutter/foundation.dart';

/// Immutable model representing a team member (staff) in a CA firm.
@immutable
class TeamMember {
  const TeamMember({
    required this.id,
    required this.firmId,
    required this.name,
    required this.pan,
    this.role,
    this.email,
    this.phone,
    this.permissions = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String firmId;
  final String name;
  final String pan;
  final String? role;
  final String? email;
  final String? phone;

  /// List of permission strings (e.g. ['gst', 'tds', 'audit']).
  final List<String> permissions;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  TeamMember copyWith({
    String? id,
    String? firmId,
    String? name,
    String? pan,
    String? role,
    String? email,
    String? phone,
    List<String>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeamMember(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      name: name ?? this.name,
      pan: pan ?? this.pan,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamMember &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          pan == other.pan;

  @override
  int get hashCode => Object.hash(id, pan);

  @override
  String toString() => 'TeamMember(id: $id, name: $name, pan: $pan)';
}
