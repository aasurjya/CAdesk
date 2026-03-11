import 'package:flutter/foundation.dart';

/// Type of entity responsible for deducting TDS/TCS.
enum DeductorType {
  government(label: 'Government'),
  company(label: 'Company'),
  individual(label: 'Individual'),
  firm(label: 'Firm');

  const DeductorType({required this.label});

  final String label;
}

/// Immutable model representing a TDS/TCS deductor.
///
/// A deductor is an entity (employer, company, government body, etc.) that
/// deducts tax at source and is responsible for filing TDS/TCS returns.
@immutable
class TdsDeductor {
  const TdsDeductor({
    required this.id,
    required this.deductorName,
    required this.tan,
    required this.pan,
    required this.deductorType,
    required this.address,
    required this.email,
    required this.phone,
    required this.responsiblePerson,
  });

  final String id;
  final String deductorName;
  final String tan;
  final String pan;
  final DeductorType deductorType;
  final String address;
  final String email;
  final String phone;
  final String responsiblePerson;

  /// Returns a new [TdsDeductor] with the given fields replaced.
  TdsDeductor copyWith({
    String? id,
    String? deductorName,
    String? tan,
    String? pan,
    DeductorType? deductorType,
    String? address,
    String? email,
    String? phone,
    String? responsiblePerson,
  }) {
    return TdsDeductor(
      id: id ?? this.id,
      deductorName: deductorName ?? this.deductorName,
      tan: tan ?? this.tan,
      pan: pan ?? this.pan,
      deductorType: deductorType ?? this.deductorType,
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsDeductor &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deductorName == other.deductorName &&
          tan == other.tan &&
          pan == other.pan &&
          deductorType == other.deductorType &&
          address == other.address &&
          email == other.email &&
          phone == other.phone &&
          responsiblePerson == other.responsiblePerson;

  @override
  int get hashCode => Object.hash(
    id,
    deductorName,
    tan,
    pan,
    deductorType,
    address,
    email,
    phone,
    responsiblePerson,
  );

  @override
  String toString() => 'TdsDeductor(id: $id, name: $deductorName, tan: $tan)';
}
