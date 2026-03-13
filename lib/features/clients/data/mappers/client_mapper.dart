import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';

class ClientMapper {
  const ClientMapper._();

  // JSON (from Supabase) → Client domain model
  static Client fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
      pan: json['pan'] as String,
      // aadhaar is NEVER stored in Supabase — only aadhaar_hash
      // We don't return aadhaar in domain model from remote
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      alternatePhone: json['alternate_phone'] as String?,
      clientType: _safeClientType(
        json['client_type'] as String? ?? 'individual',
      ),
      dateOfBirth: _parseDate(json['date_of_birth'] as String?),
      dateOfIncorporation: _parseDate(json['date_of_incorporation'] as String?),
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      gstin: json['gstin'] as String?,
      tan: json['tan'] as String?,
      servicesAvailed: _parseServices(json['services_availed']),
      status: _safeClientStatus(json['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      notes: json['notes'] as String?,
    );
  }

  // Client domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(Client client) {
    return {
      'id': client.id,
      'name': client.name,
      'pan': client.pan,
      // Hash aadhaar if present — DPDP compliance
      if (client.aadhaar != null) 'aadhaar_hash': _hashAadhaar(client.aadhaar!),
      'email': client.email,
      'phone': client.phone,
      'alternate_phone': client.alternatePhone,
      'client_type': client.clientType.name,
      'date_of_birth': client.dateOfBirth?.toIso8601String().substring(0, 10),
      'date_of_incorporation': client.dateOfIncorporation
          ?.toIso8601String()
          .substring(0, 10),
      'address': client.address,
      'city': client.city,
      'state': client.state,
      'pincode': client.pincode,
      'gstin': client.gstin,
      'tan': client.tan,
      'services_availed': client.servicesAvailed.map((s) => s.name).toList(),
      'status': client.status.name,
      'notes': client.notes,
    };
  }

  // Drift row → Client domain model
  static Client fromRow(ClientRow row) {
    return Client(
      id: row.id,
      name: row.name,
      pan: row.pan,
      // aadhaarHash is a one-way hash — never expose it as plaintext aadhaar
      email: row.email,
      phone: row.phone,
      alternatePhone: row.alternatePhone,
      clientType: _safeClientType(row.clientType),
      dateOfBirth: row.dateOfBirth != null
          ? DateTime.tryParse(row.dateOfBirth!)
          : null,
      dateOfIncorporation: row.dateOfIncorporation != null
          ? DateTime.tryParse(row.dateOfIncorporation!)
          : null,
      address: row.address,
      city: row.city,
      state: row.state,
      pincode: row.pincode,
      gstin: row.gstin,
      tan: row.tan,
      servicesAvailed: _parseServicesFromJson(row.servicesAvailed),
      status: _safeClientStatus(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      notes: row.notes,
    );
  }

  // Client → Drift companion (for insert/update)
  static ClientsTableCompanion toCompanion(
    Client client, {
    String firmId = '',
  }) {
    return ClientsTableCompanion(
      id: Value(client.id),
      firmId: Value(firmId),
      name: Value(client.name),
      pan: Value(client.pan),
      aadhaarHash: Value(
        client.aadhaar != null ? _hashAadhaar(client.aadhaar!) : null,
      ),
      email: Value(client.email),
      phone: Value(client.phone),
      alternatePhone: Value(client.alternatePhone),
      clientType: Value(client.clientType.name),
      dateOfBirth: Value(client.dateOfBirth?.toIso8601String()),
      dateOfIncorporation: Value(client.dateOfIncorporation?.toIso8601String()),
      address: Value(client.address),
      city: Value(client.city),
      state: Value(client.state),
      pincode: Value(client.pincode),
      gstin: Value(client.gstin),
      tan: Value(client.tan),
      servicesAvailed: Value(
        jsonEncode(client.servicesAvailed.map((s) => s.name).toList()),
      ),
      status: Value(client.status.name),
      notes: Value(client.notes),
      createdAt: Value(client.createdAt),
      updatedAt: Value(client.updatedAt),
      isDirty: const Value(true), // newly written = needs sync
    );
  }

  static String _hashAadhaar(String aadhaar) {
    final clean = aadhaar.replaceAll(RegExp(r'\s+'), '');
    final bytes = utf8.encode(clean);
    return sha256.convert(bytes).toString();
  }

  static DateTime? _parseDate(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  static List<ServiceType> _parseServices(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw
          .map((e) => _safeServiceType(e as String))
          .whereType<ServiceType>()
          .toList();
    }
    return const [];
  }

  static List<ServiceType> _parseServicesFromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => _safeServiceType(e as String))
          .whereType<ServiceType>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static ServiceType? _safeServiceType(String name) {
    try {
      return ServiceType.values.byName(name);
    } catch (_) {
      return null;
    }
  }

  static ClientType _safeClientType(String name) {
    try {
      return ClientType.values.byName(name);
    } catch (_) {
      return ClientType.individual;
    }
  }

  static ClientStatus _safeClientStatus(String name) {
    try {
      return ClientStatus.values.byName(name);
    } catch (_) {
      return ClientStatus.active;
    }
  }
}
