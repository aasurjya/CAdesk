import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/firm_operations/domain/models/client_assignment.dart';
import 'package:ca_app/features/firm_operations/domain/models/firm_info.dart';
import 'package:ca_app/features/firm_operations/domain/models/team_member.dart';

/// Bidirectional mapper between domain models and Drift rows / Supabase JSON.
class FirmOperationsMapper {
  const FirmOperationsMapper._();

  // ---------------------------------------------------------------------------
  // FirmInfo
  // ---------------------------------------------------------------------------

  static FirmInfo firmInfoFromRow(FirmInfoTableData row) {
    return FirmInfo(
      id: row.id,
      name: row.name,
      address: row.address,
      panNumber: row.panNumber,
      tanNumber: row.tanNumber,
      city: row.city,
      state: row.state,
      pincode: row.pincode,
      bankAccount: row.bankAccount,
      registrationDate: row.registrationDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static FirmInfoTableCompanion firmInfoToCompanion(FirmInfo info) {
    return FirmInfoTableCompanion(
      id: Value(info.id),
      name: Value(info.name),
      address: Value(info.address),
      panNumber: Value(info.panNumber),
      tanNumber: Value(info.tanNumber),
      city: Value(info.city),
      state: Value(info.state),
      pincode: Value(info.pincode),
      bankAccount: Value(info.bankAccount),
      registrationDate: Value(info.registrationDate),
      updatedAt: Value(DateTime.now()),
    );
  }

  static FirmInfo firmInfoFromJson(Map<String, dynamic> json) {
    return FirmInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      panNumber: json['pan_number'] as String,
      tanNumber: json['tan_number'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      bankAccount: json['bank_account'] as String?,
      registrationDate: _parseDateTime(json['registration_date'] as String?),
      createdAt: _parseDateTime(json['created_at'] as String?),
      updatedAt: _parseDateTime(json['updated_at'] as String?),
    );
  }

  static Map<String, dynamic> firmInfoToJson(FirmInfo info) {
    return {
      'id': info.id,
      'name': info.name,
      'address': info.address,
      'pan_number': info.panNumber,
      'tan_number': info.tanNumber,
      'city': info.city,
      'state': info.state,
      'pincode': info.pincode,
      'bank_account': info.bankAccount,
      'registration_date': info.registrationDate?.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // TeamMember
  // ---------------------------------------------------------------------------

  static TeamMember teamMemberFromRow(TeamMembersTableData row) {
    return TeamMember(
      id: row.id,
      firmId: row.firmId,
      name: row.name,
      pan: row.pan,
      role: row.role,
      email: row.email,
      phone: row.phone,
      permissions: _parsePermissions(row.permissions),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static TeamMembersTableCompanion teamMemberToCompanion(TeamMember member) {
    return TeamMembersTableCompanion(
      id: Value(member.id),
      firmId: Value(member.firmId),
      name: Value(member.name),
      pan: Value(member.pan),
      role: Value(member.role),
      email: Value(member.email),
      phone: Value(member.phone),
      permissions: Value(jsonEncode(member.permissions)),
      updatedAt: Value(DateTime.now()),
    );
  }

  static TeamMember teamMemberFromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String,
      firmId: json['firm_id'] as String,
      name: json['name'] as String,
      pan: json['pan'] as String,
      role: json['role'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      permissions: _parsePermissions(json['permissions']),
      createdAt: _parseDateTime(json['created_at'] as String?),
      updatedAt: _parseDateTime(json['updated_at'] as String?),
    );
  }

  static Map<String, dynamic> teamMemberToJson(TeamMember member) {
    return {
      'id': member.id,
      'firm_id': member.firmId,
      'name': member.name,
      'pan': member.pan,
      'role': member.role,
      'email': member.email,
      'phone': member.phone,
      'permissions': member.permissions,
    };
  }

  // ---------------------------------------------------------------------------
  // ClientAssignment
  // ---------------------------------------------------------------------------

  static ClientAssignment clientAssignmentFromRow(
    ClientAssignmentsTableData row,
  ) {
    return ClientAssignment(
      id: row.id,
      clientId: row.clientId,
      assignedToId: row.assignedToId,
      startDate: row.startDate,
      endDate: row.endDate,
      role: row.role,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static ClientAssignmentsTableCompanion clientAssignmentToCompanion(
    ClientAssignment assignment,
  ) {
    return ClientAssignmentsTableCompanion(
      id: Value(assignment.id),
      clientId: Value(assignment.clientId),
      assignedToId: Value(assignment.assignedToId),
      startDate: Value(assignment.startDate),
      endDate: Value(assignment.endDate),
      role: Value(assignment.role),
      updatedAt: Value(DateTime.now()),
    );
  }

  static ClientAssignment clientAssignmentFromJson(Map<String, dynamic> json) {
    return ClientAssignment(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      assignedToId: json['assigned_to_id'] as String?,
      startDate: _parseDateTime(json['start_date'] as String?),
      endDate: _parseDateTime(json['end_date'] as String?),
      role: json['role'] as String?,
      createdAt: _parseDateTime(json['created_at'] as String?),
      updatedAt: _parseDateTime(json['updated_at'] as String?),
    );
  }

  static Map<String, dynamic> clientAssignmentToJson(
    ClientAssignment assignment,
  ) {
    return {
      'id': assignment.id,
      'client_id': assignment.clientId,
      'assigned_to_id': assignment.assignedToId,
      'start_date': assignment.startDate?.toIso8601String(),
      'end_date': assignment.endDate?.toIso8601String(),
      'role': assignment.role,
    };
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static List<String> _parsePermissions(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) return raw.cast<String>();
    if (raw is String) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.cast<String>();
      } catch (_) {
        return const [];
      }
    }
    return const [];
  }

  static DateTime? _parseDateTime(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }
}
