import 'package:flutter/material.dart';

/// Category / type of company under Companies Act 2013.
enum CompanyCategory {
  privateLimited(label: 'Pvt Ltd', shortLabel: 'PVT'),
  publicLimited(label: 'Public Ltd', shortLabel: 'PUB'),
  opc(label: 'OPC', shortLabel: 'OPC'),
  section8(label: 'Section 8', shortLabel: 'S8'),
  producer(label: 'Producer', shortLabel: 'PROD');

  const CompanyCategory({required this.label, required this.shortLabel});

  final String label;
  final String shortLabel;
}

/// Registration status of the company with MCA.
enum CompanyStatus {
  active(
    label: 'Active',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  ),
  struckOff(
    label: 'Struck Off',
    color: Color(0xFFC62828),
    icon: Icons.cancel_rounded,
  ),
  dissolved(
    label: 'Dissolved',
    color: Color(0xFF718096),
    icon: Icons.remove_circle_outline_rounded,
  );

  const CompanyStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a director on the board.
class Director {
  const Director({
    required this.din,
    required this.name,
    required this.designation,
    required this.appointmentDate,
    this.isActive = true,
  });

  final String din;
  final String name;
  final String designation;
  final DateTime appointmentDate;
  final bool isActive;

  Director copyWith({
    String? din,
    String? name,
    String? designation,
    DateTime? appointmentDate,
    bool? isActive,
  }) {
    return Director(
      din: din ?? this.din,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Director && runtimeType == other.runtimeType && din == other.din;

  @override
  int get hashCode => din.hashCode;
}

/// Immutable model representing a company registered with MCA/ROC.
class Company {
  const Company({
    required this.id,
    required this.cin,
    required this.companyName,
    required this.incorporationDate,
    required this.category,
    required this.paidUpCapital,
    required this.authorisedCapital,
    required this.registeredAddress,
    required this.rocJurisdiction,
    required this.directors,
    this.status = CompanyStatus.active,
  });

  final String id;

  /// Corporate Identification Number, e.g. U74999MH2018PTC123456
  final String cin;
  final String companyName;
  final DateTime incorporationDate;
  final CompanyCategory category;

  /// In Indian Rupees
  final double paidUpCapital;

  /// In Indian Rupees
  final double authorisedCapital;
  final String registeredAddress;

  /// ROC office jurisdiction, e.g. "ROC Mumbai", "ROC Bengaluru"
  final String rocJurisdiction;
  final List<Director> directors;
  final CompanyStatus status;

  int get activeDirectorCount => directors.where((d) => d.isActive).length;

  Company copyWith({
    String? id,
    String? cin,
    String? companyName,
    DateTime? incorporationDate,
    CompanyCategory? category,
    double? paidUpCapital,
    double? authorisedCapital,
    String? registeredAddress,
    String? rocJurisdiction,
    List<Director>? directors,
    CompanyStatus? status,
  }) {
    return Company(
      id: id ?? this.id,
      cin: cin ?? this.cin,
      companyName: companyName ?? this.companyName,
      incorporationDate: incorporationDate ?? this.incorporationDate,
      category: category ?? this.category,
      paidUpCapital: paidUpCapital ?? this.paidUpCapital,
      authorisedCapital: authorisedCapital ?? this.authorisedCapital,
      registeredAddress: registeredAddress ?? this.registeredAddress,
      rocJurisdiction: rocJurisdiction ?? this.rocJurisdiction,
      directors: directors ?? this.directors,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Company && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
