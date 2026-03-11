import 'package:flutter/foundation.dart';

/// Designation levels within a CA firm.
enum StaffDesignation {
  partner(label: 'Partner'),
  manager(label: 'Manager'),
  senior(label: 'Senior'),
  associate(label: 'Associate'),
  intern(label: 'Intern');

  const StaffDesignation({required this.label});

  final String label;
}

/// Immutable model representing a staff member in a CA firm.
@immutable
class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.department,
    required this.joiningDate,
    required this.billableTarget,
    required this.cpeHoursRequired,
    required this.cpeHoursCompleted,
    required this.skills,
    required this.isActive,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final StaffDesignation designation;
  final String department;
  final DateTime joiningDate;
  final double billableTarget;
  final double cpeHoursRequired;
  final double cpeHoursCompleted;
  final List<String> skills;
  final bool isActive;

  /// CPE completion ratio (0.0 to 1.0).
  double get cpeProgress => cpeHoursRequired > 0
      ? (cpeHoursCompleted / cpeHoursRequired).clamp(0.0, 1.0)
      : 0.0;

  /// Returns a new [StaffMember] with the given fields replaced.
  StaffMember copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    StaffDesignation? designation,
    String? department,
    DateTime? joiningDate,
    double? billableTarget,
    double? cpeHoursRequired,
    double? cpeHoursCompleted,
    List<String>? skills,
    bool? isActive,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      joiningDate: joiningDate ?? this.joiningDate,
      billableTarget: billableTarget ?? this.billableTarget,
      cpeHoursRequired: cpeHoursRequired ?? this.cpeHoursRequired,
      cpeHoursCompleted: cpeHoursCompleted ?? this.cpeHoursCompleted,
      skills: skills ?? this.skills,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffMember &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          designation == other.designation &&
          department == other.department &&
          joiningDate == other.joiningDate &&
          billableTarget == other.billableTarget &&
          cpeHoursRequired == other.cpeHoursRequired &&
          cpeHoursCompleted == other.cpeHoursCompleted &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    phone,
    designation,
    department,
    joiningDate,
    billableTarget,
    cpeHoursRequired,
    cpeHoursCompleted,
    isActive,
  );

  @override
  String toString() =>
      'StaffMember(id: $id, name: $name, designation: ${designation.label})';
}
