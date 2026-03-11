import 'package:ca_app/features/clients/domain/models/client_type.dart';

enum ServiceType {
  itrFiling('ITR Filing'),
  gstFiling('GST Filing'),
  tds('TDS'),
  audit('Audit'),
  roc('ROC'),
  payroll('Payroll'),
  bookkeeping('Bookkeeping');

  const ServiceType(this.label);

  final String label;
}

enum ClientStatus {
  active('Active'),
  inactive('Inactive'),
  prospect('Prospect');

  const ClientStatus(this.label);

  final String label;
}

class Client {
  const Client({
    required this.id,
    required this.name,
    required this.pan,
    required this.clientType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.aadhaar,
    this.email,
    this.phone,
    this.alternatePhone,
    this.dateOfBirth,
    this.dateOfIncorporation,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.gstin,
    this.tan,
    this.servicesAvailed = const [],
    this.notes,
  });

  final String id;
  final String name;
  final String pan;
  final String? aadhaar;
  final String? email;
  final String? phone;
  final String? alternatePhone;
  final ClientType clientType;
  final DateTime? dateOfBirth;
  final DateTime? dateOfIncorporation;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstin;
  final String? tan;
  final List<ServiceType> servicesAvailed;
  final ClientStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get fullAddress {
    final parts = [address, city, state, pincode].whereType<String>().toList();
    return parts.join(', ');
  }

  Client copyWith({
    String? id,
    String? name,
    String? pan,
    String? aadhaar,
    String? email,
    String? phone,
    String? alternatePhone,
    ClientType? clientType,
    DateTime? dateOfBirth,
    DateTime? dateOfIncorporation,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? gstin,
    String? tan,
    List<ServiceType>? servicesAvailed,
    ClientStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      pan: pan ?? this.pan,
      aadhaar: aadhaar ?? this.aadhaar,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      clientType: clientType ?? this.clientType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfIncorporation: dateOfIncorporation ?? this.dateOfIncorporation,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      gstin: gstin ?? this.gstin,
      tan: tan ?? this.tan,
      servicesAvailed: servicesAvailed ?? this.servicesAvailed,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
