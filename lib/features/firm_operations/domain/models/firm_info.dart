import 'package:flutter/foundation.dart';

/// Immutable model representing a CA firm's core information.
@immutable
class FirmInfo {
  const FirmInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.panNumber,
    required this.tanNumber,
    this.city,
    this.state,
    this.pincode,
    this.bankAccount,
    this.registrationDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String address;
  final String panNumber;
  final String tanNumber;
  final String? city;
  final String? state;
  final String? pincode;
  final String? bankAccount;
  final DateTime? registrationDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FirmInfo copyWith({
    String? id,
    String? name,
    String? address,
    String? panNumber,
    String? tanNumber,
    String? city,
    String? state,
    String? pincode,
    String? bankAccount,
    DateTime? registrationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FirmInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      panNumber: panNumber ?? this.panNumber,
      tanNumber: tanNumber ?? this.tanNumber,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      bankAccount: bankAccount ?? this.bankAccount,
      registrationDate: registrationDate ?? this.registrationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirmInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          panNumber == other.panNumber &&
          tanNumber == other.tanNumber;

  @override
  int get hashCode => Object.hash(id, name, panNumber, tanNumber);

  @override
  String toString() => 'FirmInfo(id: $id, name: $name, pan: $panNumber)';
}
